// ignore_for_file: prefer_const_constructors

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:viajuntos/feature_chat/screens/chat_screen.dart';
import 'package:viajuntos/feature_navigation/widgets/report_user.dart';
import 'package:viajuntos/utils/api_controller.dart';
import 'dart:convert';
import 'package:viajuntos/feature_navigation/widgets/settings.dart';
import 'package:viajuntos/feature_user/services/externalService.dart';
import 'package:viajuntos/utils/friend_request_notifier.dart';

class ProfileScreen extends StatefulWidget {
  final String id;
  const ProfileScreen({Key? key, required this.id}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  var creatorStyle =
      const TextStyle(color: Color.fromARGB(255, 17, 92, 153), fontSize: 20);
  var explainStyle =
      const TextStyle(color: Color.fromARGB(255, 61, 60, 60), fontSize: 18);
  var titleStyle = const TextStyle(color: Colors.black, fontSize: 18);
  bool isFriend = false;
  Map user = {};
  String idProfile = '0';
  final ExternServicePhoto es = ExternServicePhoto();
  bool hasFriendship = false;

  bool hasFriendRequest = false;
  void getHasFriendship() async {
    if (idProfile == APICalls().getCurrentUser()) return;
    var response = await APICalls()
        .getCollection('/v2/users/is_friend', [], {"id": widget.id});
    // isFriend = json.decode(response.body)["is_friend"];
    setState(() {
      isFriend = json.decode(response.body)["is_friend"];
    });
  }

  Future<void> addFriendRequest() async {
    try {
      var response = await APICalls().postItem(
        '/v2/users/add_friend_request',
        [],
        {"id": widget.id},
      );

      if (response.body != null &&
          json.decode(response.body)["message"] != null) {
        // 成功处理
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(json.decode(response.body)["message"]),
            backgroundColor: Colors.green,
          ),
        );
      } else if (response.body != null &&
          json.decode(response.body)["error_message"] != null) {
        // 错误处理
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(json.decode(response.body)["error_message"]),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        // 未知错误
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("An unexpected error occurred. Please try again."),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      // 捕获异常
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to send friend request: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> showConfirmDialog() async {
    final shouldSend = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('ConfirmFriendRequestTitle').tr(),
          content: Text('ConfirmFriendRequestContent').tr(),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // 用户点击“取消”
              },
              child: Text('Cancel').tr(),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // 用户点击“确认”
              },
              child: Text('Confirm').tr(),
            ),
          ],
        );
      },
    );

    if (shouldSend == true) {
      // 用户确认发送请求
      await addFriendRequest();
    }
  }

  @override
  void initState() {
    super.initState();
    idProfile = widget.id;
    getHasFriendship();
    hasFriendRequest = APICalls()
        .friendRequests
        .where((request) => request["accepted"] == null)
        .isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('Profile',
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
              Navigator.pop(context, true);
            },
          ),
          iconTheme:
              const IconThemeData(color: Color.fromARGB(255, 17, 92, 153)),
          actions: <Widget>[
            if (idProfile != APICalls().getCurrentUser())
              ReportUser(id: idProfile),
            if (isFriend)
              IconButton(
                iconSize: 24,
                color: Theme.of(context).colorScheme.onSurface,
                icon: const Icon(Icons.chat),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ChatScreen(
                              chatId: widget.id,
                              chatName: "${user["username"]}",
                              chatImageUrl: "${user["image_url"]}")));
                },
              )
            else if (idProfile != APICalls().getCurrentUser())
              IconButton(
                iconSize: 24,
                color: Theme.of(context).colorScheme.onSurface,
                icon: const Icon(Icons.add),
                onPressed: () async {
                  await showConfirmDialog();
                },
              ),
            if (idProfile == APICalls().getCurrentUser())
              Builder(
                builder: (BuildContext context) {
                  return IconButton(
                    icon: Consumer<RedDotNotifier>(
                      builder: (context, notifier, child) {
                        return Stack(
                          alignment: Alignment.topRight,
                          children: [
                            Icon(Icons.menu, size: 28),
                            if (notifier.hasFriendRequest)
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                    onPressed: () {
                      // 打开 endDrawer
                      Scaffold.of(context).openEndDrawer();
                    },
                  );
                },
              ),
          ],
        ),
        endDrawer: Settings(id: idProfile, hasNewMessage: hasFriendRequest),
        body: FutureBuilder(
            future: APICalls().getItem('v2/users/:0', [idProfile]),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                user = json.decode(snapshot.data.body);
                return SingleChildScrollView(
                    child: Center(
                        child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(children: [
                    Row(children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.14,
                        width: MediaQuery.of(context).size.width * 0.3,
                        child: Column(children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundImage: ("${user["image_url"]}" == "")
                                ? const AssetImage('assets/noProfileImage.png')
                                : NetworkImage("${user["image_url"]}")
                                    as ImageProvider,
                          ),
                        ]),
                      ),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.14,
                          width: MediaQuery.of(context).size.width * 0.5,
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text("${user["username"]}",
                                        style: creatorStyle),
                                    const Divider(indent: 5, endIndent: 5),
                                  ],
                                ),
                                const Divider(),
                                Row(children: [
                                  Container(
                                    height: 23.0,
                                    width: 30.0,
                                    decoration: BoxDecoration(
                                      image: (user["languages"]
                                              .contains("catalan"))
                                          ? const DecorationImage(
                                              image:
                                                  AssetImage('assets/cat.png'),
                                              fit: BoxFit.fill,
                                            )
                                          : const DecorationImage(
                                              image:
                                                  AssetImage('assets/cat.png'),
                                              fit: BoxFit.fill,
                                              colorFilter: ColorFilter.mode(
                                                  Color.fromARGB(
                                                      255, 143, 141, 141),
                                                  BlendMode.color)),
                                    ),
                                  ),
                                  const Divider(indent: 5, endIndent: 5),
                                  Container(
                                    height: 23.0,
                                    width: 30.0,
                                    decoration: BoxDecoration(
                                        image: (user["languages"]
                                                .contains("spanish"))
                                            ? const DecorationImage(
                                                image: AssetImage(
                                                    'assets/esp.jpg'),
                                                fit: BoxFit.fill,
                                              )
                                            : const DecorationImage(
                                                image: AssetImage(
                                                    'assets/esp.jpg'),
                                                fit: BoxFit.fill,
                                                colorFilter: ColorFilter.mode(
                                                    Color.fromARGB(
                                                        255, 143, 141, 141),
                                                    BlendMode.color))),
                                  ),
                                  const Divider(indent: 5, endIndent: 5),
                                  Container(
                                    height: 23.0,
                                    width: 30.0,
                                    decoration: BoxDecoration(
                                      image: (user["languages"]
                                              .contains("english"))
                                          ? const DecorationImage(
                                              image:
                                                  AssetImage('assets/ing.jpg'),
                                              fit: BoxFit.fill,
                                            )
                                          : const DecorationImage(
                                              image:
                                                  AssetImage('assets/ing.jpg'),
                                              fit: BoxFit.fill,
                                              colorFilter: ColorFilter.mode(
                                                  Color.fromARGB(
                                                      255, 143, 141, 141),
                                                  BlendMode.color)),
                                    ),
                                  ),
                                ])
                              ])),
                    ]),
                    const Divider(indent: 5, endIndent: 5),
                    Text(
                      "${user["description"]}${user["description"]}${user["description"]}${user["description"]}${user["description"]}${user["description"]}${user["description"]}${user["description"]}${user["description"]}${user["description"]}${user["description"]}${user["description"]}${user["description"]}${user["description"]}${user["description"]}${user["description"]}${user["description"]}${user["description"]}${user["description"]}${user["description"]}${user["description"]}",
                      style: explainStyle,
                      textAlign: TextAlign.center,
                    ),
                    const Divider(indent: 5, endIndent: 5),
                    SizedBox(
                      height: 20,
                      child: Text(
                        'Logros',
                        style: titleStyle,
                        textAlign: TextAlign.center,
                      ).tr(),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      // color: Colors.red,
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      height: 160,
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4, // 每行显示两个成就
                          crossAxisSpacing: 8.0, // 列间距
                          mainAxisSpacing: 8.0, // 行间距
                          childAspectRatio: 3 / 4, // 子项宽高比，根据需要调整
                        ),
                        itemCount: user["achievements"].length,
                        itemBuilder: (context, i) {
                          return GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text(user["achievements"][i]["title"]),
                                  content: Text(
                                      user["achievements"][i]["description"]),
                                  actions: [
                                    TextButton(
                                      child: Text('Ok').tr(),
                                      onPressed: () => Navigator.pop(context),
                                    )
                                  ],
                                ),
                              );
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  backgroundImage: AssetImage(
                                    'assets/achievements/' +
                                        user["achievements"][i]["id"] +
                                        '.png',
                                  ),
                                  radius: 15, // 调整图标大小
                                ),
                                const SizedBox(height: 4.0),
                                Text(
                                  user["achievements"][i]["title"],
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4.0),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      '${user["achievements"][i]["progress"]}/${user["achievements"][i]["stages"]}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const Divider(indent: 5, endIndent: 5),
                    if (APICalls().getCurrentUser() == idProfile) ...[
                      SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                        child: Text(
                          'Amigos',
                          style: titleStyle,
                          textAlign: TextAlign.center,
                        ).tr(),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            height: MediaQuery.of(context).size.height * 0.4,
                            width: MediaQuery.of(context).size.width * 0.9,
                            child: ListView(
                              children: <Widget>[
                                for (var i = 0; i < user["friends"].length; i++)
                                  FutureBuilder(
                                    future: APICalls().getItem('v2/users/:0',
                                        [user["friends"][i]["id"]]),
                                    builder: (BuildContext context,
                                        AsyncSnapshot snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.done) {
                                        Map auxUser =
                                            json.decode(snapshot.data.body);
                                        return Card(
                                          clipBehavior: Clip.antiAlias,
                                          // margin:
                                          //     const EdgeInsets.symmetric(
                                          //         vertical: 8),
                                          child: InkWell(
                                            borderRadius:
                                                BorderRadius.circular(0),
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      ProfileScreen(
                                                    id: auxUser["id"],
                                                  ),
                                                ),
                                              );
                                            },
                                            child: Ink(
                                              height: 50,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSecondary,
                                              padding: const EdgeInsets.only(
                                                  left: 16, top: 10),
                                              child: Row(
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            right: 8),
                                                    child: (auxUser["image_url"] ==
                                                                null ||
                                                            auxUser["image_url"] ==
                                                                "")
                                                        ? const Image(
                                                            image: AssetImage(
                                                                'assets/noProfileImage.png'),
                                                            width: 40,
                                                            height: 40,
                                                          )
                                                        : Image.network(
                                                            auxUser[
                                                                "image_url"],
                                                            width: 40,
                                                            height: 40,
                                                          ),
                                                  ),
                                                  Text(
                                                    auxUser["username"],
                                                    textAlign: TextAlign.start,
                                                    style: TextStyle(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onBackground,
                                                      fontSize: 20,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      } else {
                                        return const Center(
                                            child: CircularProgressIndicator());
                                      }
                                    },
                                  ),
                              ],
                            ),
                          ),
                        ],
                      )
                    ]
                  ]),
                )));
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            }));
  }
}
