import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:viajuntos/feature_chat/models/chat_model.dart';
import 'package:viajuntos/feature_chat/models/message_model.dart';
import 'package:viajuntos/feature_chat/widgets/chat_body.dart';
import 'package:viajuntos/feature_user/models/user_model.dart';
import 'package:viajuntos/utils/api_controller.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:viajuntos/utils/globals.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String chatName;
  final String chatImageUrl;

  const ChatScreen(
      {Key? key,
      required this.chatId,
      required this.chatName,
      required this.chatImageUrl})
      : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late IO.Socket _socket;
  final APICalls api = APICalls();
  final TextEditingController messageTextController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Message> chatMessages = [];
  Map<String, User> mapMembers = {};

  @override
  void initState() {
    super.initState();
    _initializeSocket();
    _initializeChatData();
  }

  @override
  void dispose() {
    _socket.disconnect();
    _scrollController.dispose();
    messageTextController.dispose();
    super.dispose();
  }

  void _initializeSocket() {
    _socket = IO.io(
      baseLocalUrl,
      IO.OptionBuilder().setTransports(['websocket']).build(),
    );

    _socket.onConnect((_) {
      _socket.emit('join_room', {
        'username': api.getCurrentUser(),
        'room': widget.chatId,
      });
    });

    _socket.on('ChatMessage', (data) {
      setState(() {
        chatMessages.insert(0, Message.fromJson(jsonDecode(data)));
      });
      _scrollToBottom();
    });

    _socket.onDisconnect((_) {
      print('Disconnected from server');
    });

    _socket.connect();
  }

  void _initializeChatData() async {
    // Fetch messages
    final response =
        await api.getItemNullable("/v1/chat/Message/:0", [widget.chatId]);
    List<Message> msgs = [];
    if (response != null) {
      msgs = List<Message>.from(
        json.decode(response.body).map((data) => Message.fromJson(data)),
      );
    }
    setState(() {
      chatMessages = msgs;
    });

    // Fetch members
    final membersResponse =
        await api.getItemNullable("/v1/chat/all_members/:0", [widget.chatId]);
    List<User> members = [];
    if (response != null) {
      members = List<User>.from(
        json.decode(membersResponse.body).map((user) => User.fromJson(user)),
      );
    }
    setState(() {
      for (var member in members) {
        mapMembers[member.id.toString()] = member;
      }
    });
  }

  void _sendMessage(String messageText) {
    if (messageText.isEmpty) return;

    _socket.emit('ChatMessage', {
      'chat_id': widget.chatId,
      'text': messageText,
      'sender_id': api.getCurrentUser(),
    });
    messageTextController.clear();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.minScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage(widget.chatImageUrl),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 10),
            Text(widget.chatName),
          ],
        ),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => {
                  Navigator.pop(context),
                  _socket.connect(),
                }),
      ),
      body: Column(
        children: [
          Expanded(
            child: ChatBody(
              chatMessages: chatMessages,
              mapMembers: mapMembers,
              scrollController: _scrollController,
            ),
          ),
          _buildMessageInputField(),
        ],
      ),
    );
  }

  Widget _buildMessageInputField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: messageTextController,
              decoration: InputDecoration(
                hintText: 'Write a message...'.tr(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () => _sendMessage(messageTextController.text),
          ),
        ],
      ),
    );
  }
}
