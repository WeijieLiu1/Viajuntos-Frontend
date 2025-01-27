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
    String imageUrl = "";
    final file = File(path);
    List<String> parts = path.split('/');
    String fileId = parts[parts.length - 2];
    String fileType = parts[parts.length - 1].split('.')[1];

    final storageRef = FirebaseStorage.instance.ref();
    final metadata = SettableMetadata(contentType: "image/jpeg");
    final uploadTask = storageRef
        .child("viajuntos-48ca9-images/EventImages/" +
            widget.path +
            "/" +
            fileId +
            "." +
            fileType)
        .putFile(file, metadata);

    bool isUploadCanceled = false; // 标记是否取消上传

    // 显示上传进度对话框
    showDialog(
      context: context,
      barrierDismissible: false, // 禁止点击对话框外部关闭
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text("Uploading..."),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 10),
              Text("Please wait while the image is uploading."),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                isUploadCanceled = true; // 设置取消标记
                uploadTask.cancel(); // 取消上传任务
                Navigator.pop(context); // 关闭对话框
              },
              child: Text("Cancel"),
            ),
          ],
        ),
      ),
    );

    try {
      // 使用 snapshotEvents 监听上传进度
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        if (snapshot.state == TaskState.running) {
          double progress =
              100.0 * (snapshot.bytesTransferred / snapshot.totalBytes);
          print("Upload progress: $progress%");
        }
      });

      // 等待上传完成
      await uploadTask;

      if (!isUploadCanceled) {
        // 获取下载链接
        imageUrl = await storageRef
            .child("viajuntos-48ca9-images/EventImages/" +
                widget.path +
                "/" +
                fileId +
                "." +
                fileType)
            .getDownloadURL();
      }
    } on FirebaseException catch (e) {
      if (e.code == 'canceled') {
        print("Upload canceled by user.");
      } else {
        print("Error uploading image: $e");
      }
    } finally {
      // 确保对话框关闭
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    }

    return imageUrl; // 返回上传结果
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
