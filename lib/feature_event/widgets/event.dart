// ignore_for_file: prefer_const_constructors

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_paypal_payment/flutter_paypal_payment.dart';
import 'package:http/http.dart';
import 'package:viajuntos/feature_event/models/event_model.dart';
import 'package:viajuntos/feature_event/widgets/event_map.dart';
import 'package:viajuntos/feature_event/widgets/image_card.dart';
import 'package:viajuntos/feature_navigation/screens/profile.dart';
import 'package:viajuntos/feature_user/services/externalService.dart';
import 'package:viajuntos/utils/api_controller.dart';
import 'dart:convert';
import 'package:skeletons/skeletons.dart';
import 'package:viajuntos/utils/globals.dart';
import 'package:viajuntos/utils/share.dart';

import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:viajuntos/utils/snackbar_helper.dart';

class Event extends StatefulWidget {
  final EventModel event;
  const Event({Key? key, required this.event}) : super(key: key);

  @override
  State<Event> createState() => _EventState();
}

class _EventState extends State<Event> {
  APICalls api = APICalls();
  final ExternServicePhoto es = ExternServicePhoto();
  bool found = false;
  bool paid = false;
  List attendesEvent = [];
  // late EventModel event;
  late IO.Socket _socket;
  String _scanResult = 'Unknown';
  @override
  void initState() {
    super.initState();
    checkTimeConflict();
    getPaymentStatus(widget.event.id.toString());
  }

  void showMyVerifyCode(String idParticipant) async {
    showVerifyCodeEvent(idParticipant, widget.event.id.toString(), context);
  }

