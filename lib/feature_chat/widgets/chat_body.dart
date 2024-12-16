import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:viajuntos/feature_chat/models/chat_model.dart';
import 'package:viajuntos/feature_chat/models/message_model.dart';
import 'package:viajuntos/feature_user/models/user_model.dart';
import 'package:viajuntos/utils/api_controller.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:viajuntos/utils/globals.dart';

class ChatBody extends StatelessWidget {
  final Chat chat;
  final List<Message> chatMessage;
  final Map<String, User> mapMembers;
  ChatBody({
    Key? key,
    required this.chat,
    required this.chatMessage,
    required this.mapMembers,
  }) : super(key: key);

  late ScrollController _scrollController;
  APICalls api = APICalls();
  String urlPhotoOther = "";
  String urlPhotoMine = "";
  final TextEditingController messageTextController =
      TextEditingController(text: '');
  late IO.Socket _socket;
  late Future<List<Message>> chatMessageFuture;
  // Map<String, User> mapMembers = {};
  List<Message> auxChatMessage = [];
  // void receiveMessage(message) {
  //   if (mounted) {
  //     Message newMessage = Message.fromJson(message);

  //     setState(() {
  //       auxChatMessage.insert(0, newMessage);
  //       chatMessageFuture = Future.value(auxChatMessage.reversed.toList());
  //     });

  //     // Scroll to the bottom after adding the new message
  //     _scrollController.animateTo(
  //       _scrollController.position.maxScrollExtent,
  //       duration: Duration(milliseconds: 300),
  //       curve: Curves.easeOut,
  //     );
  //     print("message: " + message.toString());
  //   }
  // }

  _connectSocket() {
    _socket.onConnect((data) => {
          print('Socket.io Connection established'),
          _socket.emit('msg', "msgtest"),
          print('Socket.io Connection established2'),
        });
    _socket.onConnectError((data) => print('Socket.io Connect Error: $data'));
    _socket.onDisconnect((data) => print('Socket.io server disconnected'));
    _socket.on('msg', (data) => print(data));
    _socket.emit('msg', 'msgtest');
    _socket.connect();
    _socket.on('broadcast_message', (data) {
      print("message: " + data.toString());
    });
    _socket.on('ChatMessage', (data) {
      print("message: " + data.toString());
      // receiveMessage(jsonMap);
    });
    _socket.emit('join_room', {
      'username': api.getCurrentUser().toString(),
      'room': chat.id.toString()
    });
  }

  Future<List<Message>> initAllMessages() async {
    final response =
        await api.getItem("/v1/chat/Message/:0", [chat.id.toString()]);
    var msg = json.decode(response.body);
    List<Message> chatMessage =
        List<Message>.from(msg.map((data) => Message.fromJson(data)));
    return chatMessage;
  }

  void InitMembers(String chatId) async {
    final response = await api.getItem("/v1/chat/all_members/:0", [chatId]);
    var auxMembers = json.decode(response.body);
    List<User> listMembers =
        auxMembers.map((user) => User.fromJson(user)).toList().cast<User>();
    listMembers.forEach((user) {
      mapMembers[user.id.toString()] = user;
    });
  }

