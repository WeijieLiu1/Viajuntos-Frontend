// ignore_for_file: prefer_const_constructors

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:viajuntos/utils/api_controller.dart';
import 'package:viajuntos/utils/friend_request_notifier.dart';
import 'package:viajuntos/utils/share.dart';
import 'dart:convert';

class Settings extends StatefulWidget {
  final String id;
  final bool hasNewMessage;
  const Settings({Key? key, required this.id, required this.hasNewMessage})
      : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  Map url = {};
  Map user = {};
  String idProfile = '0';

  @override
  void initState() {
    super.initState();
    idProfile = widget.id;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: APICalls().getItem('v2/users/:0', [idProfile]),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            user = json.decode(snapshot.data.body);
            return Drawer(
              backgroundColor: Theme.of(context).colorScheme.background,
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  DrawerHeader(
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 102, 150, 171),
                    ),
                    child: Container(
                      alignment: Alignment.center,
                      child: Text(
                        'Settings',
                        style: TextStyle(color: Colors.white, fontSize: 28),
                      ).tr(),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.edit),
                    title: Text('editprofile').tr(),
                    onTap: () =>
                        {Navigator.of(context).pushNamed('/edit_profile')},
                  ),
                  Divider(
                    thickness: 0.2,
                  ),
                  ListTile(
                    leading: Stack(
                      alignment: Alignment.topRight,
                      children: [
                        const Icon(Icons.person_add_sharp, size: 24),
                        Consumer<RedDotNotifier>(
                          builder: (context, notifier, child) {
                            return notifier.hasFriendRequest
                                ? Positioned(
                                    right: 0, // 红点位置
                                    top: 0,
                                    child: Container(
                                      width: 8, // 红点宽度
                                      height: 8, // 红点高度
                                      decoration: BoxDecoration(
                                        color: Colors.red, // 红点颜色
                                        shape: BoxShape.circle, // 红点形状
                                      ),
                                    ),
                                  )
                                : SizedBox(); // 没有红点时为空
                          },
                        ),
                      ],
                    ),
                    title: Text('FriendRequest').tr(),
                    onTap: () async {
                      final result = await Navigator.of(context)
                          .pushNamed('/friend_request');
                      if (result != null && result is bool && result) {
                        setState(() {});
                      }
                    },
                  ),
                  Divider(
                    thickness: 0.2,
                  ),
                  (user["auth_methods"].contains("viajuntos"))
                      ? ListTile(
                          leading: const Icon(Icons.verified_user),
                          title: Text('Changepassword').tr(),
                          onTap: () => {
                            Navigator.of(context).pushNamed('/change_password')
                          },
                        )
                      : ListTile(
                          leading: const Icon(Icons.verified_user),
                          title: Text('Changepassword').tr(),
                          onTap: () => {
                            showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                        title: Text('Change password').tr(),
                                        content: Text('notchangepassword').tr(),
                                        actions: [
                                          TextButton(
                                            child: Text('Ok').tr(),
                                            onPressed: () =>
                                                Navigator.pop(context, true),
                                          ),
                                        ]))
                          },
                        ),
                  Divider(
                    thickness: 0.2,
                  ),
                  ListTile(
                    leading: const Icon(Icons.language),
                    title: Text('Languages').tr(),
                    onTap: () =>
                        {Navigator.of(context).pushNamed('/languages')},
                  ),
                  Divider(
                    thickness: 0.2,
                  ),
                  ListTile(
                      leading: const Icon(Icons.delete),
                      title: Text('DeleteAccount').tr(),
                      onTap: () => showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                                  title: Text('DeleteAccount').tr(),
                                  content: Text('SureDeleteAccount').tr(),
                                  actions: [
                                    TextButton(
                                      child: Text('Cancel').tr(),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                    TextButton(
                                        child: Text('Yes').tr(),
                                        onPressed: () {
                                          DeleteUser();
                                          // final response = await APICalls().deleteItem(
                                          //     "/v1/users/:0/delete",
                                          //     [APICalls().getCurrentUser()]);
                                          // if(response.statusCode != 400)
                                          // APICalls().logOut();
                                        })
                                  ]))),
                  Divider(
                    thickness: 0.2,
                  ),
                  ListTile(
                    leading: const Icon(Icons.exit_to_app),
                    title: Text('Logout').tr(),
                    onTap: () => {
                      showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                                  title: Text('Logout').tr(),
                                  content: Text('sureout').tr(),
                                  actions: [
                                    TextButton(
                                      child: Text('Cancel').tr(),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                    TextButton(
                                        child: Text('Yes').tr(),
                                        onPressed: () => APICalls().logOut())
                                  ]))
                    },
                  ),
                ],
              ),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        });
  }

  void DeleteUser() async {
    final response = await APICalls()
        .deleteItem("/v1/users/:0/delete", [APICalls().getCurrentUser()]);
    print(response.statusCode + json.decode(response.body)['error_message']);
    if (response.statusCode == 200) APICalls().logOut();
  }
}
