import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:nalia_app/models/api.file.model.dart';
import 'package:nalia_app/services/defines.dart';
import 'package:nalia_app/services/global.dart';
import 'package:nalia_app/services/helper.functions.dart';

import 'package:flutter_image_compress/flutter_image_compress.dart';

// import 'package:nalia_app/services/global.dart';
// import 'package:get_storage/get_storage.dart';

class App {
  Location location = Location();
  bool locationServiceEnabled = false;
  RxBool locationServiceChanges = false.obs;
  RxBool locationAppPermissionChanges = false.obs;
  // PermissionStatus _permissionGranted;

  /// [justGotDailyBonus] is to indiate that the user got bonus.
  RxBool justGotDailyBonus = false.obs;

  App() {
    // initLocalStorage();
  }

  initLocalStorage() {
    // GetStorage.init().then((b) {
    //   localStorage = GetStorage();
    //   localStorageReady.add(true);
    // });

    // localStorageReady.listen((v) {
    //   if (v == false) return;
    //   // initLocation();
    // });
  }

  void error(dynamic e, [String message]) {
    print('=> error(e): ');
    print(e);
    print('=> e.runtimeType: ${e.runtimeType}');

    String title = 'Ooh'.tr;
    String msg = '';

    /// e is title, message is String
    if (message != null) {
      title = e;
      msg = message;
    } else if (e is String) {
      /// Is error string? If error string begins with `ERROR_`, then it might be PHP error or client error.
      if (e.indexOf('ERROR_') == 0) {
        if (e.indexOf(':') > 0) {
          List<String> arr = e.split(':');
          msg = arr[0].tr + ' : ' + arr[1];
        } else {
          msg = e.tr;
        }
      } else {
        msg = e;
      }
    } else if (e is DioError) {
      print(e.error);
      msg = e.message;
    } else {
      /// other errors.
      msg = "Unknown error";
    }

    print('error msg: $msg');
    Get.snackbar(
      title,
      msg,
      animationDuration: Duration(milliseconds: 700),
    );
  }

  Future alert(String message) async {
    await Get.defaultDialog(
      title: '알림',
      content: Text(
        message,
        textAlign: TextAlign.center,
      ),
      textConfirm: '확인',
      onConfirm: () => Get.back(),
      confirmTextColor: Colors.white,
    );
  }

  bool get locationReady =>
      locationServiceChanges.value == true &&
      locationAppPermissionChanges.value == true;

  Future<ApiFile> imageUpload({int quality = 90, Function onProgress}) async {
    /// Ask user
    final re = await Get.bottomSheet(
      Container(
        color: Colors.white,
        child: SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                  leading: Icon(Icons.music_note),
                  title: Text('take photo from camera'),
                  onTap: () => Get.back(result: ImageSource.camera)),
              ListTile(
                leading: Icon(Icons.videocam),
                title: Text('get photo from gallery'),
                onTap: () => Get.back(result: ImageSource.gallery),
              ),
            ],
          ),
        ),
      ),
    );
    if (re == null) throw ERROR_IMAGE_NOT_SELECTED;

    /// Pick image
    final picker = ImagePicker();

    final pickedFile = await picker.getImage(source: re);
    if (pickedFile == null) throw ERROR_IMAGE_NOT_SELECTED;

    String localFile =
        await getAbsoluteTemporaryFilePath(getRandomString() + '.jpeg');
    File file = await FlutterImageCompress.compressAndGetFile(
      pickedFile.path, // source file
      localFile, // target file. Overwrite the source with compressed.
      quality: quality,
    );

    /// Upload
    return await api.uploadFile(file: file, onProgress: onProgress);
  }

  Future<bool> confirm(String title, String message) async {
    return await showDialog(
      context: Get.context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Get.back(result: true),
                  child: Text('yes'.tr),
                ),
                TextButton(
                  onPressed: () => Get.back(result: false),
                  child: Text('no'.tr),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
