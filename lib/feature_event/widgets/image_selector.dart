import 'dart:io';
import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:viajuntos/utils/api_controller.dart';

class ImageSelector extends StatefulWidget {
  final path;
  final List<String> uploadImages;
  final Function(List<String>) onImagesChanged;
  const ImageSelector(
      {Key? key,
      required this.path,
      required this.uploadImages,
      required this.onImagesChanged})
      : super(key: key);

  @override
  State<ImageSelector> createState() => _ImageSelectorState();
}

class _ImageSelectorState extends State<ImageSelector> {
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      String image_url = await uploadImages(pickedImage.path.toString());

      setState(() {
        // if (image_url != "") {
        widget.uploadImages.add(image_url);
        widget.onImagesChanged(widget.uploadImages);
        // }
        // widget.uploadImages.add(pickedImage.path.toString());
        // widget.onImagesChanged(widget.uploadImages);
      });
    }
  }

  Future<String> uploadImages(String path) async {
    String image_url = "";
    final file = File(path);

    List<String> parts = path.split('/');
    String fileId = parts[parts.length - 2];
    String fileType = parts[parts.length - 1].split('.')[1];
    final storageRef = FirebaseStorage.instance.ref();
    // Create the file metadata
    final metadata = SettableMetadata(contentType: "image/jpeg");
    // Upload file and metadata to the path 'images/mountains.jpg'
    final uploadTask = storageRef
        .child("viajuntos-397806-images/EventImages/" +
            widget.path +
            "/" +
            fileId +
            "." +
            fileType)
        .putFile(file, metadata);
    try {
      // 使用 await 等待上传完成
      await uploadTask;
      // 如果上传成功，获取下载链接
      image_url = await storageRef
          .child("viajuntos-397806-images/EventImages/" +
              APICalls().getCurrentUser() +
              "/" +
              fileId +
              "." +
              fileType)
          .getDownloadURL();
      // 这里可以执行上传成功后的其他操作
    } catch (error) {
      // 处理上传失败的情况
      print("Error uploading image: $error");
    }
    // // Listen for state changes, errors, and completion of the upload.
    // uploadTask.snapshotEvents.listen((TaskSnapshot taskSnapshot) {
    //   switch (taskSnapshot.state) {
    //     case TaskState.running:
    //       final progress =
    //           100.0 * (taskSnapshot.bytesTransferred / taskSnapshot.totalBytes);
    //       print("Upload is $progress% complete.");
    //       break;
    //     case TaskState.paused:
    //       showDialog(
    //           context: context,
    //           builder: (context) => AlertDialog(
    //                   title: Text("UploadPausedTitle").tr(),
    //                   content: Text("UploadPausedContent").tr(),
    //                   actions: [
    //                     TextButton(
    //                       child: Text('Ok').tr(),
    //                       onPressed: () => Navigator.pop(context),
    //                     )
    //                   ]));
    //       break;
    //     case TaskState.canceled:
    //       showDialog(
    //           context: context,
    //           builder: (context) => AlertDialog(
    //                   title: Text("UploadCanceledTitle").tr(),
    //                   content: Text("UploadCanceledContent").tr(),
    //                   actions: [
    //                     TextButton(
    //                       child: Text('Ok').tr(),
    //                       onPressed: () => Navigator.pop(context),
    //                     )
    //                   ]));
    //       break;
    //     case TaskState.error:
    //       // Handle unsuccessful uploads
    //       showDialog(
    //           context: context,
    //           builder: (context) => AlertDialog(
    //                   title: Text("UploadErrorTitle").tr(),
    //                   content: Text("UploadErrorContent").tr(),
    //                   actions: [
    //                     TextButton(
    //                       child: Text('Ok').tr(),
    //                       onPressed: () => Navigator.pop(context),
    //                     )
    //                   ]));
    //       break;
    //     case TaskState.success:
    //       showDialog(
    //           context: context,
    //           builder: (context) => AlertDialog(
    //                   title: Text("UploadSuccessTitle").tr(),
    //                   content: Text("UploadSuccessContent").tr(),
    //                   actions: [
    //                     TextButton(
    //                       child: Text('Ok').tr(),
    //                       onPressed: () => Navigator.pop(context),
    //                     )
    //                   ]));
    //       var a = taskSnapshot.ref.getDownloadURL();
    //       // 管理调试令牌
    //       // viajuntos-token1: 74DAE15D-F943-40F6-8034-F0B280917599
    //       taskSnapshot.ref.getDownloadURL().then((value) => {
    //             // widget.uploadImages.add(value.toString())
    //             image_url = value.toString()
    //             // setState(() {
    //             //   images.add(value.toString());
    //             //   // image_url = value.toString();
    //             // })
    //           });
    //       break;
    //   }
    // });
    return image_url;
  }

  Future<void> deleteImageFromStorage(String downloadUrl) async {
    try {
      final storageRef = FirebaseStorage.instance.refFromURL(downloadUrl);
      await storageRef.delete();
      print('File deleted successfully');
    } catch (e) {
      print('Error deleting file: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: max((widget.uploadImages.length / 3).ceil() * 130.0, 130),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 4.0,
          mainAxisSpacing: 4.0,
        ),
        itemCount: (widget.uploadImages.length < 9)
            ? widget.uploadImages.length + 1
            : widget.uploadImages.length,
        itemBuilder: (BuildContext context, int index) {
          if (index == widget.uploadImages.length &&
              widget.uploadImages.length < 9) {
            return GestureDetector(
              onTap: () {
                _pickImage();
              },
              child: Container(
                color: Colors.grey[300],
                child: Icon(Icons.add),
              ),
            );
          } else {
            return GestureDetector(
                onTap: () {
                  if (widget.uploadImages.length == 1) {
                    showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                                title: Text("DeleteLastImageTitle").tr(),
                                content: Text("DeleteLastImageMessage").tr(),
                                actions: [
                                  TextButton(
                                    child: Text('Ok').tr(),
                                    onPressed: () async {
                                      Navigator.pop(context);
                                    },
                                  ),
                                ]));
                  } else
                    showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                                title: Text("DeleteImageTitle").tr(),
                                content: Text("DeleteImageMessage").tr(),
                                actions: [
                                  TextButton(
                                    child: Text('Yes').tr(),
                                    onPressed: () async {
                                      Navigator.pop(context);

                                      await deleteImageFromStorage(
                                          widget.uploadImages[index]);
                                      setState(() {
                                        widget.uploadImages.removeAt(index);
                                        widget.onImagesChanged(
                                            widget.uploadImages);
                                      });
                                    },
                                  ),
                                  TextButton(
                                    child: Text('Cancel').tr(),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                  )
                                ]));
                },
                child: Container(
                    width: 100,
                    height: 100,
                    color: Colors.grey[300],
                    alignment: Alignment.center,
                    child: Image.network(
                      widget.uploadImages[index],
                      fit: BoxFit.cover,
                    )));
          }
        },
      ),
    );
  }
}
