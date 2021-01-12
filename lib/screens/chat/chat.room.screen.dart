import 'dart:async';

import 'package:firechat/firechat.dart';
import 'package:flutter/material.dart';
import 'package:nalia_app/models/api.bio.controller.dart';
import 'package:nalia_app/models/api.bio.model.dart';
import 'package:nalia_app/models/api.user.model.dart';
import 'package:nalia_app/services/defines.dart';
import 'package:nalia_app/services/global.dart';
import 'package:nalia_app/services/helper.functions.dart';
import 'package:nalia_app/services/route_names.dart';
import 'package:nalia_app/widgets/custom_app_bar.dart';
import 'package:nalia_app/widgets/home.content_wrapper.dart';

import 'package:flutter/rendering.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

import 'package:get/get.dart';
import 'package:nalia_app/widgets/spinner.dart';
import 'package:nalia_app/widgets/user_avatar.dart';

class ChatRoomScreen extends StatefulWidget {
  @override
  _ChatRoomScreenState createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final scrollController = ScrollController();
  final textController = TextEditingController();

  final keyboardVisibilityController = KeyboardVisibilityController();
  StreamSubscription keyboardSubscription;

  bool get atBottom {
    return scrollController.offset > (scrollController.position.maxScrollExtent - 640);
  }

  bool get atTop {
    return scrollController.position.pixels < 200;
  }

  bool get scrollUp {
    return scrollController.position.userScrollDirection == ScrollDirection.forward;
  }

  bool get scrollDown {
    return scrollController.position.userScrollDirection == ScrollDirection.reverse;
  }

  String get text {
    String _text = textController.text;
    textController.text = '';
    return _text;
  }

  /// Scrolls down to the bottom when,
  /// * chat room is loaded (only one time.)
  /// * when I chat,
  /// * when new chat is coming and the page is scrolled near to bottom. Logically it should not scroll down when the page is scrolled far from the bottom.
  /// * when keyboard is open and the page scroll is near to bottom. Locally it should not scroll down when the user is reading message that is far from the bottom.
  scrollToBottom({int ms = 200}) {
    /// This is needed to safely scroll to bottom after chat messages has been added.

    Timer(Duration(milliseconds: ms), () {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        scrollController.animateTo(scrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: ms), curve: Curves.ease);
      });
    });
  }

  /// Let user enter into the chosen room.
  enterChatRoom(args) async {
    if (args == null) return;

    _otherUsername = null;
    print("enterChatRoom(args) called;");

    // Create a `ChatRoom` instance and save it to global variable.
    chat = ChatRoom(
      loginUserId: api.id,
      render: () {
        setState(() {});
        if (chat.messages.isNotEmpty) {
          if (chat.page == 1) {
            scrollToBottom(ms: 10);
          } else if (atBottom) {
            scrollToBottom();
          }
        }
      },
      globalRoomChange: () {
        // This will be invoked when the information of global room of this chat room changes.
        // print('global room change');
      },
    );

    // if there is no incoming chat room id, then, create one
    try {
      await app.checkUserProfile();
      await chat.enter(id: args['roomId'], users: [args['userId']], hatch: false);
    } catch (e) {
      app.error(e);
    }

    // fetch previous chat when user scrolls up
    scrollController.addListener(() {
      if (scrollUp && atTop) {
        chat.fetchMessages();
      }
    });

    // scroll to bottom only if needed when user open/hide keyboard.
    keyboardSubscription = keyboardVisibilityController.onChange.listen((bool visible) {
      if (visible && atBottom) {
        scrollToBottom(ms: 10);
      }
    });
  }

  // send a message to the room users
  sendMessage() async {
    String _text = text;
    if (_text.isEmpty) return;
    try {
      await chat.sendMessage(
        text: _text,
        displayName: Bio.data.userId,
        photoURL: Bio.data.profilePhotoUrl,
      );
    } catch (e) {
      app.error(e);
    }
  }

  /// Translate text if it is chat protocol.
  translateIfChatProtocol(String text) {
    if (text.indexOf('ChatProtocol.') != -1) {
      return text.tr;
    } else {
      return text;
    }
  }

  /// It does not have to cache `other's user name`, but to prevent falshing
  /// user name widget (since it returns `SizedBox.shrink()`).
  Widget _otherUsername;

  /// Returns user name widget.
  Widget get otherUsername {
    // To prevent flashing.
    if (_otherUsername != null) return _otherUsername;

    // If chat room's global information is not loaded, yet.
    if (chat.users == null) return SizedBox.shrink();

    String uid = chat.global.otherUserId;
    if (uid == null) return SizedBox.shrink();

    // return Text('Other user name');

    // If there is other user, then return his name.
    return FutureBuilder<ApiBio>(
      future: app.getBio(uid),
      builder: (_, snapshot) {
        if (snapshot.hasError) return SizedBox.shrink();
        if (snapshot.connectionState == ConnectionState.waiting) return Spinner();
        _otherUsername = Text(
          snapshot.data.name,
          style: TextStyle(fontSize: md),
        );
        return _otherUsername;
      },
    );
  }

  @override
  void initState() {
    super.initState();
    print('ChatRoomScreen::initState()');
    enterChatRoom(Get.arguments);
  }

  @override
  void dispose() {
    super.dispose();
    print('ChatRoomScreen::dispose()');
    chat.unsubscribe();
    chat = null;

    keyboardSubscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        route: RouteNames.chatRoom,
      ),
      backgroundColor: kBackgroundColor,
      body: HomeContentWrapper(
        header: Container(
          padding: EdgeInsets.all(sm),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              otherUsername,
              IconButton(icon: Icon(Icons.notification_important), onPressed: () {}),
            ],
          ),
        ),
        child: chat.loading
            ? Spinner()
            : Column(
                children: [
                  Expanded(
                    child: KeyboardDismissOnTap(
                      child: ListView.builder(
                        padding: EdgeInsets.all(0),
                        controller: scrollController,
                        itemCount: chat.messages.length,
                        itemBuilder: (_, i) {
                          final message = ChatMessage.fromData(chat.messages[i]);

                          print("first message : " + message.toString());
                          return ListTile(
                            leading: message.isMine(api.id)
                                ? SizedBox.shrink()
                                : UserAvatar(
                                    message.senderPhotoURL,
                                    size: 42,
                                  ),
                            title: Text(
                              translateIfChatProtocol(message.text),
                              textAlign: message.isMine(api.id) ? TextAlign.right : TextAlign.left,
                            ),
                            subtitle: Text(
                              'at ' + dateTime(message.createdAt),
                              style: TextStyle(fontSize: 8),
                              textAlign: message.isMine(api.id) ? TextAlign.right : TextAlign.left,
                            ),
                            trailing: message.isMine(api.id)
                                ? UserAvatar(
                                    message.senderPhotoURL,
                                    size: 42,
                                  )
                                : SizedBox.shrink(),
                          );
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(sm),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: textController,
                            onEditingComplete: sendMessage,
                            decoration: InputDecoration(
                              hintText: "메시지를 입력하세요.",
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30.0),
                                borderSide: BorderSide(
                                  color: Colors.amber[600],
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30.0),
                                borderSide: BorderSide(
                                  color: Colors.blueGrey[300],
                                  width: 1.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: sendMessage,
                          icon: Icon(Icons.send),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}