import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:skeletons/skeletons.dart';
import 'package:viajuntos/feature_event/models/event_model.dart';
import 'package:viajuntos/feature_event/screens/event_screen.dart';
import 'package:viajuntos/feature_event/widgets/image_card.dart';
import 'package:viajuntos/feature_navigation/screens/profile.dart';
import 'package:viajuntos/utils/api_controller.dart';
import 'package:viajuntos/utils/globals.dart';
import 'package:viajuntos/utils/like_button.dart';
import 'package:viajuntos/utils/share.dart';

class EventSearchMap extends StatefulWidget {
  const EventSearchMap({super.key});

  @override
  State<EventSearchMap> createState() => EventSearchMapState();
}

class EventSearchMapState extends State<EventSearchMap> {
  Completer<GoogleMapController> _controller = Completer<GoogleMapController>();
  CameraPosition? _cameraPosition;
  static const LatLng _center =
      const LatLng(41.4048648812451, 2.1722214341300163);
  LatLng? _lastMapPosition;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // GetCurrentLocation();
  }

  void GetCurrentLocation() async {
    try {
      var a = await _getCurrentLocation();
    } catch (e) {
      print(e);
    }
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 检查位置服务是否已启用
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('位置服务未启用');
      return;
    }

    // 获取位置授权
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('位置权限被拒绝');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print('位置权限被永久拒绝');
      return;
    }

    // 获取当前位置
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium);

    setState(() {
      _cameraPosition = CameraPosition(
        target: LatLng(position.latitude, position.longitude),
        zoom: 14.0,
      );
    });
    _controller.future.then((controller) {
      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: 14.0,
          ),
        ),
      );
    });
  }

  Future<CameraPosition> _getCameraPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 检查位置服务是否已启用
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('位置服务未启用');
      // 返回默认 CameraPosition
      return CameraPosition(
        target: _center,
        zoom: 14.0,
      );
    }

    // 获取位置授权
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('位置权限被拒绝');
        // 返回默认 CameraPosition
        return CameraPosition(
          target: _center,
          zoom: 14.0,
        );
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print('位置权限被永久拒绝');
      // 返回默认 CameraPosition
      return CameraPosition(
        target: _center,
        zoom: 14.0,
      );
    }

    // 获取当前位置
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium);

    // 返回根据当前位置计算得到的 CameraPosition
    return CameraPosition(
      target: LatLng(position.latitude, position.longitude),
      zoom: 14.0,
    );
  }
  // void _onMapTapped(LatLng latLng) {
  //   setState(() {
  //     _lastMapPosition = latLng;
  //   });
  // }

  void _onInfoWindowTapped() {
    // 在这里执行你想要的操作，比如打开新的页面、显示其他信息等
    print('InfoWindow 被点击了！');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('EventMap').tr(),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.background,
      ),
      body: FutureBuilder(
        future: APICalls().getItem('/v3/events/', []),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            } else {
              var auxEvents = json.decode(snapshot.data.body);
              // auxMembers.map((user) => User.fromJson(user)).toList().cast<User>();
              List<EventModel> events = auxEvents
                  .map((event) => EventModel.fromJson(event))
                  .toList()
                  .cast<EventModel>();
              if (_cameraPosition == null) {
                return FutureBuilder<CameraPosition>(
                  future: _getCameraPosition(),
                  builder: (context, positionSnapshot) {
                    if (positionSnapshot.connectionState ==
                        ConnectionState.done) {
                      _cameraPosition = positionSnapshot.data;
                      return _buildGoogleMap(events);
                    } else {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  },
                );
              } else {
                return _buildGoogleMap(events);
              }
            }
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: () {
      //     if (_lastMapPosition != null) {
      //       print(
      //           '经度: ${_lastMapPosition!.latitude}, 纬度: ${_lastMapPosition!.longitude}');
      //     } else {
      //       print('未选择位置');
      //     }
      //     if (_cameraPosition != null) {
      //       print(
      //           '当前经度: ${_cameraPosition!.target.latitude}, 纬度: ${_cameraPosition!.target.longitude}');
      //     } else {
      //       print('未找到用户位置');
      //     }
      //   },
      //   label: Text('显示经纬度'),
      //   icon: Icon(Icons.map),
      // ),
    );
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          // 底部弹出框的内容
          padding: EdgeInsets.all(20.0),
          child: Text('这是一个从底部弹出的框'),
        );
      },
    );
  }

  Widget _buildGoogleMap(List<EventModel> events) {
    return GoogleMap(
      // onTap: _onMapTapped,
      mapType: MapType.normal,
      initialCameraPosition: _cameraPosition ??
          CameraPosition(
            target: _center,
            zoom: 14.0,
          ),
      onMapCreated: (GoogleMapController controller) {
        _controller.complete(controller);
        for (var event in events) {
          controller.showMarkerInfoWindow(MarkerId(event.id.toString()));
        }
      },
      markers: {
        for (var event in events)
          Marker(
            markerId: MarkerId(event.id.toString()),
            position: LatLng(event.latitude!, event.longitud!),
            infoWindow: InfoWindow(title: event.name),
            onTap: () => {
              showModalBottomSheet(
                isScrollControlled: false,
                context: context,
                builder: (BuildContext context) {
                  return GestureDetector(
                    onTap: () {},
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      color: Colors.white,
                      child: Container(
                          height: 350,
                          margin: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 5,
                                blurRadius: 7,
                                offset: const Offset(
                                    0, 3), // changes position of shadow
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Stack(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => EventScreen(
                                                  id: event.id.toString())));
                                    },
                                    child: Container(
                                        height: 180,
                                        alignment: Alignment.topCenter,
                                        decoration: const BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10)),
                                          color: Colors.white,
                                        ),
                                        child: ClipRRect(
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(10)),
                                          child: SizedBox(
                                            height: 180,
                                            child: FittedBox(
                                                child: ImageCard(
                                                    linksImage:
                                                        event.event_image_uris,
                                                    maxWidth:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                    maxHeight: 250),
                                                fit: BoxFit.cover),
                                          ),
                                        )),
                                  ),
                                  if (!event.is_event_free!)
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
                              Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => EventScreen(
                                                  id: event.id.toString())));
                                    },
                                    child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(10)),
                                          color: Theme.of(context)
                                              .colorScheme
                                              .background,
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.grey.withOpacity(0.5),
                                              spreadRadius: 5,
                                              blurRadius: 7,
                                              offset: const Offset(0,
                                                  -3), // changes position of shadow
                                            ),
                                          ],
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 8,
                                              top: 8,
                                              bottom: 8,
                                              right: 8),
                                          child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                FutureBuilder(
                                                  future: APICalls().getItem(
                                                      "/v1/users/:0", [
                                                    event.user_creator
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
                                                Row(
                                                  children: [
                                                    Text("from").tr(),
                                                    Text(
                                                        event
                                                                .date_started!
                                                                .toString()
                                                                .substring(
                                                                    0,
                                                                    event.date_started!
                                                                            .toString()
                                                                            .length -
                                                                        7) +
                                                            " ",
                                                        style: TextStyle(
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .primary,
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                    Text("to").tr(),
                                                    Text(
                                                        " " +
                                                            event
                                                                .date_end!
                                                                .toString()
                                                                .substring(
                                                                    0,
                                                                    event.date_end!
                                                                            .toString()
                                                                            .length -
                                                                        7),
                                                        style: TextStyle(
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .primary,
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                  ],
                                                ),
                                                Text(event.name!,
                                                    style: TextStyle(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .surface,
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                                Text(event.description!,
                                                    style: TextStyle(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .surface,
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                                Row(
                                                  children: [
                                                    const Expanded(
                                                        child: SizedBox()),
                                                    IconButton(
                                                        iconSize: 20,
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .onSurface,
                                                        icon: const Icon(
                                                            Icons.share),
                                                        onPressed: () => showShareMenu(
                                                            baseLocalUrl +
                                                                '/v3/events/' +
                                                                event.id
                                                                    .toString(),
                                                            context)),
                                                    const SizedBox(width: 10),
                                                    LikeButton(
                                                        id: event.id.toString())
                                                  ],
                                                )
                                              ]),
                                        )),
                                  )
                                ],
                              ),
                            ],
                          )),
                    ),
                  );
                },
              ),
            },
          ),
        // if (_lastMapPosition != null)
        //   Marker(
        //     markerId: MarkerId('1'),
        //     position: _lastMapPosition!,
        //     infoWindow: InfoWindow(title: '1', snippet: '1'),
        //     onTap: _onInfoWindowTapped,
        //   ),
      },
    );
  }
}
