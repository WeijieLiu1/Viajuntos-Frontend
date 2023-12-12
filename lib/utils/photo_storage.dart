import 'dart:async';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:viajuntos/utils/api_controller.dart';

final storageRef = FirebaseStorage.instance.ref();
// Create the file metadata
final metadata = SettableMetadata(contentType: "image/jpeg");
// Upload file and metadata to the path 'images/mountains.jpg'

Future<String> UploadProfileImage(BuildContext context, File image) async {
  final completerImageUrl = Completer<String>();
  final uploadTask = storageRef
      .child("viajuntos-397806-images/ProfileImages/" +
          APICalls().getCurrentUser())
      .putFile(image, metadata);
  // Listen for state changes, errors, and completion of the upload.
  uploadTask.snapshotEvents.listen((TaskSnapshot taskSnapshot) {
    switch (taskSnapshot.state) {
      case TaskState.running:
        final progress =
            100.0 * (taskSnapshot.bytesTransferred / taskSnapshot.totalBytes);
        print("Upload is $progress% complete.");
        break;
      case TaskState.paused:
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                    title: Text("UploadPausedTitle").tr(),
                    content: Text("UploadPausedContent").tr(),
                    actions: [
                      TextButton(
                        child: Text('Ok').tr(),
                        onPressed: () => Navigator.pop(context),
                      )
                    ]));
        break;
      case TaskState.canceled:
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                    title: Text("UploadCanceledTitle").tr(),
                    content: Text("UploadCanceledContent").tr(),
                    actions: [
                      TextButton(
                        child: Text('Ok').tr(),
                        onPressed: () => Navigator.pop(context),
                      )
                    ]));
        break;
      case TaskState.error:
        // Handle unsuccessful uploads
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                    title: Text("UploadErrorTitle").tr(),
                    content: Text("UploadErrorContent").tr(),
                    actions: [
                      TextButton(
                        child: Text('Ok').tr(),
                        onPressed: () => Navigator.pop(context),
                      )
                    ]));
        break;
      case TaskState.success:
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                    title: Text("UploadSuccessTitle").tr(),
                    content: Text("UploadSuccessContent").tr(),
                    actions: [
                      TextButton(
                          child: Text('Ok').tr(),
                          onPressed: () async {
                            Navigator.pop(context);
                            String url = await taskSnapshot.ref
                                .getDownloadURL()
                                .toString();
                            print("url" + url);
                            completerImageUrl.complete(taskSnapshot.ref
                                .getDownloadURL()
                                .toString()); // 将 url 作为结果返回
                          })
                    ]));
        // 管理调试令牌
        // viajuntos-token1: 74DAE15D-F943-40F6-8034-F0B280917599
        // taskSnapshot.ref.getDownloadURL().then((value) => {
        //       return value,
        //     });
        break;
    }
  });

  // 返回 Completer 的 Future
  return completerImageUrl.future;
}

Future<String> UploadEventImage(
    BuildContext context, String idEvent, File image) async {
  String url = "";
  final uploadTask = storageRef
      .child("viajuntos-397806-images/ProfileImages/" +
          APICalls().getCurrentUser())
      .putFile(image, metadata);
  // Listen for state changes, errors, and completion of the upload.
  uploadTask.snapshotEvents.listen((TaskSnapshot taskSnapshot) {
    switch (taskSnapshot.state) {
      case TaskState.running:
        final progress =
            100.0 * (taskSnapshot.bytesTransferred / taskSnapshot.totalBytes);
        print("Upload is $progress% complete.");
        break;
      case TaskState.paused:
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                    title: Text("UploadPausedTitle").tr(),
                    content: Text("UploadPausedContent").tr(),
                    actions: [
                      TextButton(
                        child: Text('Ok').tr(),
                        onPressed: () => Navigator.pop(context),
                      )
                    ]));
        break;
      case TaskState.canceled:
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                    title: Text("UploadCanceledTitle").tr(),
                    content: Text("UploadCanceledContent").tr(),
                    actions: [
                      TextButton(
                        child: Text('Ok').tr(),
                        onPressed: () => Navigator.pop(context),
                      )
                    ]));
        break;
      case TaskState.error:
        // Handle unsuccessful uploads
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                    title: Text("UploadErrorTitle").tr(),
                    content: Text("UploadErrorContent").tr(),
                    actions: [
                      TextButton(
                        child: Text('Ok').tr(),
                        onPressed: () => Navigator.pop(context),
                      )
                    ]));
        break;
      case TaskState.success:
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                    title: Text("UploadSuccessTitle").tr(),
                    content: Text("UploadSuccessContent").tr(),
                    actions: [
                      TextButton(
                          child: Text('Ok').tr(),
                          onPressed: () {
                            url = taskSnapshot.ref.getDownloadURL().toString();
                            Navigator.pop(context);
                          })
                    ]));
        // 管理调试令牌
        // viajuntos-token1: 74DAE15D-F943-40F6-8034-F0B280917599
        // taskSnapshot.ref.getDownloadURL().then((value) => {
        //       return value,
        //     });
        break;
    }
    // 返回 Completer 的 Future
  });
  return url;
}

Future<String?> uploadFileAndGetUrl(File file) async {
  final storageRef = FirebaseStorage.instance.ref();
  final metadata = SettableMetadata(contentType: "image/jpeg");

  final uploadTask = storageRef
      .child("viajuntos-397806-images/ProfileImages/" +
          APICalls().getCurrentUser())
      .putFile(file, metadata);

  try {
    final TaskSnapshot taskSnapshot = await uploadTask;
    if (taskSnapshot.state == TaskState.success) {
      var downloadUrl = await taskSnapshot.ref.getDownloadURL();
      return downloadUrl.toString();
    } else {
      // Handle other states if needed
      return null;
    }
  } catch (error) {
    print("Upload error: $error");
    return null;
  }
}
