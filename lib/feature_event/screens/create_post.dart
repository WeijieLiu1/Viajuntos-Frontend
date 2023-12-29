import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:viajuntos/feature_event/widgets/create_form.dart';
import 'package:viajuntos/feature_event/widgets/create_post_form.dart';
import 'package:viajuntos/utils/api_controller.dart';

class CreatePostScreen extends StatefulWidget {
  final String id;
  const CreatePostScreen({Key? key, required this.id}) : super(key: key);

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  List<String> images = [];
  List<String> uploadImages = [];
  TextEditingController textEditingController = TextEditingController();

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        images.add(pickedImage.path.toString());
        // image_url = value.toString();
      });
    }
  }

  Future<bool> uploadAllImages() async {
    bool succeed = true;
    for (var i = 0; i < images.length && succeed; i++) {
      final file = File(images[i]);

      final storageRef = FirebaseStorage.instance.ref();
      // Create the file metadata
      final metadata = SettableMetadata(contentType: "image/jpeg");
      // Upload file and metadata to the path 'images/mountains.jpg'
      final uploadTask = storageRef
          .child("viajuntos-397806-images/PostImages/" +
              APICalls().getCurrentUser())
          .putFile(file, metadata);
      // Listen for state changes, errors, and completion of the upload.
      uploadTask.snapshotEvents.listen((TaskSnapshot taskSnapshot) {
        switch (taskSnapshot.state) {
          case TaskState.running:
            final progress = 100.0 *
                (taskSnapshot.bytesTransferred / taskSnapshot.totalBytes);
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
            succeed = false;
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
            succeed = false;
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
            succeed = false;
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
                            onPressed: () => Navigator.pop(context),
                          )
                        ]));
            var a = taskSnapshot.ref.getDownloadURL();
            // 管理调试令牌
            // viajuntos-token1: 74DAE15D-F943-40F6-8034-F0B280917599
            taskSnapshot.ref.getDownloadURL().then((value) => {
                  uploadImages.add(value.toString())
                  // setState(() {
                  //   images.add(value.toString());
                  //   // image_url = value.toString();
                  // })
                });
            break;
        }
      });
    }
    return succeed;
  }

  Future<void> _pickUploadImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      // 裁剪成功，可以在这里进行操作，例如将图片显示在界面上
      //gs://viajuntos-397806.appspot.com/viajuntos-397806-images/ProfileImages
      // final path =
      //     'gs://viajuntos-397806.appspot.com/viajuntos-397806-images/ProfileImages/' +
      //         APICalls().getCurrentUser();

      final file = File(pickedImage.path);

      final storageRef = FirebaseStorage.instance.ref();
      // Create the file metadata
      final metadata = SettableMetadata(contentType: "image/jpeg");
      // Upload file and metadata to the path 'images/mountains.jpg'
      final uploadTask = storageRef
          .child("viajuntos-397806-images/PostImages/" +
              APICalls().getCurrentUser())
          .putFile(file, metadata);
      // Listen for state changes, errors, and completion of the upload.
      uploadTask.snapshotEvents.listen((TaskSnapshot taskSnapshot) {
        switch (taskSnapshot.state) {
          case TaskState.running:
            final progress = 100.0 *
                (taskSnapshot.bytesTransferred / taskSnapshot.totalBytes);
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
                            onPressed: () => Navigator.pop(context),
                          )
                        ]));
            var a = taskSnapshot.ref.getDownloadURL();
            // 管理调试令牌
            // viajuntos-token1: 74DAE15D-F943-40F6-8034-F0B280917599
            taskSnapshot.ref.getDownloadURL().then((value) => {
                  setState(() {
                    images.add(value.toString());
                    // image_url = value.toString();
                  })
                });
            break;
        }
      });
    }
  }

  Future<void> publishPost() async {
    var response = await APICalls().postItem('/v3/events/:0/post/', [
      widget.id
    ], {
      "parent_post_id": "",
      "text": textEditingController.text,
      "post_image_uris": uploadImages
    });
    if (response.statusCode == 200) {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                  title: Text("PublishSuccessTitle").tr(),
                  content: Text("PublishSuccessContent").tr(),
                  actions: [
                    TextButton(
                      child: Text('Ok').tr(),
                      onPressed: () => Navigator.pop(context),
                    )
                  ]));
    } else {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                  title: Text("PublishErrorTitle").tr(),
                  content: Text("PublishErrorContent").tr(),
                  actions: [
                    TextButton(
                      child: Text('Ok').tr(),
                      onPressed: () => Navigator.pop(context),
                    )
                  ]));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('NewPost').tr(),
        actions: <Widget>[
          IconButton(
            iconSize: 24,
            color: Theme.of(context).colorScheme.onSurface,
            icon: const Icon(Icons.send),
            onPressed: () async {
              bool b = await uploadAllImages();
              if (b) await publishPost();
            },
          )
        ],
      ),
      body: Column(
        children: [
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return Container(
                color: Colors.blue,
                constraints: BoxConstraints(
                  minHeight: 100,
                  maxHeight: constraints.maxHeight,
                ),
                child: TextField(
                  controller: textEditingController,
                  decoration: InputDecoration(
                    hintText: 'EnterText'.tr(),
                    border: InputBorder.none,
                  ),
                  maxLines: null,
                ),
              );
            },
          ),
          SizedBox(height: 10),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, // 每行三个图片
                crossAxisSpacing: 4.0, // 交叉轴间距
                mainAxisSpacing: 4.0, // 主轴间距
              ),
              itemCount: images.length + 1,
              itemBuilder: (BuildContext context, int index) {
                if (index == images.length) {
                  // 最后一个项目显示添加图片按钮
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
                  return Container(
                    width: 100,
                    height: 100,
                    color: Colors.grey[300],
                    alignment: Alignment.center,
                    child: Image.file(
                      File(images[index]),
                      fit: BoxFit.cover,
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
