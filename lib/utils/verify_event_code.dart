// ignore_for_file: prefer_const_constructors

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:viajuntos/utils/api_controller.dart';

import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:viajuntos/utils/globals.dart';

class VerifyEventCode extends StatefulWidget {
  final String idParticipant;
  final String idEvent;
  const VerifyEventCode(
      {Key? key, required this.idParticipant, required this.idEvent})
      : super(key: key);

  @override
  State<VerifyEventCode> createState() => _VerifyEventCodeState();
}

class _VerifyEventCodeState extends State<VerifyEventCode> {
  String code = "";
  late IO.Socket _socket;
  @override
  dispose() {
    _socket.disconnect();
    super.dispose();
  }

  void OnVerificationDone(String data) {
    Text titleText = Text("ErrorVerificationTitle").tr();
    Text contentText = Text("ErrorVerificationContent").tr();
    switch (data) {
      case "User is not participant of this event":
        titleText = Text("UserNotParticipantTitle").tr();
        contentText = Text("UserNotParticipantContent").tr();
        break;
      case "User already verified":
        titleText = Text("UserAlreadyVerifiedTitle").tr();
        contentText = Text("UserAlreadyVerifiedContent").tr();
        break;
      case "Successful verification":
        titleText = Text("SuccessfulVerificationTitle").tr();
        contentText = Text("SuccessfulVerificationContent").tr();
        break;
      case "Incorrect code":
        titleText = Text("IncorrectCodeTitle").tr();
        contentText = Text("IncorrectCodeContent").tr();
        break;
    }

    showDialog(
        context: context,
        builder: (context) =>
            AlertDialog(title: titleText, content: contentText, actions: [
              TextButton(
                child: Text('Ok').tr(),
                onPressed: () {
                  // _socket.emit('ConfirmVerification',
                  //     [widget.idParticipant, widget.idEvent]);
                  Navigator.pop(context);
                },
              ),
            ]));
  }

  _connectSocket() {
    _socket.onConnect((data) => {});
    _socket.onConnectError((data) => print('Socket.io Connect Error: $data'));
    _socket.onDisconnect((data) => print('Socket.io server disconnected'));
    _socket.connect();
    _socket.on('VerificationDone', (data) {
      print("onVerificationDone: " + data);
      OnVerificationDone(data.toString());
      _socket.disconnect();
    });
    _socket.emit('be_scanning', {
      'idEvent': widget.idEvent.toString(),
      'code': code,
    });
  }

  @override
  void initState() {
    super.initState();

    _socket = IO.io(
      baseUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );
    _connectSocket();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future:
            APICalls().getItem('/v3/events/:0/verify_code', [widget.idEvent]),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            var data = json.decode(snapshot.data.body);
            code = data["verify_code"];
            return Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                margin: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    Text('LetCreatorOfEventScanThisCode',
                            style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.secondary))
                        .tr(),
                    const SizedBox(height: 20),
                    QrImageView(
                      data: code,
                      version: QrVersions.auto,
                      size: MediaQuery.of(context).size.height / 4.5,
                    ),
                  ],
                ));
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        });
  }
}
