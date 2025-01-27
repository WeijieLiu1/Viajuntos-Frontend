// ignore_for_file: prefer_const_constructors

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:viajuntos/feature_event/widgets/image_selector.dart';
import 'package:viajuntos/feature_map/screens/EventPickMap.dart';
import 'dart:convert';

import 'package:viajuntos/utils/api_controller.dart';

class EditEventForm extends StatefulWidget {
  final String id;
  const EditEventForm({Key? key, required this.id}) : super(key: key);

  @override
  State<EditEventForm> createState() => EditEventFormState();
}

class EditEventFormState extends State<EditEventForm> {
  APICalls api = APICalls();

  TextEditingController _name = TextEditingController(text: '');
  TextEditingController _description = TextEditingController(text: '');
  TextEditingController _max_participants = TextEditingController(text: '');
  TextEditingController _lat = TextEditingController(text: '');
  TextEditingController _lng = TextEditingController(text: '');

  List<String> uploadImages = [];

  void _handleImagesChanged(List<String> newUploadImages) {
    setState(() {
      uploadImages = newUploadImages;
    });
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isMapSelected = false;
  void setTextFields(dynamic event) {
    _name = TextEditingController(text: event[0]["name"]);
    _description = TextEditingController(text: event[0]["description"]);
    _lat = TextEditingController(text: event[0]["latitude"].toString());
    _lng = TextEditingController(text: event[0]["longitud"].toString());
    _max_participants =
        TextEditingController(text: event[0]["max_participants"].toString());
    if (uploadImages.isEmpty)
      uploadImages = event[0]["event_image_uris"].cast<String>();
  }

  void _toggleInputMode() {
    if (_lat.text.isEmpty || _lng.text.isEmpty) {
      _lat.text = '0.0';
      _lng.text = '0.0';
    }
    LatLng aux = LatLng(
        double.parse(_lat.text), double.parse(_lng.text)); //todo: editar aqui
    Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => EventPickMap(initialPosition: aux)))
        .then((result) {
      if (result != null && result is LatLng) {
        setState(() {
          _lat.text = result.latitude.toString();
          _lng.text = result.longitude.toString();
        });
      }
    });
    ;
    setState(() {
      _isMapSelected = !_isMapSelected;
    });
  }

  @override
  void initState() {
    super.initState();
    // 在这里调用加载数据的方法
    loadData();
  }

  void loadData() async {
    var response = await api.getItem('/v3/events/:0', [widget.id]);
    var event = [json.decode(response.body)];
    setState(() {
      setTextFields(event);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: SingleChildScrollView(
          child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Form(
                  key: _formKey,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 40),
                        Center(
                          child: Text('Editevent',
                                  style: TextStyle(
                                      color:
                                          Theme.of(context).colorScheme.surface,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold))
                              .tr(),
                        ),
                        const SizedBox(height: 40),
                        Text('Name',
                                style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16))
                            .tr(),
                        TextFormField(
                          controller: _name,
                          decoration:
                              InputDecoration(hintText: 'eventname'.tr()),
                        ),
                        const SizedBox(height: 20),
                        Text('Description',
                                style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16))
                            .tr(),
                        TextFormField(
                          controller: _description,
                          decoration: InputDecoration(
                              hintText: 'eventdescription'.tr()),
                        ),
                        const SizedBox(height: 20),
                        Text('MaxAttendees',
                                style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16))
                            .tr(),
                        TextFormField(
                          controller: _max_participants,
                          decoration:
                              InputDecoration(hintText: 'peoplecanjoin'.tr()),
                        ),
                        const SizedBox(height: 20),
                        Text('Location',
                                style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16))
                            .tr(),
                        Row(children: [
                          Expanded(
                            child: TextFormField(
                              controller: _lng,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d+\.?\d{0,2}')),
                              ],
                              decoration:
                                  InputDecoration(hintText: 'Longitude'.tr()),
                            ),
                          ),
                          const SizedBox(width: 30),
                          Expanded(
                            child: TextFormField(
                              controller: _lat,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d+\.?\d{0,2}')),
                              ],
                              decoration:
                                  InputDecoration(hintText: 'Latitude'.tr()),
                            ),
                          ),
                        ]),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.secondary,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: _toggleInputMode,
                          child: Text('SelectOnMap').tr(),
                        ),
                        const SizedBox(height: 20),
                        Text('ImageUrl',
                                style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16))
                            .tr(),
                        ImageSelector(
                            path: APICalls().getCurrentUser(),
                            uploadImages: uploadImages,
                            onImagesChanged: _handleImagesChanged),
                        const SizedBox(height: 40),
                        Center(
                          child: InkWell(
                            onTap: () async {
                              // SAVE
                              Map<String, dynamic> body = {
                                "name": _name.text,
                                "description": _description.text,
                                "latitude": double.parse(_lat.text),
                                "longitud": double.parse(_lng.text),
                                "max_participants":
                                    int.parse(_max_participants.text),
                                "event_image_uris": uploadImages,
                              };
                              var response = await api.putItem(
                                  '/v3/events/:0', [widget.id], body);
                              SnackBar snackBar;
                              if (response.statusCode == 200) {
                                snackBar = SnackBar(
                                  backgroundColor:
                                      Theme.of(context).colorScheme.secondary,
                                  content: Text('eventupdated').tr(),
                                );
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(snackBar);
                                Navigator.of(context).pushNamedAndRemoveUntil(
                                    '/home', (route) => false);
                              } else {
                                snackBar = SnackBar(
                                  backgroundColor:
                                      Theme.of(context).colorScheme.error,
                                  content: Text('BadRequest'.tr() +
                                      json.decode(
                                          response.body)["error_message"]),
                                );
                              }
                            },
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                color: Theme.of(context).colorScheme.onError,
                                boxShadow: [
                                  BoxShadow(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onError
                                        .withOpacity(0.5),
                                    spreadRadius: 5,
                                    blurRadius: 7,
                                    offset: const Offset(
                                        0, 3), // changes position of shadow
                                  ),
                                ],
                              ),
                              width: 150,
                              height: 40,
                              child: Center(
                                  child: Text('UPDATE',
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .background,
                                              fontWeight: FontWeight.bold))
                                      .tr()),
                            ),
                          ),
                        )
                      ])))),
    );
  }
}
