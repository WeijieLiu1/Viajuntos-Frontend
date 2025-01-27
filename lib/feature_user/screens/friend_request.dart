import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:viajuntos/feature_navigation/screens/profile.dart';
import 'package:viajuntos/utils/api_controller.dart';
import 'package:viajuntos/utils/default_image.dart';
import 'package:viajuntos/utils/friend_request_notifier.dart';

class FriendRequest extends StatefulWidget {
  const FriendRequest({Key? key}) : super(key: key);

  @override
  State<FriendRequest> createState() => _FriendRequestState();
}

class _FriendRequestState extends State<FriendRequest> {
  var friendRequestList = APICalls().friendRequests;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('FriendRequests',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.surface, fontSize: 16))
            .tr(),
        backgroundColor: Theme.of(context).colorScheme.background,
        leading: IconButton(
          iconSize: 24,
          color: Theme.of(context).colorScheme.onSurface,
          icon: const Icon(Icons.arrow_back_ios_new_sharp),
          onPressed: () {
            Provider.of<RedDotNotifier>(context, listen: false)
                .updateFriendRequests(friendRequestList);
            Navigator.pop(context, true);
          },
        ),
      ),
      body: Container(
        child: ListView.builder(
          reverse: true,
          itemCount: friendRequestList.length,
          shrinkWrap: true,
          physics: AlwaysScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            var request = friendRequestList[index];
            return Card(
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                borderRadius: BorderRadius.circular(5),
                onTap: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfileScreen(
                        id: friendRequestList[index]["invitee"].toString(),
                      ),
                    ),
                  );
                },
                child: Ink(
                  height: 80,
                  color: Theme.of(context).colorScheme.onSecondary,
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // 左侧头像和用户名
                      Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: DefaultImage(
                          imageUrl: request["image_url"].toString(),
                          placeholderPath: "assets/noProfileImage.png",
                          width: 40,
                          height: 40,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          request["username"].toString(),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onBackground,
                            fontSize: 20,
                          ),
                        ),
                      ),

                      // 右侧图标按钮或状态
                      if (request["accepted"] == null) // 显示勾和叉
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.check, color: Colors.green),
                              onPressed: () => _handleAcceptOrReject(
                                context,
                                index,
                                isAccepted: true,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.close, color: Colors.red),
                              onPressed: () => _handleAcceptOrReject(
                                context,
                                index,
                                isAccepted: false,
                              ),
                            ),
                          ],
                        ),
                      if (request["accepted"] == true) // 已接受
                        Text(
                          '✔ Accepted',
                          style: TextStyle(color: Colors.green),
                        ).tr(),
                      if (request["accepted"] == false) // 已拒绝
                        Text(
                          '✖ Rejected',
                          style: TextStyle(color: Colors.red),
                        ).tr(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _handleAcceptOrReject(BuildContext context, int index,
      {required bool isAccepted}) async {
    String action = isAccepted ? 'accept' : 'reject';
    bool? confirm = await _showConfirmDialog(context, action);

    if (confirm == true) {
      // 调用 API 更新状态
      var resp = await APICalls().postItem('v2/users/add_friend_response', [],
          {"id": friendRequestList[index]["invitee"], "res": isAccepted});
      var aux = await APICalls().getItem('v2/users/get_friend_request', []);
      APICalls().friendRequests = json.decode(aux.body);
      // 更新界面状态
      setState(() {
        friendRequestList = APICalls().friendRequests;
      });
    }
  }

  Future<bool?> _showConfirmDialog(BuildContext context, String action) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm').tr(),
        content: Text('Are you sure you want to $action this request?').tr(),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel').tr(),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Yes').tr(),
          ),
        ],
      ),
    );
  }
}
