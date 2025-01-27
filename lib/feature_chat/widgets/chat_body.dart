import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:viajuntos/feature_chat/models/chat_model.dart';
import 'package:viajuntos/feature_chat/models/message_model.dart';
import 'package:viajuntos/feature_user/models/user_model.dart';

class ChatBody extends StatelessWidget {
  final List<Message> chatMessages;
  final Map<String, User> mapMembers;
  final ScrollController scrollController;

  const ChatBody({
    Key? key,
    required this.chatMessages,
    required this.mapMembers,
    required this.scrollController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      reverse: true,
      controller: scrollController,
      padding: const EdgeInsets.only(top: 10, bottom: 70),
      itemCount: chatMessages.length,
      itemBuilder: (context, index) {
        final message = chatMessages[index];
        final isMine = message.sender_id == mapMembers[message.sender_id]?.id;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Align(
            alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              decoration: BoxDecoration(
                color: isMine ? HexColor('80ED99') : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(10),
              child: Text(message.text),
            ),
          ),
        );
      },
    );
  }
}
