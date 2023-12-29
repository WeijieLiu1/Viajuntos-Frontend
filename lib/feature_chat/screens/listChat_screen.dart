import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart';
import 'package:viajuntos/feature_chat/models/chat_model.dart';
import 'package:viajuntos/feature_chat/models/message_model.dart';
import 'package:viajuntos/feature_chat/screens/chat_screen.dart';
import 'package:viajuntos/feature_chat/services/chat_service.dart';
import 'package:viajuntos/feature_chat/widgets/chat_widget.dart';
import 'package:viajuntos/feature_event/screens/edit_event_screen.dart';
import 'package:viajuntos/feature_user/services/login_signUp.dart';
import 'package:viajuntos/utils/api_controller.dart';
import 'package:viajuntos/feature_user/services/externalService.dart';

class ListChatScreen extends StatefulWidget {
  const ListChatScreen({Key? key}) : super(key: key);
  @override
  State<ListChatScreen> createState() => _ListChatScreen();
}

class _ListChatScreen extends State<ListChatScreen> {
  final chatAPI cAPI = chatAPI();
  final ExternServicePhoto espApi = ExternServicePhoto();
  final APICalls api = APICalls();
  Map user = {};
  void getListChat() {
    cAPI.getListChat(APICalls().getCurrentUser());
  }

  void setListChat() {
    getListChat();
  }

  @override
  void initState() {
    //initUser();
    // TODO: implement initState
    setListChat();
    //getEventName().then((value) => print("value: " + value));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        //future: api.getItem('/v2/events/:0', [eventId]),

        // {
        //   "chat_id": "a083cdd5-d7b2-4fc0-ad4a-1fe91682da0d",
        //   "date_creation": "Sat, 11 Nov 2023 20:03:05 GMT",
        //   "date_end": "Mon, 11 Nov 2024 17:34:00 GMT",
        //   "date_started": "Mon, 11 Dec 2023 17:33:00 GMT",
        //   "description": "event desc",
        //   "event_image_uri": "https://i0.hdslb.com/bfs/face/ad5d9c72aff660d3eca3d1b114331fdacd33c5f3.jpg",
        //   "id": "2240ec1d-7aea-4d19-8e1a-8ce7da2e13f2",
        //   "latitude": 41.0,
        //   "longitud": 3.0,
        //   "max_participants": 10,
        //   "name": "event1",
        //   "user_creator": "38d1837b-c4ea-4e0a-98e5-ba09a4ee69bd"
        // }

        future: cAPI.getListChat(APICalls().getCurrentUser()),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.data.body
                .contains('"error_message": "The user has no chats"')) {
              return Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 80,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 20),
                      Text(
                        'NoChatYet'.tr(),
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'StartConversation'.tr(),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            } else {
              var chats = json.decode(snapshot.data.body);
              List<Chat> listChats = chats
                  .map((chat) => Chat.fromJson(chat))
                  .toList()
                  .cast<Chat>();
              return Scaffold(
                body: Container(
                    child: Stack(children: [
                  Container(
                      child: ListView.builder(
                          reverse: true,
                          itemCount: listChats.length,
                          shrinkWrap: true,
                          // padding: EdgeInsets.only(top: 10),
                          physics: AlwaysScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            //String uriPhoro = await espApi.getAPhoto(listChats[index].participant_id);
                            return FutureBuilder(
                                future: api.getItem(
                                    '/v1/chat/chat_image_url/:0',
                                    [listChats[index].id.toString()]),
                                builder: (BuildContext context,
                                    AsyncSnapshot snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.done) {
                                    var chat_image_url =
                                        json.decode(snapshot.data.body);
                                    print(chat_image_url);
                                    return Card(
                                        clipBehavior: Clip.antiAlias,
                                        child: InkWell(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            onTap: () async {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          ChatScreen(
                                                              chat: listChats[
                                                                  index],
                                                              chat_image_url:
                                                                  chat_image_url[
                                                                      "image_url"])));
                                            },
                                            child: Ink(
                                              height: 80,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSecondary,
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              padding: EdgeInsets.only(
                                                  left: 16, top: 10),
                                              child: Row(
                                                children: [
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        right: 8),
                                                    child: (chat_image_url !=
                                                                null &&
                                                            chat_image_url[
                                                                    "image_url"] !=
                                                                null &&
                                                            chat_image_url[
                                                                    "image_url"] !=
                                                                "")
                                                        ? Image.network(
                                                            chat_image_url[
                                                                "image_url"], // 您的图像路径
                                                            width: 40,
                                                            height: 40,
                                                            // 其他图像属性
                                                          )
                                                        : Image.asset(
                                                            'assets/noProfileImage.png', // 占位图像路径
                                                            width: 40,
                                                            height: 40,
                                                            // 其他图像属性
                                                          ),
                                                  ),
                                                  Text(
                                                    listChats[index]
                                                        .name
                                                        .toString(),
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
                                            )));
                                  } else {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  }
                                });
                          }))
                ])),
              );
            }
          } else {
            return Center(
                child: SizedBox(
              child: CircularProgressIndicator(),
              height: 30.0,
              width: 30.0,
            ));
          }
        });
  }
}
