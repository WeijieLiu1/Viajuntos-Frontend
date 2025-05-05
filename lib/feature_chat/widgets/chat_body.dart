import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:viajuntos/feature_chat/models/message_model.dart';
import 'package:viajuntos/feature_navigation/screens/profile.dart';
import 'package:viajuntos/feature_user/models/user_model.dart';
import 'package:viajuntos/utils/api_controller.dart';

class ChatBody extends StatefulWidget {
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
  _ChatBodyState createState() => _ChatBodyState();
}

class _ChatBodyState extends State<ChatBody> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      reverse: false,
      controller: widget.scrollController,
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      itemCount: widget.chatMessages.length,
      itemBuilder: (context, index) {
        final message = widget.chatMessages[index];
        final isMine = message.sender_id == APICalls().getCurrentUser();
        final userImageUrl = isMine
            ? widget.mapMembers[APICalls().getCurrentUser()]?.image_url ?? ""
            : widget.mapMembers[message.sender_id]?.image_url ?? "";

        double paddingSelf = 30;
        double paddingOther = 10;
        return Container(
            //icon+message
            alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
            padding: EdgeInsets.only(
                left: isMine ? paddingSelf : paddingOther,
                right: isMine ? paddingOther : paddingSelf,
                top: 10,
                bottom: 10),
            child: Align(
              alignment: (isMine ? Alignment.topRight : Alignment.topLeft),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment:
                    isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
                children: [
                  if (!isMine)
                    _buildUserAvatar(userImageUrl, message.sender_id), // 对方的头像
                  SizedBox(width: 10),
                  Flexible(
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: isMine
                                ? HexColor('80ED99')
                                : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.all(10),
                          child: Text(message.text),
                        ),
                        Positioned(
                          top: 10, // 小箭头的垂直位置，使其位于气泡框中
                          left: isMine ? null : -8, // 对方箭头（左边）
                          right: isMine ? -8 : null, // 自己的箭头（右边）
                          child: CustomPaint(
                            size: Size(16, 16), // 三角形大小
                            painter: TrianglePainter(isMine: isMine),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 10),
                  if (isMine)
                    _buildUserAvatar(userImageUrl, message.sender_id), // 自己的头像
                ],
              ),
            ));
      },
    );
  }

  Widget _buildUserAvatar(String imageUrl, String sender_id) {
    return InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ProfileScreen(id: sender_id)));
        },
        child: SizedBox(
          width: 36,
          height: 36,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: imageUrl.isEmpty
                ? Image.asset('assets/noProfileImage.png')
                : Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Image.asset('assets/noProfileImage.png'),
                  ),
          ),
        ));
  }

  @override
  void didUpdateWidget(covariant ChatBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.chatMessages != oldWidget.chatMessages) {
      setState(() {});
    }
  }
}

class TrianglePainter extends CustomPainter {
  final bool isMine;

  TrianglePainter({required this.isMine});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isMine ? HexColor('80ED99') : Colors.grey.shade200
      ..style = PaintingStyle.fill;

    final path = Path();
    if (!isMine) {
      // 三角形指向左
      path.moveTo(0, size.height / 2);
      path.lineTo(size.width, -size.height / 2);
      path.lineTo(size.width, size.height * 1.5);
    } else {
      // 三角形指向右
      path.moveTo(0, -size.height / 2);
      path.lineTo(size.width, size.height / 2);
      path.lineTo(0, size.height * 1.5);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
