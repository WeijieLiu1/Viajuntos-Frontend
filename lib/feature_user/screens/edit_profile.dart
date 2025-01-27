// ignore_for_file: prefer_const_constructors

import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:viajuntos/feature_navigation/screens/profile.dart';
import 'package:viajuntos/feature_user/services/externalService.dart';
import 'package:viajuntos/utils/api_controller.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
//import '../services/sharedPreferencesHelper.dart';

class EditarProfile extends StatefulWidget {
  const EditarProfile({Key? key}) : super(key: key);

  @override
  State<EditarProfile> createState() => _EditarProfileState();
}

class _EditarProfileState extends State<EditarProfile> {
  final formKey = GlobalKey<FormState>();
  late String username;
  late String description;
  late String hobbies;
  late String idUser;
  late String image_url;
  late bool isPremium;
  List<dynamic> idiomas = [];
  bool colorInit = false;
  bool colorInit2 = false;
  bool colorInit3 = false;
  Color primary = Colors.white;
  Color secundary = Colors.black;
  Color primary2 = Colors.white;
  Color secundary2 = Colors.black;
  Color primary3 = Colors.white;
  Color secundary3 = Colors.black;
  Map user = {};
  String idProfile = "0";
  APICalls ac = APICalls();
  final ExternServicePhoto es = ExternServicePhoto();

  String getCurrentUser() {
    return ac.getCurrentUser();
  }

  Future<int> updateUser(Map<String, dynamic> body) async {
    final response =
        await ac.putItem('/v1/users/:0', [ac.getCurrentUser()], body);
    return response.statusCode;
  }

  // Future<void> purchasePremium() async {
  //   final response = await ac.postItem(
  //       '/v1/users/:0/update_premium', [ac.getCurrentUser()], null);
  //   bool activated = false;
  //   if (response == null) return;
  //   if (response.body.contains('"Premuim actived"')) activated = true;

  //   print("purchasePremium body: " + response.body);
  //   APICalls().setIsPremium(activated);
  //   setState(() {});
  // }

  Future<void> getUser() async {
    final response = await ac.getItem("/v2/users/:0", [idProfile]);
    setState(() {
      user = json.decode(response.body);
      idiomas = user["languages"];
      username = user["username"];
      description = user["description"];
      hobbies = user["hobbies"];
      idUser = user["id"];
      image_url = user["image_url"];
      isPremium = user["isPremium"];
      APICalls().setIsPremium(isPremium);
    });
    // getProfilePhoto(idUser);
  }

  // Future<void> getProfilePhoto(String idUser) async {
  //   final response = await es.getAPhoto(idUser);
  //   if (response != 'Fail') {
  //     setState(() {
  //       urlProfilePhoto = response;
  //     });
  //   }
  // }

  @override
  void initState() {
    super.initState();
    idProfile = getCurrentUser();
    getUser();
  }

