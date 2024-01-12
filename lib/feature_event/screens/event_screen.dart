import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:viajuntos/feature_chat/screens/chat_screen.dart';
import 'package:viajuntos/feature_chat/screens/listChat_screen.dart';
import 'package:viajuntos/feature_event/models/event_model.dart';
import 'package:viajuntos/feature_event/screens/information_wall_screen.dart';
import 'package:viajuntos/feature_event/widgets/event.dart';
import 'package:viajuntos/utils/api_controller.dart';
import 'package:viajuntos/utils/globals.dart';
import 'package:viajuntos/utils/share.dart';
import 'package:viajuntos/utils/like_button.dart';
import 'package:http/http.dart' as http;
import 'package:device_calendar/device_calendar.dart' as device_calendar;
import 'package:timezone/timezone.dart' as tz;
import 'package:intl/intl.dart';

class EventScreen extends StatefulWidget {
  final String id;
  const EventScreen({Key? key, required this.id}) : super(key: key);

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  APICalls api = APICalls();
  late EventModel event;

  Future<http.Response> getEventItem(
      String endpoint, List<String> pathParams) async {
    final uri = api.buildUri(endpoint, pathParams, null);
    final response = await http.get(uri, headers: {
      'Authorization': 'Bearer ' + APICalls().getCurrentAccess(),
      'Content-Type': 'application/json'
    });

    return response;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getEventItem('/v3/events/:0', [widget.id]),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            EventModel event =
                EventModel.fromJson(json.decode(snapshot.data.body));
            return Scaffold(
                appBar: AppBar(
                    centerTitle: true,
                    title: Text(event.name!,
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.surface,
                                fontSize: 20,
                                fontWeight: FontWeight.bold))
                        .tr(),
                    backgroundColor: Theme.of(context).colorScheme.background,
                    actions: <Widget>[
                      LikeButton(id: widget.id),
                      PopupMenuButton<String>(
                        offset: const Offset(0, 50),
                        color: Theme.of(context).colorScheme.background,
                        itemBuilder: (BuildContext context) =>
                            <PopupMenuEntry<String>>[
                          PopupMenuItem<String>(
                            value: 'share',
                            child: Row(
                              children: [
                                const Icon(Icons.share),
                                const SizedBox(width: 8),
                                Text('Share').tr(),
                              ],
                            ),
                          ),
                          PopupMenuItem<String>(
                            value: 'calendar',
                            child: Row(
                              children: [
                                const Icon(CupertinoIcons.calendar_badge_plus),
                                const SizedBox(width: 8),
                                Text('AddToCalendar').tr(),
                              ],
                            ),
                          ),
                          PopupMenuItem<String>(
                            value: 'information_wall',
                            child: Row(
                              children: [
                                const Icon(Icons.info),
                                const SizedBox(width: 8),
                                Text('InformationWall').tr(),
                              ],
                            ),
                          ),
                        ],
                        onSelected: (String value) {
                          if (value == 'share') {
                            showShareMenu(
                                baseLocalUrl + '/v3/events/' + widget.id,
                                context);
                          } else if (value == 'information_wall') {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => InformationWallScreen(
                                          id: widget.id,
                                        )));
                          } else if (value == 'calendar') {
                            showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                        title: Text('AddToCalendar').tr(),
                                        content:
                                            Text('ComfirmAddTOCalendar').tr(),
                                        actions: [
                                          TextButton(
                                            child: Text('Cancel').tr(),
                                            onPressed: () =>
                                                Navigator.pop(context),
                                          ),
                                          TextButton(
                                              child: Text('Yes').tr(),
                                              onPressed: () async {
                                                final device_calendar
                                                    .DeviceCalendarPlugin
                                                    _deviceCalendarPlugin =
                                                    device_calendar
                                                        .DeviceCalendarPlugin();
                                                var permissionsGranted =
                                                    await _deviceCalendarPlugin
                                                        .hasPermissions();
                                                if (permissionsGranted
                                                        .isSuccess &&
                                                    !permissionsGranted.data!) {
                                                  permissionsGranted =
                                                      await _deviceCalendarPlugin
                                                          .requestPermissions();
                                                  if (!permissionsGranted
                                                          .isSuccess ||
                                                      !permissionsGranted
                                                          .data!) {
                                                    // Handle permissions denied
                                                    return;
                                                  }
                                                }

                                                device_calendar.Event auxEvent =
                                                    device_calendar.Event(
                                                  "1",
                                                  title: event.name,
                                                  description:
                                                      event.description,
                                                  location: "latitude: " +
                                                      event.latitude
                                                          .toString() +
                                                      "," +
                                                      "longitude: " +
                                                      event.longitud.toString(),
                                                  start: tz.TZDateTime.from(
                                                      event.date_started!,
                                                      tz.UTC),
                                                  end: tz.TZDateTime.from(
                                                      event.date_end!, tz.UTC),
                                                );

                                                final createResult =
                                                    await _deviceCalendarPlugin
                                                        .createOrUpdateEvent(
                                                            auxEvent);

                                                if (createResult!.isSuccess &&
                                                    createResult.data != null) {
                                                  // 事件创建成功
                                                  Navigator.pop(context);
                                                  showDialog(
                                                      context: context,
                                                      builder: (context) =>
                                                          AlertDialog(
                                                            title: Text(
                                                                    'EventAdded')
                                                                .tr(),
                                                            content: Text(
                                                                    'SuccessfullyAdding')
                                                                .tr(),
                                                            actions: [
                                                              TextButton(
                                                                child:
                                                                    Text('Ok')
                                                                        .tr(),
                                                                onPressed: () =>
                                                                    Navigator.pop(
                                                                        context),
                                                              ),
                                                            ],
                                                          ));
                                                } else {
                                                  // 事件创建失败
                                                  Navigator.pop(context);
                                                  showDialog(
                                                      context: context,
                                                      builder: (context) =>
                                                          AlertDialog(
                                                            title: Text(
                                                                    'EventAddFailed')
                                                                .tr(),
                                                            content: Text(
                                                                    'ErrorAddingEvent')
                                                                .tr(),
                                                            actions: [
                                                              TextButton(
                                                                child:
                                                                    Text('Ok')
                                                                        .tr(),
                                                                onPressed: () =>
                                                                    Navigator.pop(
                                                                        context),
                                                              ),
                                                            ],
                                                          ));
                                                }
                                              })
                                        ]));
                          }
                        },
                      ),
                    ],
                    leading: IconButton(
                      iconSize: 24,
                      color: Theme.of(context).colorScheme.onSurface,
                      icon: const Icon(Icons.arrow_back_ios_new_sharp),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    )),
                body: Center(child: Event(event: event)));
          } else
            return CircularProgressIndicator();
        });
  }
}
