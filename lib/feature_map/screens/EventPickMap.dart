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
import 'package:viajuntos/feature_map/models/event.dart';
import 'package:viajuntos/feature_navigation/screens/profile.dart';
import 'package:viajuntos/utils/api_controller.dart';
import 'package:viajuntos/utils/globals.dart';
import 'package:viajuntos/utils/like_button.dart';
import 'package:viajuntos/utils/share.dart';

class EventPickMap extends StatefulWidget {
  final LatLng? initialPosition;
  const EventPickMap({super.key, required this.initialPosition});

  @override
  State<EventPickMap> createState() => EventPickMapState();
}

class EventPickMapState extends State<EventPickMap> {
  Completer<GoogleMapController> _controller = Completer<GoogleMapController>();
  CameraPosition? _cameraPosition;
  static const LatLng _center =
      const LatLng(41.4048648812451, 2.1722214341300163);
  LatLng? _lastMapPosition;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    GetCurrentLocation();
  }

  void GetCurrentLocation() async {
    if (widget.initialPosition != null &&
        widget.initialPosition is LatLng &&
        widget.initialPosition!.latitude != 0 &&
        widget.initialPosition!.longitude != 0) {
      setState(() {
        _lastMapPosition = widget.initialPosition!;
        _cameraPosition = CameraPosition(
          target: widget.initialPosition!,
          zoom: 14.0,
        );
      });
      return;
    }

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

  void _onMapTapped(LatLng latLng) {
    setState(() {
      _lastMapPosition = latLng;
    });
  }

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
      body: _buildGoogleMap(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (_lastMapPosition != null) {
            print(
                '经度: ${_lastMapPosition!.latitude}, 纬度: ${_lastMapPosition!.longitude}');
          } else {
            print('未选择位置');
          }
          if (_cameraPosition != null) {
            print(
                '当前经度: ${_cameraPosition!.target.latitude}, 纬度: ${_cameraPosition!.target.longitude}');
          } else {
            print('未找到用户位置');
          }
          showDialog(
              context: context,
              builder: (context) => AlertDialog(
                      title: Text("ConfirmPosition").tr(),
                      content: Text("ConfirmPosition").tr(),
                      actions: [
                        TextButton(
                            child: Text('Ok').tr(),
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.pop(
                                  context, _lastMapPosition); // 返回选择的经纬度信息
                            }),
                        TextButton(
                          child: Text('Cancel').tr(),
                          onPressed: () => Navigator.pop(context),
                        )
                      ]));
        },
        label: Text('显示经纬度'),
        // icon: Icon(Icons.map),
      ),
    );
  }

  Widget _buildGoogleMap() {
    return GoogleMap(
      onTap: _onMapTapped,
      mapType: MapType.normal,
      initialCameraPosition: _cameraPosition ??
          CameraPosition(
            target: _center,
            zoom: 14.0,
          ),
      onMapCreated: (GoogleMapController controller) {
        _controller.complete(controller);
      },
      markers: {
        if (_lastMapPosition != null)
          Marker(
            markerId: MarkerId('1'),
            position: _lastMapPosition!,
          ),
      },
    );
  }
}
