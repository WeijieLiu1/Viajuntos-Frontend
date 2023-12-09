import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:viajuntos/feature_chat/screens/chat_screen.dart';
import 'package:viajuntos/feature_chat/screens/listChat_screen.dart';
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
  String user_creator = "";
  var _event;
  Future<String> getEventCreator() async {
    http.Response resp = await getEventItem('/v2/events/:0', [widget.id]);
    _event = [json.decode(resp.body)];
    user_creator = _event[0]["user_creator"];

    return user_creator;
  }

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
    return Scaffold(
        appBar: AppBar(
            centerTitle: true,
            title: Text('Event',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.surface,
                        fontSize: 16))
                .tr(),
            backgroundColor: Theme.of(context).colorScheme.background,
            actions: <Widget>[
              IconButton(
                  iconSize: 24,
                  color: Theme.of(context).colorScheme.onSurface,
                  icon: const Icon(Icons.share),
                  onPressed: () => showShareMenu(
                      baseLocalUrl + '/v3/events/' + widget.id, context)),
              LikeButton(id: widget.id),
              IconButton(
                iconSize: 24,
                color: Theme.of(context).colorScheme.onSurface,
                icon: const Icon(CupertinoIcons.calendar_badge_plus),
                onPressed: () async {
                  showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                              title: Text('AddToCalendar').tr(),
                              content: Text('ComfirmAddTOCalendar').tr(),
                              actions: [
                                TextButton(
                                  child: Text('Cancel').tr(),
                                  onPressed: () => Navigator.pop(context),
                                ),
                                TextButton(
                                    child: Text('Yes').tr(),
                                    onPressed: () async {
                                      final device_calendar.DeviceCalendarPlugin
                                          _deviceCalendarPlugin =
                                          device_calendar
                                              .DeviceCalendarPlugin();
                                      var permissionsGranted =
                                          await _deviceCalendarPlugin
                                              .hasPermissions();
                                      if (permissionsGranted.isSuccess &&
                                          !permissionsGranted.data!) {
                                        permissionsGranted =
                                            await _deviceCalendarPlugin
                                                .requestPermissions();
                                        if (!permissionsGranted.isSuccess ||
                                            !permissionsGranted.data!) {
                                          // Handle permissions denied
                                          return;
                                        }
                                      }

                                      http.Response resp = await getEventItem(
                                          '/v2/events/:0', [widget.id]);
                                      _event = [json.decode(resp.body)];
                                      final dateFormat = DateFormat(
                                          'EEE, dd MMM yyyy HH:mm:ss \'GMT\'');
                                      final dateTimeStart = dateFormat
                                          .parse(_event[0]["date_started"]);
                                      final tzDateTimeStart =
                                          tz.TZDateTime.from(
                                              dateTimeStart, tz.UTC);

                                      final dateTimeEnd = dateFormat
                                          .parse(_event[0]["date_end"]);
                                      final tzDateTimeEnd = tz.TZDateTime.from(
                                          dateTimeEnd, tz.UTC);

                                      device_calendar.Event event =
                                          device_calendar.Event(
                                        "1",
                                        title: _event[0]["name"],
                                        description: _event[0]["description"],
                                        location: "latitude: " +
                                            _event[0]["latitude"].toString() +
                                            "," +
                                            "longitude: " +
                                            _event[0]["longitud"].toString(),
                                        start: tzDateTimeStart,
                                        end: tzDateTimeEnd,
                                      );

                                      final createResult =
                                          await _deviceCalendarPlugin
                                              .createOrUpdateEvent(event);

                                      if (createResult!.isSuccess &&
                                          createResult.data != null) {
                                        // 事件创建成功
                                        Navigator.pop(context);
                                        showDialog(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                                  title:
                                                      Text('EventAdded').tr(),
                                                  content:
                                                      Text('SuccessfullyAdding')
                                                          .tr(),
                                                  actions: [
                                                    TextButton(
                                                      child: Text('Ok').tr(),
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
                                            builder: (context) => AlertDialog(
                                                  title: Text('EventAddFailed')
                                                      .tr(),
                                                  content:
                                                      Text('ErrorAddingEvent')
                                                          .tr(),
                                                  actions: [
                                                    TextButton(
                                                      child: Text('Ok').tr(),
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                              context),
                                                    ),
                                                  ],
                                                ));
                                      }
                                    })
                              ]));
                },
              )
            ],
            leading: IconButton(
              iconSize: 24,
              color: Theme.of(context).colorScheme.onSurface,
              icon: const Icon(Icons.arrow_back_ios_new_sharp),
              onPressed: () {
                Navigator.pop(context);
              },
            )),
        body: Center(child: Event(id: widget.id)));
  }
}
