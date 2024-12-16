import 'dart:async';
import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:viajuntos/feature_chat/models/chat_model.dart';
import 'package:viajuntos/feature_chat/models/message_model.dart';

import 'package:viajuntos/feature_chat/widgets/chat_body.dart';
import 'package:viajuntos/feature_chat/services/chat_service.dart';
import 'package:viajuntos/utils/api_controller.dart';
import 'package:viajuntos/feature_user/services/externalService.dart';
import 'package:viajuntos/feature_user/models/user_model.dart';
import '../../utils/globals.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatScreen extends StatefulWidget {
  final Chat chat;
  final String chat_image_url;
  const ChatScreen({Key? key, required this.chat, required this.chat_image_url})
      : super(key: key);
  @override
  State<ChatScreen> createState() => _ChatScreen();
}

class _ChatScreen extends State<ChatScreen> {
  late IO.Socket _socket;
  final chatAPI cAPI = chatAPI();
  APICalls api = APICalls();
  final TextEditingController messageTextController =
      TextEditingController(text: '');
  String chatName = "";
  String linkImageEvent = "";
  String otherId = "";
  Map<String, User> mapMembers = {};
  late Future<List<Message>> chatMessageFuture;
  String urlPhotoMine = "";
  String urlPhotoOther = "";
  final ExternServicePhoto es = ExternServicePhoto();
  late ScrollController _scrollController;
  List<Message> chatMessage = [];
  Map<String, dynamic> userImages = {};

  void initializeMembers(String chatId) async {
    await InitMembers(chatId);
  }

  Future<void> InitMembers(String chatId) async {
    final response = await api.getItem("/v1/chat/all_members/:0", [chatId]);
    var auxMembers = json.decode(response.body);
    List<User> listMembers =
        auxMembers.map((user) => User.fromJson(user)).toList().cast<User>();
    listMembers.forEach((user) {
      mapMembers[user.id.toString()] = user;
    });
  }

  void receiveMessage(message) {
    if (mounted) {
      Message newMessage = Message.fromJson(message);

      setState(() {
        chatMessage.insert(0, newMessage);
        chatMessageFuture = Future.value(chatMessage.reversed.toList());
      });

      // Scroll to the bottom after adding the new message
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
      print("message: " + message.toString());
    }
  }

  Future<String> getAllMessages(String idEventCreator) async {
    final response = await api.getItem("/v2/users/:0", [idEventCreator]);
    String username = json.decode(response.body)["username"];

    print(json.decode(response.body));
    return username;
  }

  Future<List<Message>> initAllMessages() async {
    final response =
        await api.getItem("/v1/chat/Message/:0", [widget.chat.id.toString()]);
    var msg = json.decode(response.body);
    List<Message> chatMessage =
        List<Message>.from(msg.map((data) => Message.fromJson(data)));
    return chatMessage;
  }

  // Future<dynamic> initAllMessages() async {
  //   final response =
  //       await api.getItem("/v1/chat/Message/:0", [widget.chat.id.toString()]);
  //   return response;
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
      Map<String, dynamic> jsonMap = jsonDecode(data);
      print("message: " + data.toString());
      receiveMessage(jsonMap);
    });
    _socket.emit('join_room', {
      'username': api.getCurrentUser().toString(),
      'room': widget.chat.id.toString()
    });
  }

  @override
  void initState() {
    super.initState();
    chatName = widget.chat.name!;
    linkImageEvent = widget.chat_image_url;
    initializeMembers(widget.chat.id.toString());
    chatMessageFuture = initAllMessages();

    _socket = IO.io(
      baseLocalUrl,
      IO.OptionBuilder().setTransports(['websocket'])
          // .disableAutoConnect()
          .build(),
    );
    _connectSocket();
    _scrollController = ScrollController();
    //getEventName().then((value) => print("value: " + value));
  }

  @override
  Widget build(BuildContext context) {
    //print("eventname:" + eventsName);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        flexibleSpace: SafeArea(
          child: Container(
            padding: EdgeInsets.only(right: 16),
            child: Row(
              children: <Widget>[
                IconButton(
                    iconSize: 24,
                    color: Theme.of(context).colorScheme.onSurface,
                    icon: const Icon(Icons.arrow_back_ios_new_sharp),
                    onPressed: () {
                      _socket.disconnect();
                      Navigator.pop(context);
                    }),
                SizedBox(
                  width: 2,
                ),
                ClipOval(
                  child: SizedBox(
                    width: 36,
                    height: 36,
                    child: ClipRRect(
                        child: FittedBox(
                            child: (widget.chat_image_url.isEmpty)
                                ? Image.asset('assets/noProfileImage.png')
                                : Image.network(widget.chat_image_url),
                            fit: BoxFit.fitHeight),
                        borderRadius: BorderRadius.circular(100)),
                  ),
                ),
                SizedBox(
                  width: 12,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        chatName,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onBackground,
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ),
                      SizedBox(
                        height: 6,
                      ),
                      Text(
                        widget.chat.name!,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onBackground,
                            fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body:
          // ChatBody(
          //   chat: widget.chat,
          //   chatMessage: chatMessage,
          // )
          Container(
              child: Stack(
        children: [
          FutureBuilder(
              //future: api.getItem('/v3/events/:0', [eventId]),
              future: chatMessageFuture,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  }

                  chatMessage = snapshot.data ?? [];
                  chatMessage = chatMessage.reversed.toList();
                  return Container(
                      child: ChatBody(
                    chat: widget.chat,
                    chatMessage: chatMessage,
                    mapMembers: mapMembers,
                  ));
                } else {
                  return Center(
                      child: SizedBox(
                    child: CircularProgressIndicator(),
                    height: 30.0,
                    width: 30.0,
                  ));
                }
              }),
          // Positioned(
          //   top: 0,
          //   left: 0,
          //   right: 0,
          //   child: Container(
          //     alignment: Alignment.center,
          //     padding: EdgeInsets.symmetric(vertical: 5),
          //     child: Text(
          //       'NoMoreMessages',
          //       style: TextStyle(
          //         color: Colors.grey,
          //         fontStyle: FontStyle.italic,
          //       ),
          //     ).tr(),
          //   ),
          // ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              padding: EdgeInsets.only(left: 10, bottom: 10, top: 10),
              height: 60,
              width: double.infinity,
              color: Colors.white,
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: 15,
                  ),
                  Expanded(
                    child: TextFormField(
                      controller: messageTextController,
                      decoration: InputDecoration(
                          hintText: "Writemessag".tr(),
                          hintStyle: TextStyle(color: Colors.black54),
                          border: InputBorder.none),
                    ),
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  FloatingActionButton(
                    onPressed: () {
                      if (messageTextController.text.isNotEmpty) {
                        _socket.emit('ChatMessage', {
                          'chat_id': widget.chat.id.toString(),
                          'text': messageTextController.text,
                          'sender_id': api.getCurrentUser(),
                        });
                        messageTextController.clear();
                      }
                    },
                    child: Icon(
                      Icons.send,
                      color: Theme.of(context).colorScheme.primary,
                      size: 18,
                    ),
                    backgroundColor: Colors.blue,
                    elevation: 0,
                  ),
                ],
              ),
            ),
          )
        ],
      )),
    );
  }
}
