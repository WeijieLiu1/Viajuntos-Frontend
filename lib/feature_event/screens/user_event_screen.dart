import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:viajuntos/feature_chat/screens/listChat_screen.dart';
import 'package:viajuntos/feature_event/models/event_model.dart';
import 'package:viajuntos/feature_event/screens/information_wall_screen.dart';
import 'package:viajuntos/feature_event/widgets/event.dart';
import 'package:viajuntos/feature_event/widgets/user_event.dart';
import 'package:viajuntos/feature_event/screens/edit_event_screen.dart';
import 'package:viajuntos/utils/api_controller.dart';
import 'package:viajuntos/utils/globals.dart';
import 'package:viajuntos/utils/share.dart';
import 'package:http/http.dart' as http;

class UserEventScreen extends StatelessWidget {
  final String id;
  const UserEventScreen({Key? key, required this.id}) : super(key: key);
  Future<http.Response> getEventItem(
      String endpoint, List<String> pathParams) async {
    final uri = APICalls().buildUri(endpoint, pathParams, null);
    final response = await http.get(uri, headers: {
      'Authorization': 'Bearer ' + APICalls().getCurrentAccess(),
      'Content-Type': 'application/json'
    });

    return response;
  }

  @override
  Widget build(BuildContext context) {
    EventModel event;
    return FutureBuilder(
        future: getEventItem('/v3/events/:0', [id]),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            event = EventModel.fromJson(json.decode(snapshot.data.body));

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
                          icon: const Icon(Icons.create_sharp),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        EditEventScreen(id: id)));
                          }),
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
                                baseLocalUrl + '/v3/events/' + id, context);
                          } else if (value == 'information_wall') {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => InformationWallScreen(
                                          id: id,
                                        )));
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