  void LeaveEvent() async {
    final bodyData = {"user_id": api.getCurrentUser()};
    var response = await leaveEvent(widget.event.id.toString(), bodyData);

    if (response != null) {
      SnackBar snackBar;
      snackBar = SnackBar(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        content: Text('Youleft').tr(),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      setState(() {
        found = false;
      });
    }
  }

  // void PayEvent(EventModel event) async {
  //   var amount = event.amountevent.toString();
  //   Navigator.of(context).push(MaterialPageRoute(
  //     builder: (BuildContext context) => PaypalCheckoutView(
  //       sandboxMode: true,
  //       clientId:
  //           // "AYQPBYQ6U-hyIKBERgEN_qjO4fSIFvjljwKaYaCgU00NEKXB76Uxsba29zRPHp6AO1HBV7-VMFNyDhYt",
  //           "AXHMcwYupckK_UUb8KkxDQrRyHvGh0_Il9hyQa07GQ1DZnIQHYEYAr4XcK2Y2E2o-Xp5pwmQQio5vvRG",
  //       secretKey:
  //           // "EMfnOAW3h4UuOjrQJnnDBAf7s-ro7RLguWanGlXjYJxpF_OCH7-wZD4HKw45wIq1jXKkYlSMXUcsoSg_",
  //           "EEmXD8B5bghWYcTrY1PgZqPnhVy4kC-bCD6mhNb5DllTD_MZi3brp0ZDkqx0F57lKrBkFS5mbMqNwcnG",
  //       transactions: [
  //         {
  //           "amount": {
  //             "total": event.amountevent,
  //             "currency": "USD",
  //             "details": {
  //               "subtotal": event.amountevent,
  //               "shipping": '0',
  //               "shipping_discount": 0
  //             }
  //           },
  //           "description": "Viajuntos Fee Event",
  //           // "payment_options": {
  //           //   "allowed_payment_method":
  //           //       "INSTANT_FUNDING_SOURCE"
  //           // },
  //           "item_list": {
  //             "items": [
  //               {
  //                 "name": event.name.toString(),
  //                 "quantity": 1,
  //                 "price": event.amountevent,
  //                 "currency": "USD"
  //               }
  //             ],
  //           }
  //         }
  //       ],
  //       note: "Contact us for any questions on your order.",
  //       onSuccess: (Map params) async {
  //         print('onSuccess');
  //         print(params);
  //         Navigator.pop(context);
  //         final bodyData = {
  //           "event_id": event.id.toString(),
  //           "amount": amount,
  //           "payment_type": "Paypal",
  //           "payment_id": params["data"]["id"]
  //         };

  //         final response =
  //             await api.postItem('/v3/events/:0', ["add_payment"], bodyData);

  //         if (response == null) return;
  //         print(response.statusCode);
  //         setState(() {
  //           paid = true;
  //         });
  //       },
  //       onError: (error) {
  //         print('onError');
  //         Navigator.pop(context);
  //       },
  //       onCancel: () {
  //         print('cancelled:');
  //         Navigator.pop(context);
  //       },
  //     ),
  //   ));
  // }
  void PayEvent(EventModel event) async {
    var amount = event.amountevent.toString();
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
                title: Text("PaymentTitle").tr(),
                content: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: "${"PaymentContent".tr()} "), // 普通文本
                      TextSpan(
                        text: "$amount euros", // 需要加粗的部分
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    child: Text('Ok').tr(),
                    onPressed: () async {
                      final bodyData = {
                        "event_id": event.id.toString(),
                        "amount": amount,
                        "payment_type": "Paypal",
                        "payment_id":
                            "${event.id}_${APICalls().getCurrentUser()}"
                      };
                      final response = await api.postItem(
                          '/v3/events/:0', ["add_payment"], bodyData);
                      SnackbarHelper.showSnackbarFromResponse(
                          context, response);
                      Navigator.pop(context);
                      if (response.statusCode == 201) {
                        setState(() {
                          paid = true;
                        });
                      }
                    },
                  ),
                  TextButton(
                    child: Text('Cancel').tr(),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ]));
  }

  Future<void> getPaymentStatus(String idEvent) async {
    if (widget.event.is_event_free == false) {
      final Response response =
          await api.getItem('/v3/events/:0/get_payment', [idEvent]);
      var data = json.decode(response.body);
      print("data: $data");
      if (response.statusCode == 200) {
        if (data["status"] == "PAID")
          setState(() {
            paid = true;
          });
        else {
          setState(() {
            paid = false;
          });
        }
      }
    }
  }

  Future<dynamic> joinEvent(Map<String, dynamic> bodyData) async {
    final response = await api.postItem(
        '/v3/events/:0/:1', [widget.event.id.toString(), 'join'], bodyData);
    return response;
  }

  Future<dynamic> leaveEvent(String id, Map<String, dynamic> bodyData) async {
    final response = await api.postItem(
        '/v3/events/:0/:1', [widget.event.id.toString(), 'leave'], bodyData);
    return response;
  }

  void CallLink(String link) async {
    var uri = Uri.parse(link);
    var type = uri.pathSegments[1];
    _socket.emit('be_scanning', {
      'username': uri.queryParameters["username"]!,
      'idEvent': widget.event.id.toString()
    });
    var a = 1;
    switch (type) {
      case "events":
        var response =
            await APICalls().getCollection('/v3/events/:0/verify_event', [
          widget.event.id.toString()
        ], {
          "code": uri.queryParameters["code"]!,
          "username": uri.queryParameters["username"]!
        });

        SnackbarHelper.showSnackbarFromResponse(context, response);

        break;
      default:
      // http://localhost:5000/v2/users/new_friend?code=bmWecsrvil7UTVT
      // https://localhost:5000/v3/events/628a0571-605a-49d4-9c81-d71773eaff7f/verify_event?code=111111
    }
  }

  void OnVerificationDone(String data) {
    print("OnVerificationDone");
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
        builder: (context) => AlertDialog(
                title: Text("titleText").tr(),
                content: Text("contentText").tr(),
                actions: [
                  TextButton(
                    child: Text('Ok').tr(),
                    onPressed: () {
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
      print("VerificationDone");
      var a = 0;

      print("VerificationDone");
      print("onVerificationDone: " + data);
      OnVerificationDone(data.toString());
      _socket.disconnect();
    });
  }

  Future<void> scanQR() async {
    String barcodeScanRes;
    CallLink(
        "https://localhost:5000/v3/events/628a0571-605a-49d4-9c81-d71773eaff7f/verify_event?username=310e139a-8759-4b35-8036-1adeb9512a20&code=GO61JB");

    // return;
    // Platform messages may fail, so we use a try/catch PlatformException.

    // try {
    //   barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
    //       '#ff6666', 'Cancel', true, ScanMode.QR);
    //   print("barcodeScanRes:" + barcodeScanRes);
    //   CallLink(barcodeScanRes);
    // } on PlatformException {
    //   barcodeScanRes = 'Failed to get platform version.';
    // }

    // // If the widget was removed from the tree while the asynchronous platform
    // // message was in flight, we want to discard the reply rather than calling
    // // setState to update our non-existent appearance.
    // if (!mounted) return;

    // setState(() {
    //   _scanResult = barcodeScanRes;
    // });
  }

  Future<bool> checkTimeConflict() async {
    final response = await api.getCollection(
        '/v3/events/:0/:1', ['joined', api.getCurrentUser()], null);
    var _joinedEvents = [json.decode(response.body)];
    final response2 =
        await api.getItem('/v3/events/:0', [widget.event.id.toString()]);
    var newEvent = json.decode(response2.body);
    final dateFormat = DateFormat('EEE, dd MMM yyyy HH:mm:ss \'GMT\'');
    DateTime newEventDateStart = dateFormat.parse(newEvent["date_started"]);
    DateTime newEventDateEnd = dateFormat.parse(newEvent["date_end"]);

    for (var event in _joinedEvents[0]) {
      DateTime eventDateStart = dateFormat.parse(event["date_started"]);
      DateTime eventDateEnd = dateFormat.parse(event["date_end"]);
      if ((newEventDateStart.isAfter(eventDateStart) &&
              newEventDateStart.isBefore(eventDateEnd)) ||
          (newEventDateEnd.isAfter(eventDateStart) &&
              newEventDateEnd.isBefore(eventDateEnd)) ||
          (newEventDateStart.isAtSameMomentAs(eventDateStart)) ||
          (newEventDateEnd.isAtSameMomentAs(eventDateEnd))) {
        return true; // 发现时间冲突
      }
    }
    return false;
  }

  Future<List<dynamic>> getAllPhotosInEvent(String idEvent) async {
    final response = await api
        .getCollection('/v3/events/participants', [], {"eventid": idEvent});
    var attendes = json.decode(response.body);
    List aux = [];
    bool amParticipant = false;
    for (var v in attendes) {
      if (v == APICalls().getCurrentUser()) amParticipant = true;
      final response2 = await APICalls().getUserImage(v);
      if (response2 != 'Fail') {
        aux.add({"user_id": v, "image": response2});
      } else {
        aux.add({"user_id": v, "image": ''});
      }
    }
    if (!amParticipant) {
      bool timeConflict = false;
      timeConflict = await checkTimeConflict();
      if (timeConflict) {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                    title: Text('TimeConflict').tr(),
                    content: Text('EventTimeConflict').tr(),
                    actions: [
                      TextButton(
                        child: Text('Ok').tr(),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ]));
      }
    }

    return aux;
  }

  Future<List<dynamic>> getAllPayments(String id) async {
    final response = await api.getItem('/v3/events/:0/get_all_payments', [id]);
    return json.decode(response.body);
  }
  // Future<String> getProfilePhoto(String idUsuar) async {
  //   final response = await es.getAPhoto(idUsuar);
  //   if (response != 'Fail') {
  //     setState(() {
  //       urlProfilePhoto = response;
  //     });
  //     return "0";
  //   }
  //   return urlProfilePhoto;
  // }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: [
            Expanded(
                child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    child: Column(children: [
                      SizedBox(
                          height: 250,
                          width: MediaQuery.of(context).size.width,
                          child: FittedBox(
                              child: ImageCard(
                                  linksImage: widget.event.event_image_uris,
                                  maxWidth: MediaQuery.of(context).size.width,
                                  maxHeight: 250),
                              fit: BoxFit.cover)),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                              width: MediaQuery.of(context).size.width,
                              height: 420,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.background,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(10),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .surface
                                        .withOpacity(0.5),
                                    spreadRadius: 5,
                                    blurRadius: 7,
                                    offset: const Offset(
                                        0, 3), // changes position of shadow
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    top: 20, left: 16, right: 16, bottom: 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Text(widget.event.name.toString(),
                                    //     style: TextStyle(
                                    //         color: Theme.of(context)
                                    //             .colorScheme
                                    //             .surface,
                                    //         fontSize: 20,
                                    //         fontWeight: FontWeight.bold)),
                                    // const SizedBox(height: 30),

                                    Expanded(
                                      child: SingleChildScrollView(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                FutureBuilder(
                                                  future: api.getItem(
                                                      "/v1/users/:0", [
                                                    widget.event.user_creator
                                                        .toString()
                                                  ]),
                                                  builder: (BuildContext
                                                          context,
                                                      AsyncSnapshot snapshot) {
                                                    if (snapshot
                                                            .connectionState ==
                                                        ConnectionState.done) {
                                                      var _user = json.decode(
                                                          snapshot.data.body);

                                                      return Row(
                                                        children: [
                                                          Text(
                                                            'Createdby'.tr() +
                                                                _user[
                                                                    "username"],
                                                            style: TextStyle(
                                                              color: Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .primary,
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              width: 10),
                                                          InkWell(
                                                            onTap: () {
                                                              Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                      builder: (context) =>
                                                                          ProfileScreen(
                                                                              id: _user["id"])));
                                                            },
                                                            child: SizedBox(
                                                              width: 36,
                                                              height: 36,
                                                              child: ClipRRect(
                                                                child:
                                                                    FittedBox(
                                                                  child: _user[
                                                                              "image_url"] !=
                                                                          ''
                                                                      ? Image.network(
                                                                          _user[
                                                                              "image_url"])
                                                                      : Image.asset(
                                                                          'assets/noProfileImage.png'),
                                                                  fit: BoxFit
                                                                      .fitHeight,
                                                                ),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            100),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      );
                                                    } else {
                                                      return Row(
                                                        children: [
                                                          SkeletonItem(
                                                            child:
                                                                SkeletonParagraph(
                                                              style:
                                                                  SkeletonParagraphStyle(
                                                                lines: 1,
                                                                spacing: 2,
                                                                lineStyle:
                                                                    SkeletonLineStyle(
                                                                  width: 40,
                                                                  height: 20,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              10),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              width: 10),
                                                          Center(
                                                            child: SkeletonItem(
                                                              child:
                                                                  SkeletonAvatar(
                                                                style:
                                                                    SkeletonAvatarStyle(
                                                                  shape: BoxShape
                                                                      .circle,
                                                                  width: 36,
                                                                  height: 36,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      );
                                                    }
                                                  },
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 20),
                                            const Divider(),
                                            const SizedBox(height: 20),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Text("from",
                                                        style: TextStyle(
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .primary,
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500))
                                                    .tr(),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                Text(widget.event.date_started
                                                    .toString()
                                                    .substring(
                                                        0,
                                                        widget.event
                                                                .date_started
                                                                .toString()
                                                                .length -
                                                            7)),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                Text("to",
                                                        style: TextStyle(
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .primary,
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500))
                                                    .tr(),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                Text(widget.event.date_end
                                                    .toString()
                                                    .substring(
                                                        0,
                                                        widget.event.date_end
                                                                .toString()
                                                                .length -
                                                            7)),
                                              ],
                                            ),
                                            // Text(
                                            //     widget.event.date_started
                                            //         .toString()
                                            //         .substring(
                                            //             0,
                                            //             widget.event
                                            //                     .date_started
                                            //                     .toString()
                                            //                     .length -
                                            //                 7),
                                            //     style: TextStyle(
                                            //         color: Theme.of(context)
                                            //             .colorScheme
                                            //             .primary,
                                            //         fontSize: 14,
                                            //         fontWeight:
                                            //             FontWeight.w500)),
                                            const SizedBox(height: 15),
                                            // Row(
                                            //     crossAxisAlignment:
                                            //         CrossAxisAlignment
                                            //             .center,
                                            //     children: [
                                            //       Text('Airqualityinthisarea',
                                            //               style: TextStyle(
                                            //                   color: Theme.of(
                                            //                           context)
                                            //                       .colorScheme
                                            //                       .onSurface,
                                            //                   fontSize:
                                            //                       14))
                                            //           .tr(),
                                            //       const Expanded(
                                            //           child: SizedBox()),
                                            //       AirTag(
                                            //           id: event[0]["id"],
                                            //           latitude: event[0]
                                            //                   ["latitude"]
                                            //               .toString(),
                                            //           longitud: event[0]
                                            //                   ["longitud"]
                                            //               .toString())
                                            // //     ]),
                                            // const SizedBox(height: 20),
                                            // const Divider(),
                                            // const SizedBox(height: 20),
                                            Text('Description',
                                                    style: TextStyle(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .surface,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 18))
                                                .tr(),
                                            const SizedBox(height: 10),
                                            Text(
                                                widget.event.description
                                                    .toString(),
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onSurface)),
                                            const SizedBox(height: 20),
                                            const Divider(),
                                            const SizedBox(height: 20),
                                            Text('Attendees',
                                                    style: TextStyle(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .surface,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 18))
                                                .tr(),
                                            const SizedBox(height: 10),
                                            SizedBox(
                                                height: 80,
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                child: FutureBuilder(
                                                    future: Future.wait([
                                                      getAllPhotosInEvent(widget
                                                          .event.id
                                                          .toString()),
                                                      getAllPayments(widget
                                                          .event.id
                                                          .toString())
                                                    ]), //

                                                    builder: (BuildContext
                                                            context,
                                                        AsyncSnapshot<
                                                                List<dynamic>>
                                                            snapshot) {
                                                      if (snapshot
                                                              .connectionState ==
                                                          ConnectionState
                                                              .done) {
                                                        var attendees =
                                                            snapshot.data![0];
                                                        var payments =
                                                            snapshot.data![1];
                                                        print(attendees);
                                                        return ListView
                                                            .separated(
                                                                shrinkWrap:
                                                                    true,
                                                                scrollDirection:
                                                                    Axis
                                                                        .horizontal,
                                                                separatorBuilder: (context,
                                                                        index) =>
                                                                    const SizedBox(
                                                                        width:
                                                                            20),
                                                                itemCount:
                                                                    attendees
                                                                        .length,
                                                                itemBuilder:
                                                                    (BuildContext
                                                                            context,
                                                                        int index) {
                                                                  bool hasPaid = widget
                                                                              .event
                                                                              .user_creator
                                                                              .toString() ==
                                                                          api
                                                                              .getCurrentUser() &&
                                                                      payments.any((payment) =>
                                                                          (payment['user_id'] ==
                                                                              attendees[index][
                                                                                  'user_id']) ||
                                                                          (widget.event.user_creator.toString() ==
                                                                              attendees[index]['user_id']));
                                                                  return InkWell(
                                                                    onTap: () {
                                                                      Navigator.push(
                                                                          context,
                                                                          MaterialPageRoute(
                                                                              builder: (context) => ProfileScreen(id: attendees[index]["user_id"])));
                                                                    },
                                                                    child:
                                                                        Stack(
                                                                      children: [
                                                                        CircleAvatar(
                                                                          radius:
                                                                              40,
                                                                          backgroundImage: attendees[index]['image'] == ''
                                                                              ? AssetImage('assets/noProfileImage.png')
                                                                              : NetworkImage(attendees[index]['image']) as ImageProvider,
                                                                        ),
                                                                        if (hasPaid)
                                                                          Positioned(
                                                                            bottom:
                                                                                0,
                                                                            right:
                                                                                0,
                                                                            child:
                                                                                Icon(
                                                                              CupertinoIcons.checkmark_circle_fill,
                                                                              // Icons.check_circle_outline_sharp,
                                                                              color: Colors.green,
                                                                              size: 24,
                                                                            ),
                                                                          ),
                                                                      ],
                                                                    ),
                                                                  );
                                                                });
                                                      } else {
                                                        return ListView
                                                            .separated(
                                                                physics:
                                                                    const NeverScrollableScrollPhysics(),
                                                                scrollDirection:
                                                                    Axis
                                                                        .horizontal,
                                                                shrinkWrap:
                                                                    true,
                                                                separatorBuilder: (context,
                                                                        index) =>
                                                                    const SizedBox(
                                                                        width:
                                                                            20),
                                                                itemCount: 5,
                                                                itemBuilder:
                                                                    (BuildContext
                                                                            context,
                                                                        int index) {
                                                                  return const Center(
                                                                    child: SkeletonItem(
                                                                        child: SkeletonAvatar(
                                                                      style: SkeletonAvatarStyle(
                                                                          shape: BoxShape
                                                                              .circle,
                                                                          width:
                                                                              80,
                                                                          height:
                                                                              80),
                                                                    )),
                                                                  );
                                                                });
                                                      }
                                                    })),
                                            const SizedBox(height: 20),
                                            const Divider(),
                                            const SizedBox(height: 20),
                                            Text('Location',
                                                    style: TextStyle(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .surface,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 18))
                                                .tr(),
                                            const SizedBox(height: 20),
                                            EventMapButton(event: widget.event),
                                            const SizedBox(height: 20)
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              )),
                        ],
                      )
                    ]))),
            Material(
              elevation: 15.0,
              child: Container(
                  decoration: BoxDecoration(
                      border: Border(
                          top: BorderSide(
                              width: 1.0,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.5)))),
                  height: 80,
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      IconButton(
                          iconSize: 27,
                          color: Theme.of(context).colorScheme.secondary,
                          icon: const Icon(Icons.people),
                          onPressed: () {}),
                      FutureBuilder(
                        future: api.getCollection(
                          '/v3/events/participants',
                          [],
                          {"eventid": widget.event.id.toString()},
                        ),
                        builder:
                            (BuildContext context, AsyncSnapshot snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            var participants = json.decode(snapshot.data.body);
                            int participantsCount = participants.length;
                            found = false;
                            int i = 0;
                            while (!found && i < participants.length) {
                              if (participants[i] == api.getCurrentUser()) {
                                found = true;
                              }
                              ++i;
                            }
                            // 第一个部分
                            Widget firstSection = Text(
                              '$participantsCount/${widget.event.max_participants}',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                            );

                            // 第二个部分
                            Widget secondSection = found
                                ? Row(
                                    children: [
                                      Visibility(
                                        visible: (paid ||
                                                widget.event.is_event_free ==
                                                    true) &&
                                            widget.event.user_creator
                                                    .toString() !=
                                                api.getCurrentUser(),
                                        child: Row(
                                          children: [
                                            InkWell(
                                              onTap: () async {
                                                showMyVerifyCode(
                                                    participants[i - 1]);
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .secondary,
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .secondary
                                                          .withOpacity(0.5),
                                                      spreadRadius: 5,
                                                      blurRadius: 7,
                                                      offset: const Offset(0,
                                                          3), // changes position of shadow
                                                    ),
                                                  ],
                                                ),
                                                width: 100,
                                                height: 40,
                                                child: Center(
                                                    child: Text('ShowCode',
                                                            style: TextStyle(
                                                                color: Theme.of(
                                                                        context)
                                                                    .colorScheme
                                                                    .background,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold))
                                                        .tr()),
                                              ),
                                            ),
                                            SizedBox(width: 40),
                                          ],
                                        ),
                                      ),
                                      Visibility(
                                        visible: !paid &&
                                            widget.event.user_creator
                                                    .toString() !=
                                                api.getCurrentUser() &&
                                            widget.event.is_event_free == false,
                                        child: Row(
                                          children: [
                                            InkWell(
                                              onTap: () async {
                                                PayEvent(widget.event);
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .error,
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .error
                                                          .withOpacity(0.5),
                                                      spreadRadius: 5,
                                                      blurRadius: 7,
                                                      offset: const Offset(0,
                                                          3), // changes position of shadow
                                                    ),
                                                  ],
                                                ),
                                                width: 60,
                                                height: 40,
                                                child: Center(
                                                    child: Text('Pay',
                                                            style: TextStyle(
                                                                color: Theme.of(
                                                                        context)
                                                                    .colorScheme
                                                                    .background,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold))
                                                        .tr()),
                                              ),
                                            ),
                                            SizedBox(width: 40),
                                          ],
                                        ),
                                      ),
                                      Visibility(
                                        visible: widget.event.user_creator
                                                .toString() !=
                                            api.getCurrentUser(),
                                        child: InkWell(
                                          onTap: () async {
                                            showDialog(
                                                context: context,
                                                builder: (context) =>
                                                    AlertDialog(
                                                        title: Text(
                                                                "LeaveEventConfirmTitle")
                                                            .tr(),
                                                        content: Text(
                                                                "LeaveEventConfirmContent")
                                                            .tr(),
                                                        actions: [
                                                          TextButton(
                                                            child:
                                                                Text('Ok').tr(),
                                                            onPressed: () {
                                                              LeaveEvent();
                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                          ),
                                                          TextButton(
                                                            child:
                                                                Text('Cancel')
                                                                    .tr(),
                                                            onPressed: () =>
                                                                Navigator.pop(
                                                                    context),
                                                          )
                                                        ]));
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .error,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .error
                                                      .withOpacity(0.5),
                                                  spreadRadius: 5,
                                                  blurRadius: 7,
                                                  offset: const Offset(0,
                                                      3), // changes position of shadow
                                                ),
                                              ],
                                            ),
                                            width: 60,
                                            height: 40,
                                            child: Center(
                                                child: Text('LEAVE',
                                                        style: TextStyle(
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .background,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold))
                                                    .tr()),
                                          ),
                                        ),
                                      ),
                                      Visibility(
                                        // modify here
                                        visible: widget.event.user_creator
                                                    .toString() ==
                                                api.getCurrentUser() &&
                                            widget.event.date_end!
                                                .isAfter(DateTime.now()) &&
                                            widget.event.date_started!
                                                .isAfter(DateTime.now()),
                                        child: Row(
                                          children: [
                                            InkWell(
                                              onTap: () async {
                                                _socket = IO.io(
                                                  baseUrl,
                                                  IO.OptionBuilder()
                                                      .setTransports(
                                                          ['websocket'])
                                                      // .disableAutoConnect()
                                                      .build(),
                                                );
                                                _connectSocket();
                                                await scanQR();
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .secondary,
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .secondary
                                                          .withOpacity(0.5),
                                                      spreadRadius: 5,
                                                      blurRadius: 7,
                                                      offset: const Offset(0,
                                                          3), // changes position of shadow
                                                    ),
                                                  ],
                                                ),
                                                width: 100,
                                                height: 40,
                                                child: Center(
                                                    child: Text('ScanCode',
                                                            style: TextStyle(
                                                                color: Theme.of(
                                                                        context)
                                                                    .colorScheme
                                                                    .background,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold))
                                                        .tr()),
                                              ),
                                            ),
                                            SizedBox(width: 40),
                                          ],
                                        ),
                                      ),
                                    ],
                                  )
                                : InkWell(
                                    onTap: () async {
                                      final bodyData = {
                                        "user_id": api.getCurrentUser()
                                      };
                                      var hasConflict =
                                          await checkTimeConflict();
                                      if (hasConflict) {
                                        showDialog(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                                    title: Text('TimeConflict')
                                                        .tr(),
                                                    content: Text(
                                                            'EventTimeConflictJoin')
                                                        .tr(),
                                                    actions: [
                                                      TextButton(
                                                        child:
                                                            Text('Cancel').tr(),
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                                context),
                                                      ),
                                                      TextButton(
                                                        child: Text('Yes').tr(),
                                                        onPressed: () async {
                                                          Navigator.pop(
                                                              context);
                                                          var response =
                                                              await joinEvent(
                                                                  bodyData);
                                                          if (response !=
                                                              null) {
                                                            SnackBar snackBar;
                                                            snackBar = SnackBar(
                                                              backgroundColor:
                                                                  Theme.of(
                                                                          context)
                                                                      .colorScheme
                                                                      .secondary,
                                                              content: Text(
                                                                      'Youarein')
                                                                  .tr(),
                                                            );
                                                            ScaffoldMessenger
                                                                    .of(context)
                                                                .showSnackBar(
                                                                    snackBar);
                                                            getPaymentStatus(
                                                                widget.event.id
                                                                    .toString());
                                                          }
                                                          setState(() {
                                                            found = response
                                                                    .statusCode ==
                                                                200;
                                                          });
                                                        },
                                                      ),
                                                    ]));
                                      } else {
                                        var response =
                                            await joinEvent(bodyData);
                                        if (response != null) {
                                          SnackBar snackBar;
                                          snackBar = SnackBar(
                                            backgroundColor: Theme.of(context)
                                                .colorScheme
                                                .secondary,
                                            content: Text('Youarein').tr(),
                                          );
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(snackBar);
                                          getPaymentStatus(
                                              widget.event.id.toString());
                                        }
                                        setState(() {
                                          found = response.statusCode == 200;
                                        });
                                      }
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary
                                                .withOpacity(0.5),
                                            spreadRadius: 5,
                                            blurRadius: 7,
                                            offset: const Offset(0,
                                                3), // changes position of shadow
                                          ),
                                        ],
                                      ),
                                      width: 150,
                                      height: 40,
                                      child: Center(
                                          child: Text('JOINNOW',
                                                  style: TextStyle(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .background,
                                                      fontWeight:
                                                          FontWeight.bold))
                                              .tr()),
                                    ),
                                  );

                            return Row(
                              children: [
                                firstSection,
                                const SizedBox(width: 30),
                                secondSection,
                              ],
                            );
                          } else {
                            return Center(
                              child: SkeletonItem(
                                child: SkeletonParagraph(
                                  style: SkeletonParagraphStyle(
                                    lines: 1,
                                    spacing: 2,
                                    lineStyle: SkeletonLineStyle(
                                      width: 150,
                                      height: 40,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  )),
            )
          ],
        ));
  }
}
