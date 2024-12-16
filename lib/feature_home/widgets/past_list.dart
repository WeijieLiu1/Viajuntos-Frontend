// ignore_for_file: prefer_const_constructors

import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:viajuntos/utils/api_controller.dart';
import 'dart:convert';
import 'package:viajuntos/utils/review.dart';
import 'package:skeletons/skeletons.dart';

class PastEventsList extends StatefulWidget {
  const PastEventsList({Key? key}) : super(key: key);

  @override
  State<PastEventsList> createState() => _PastEventsListState();
}

class _PastEventsListState extends State<PastEventsList> {
  APICalls api = APICalls();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: FutureBuilder(
          future: api.getCollection('/v3/events/:0', ['pastevents'],
              {"userid": api.getCurrentUser()}),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            print("PastEventsList");
            if (snapshot.connectionState == ConnectionState.done) {
              print("snapshot.toString(): ");
              // print("snapshot.toString(): " + snapshot.toString());
              var _joined = json.decode(snapshot.data.body);
              // print("joined: " + _joined);
              if (_joined.isEmpty) {
                return Center(child: Text('reviewedevent').tr());
              }
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
                          onTap: () =>
                              showReviewMenu(_joined[index]["id"], context),
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
                              ]),
                        ),
                        const Expanded(child: SizedBox()),
                        Column(
                            mainAxisAlignment: MainAxisAlignment.center,
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
                                          fit: BoxFit.fitWidth))),
                              if (!_joined[index]["is_event_free"]) // 如果不是免费活动
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: Transform.rotate(
                                    angle: pi / 4, // 旋转角度，这里是45度
                                    child: Container(
                                      padding: const EdgeInsets.all(4.0),
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(5),
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
                            ])
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
