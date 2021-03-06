import 'dart:async';

import 'package:firechat/firechat.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:nalia_app/controllers/api.gallery.controller.dart';
import 'package:nalia_app/controllers/api.nalia.controller.dart';
import 'package:nalia_app/controllers/api.user_card.controller.dart';
import 'package:nalia_app/models/api.translation.dart';
import 'package:nalia_app/screens/chat/chat.room.screen.dart';
import 'package:nalia_app/screens/chat/chat.user_room_list.screen.dart';
import 'package:nalia_app/screens/forum/forum.list.screen.dart';
import 'package:nalia_app/screens/gallery/gallery.screen.dart';
import 'package:nalia_app/screens/home/home.screen.dart';
import 'package:nalia_app/screens/jewelry/jewelry.screen.dart';
import 'package:nalia_app/screens/login/login.screen.dart';
import 'package:nalia_app/screens/menu/menu.screen.dart';
import 'package:nalia_app/screens/profile/profile.screen.dart';
import 'package:nalia_app/screens/purchase/purchase.history.screen.dart';
import 'package:nalia_app/screens/purchase/purchase.screen.dart';
import 'package:nalia_app/screens/user_search/user_search.screen.dart';
import 'package:nalia_app/services/config.dart';
import 'package:nalia_app/services/global.dart';
import 'package:nalia_app/services/route_names.dart';
import 'package:firelamp/firelamp.dart';

void main() {
  // Let the plugin know that this app supports pending purchases.
  InAppPurchaseConnection.enablePendingPurchases();
  runApp(MainScreen());
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // final API c = Get.put(api);
  final Api wa = Get.put(api);
  final Gallery g = Get.put(Gallery());
  final UserCardController uc = Get.put(UserCardController());
  final NaliaController nc = Get.put(NaliaController());

  @override
  void initState() {
    super.initState();

    print('api: $api');
    api.init(apiUrl: apiUrl);
    api.version().then((res) => print('api.version(): $res'));

    iapService.init().then((x) {
      // app.open(RouteNames.purchase);
    });
    Timer(Duration(milliseconds: 600), () async {
      // print('ui.window.locale.languageCode: ${Get.deviceLocale}');
      // app.open(RouteNames.menu);

      // InAppPurchaseTest().runIosVerification();

      // app.open(RouteNames.purchase);
      // app.open(RouteNames.jewelry);
      // app.open(RouteNames.userSearch);
      // app.open(RouteNames.gallery);
      // app.open(RouteNames.profile);
      // app.open(RouteNames.forumList, arguments: {'category': 'reminder'});

      // String str = "abcdefghijklmnopqrstuvwxyz--0123456789--";
      // for (int i = 0; i < 5; i++) {
      //   str += str;
      // }
      // print(str.length);

      // try {
      //   await api.request({'route': 'app.str', 'str': str});
      // } catch (e) {
      //   print((e as DioError).message);
      // }
    });

    app.firebaseReady.listen((ready) {
      if (ready == false) return;

      api.authChanges.listen((user) {
        // When user is not logged in, or logged out, clear the chat room list.
        if (user == null) {
          if (myRoomList != null) {
            myRoomList.leave();
            myRoomList = null;
          }
          return;
        }

        // print('main.dart -> firebaseReady -> authChanges ->user: $user');
        // Listening login user's chat room changes.
        // This must be here to listen new messages outside from chat screens.
        // Reset room list, when user just logs in/out.
        if (myRoomList == null) {
          myRoomList = ChatMyRoomList(
            loginUserId: api.id,
            render: () {
              // When there are changes(events) on my chat room list,
              // notify to listeners.
              myRoomListChanges.add(myRoomList.rooms);
            },
          );
        }
      });
    });

    api.translationChanges.listen((res) {
      updateTranslations(res);
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      defaultTransition: Transition.noTransition,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      locale: Locale(Get.deviceLocale.languageCode),
      translations: AppTranslations(),
      initialRoute: RouteNames.home,
      getPages: [
        GetPage(name: RouteNames.home, page: () => HomeScreen()),
        GetPage(name: RouteNames.login, page: () => LoginScreen()),
        GetPage(name: RouteNames.profile, page: () => ProfileScreen()),
        GetPage(name: RouteNames.forumList, page: () => ForumListScreen()),
        GetPage(name: RouteNames.userSearch, page: () => UserSearchScreen()),
        GetPage(name: RouteNames.gallery, page: () => GalleryScreen()),
        GetPage(name: RouteNames.purchase, page: () => PurchaseScreen()),
        GetPage(name: RouteNames.purchaseHistory, page: () => PurchaseHistoryScreen()),
        GetPage(name: RouteNames.menu, page: () => MenuScreen()),
        GetPage(name: RouteNames.chatRoom, page: () => ChatRoomScreen()),
        GetPage(name: RouteNames.chatRoomList, page: () => ChatUserRoomListScreen()),
        GetPage(name: RouteNames.jewelry, page: () => JewelryScreen()),
        GetPage(name: RouteNames.chatRoomList, page: () => ChatUserRoomListScreen())
      ],
    );
  }
}
