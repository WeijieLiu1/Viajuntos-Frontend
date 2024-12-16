import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:viajuntos/feature_event/models/event_model.dart';
// ignore: unused_import
import 'package:viajuntos/feature_event/screens/event_location.dart';
import 'package:viajuntos/feature_map/screens/EventPositionMap.dart';

class EventMapButton extends StatelessWidget {
  final EventModel event;
  const EventMapButton({Key? key, required this.event}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20))),
          child: InkWell(
              onTap: () {
                LatLng latLng = LatLng(
                    event.latitude!.toDouble(), event.longitud!.toDouble());
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => EventPositionMap(
                              initialPosition: latLng,
                            )));
              },
              child: Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 7,
                        offset:
                            const Offset(0, 3), // changes position of shadow
                      ),
                    ],
                  ),
                  width: MediaQuery.of(context).size.width / 1.3,
                  height: MediaQuery.of(context).size.height / 6,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                    child: FittedBox(
                        child: Image.asset('assets/map_preview.png'),
                        fit: BoxFit.fitWidth),
                  )))),
    );
  }
}