  // @override
  // void initState() {
  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    print("chatMessage" + auxChatMessage.length.toString());
    auxChatMessage = chatMessage;
    _socket = IO.io(
      baseLocalUrl,
      IO.OptionBuilder().setTransports(['websocket'])
          // .disableAutoConnect()
          .build(),
    );
    // InitMembers(widget.chat.id.toString());
    chatMessageFuture = initAllMessages();
    _scrollController = ScrollController();
    _connectSocket();
    return FutureBuilder(
      future: api.getItem("/v1/chat/all_members/:0", [chat.id.toString()]),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          var auxMembers = json.decode(snapshot.data.body);
          List<User> listMembers = auxMembers
              .map((user) => User.fromJson(user))
              .toList()
              .cast<User>();
          listMembers.forEach((user) {
            mapMembers[user.id.toString()] = user;
          });
          // var id = widget.chatMessage[6].sender_id;
          // var a = mapMembers[widget.chatMessage[6].sender_id];
          // var b = mapMembers[widget.chatMessage[6].sender_id]!.image_url;
          return ListView.builder(
            reverse: true,
            itemCount: auxChatMessage.length,
            shrinkWrap: true,
            padding: EdgeInsets.only(top: 10, bottom: 70),
            physics: AlwaysScrollableScrollPhysics(),
            controller: _scrollController,
            itemBuilder: (context, index) {
              //for each message
              double paddingSelf = 30;
              double paddingOther = 10;
              //hardcode
              bool messageMine =
                  auxChatMessage[index].sender_id == api.getCurrentUser();
              print("messageMine: " + auxChatMessage.length.toString());
              return Container(
                //icon+message
                alignment:
                    messageMine ? Alignment.centerRight : Alignment.centerLeft,
                padding: EdgeInsets.only(
                    left: messageMine ? paddingSelf : paddingOther,
                    right: messageMine ? paddingOther : paddingSelf,
                    top: 10,
                    bottom: 10),
                child: Align(
                    alignment:
                        (messageMine ? Alignment.topRight : Alignment.topLeft),
                    child: Row(
                      mainAxisAlignment: messageMine
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      children: <Widget>[
                        if (!messageMine)
                          SizedBox(
                            width: 36,
                            height: 36,
                            child: ClipRRect(
                                child: FittedBox(
                                    child: (mapMembers[chatMessage[index]
                                                    .sender_id]!
                                                .image_url
                                                .toString() ==
                                            "")
                                        ? Image.asset(
                                            'assets/noProfileImage.png')
                                        : Image.network(mapMembers[
                                                chatMessage[index].sender_id]!
                                            .image_url
                                            .toString()),
                                    fit: BoxFit.fitHeight),
                                borderRadius: BorderRadius.circular(100)),
                          ),
                        Flexible(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                  topLeft: messageMine
                                      ? Radius.circular(20)
                                      : Radius.circular(0),
                                  topRight: messageMine
                                      ? Radius.circular(0)
                                      : Radius.circular(20),
                                  bottomLeft: Radius.circular(20),
                                  bottomRight: Radius.circular(
                                      20)), //BorderRadius.circular(20),
                              color: (messageMine
                                  //?Theme.of(context).colorScheme.secondary:Theme.of(context).colorScheme.onSecondary
                                  ? HexColor('80ED99')
                                  : Colors.grey.shade200),
                            ),
                            padding: EdgeInsets.all(12),
                            child: Text(
                              auxChatMessage[index].text,
                              style: TextStyle(fontSize: 15),
                            ),
                          ),
                        ),
                        if (messageMine)
                          SizedBox(
                            width: 36,
                            height: 36,
                            child: ClipRRect(
                                child: FittedBox(
                                    child: (urlPhotoMine == "")
                                        ? Image.asset(
                                            'assets/noProfileImage.png')
                                        : Image.network(urlPhotoMine),
                                    fit: BoxFit.fitHeight),
                                borderRadius: BorderRadius.circular(100)),
                          ),
                      ],
                    )),
              );
            },
          );
        } else
          return CircularProgressIndicator();
      },
    );
    // return ListView.builder(
    //   reverse: true,
    //   itemCount: auxChatMessage.length,
    //   shrinkWrap: true,
    //   padding: EdgeInsets.only(top: 10, bottom: 70),
    //   physics: AlwaysScrollableScrollPhysics(),
    //   controller: _scrollController,
    //   itemBuilder: (context, index) {
    //     //for each message
    //     double paddingSelf = 30;
    //     double paddingOther = 10;
    //     //hardcode
    //     bool messageMine =
    //         auxChatMessage[index].sender_id == api.getCurrentUser();
    //     print("messageMine: " + auxChatMessage.length.toString());
    //     return Container(
    //       //icon+message
    //       alignment: messageMine ? Alignment.centerRight : Alignment.centerLeft,
    //       padding: EdgeInsets.only(
    //           left: messageMine ? paddingSelf : paddingOther,
    //           right: messageMine ? paddingOther : paddingSelf,
    //           top: 10,
    //           bottom: 10),
    //       child: Align(
    //           alignment: (messageMine ? Alignment.topRight : Alignment.topLeft),
    //           child: Row(
    //             mainAxisAlignment: messageMine
    //                 ? MainAxisAlignment.end
    //                 : MainAxisAlignment.start,
    //             children: <Widget>[
    //               if (!messageMine)
    //                 SizedBox(
    //                   width: 36,
    //                   height: 36,
    //                   child: ClipRRect(
    //                       child: FittedBox(
    //                           child: (mapMembers[widget
    //                                           .chatMessage[index].sender_id]!
    //                                       .image_url
    //                                       .toString() ==
    //                                   "")
    //                               ? Image.asset('assets/noProfileImage.png')
    //                               : Image.network(mapMembers[
    //                                       widget.chatMessage[index].sender_id]!
    //                                   .image_url
    //                                   .toString()),
    //                           fit: BoxFit.fitHeight),
    //                       borderRadius: BorderRadius.circular(100)),
    //                 ),
    //               Flexible(
    //                 child: Container(
    //                   decoration: BoxDecoration(
    //                     borderRadius: BorderRadius.only(
    //                         topLeft: messageMine
    //                             ? Radius.circular(20)
    //                             : Radius.circular(0),
    //                         topRight: messageMine
    //                             ? Radius.circular(0)
    //                             : Radius.circular(20),
    //                         bottomLeft: Radius.circular(20),
    //                         bottomRight: Radius.circular(
    //                             20)), //BorderRadius.circular(20),
    //                     color: (messageMine
    //                         //?Theme.of(context).colorScheme.secondary:Theme.of(context).colorScheme.onSecondary
    //                         ? HexColor('80ED99')
    //                         : Colors.grey.shade200),
    //                   ),
    //                   padding: EdgeInsets.all(12),
    //                   child: Text(
    //                     auxChatMessage[index].text,
    //                     style: TextStyle(fontSize: 15),
    //                   ),
    //                 ),
    //               ),
    //               if (messageMine)
    //                 SizedBox(
    //                   width: 36,
    //                   height: 36,
    //                   child: ClipRRect(
    //                       child: FittedBox(
    //                           child: (urlPhotoMine == "")
    //                               ? Image.asset('assets/noProfileImage.png')
    //                               : Image.network(urlPhotoMine),
    //                           fit: BoxFit.fitHeight),
    //                       borderRadius: BorderRadius.circular(100)),
    //                 ),
    //             ],
    //           )),
    //     );
    //   },
    // );
  }
}
