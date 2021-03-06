import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nalia_app/screens/forum/widgets/post.form.dart';
import 'package:nalia_app/screens/forum/widgets/post.list.dart';
import 'package:nalia_app/screens/forum/widgets/post.list.no_more_posts.dart';
import 'package:nalia_app/services/defines.dart';
import 'package:nalia_app/services/global.dart';
import 'package:nalia_app/services/route_names.dart';
import 'package:nalia_app/widgets/custom_app_bar.dart';
import 'package:nalia_app/widgets/home.content_wrapper.dart';
import 'package:nalia_app/widgets/spinner.dart';
import 'package:firelamp/firelamp.dart';

class ForumListScreen extends StatefulWidget {
  @override
  _ForumListScreenState createState() => _ForumListScreenState();
}

class _ForumListScreenState extends State<ForumListScreen> {
  Forum forum;
  @override
  void initState() {
    super.initState();

    forum = Forum(
      category: Get.arguments['category'],
      render: () => setState(() => null),
    );
    api.attachForum(forum);

    fetchPosts();

    /// Loading next page
    forum.itemPositionsListener.itemPositions.addListener(() {
      int lastVisibleIndex = forum.itemPositionsListener.itemPositions.value.last.index;
      if (forum.loading) return;
      if (lastVisibleIndex > forum.posts.length - 4) {
        fetchPosts();
      }
    });
  }

  fetchPosts() async {
    try {
      await api.fetchPosts(forum: forum);
    } catch (e) {
      app.error(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(route: RouteNames.jewelry),
      backgroundColor: kBackgroundColor,
      body: HomeContentWrapper(
        header: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (forum.postInEdit != null)
              IconButton(
                icon: Icon(Icons.arrow_back_rounded),
                onPressed: () => setState(() => forum.editPost(null)),
              ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: sm),
              child: Text(forum.category.toUpperCase()),
            ),
            if (forum.postInEdit == null)
              FlatButton(
                splashColor: Colors.transparent,
                child: Row(
                  children: [
                    Icon(
                      Icons.add,
                      size: md,
                      color: Colors.blueAccent,
                    ),
                    SizedBox(width: xs),
                    Text(
                      'Create Post',
                      style: TextStyle(color: Colors.blueAccent),
                    )
                  ],
                ),
                onPressed: () => setState(() => forum.editPost(ApiPost())),
              )
          ],
        ),
        child: forum.postInEdit != null
            ? PostForm(forum)
            : Column(
                children: [
                  PostList(forum: forum),
                  Spinner(loading: forum.loading),
                  NoMorePosts(noMorePosts: forum.noMorePosts)
                ],
              ),
      ),
    );
  }
}
