import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class EventPositionMap extends StatefulWidget {
  final LatLng initialPosition;
  const EventPositionMap({super.key, required this.initialPosition});

  @override
  State<EventPositionMap> createState() => EventPositionMapState();
}

class EventPositionMapState extends State<EventPositionMap> {
  Completer<GoogleMapController> _controller = Completer<GoogleMapController>();
  CameraPosition? _cameraPosition;
  static const LatLng _center =
      const LatLng(41.4048648812451, 2.1722214341300163);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    GetCurrentLocation();
  }

  void GetCurrentLocation() async {
    setState(() {
      _cameraPosition = CameraPosition(
        target: widget.initialPosition!,
        zoom: 14.0,
      );
    });
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
    );
  }

  Widget _buildGoogleMap() {
    return GoogleMap(
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
        Marker(
          markerId: MarkerId('1'),
          position: widget.initialPosition!,
        ),
      },
    );
  }
}
