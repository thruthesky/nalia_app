import 'package:flutter/material.dart';
import 'package:nalia_app/services/defines.dart';
import 'package:nalia_app/widgets/cache_image.dart';
import 'package:firelamp/firelamp.dart';

class PostViewFiles extends StatelessWidget {
  const PostViewFiles({
    Key key,
    this.postOrComment,
  }) : super(key: key);

  final dynamic postOrComment;

  @override
  Widget build(BuildContext context) {
    if (postOrComment.files.length == 0) return SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: sm),
        Text(
          'Attached files',
          style: TextStyle(color: Colors.grey, fontSize: xsm),
        ),
        Divider(),
        for (ApiFile file in postOrComment.files) CacheImage(file.url),
      ],
    );
  }
}
