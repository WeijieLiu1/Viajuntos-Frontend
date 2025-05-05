// ignore_for_file: prefer_const_constructors

import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:skeletons/skeletons.dart';
import 'package:viajuntos/utils/api_controller.dart';
import 'package:viajuntos/utils/globals.dart';
import 'package:viajuntos/utils/like_button.dart';
import 'package:viajuntos/feature_event/screens/event_screen.dart';
import 'package:viajuntos/utils/share.dart';

class JoinedList extends StatefulWidget {
  const JoinedList({Key? key}) : super(key: key);

  @override
  State<JoinedList> createState() => _JoinedListState();
}

class _JoinedListState extends State<JoinedList> {
  APICalls api = APICalls();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: FutureBuilder(
          future: api.getCollection(
              '/v3/events/:0/:1', ['joined', api.getCurrentUser()], null),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              var _joined = json.decode(snapshot.data.body);
              if (_joined.isEmpty)
                return Center(child: Text('notjoinedevent').tr());
              return ListView.separated(
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                itemCount: _joined.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (BuildContext context, int index) {
                  return SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: 130,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        EventScreen(id: _joined[index]["id"])));
                          },
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                    _joined[index]["date_started"].substring(
                                        0,
                                        _joined[index]["date_started"].length -
                                            7),
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500)),
                                const SizedBox(height: 15),
                                Text(_joined[index]["name"],
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .surface,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500)),
                                const SizedBox(height: 15),
                                Row(children: [
                                  FutureBuilder(
                                      future: api.getCollection(
                                          '/v3/events/participants',
                                          [],
                                          {"eventid": _joined[index]["id"]}),
                                      builder: (BuildContext context,
                                          AsyncSnapshot snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.done) {
                                          var participants =
                                              json.decode(snapshot.data.body);
                                          return Text(
                                              participants.length.toString() +
                                                  "aregoing".tr(),
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSurface,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 14));
                                        } else {
                                          return SkeletonItem(
                                              child: SkeletonParagraph(
                                                  style: SkeletonParagraphStyle(
                                                      lines: 1,
                                                      spacing: 4,
                                                      lineStyle:
                                                          SkeletonLineStyle(
                                                              width: 70,
                                                              height: 20,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10)))));
                                        }
                                      }),
                                  const SizedBox(width: 20),
                                  // AirTag(
                                  //     id: _joined[index]["id"],
                                  //     latitude:
                                  //         _joined[index]["latitude"].toString(),
                                  //     longitud: _joined[index]["longitud"]
                                  //         .toString()),
                                ])
                              ]),
                        ),
                        const Expanded(child: SizedBox()),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 120,
                                  height: 72,
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(10)),
                                    child: FittedBox(
                                      child: Image.network(_joined[index]
                                          ["event_image_uris"][0]),
                                      fit: BoxFit.fitWidth,
                                    ),
                                  ),
                                ),
                                if (!_joined[index]
                                    ["is_event_free"]) // 如果不是免费活动
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: Transform.rotate(
                                      angle: pi / 4, // 设置旋转角度，这里是45度
                                      child: Container(
                                        padding: const EdgeInsets.all(4.0),
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                        child: Text(
                                          'Fee',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ).tr(),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            Row(
                              children: [
                                IconButton(
                                  iconSize: 20,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                  icon: const Icon(Icons.share),
                                  onPressed: () => showShareMenu(
                                    baseUrl +
                                        '/v3/events/' +
                                        _joined[index]["id"],
                                    context,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                LikeButton(id: _joined[index]["id"]),
                              ],
                            )
                          ],
                        )
                      ],
                    ),
                  );
                },
              );
            } else {
              return ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 20),
                  itemCount: 5,
                  itemBuilder: (BuildContext context, int index) {
                    return Center(
                      child: SkeletonItem(
                          child: SkeletonParagraph(
                              style: SkeletonParagraphStyle(
                                  lines: 1,
                                  spacing: 4,
                                  lineStyle: SkeletonLineStyle(
                                      width: MediaQuery.of(context).size.width,
                                      height: 130,
                                      borderRadius:
                                          BorderRadius.circular(10))))),
                    );
                  });
            }
          }),
    );
  }
}