  Widget builWidgetText(String labelText2, String placeHolder) {
    return TextFormField(
      initialValue: placeHolder,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.only(left: 30),
        labelText: labelText2,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        hintStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(29),
          ),
        ),
      ),
      validator: (value) {
        if (value!.isEmpty) {
          if (labelText2 == "Username".tr()) {
            return 'enterUsername'.tr();
          } else if (labelText2 == "Description".tr()) {
            return 'enterDescription'.tr();
          } else if (labelText2 == "hobbies".tr()) {
            return 'enterhobbie'.tr();
          }
        }
        return null;
      },
      onSaved: (value) {
        if (labelText2 == "Username".tr()) {
          setState(() {
            username = value.toString();
          });
        } else if (labelText2 == "Description".tr()) {
          setState(() {
            description = value.toString();
          });
        } else if (labelText2 == "hobbies".tr()) {
          setState(() {
            hobbies = value.toString();
          });
        }
      },
    );
  }

  Widget _buildLanguages() {
    // ignore: sized_box_for_whitespace
    return Container(
      height: 30,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          const SizedBox(width: 15),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                primary:
                    colorInit ? Theme.of(context).colorScheme.primary : primary,
                onPrimary: colorInit
                    ? Theme.of(context).colorScheme.onPrimary
                    : secundary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                minimumSize: const Size(80, 50)),
            onPressed: () {
              colorInit = !colorInit;
              if (!colorInit) {
                idiomas.remove("spanish");
              } else {
                idiomas.add("spanish");
              }
              setState(() {
                primary = nuevoColor(colorInit, "primary");
                secundary = nuevoColor(colorInit, "secondary");
              });
            },
            child: Text(
              "Spanish",
              style: TextStyle(
                  height: 1.0, fontSize: 16, fontWeight: FontWeight.bold),
            ).tr(),
          ),
          const SizedBox(width: 5),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                primary: colorInit2
                    ? Theme.of(context).colorScheme.primary
                    : primary2,
                onPrimary: colorInit2
                    ? Theme.of(context).colorScheme.onPrimary
                    : secundary2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                minimumSize: const Size(80, 50)),
            onPressed: () {
              colorInit2 = !colorInit2;
              if (!colorInit2) {
                idiomas.remove("english");
              } else {
                idiomas.add("english");
              }
              setState(() {
                primary2 = nuevoColor(colorInit2, "primary");
                secundary2 = nuevoColor(colorInit2, "secondary");
              });
            },
            child: Text(
              "English",
              style: TextStyle(
                  height: 1.0, fontSize: 16, fontWeight: FontWeight.bold),
            ).tr(),
          ),
          const SizedBox(width: 5),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                primary: colorInit3
                    ? Theme.of(context).colorScheme.primary
                    : primary3,
                onPrimary: colorInit3
                    ? Theme.of(context).colorScheme.onPrimary
                    : secundary3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                minimumSize: const Size(80, 50)),
            onPressed: () {
              colorInit3 = !colorInit3;
              if (!colorInit3) {
                idiomas.remove("catalan");
              } else {
                idiomas.add("catalan");
              }
              setState(() {
                primary3 = nuevoColor(colorInit3, "primary");
                secundary3 = nuevoColor(colorInit3, "secondary");
              });
            },
            child: Text(
              "Catalan",
              style: TextStyle(
                  height: 1.0, fontSize: 16, fontWeight: FontWeight.bold),
            ).tr(),
          ),
        ],
      ),
    );
  }

  Color nuevoColor(initColor, String priority) {
    Color colorRetorno;
    if (priority == "primary") {
      if (!initColor) {
        colorRetorno = Colors.white;
      } else {
        colorRetorno = Theme.of(context).colorScheme.primary;
      }
    } else {
      if (!initColor) {
        colorRetorno = Colors.black;
      } else {
        colorRetorno = Theme.of(context).colorScheme.onPrimary;
      }
    }
    return colorRetorno;
  }

  Future<void> _pickAndCropImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      final croppedImage = await ImageCropper().cropImage(
          sourcePath: pickedImage.path,
          aspectRatio: CropAspectRatio(
            ratioX: 4, // 设置裁剪框的宽高比例
            ratioY: 4,
          ),
          compressFormat: ImageCompressFormat.jpg, // 设置裁剪后的图片格式
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: 'Crop Image', // Android端裁剪页面的标题
              toolbarColor: Colors.deepOrange, // Android端裁剪页面的工具栏颜色
              toolbarWidgetColor: Colors.white, // Android端裁剪页面的工具栏图标颜色
            ),
            IOSUiSettings(
              title: 'Cropper',
            ),
          ]);

      if (croppedImage != null) {
        // 裁剪成功，可以在这里进行操作，例如将图片显示在界面上
        //gs://viajuntos-48ca9.firebasestorage.app/viajuntos-48ca9-images/ProfileImages
        // final path =
        //     'gs://viajuntos-48ca9.firebasestorage.app/viajuntos-48ca9-images/ProfileImages/' +
        //         APICalls().getCurrentUser();

        final file = File(croppedImage.path);

        final storageRef = FirebaseStorage.instance.ref();
        // Create the file metadata
        final metadata = SettableMetadata(contentType: "image/jpeg");
        // Upload file and metadata to the path 'images/mountains.jpg'
        final uploadTask = storageRef
            .child("viajuntos-48ca9-images/ProfileImages/" +
                APICalls().getCurrentUser())
            .putFile(file, metadata);
        // Listen for state changes, errors, and completion of the upload.
        bool isCanceledDialogShown = false;
        bool isUploadCanceled = false;
        showDialog(
          context: context,
          barrierDismissible: false, // Prevent dismissal by tapping outside
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
                    isUploadCanceled = true; // Mark upload as canceled
                    Navigator.pop(context); // Close the dialog
                    uploadTask.cancel(); // Cancel the upload
                  },
                  child: Text("Cancel"),
                ),
              ],
            ),
          ),
        );
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
              if (!isCanceledDialogShown) {
                isCanceledDialogShown = true;
                if (isUploadCanceled) {
                  print("User canceled the upload.");
                } else {
                  print("Upload was canceled due to other reasons.");
                }
                ;
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
              }
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
              Navigator.pop(context);
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
                      image_url = value.toString();
                    })
                  });
              break;
          }
        });
      }
    }
  }

  SnackBar mensajeMuestra(String mensaje) {
    return SnackBar(
      content: Text(mensaje),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (user.isEmpty) {
      return const Scaffold(
          body: Center(
        child: CircularProgressIndicator(),
      ));
    } else {
      if (idiomas.contains("spanish")) {
        colorInit = true;
      }
      if (idiomas.contains("english")) {
        colorInit2 = true;
      }
      if (idiomas.contains("catalan")) {
        colorInit3 = true;
      }
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text("editprofile",
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.surface,
                      fontSize: 16))
              .tr(),
          backgroundColor: Theme.of(context).colorScheme.background,
          leading: IconButton(
            iconSize: 24,
            color: Theme.of(context).colorScheme.onSurface,
            icon: const Icon(Icons.arrow_back_ios_new_sharp),
            onPressed: () {
              Navigator.pop(context);
              // Navigator.pushAndRemoveUntil(
              //     context,
              //     MaterialPageRoute(
              //         builder: (context) => ProfileScreen(id: idUser)),
              //     (route) => false);
            },
          ),
        ),
        body: Padding(
          padding:
              const EdgeInsets.only(left: 64, right: 64, top: 16, bottom: 16),
          child: Form(
            key: formKey,
            child: ListView(
              children: <Widget>[
                const SizedBox(height: 15),
                Center(
                  child: Stack(
                    children: <Widget>[
                      Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            width: 4.0,
                            style: BorderStyle.solid,
                          ),
                          boxShadow: [
                            BoxShadow(
                                spreadRadius: 2,
                                blurRadius: 10,
                                color: Theme.of(context)
                                    .colorScheme
                                    .secondary
                                    .withOpacity(0.6),
                                offset: const Offset(0, 10))
                          ],
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: (image_url == "")
                                ? AssetImage('assets/noProfileImage.png')
                                : NetworkImage(image_url) as ImageProvider,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: IconButton(
                          iconSize: 24,
                          icon: Icon(
                            Icons.edit,
                            color: Theme.of(context).colorScheme.primary,
                            size: 30,
                          ),
                          onPressed: _pickAndCropImage,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                builWidgetText("Username".tr(), username),
                const SizedBox(height: 15),
                builWidgetText("Description".tr(), description),
                const SizedBox(height: 15),
                builWidgetText("hobbies".tr(), hobbies),
                const SizedBox(height: 15),
                Text(
                  "preferredlanguages",
                  textAlign: TextAlign.center,
                ).tr(),
                const SizedBox(height: 15),
                _buildLanguages(),
                const SizedBox(height: 15),
                Text(
                  "premium",
                  textAlign: TextAlign.center,
                ).tr(),
                Switch(
                  value: isPremium,
                  inactiveTrackColor: Theme.of(context).colorScheme.background,
                  activeTrackColor: Theme.of(context).colorScheme.secondary,
                  inactiveThumbColor: Theme.of(context).colorScheme.primary,
                  activeColor: Theme.of(context).colorScheme.primary,
                  onChanged: (bool value) {
                    // This is called when the user toggles the switch.
                    // print("purchasePremium: " +
                    //     APICalls().getIsPremium().toString());

                    setState(() {
                      isPremium = value;
                    });
                    // purchasePremium();
                  },
                ),
                const SizedBox(height: 55),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Theme.of(context).colorScheme.secondary,
                          onPrimary: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          minimumSize: const Size(200, 40),
                        ),
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            formKey.currentState!.save();
                            Map<String, dynamic> bodyAux = {
                              "username": username,
                              "languages": idiomas,
                              "description": description,
                              "hobbies": hobbies,
                              "image_url": image_url,
                              "isPremium": isPremium,
                            };
                            var ap = await updateUser(bodyAux);
                            if (ap == 200) {
                              // getUser();
                              ScaffoldMessenger.of(context).showSnackBar(
                                  mensajeMuestra("updateddata".tr()));
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                  '/home', (route) => false);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  mensajeMuestra("updateerror".tr()));
                            }
                          }
                          // Navigator.of(context).pushNamedAndRemoveUntil(
                          //     '/home', (route) => false);
                        },
                        child: Text(
                          'Update'.tr(),
                          style: TextStyle(
                              height: 1.0,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
}
