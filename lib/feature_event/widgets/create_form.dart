// ignore_for_file: prefer_const_constructors

import 'dart:ffi';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:image_picker/image_picker.dart';
import 'package:viajuntos/feature_event/screens/creation_sucess.dart';
// import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart'
    as picker;
import 'package:viajuntos/feature_event/widgets/image_selector.dart';
import 'package:viajuntos/feature_map/screens/EventPickMap.dart';
import 'package:viajuntos/utils/api_controller.dart';
import 'dart:convert';

class CreateEventForm extends StatefulWidget {
  const CreateEventForm({Key? key}) : super(key: key);

  @override
  State<CreateEventForm> createState() => _CreateEventFormState();
}

class _CreateEventFormState extends State<CreateEventForm> {
  APICalls api = APICalls();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  DateTime _selectedStartedTime = DateTime.now();
  TimeOfDay _startedtime =
      TimeOfDay(hour: DateTime.now().hour, minute: DateTime.now().minute);

  DateTime _selectedEndTime = DateTime.now();
  TimeOfDay _endtime =
      TimeOfDay(hour: DateTime.now().hour, minute: DateTime.now().minute + 1);

  List event = [];
  final TextEditingController _name = TextEditingController(text: '');
  final TextEditingController _description = TextEditingController(text: '');
  final TextEditingController _latitude = TextEditingController(text: '');
  final TextEditingController _longitude = TextEditingController(text: '');
  final TextEditingController _max_participants =
      TextEditingController(text: '');
  final TextEditingController _amount_event =
      TextEditingController(text: '0.0');
  String event_type = 'PUBLIC'.tr();
  late Uint8List _imageContent;
  bool is_event_pee = false;
  bool _isMapSelected = false;

  List<String> uploadImages = [];

  void _toggleInputMode() {
    if (_latitude.text.isEmpty || _longitude.text.isEmpty) {
      _latitude.text = '0.0';
      _longitude.text = '0.0';
    }
    LatLng aux = LatLng(double.parse(_latitude.text),
        double.parse(_longitude.text)); //todo: editar aqui
    Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => EventPickMap(initialPosition: aux)))
        .then((result) {
      if (result != null && result is LatLng) {
        setState(() {
          _latitude.text = result.latitude.toString();
          _longitude.text = result.longitude.toString();
        });
      }
    });
    ;
    setState(() {
      _isMapSelected = !_isMapSelected;
    });
  }

  void _selectTime() async {
    TimeOfDay? newTime = await showTimePicker(
      context: context,
      initialTime: _startedtime,
    );
    if (newTime != null) {
      setState(() {
        _startedtime = newTime;
        _endtime = newTime;
      });
    }
  }

  Future getImage() async {
    // // var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    // XFile? image = await ImagePicker.pickImage(source: ImageSource.gallery);
    // setState(() {
    //   _imageContent = image as Uint8List;
    //   print(_imageContent);
    // });
    // // uploadImage();
  }

  void _selectEndTime() async {
    TimeOfDay? newTime = await showTimePicker(
      context: context,
      initialTime: _endtime,
    );
    if (newTime != null) {
      setState(() {
        _endtime = newTime;
      });
    }
  }

  void _handleImagesChanged(List<String> newUploadImages) {
    setState(() {
      uploadImages = newUploadImages;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      SizedBox(height: MediaQuery.of(context).size.height / 8),
      Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                    text: 'Startcreatingyour'.tr(),
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                        color: Theme.of(context).colorScheme.surface),
                    children: <TextSpan>[
                      TextSpan(
                          text: 'dream'.tr(),
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.secondary,
                              fontSize: 28)),
                      TextSpan(
                          text: 'event'.tr(),
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 28,
                              color: Theme.of(context).colorScheme.surface))
                    ])),
            const SizedBox(height: 20),
            Text('Fillinfonewevent',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.onSurface))
                .tr(),
            SizedBox(height: MediaQuery.of(context).size.height / 8),
          ],
        ),
      ),
      Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Title',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 16))
                  .tr(),
              TextFormField(
                controller: _name,
                decoration: InputDecoration(hintText: 'Whatcreating'.tr()),
              ),
              const SizedBox(height: 20),
              Text('EventType',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 16))
                  .tr(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  DropdownButtonFormField<String>(
                    value: event_type,
                    onChanged: (String? newValue) {
                      setState(() {
                        event_type = newValue!;
                      });
                    },
                    items: <String>[
                      'PUBLIC'.tr(),
                      'FRIENDS'.tr(),
                      'PRIVATE'.tr()
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text('Datetimeeventstarts',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 16))
                  .tr(),
              Row(children: [
                TextButton(
                    onPressed: () {
                      picker.DatePicker.showDatePicker(context,
                          showTitleActions: true,
                          maxTime: DateTime(2100, 1, 1),
                          minTime: DateTime.now(),
                          onChanged: (date) {}, onConfirm: (date) {
                        setState(() {
                          _selectedStartedTime = date;
                          _selectedEndTime = date;
                        });
                      },
                          currentTime: DateTime.now(),
                          locale: picker.LocaleType.en);
                    },
                    child: Text(
                      ('' +
                          _selectedStartedTime.year.toString() +
                          '/' +
                          _selectedStartedTime.month.toString() +
                          '/' +
                          _selectedStartedTime.day.toString()),
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary),
                    )),
                const SizedBox(width: 40),
                TextButton(
                    onPressed: _selectTime,
                    child: Text(
                      _startedtime.hour.toString() +
                          ':' +
                          _startedtime.minute.toString(),
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary),
                    )),
              ]),
              const SizedBox(height: 20),
              Text('Datetimeeventends',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 16))
                  .tr(),
              Row(children: [
                TextButton(
                    onPressed: () {
                      picker.DatePicker.showDatePicker(context,
                          showTitleActions: true,
                          maxTime: DateTime(2100, 1, 1),
                          minTime: DateTime.now(),
                          onChanged: (date) {}, onConfirm: (date) {
                        setState(() {
                          if (_selectedEndTime.isBefore(_selectedStartedTime)) {
                            _selectedStartedTime = date;
                          }
                          _selectedEndTime = date;
                        });
                      },
                          currentTime: DateTime.now(),
                          locale: picker.LocaleType.en);
                    },
                    child: Text(
                      ('' +
                          _selectedEndTime.year.toString() +
                          '/' +
                          _selectedEndTime.month.toString() +
                          '/' +
                          _selectedEndTime.day.toString()),
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary),
                    )),
                const SizedBox(width: 40),
                TextButton(
                    onPressed: _selectEndTime,
                    child: Text(
                      _endtime.hour.toString() +
                          ':' +
                          _endtime.minute.toString(),
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary),
                    )),
              ]),
              const SizedBox(height: 20),
              Text('Location',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 16))
                  .tr(),
              Row(children: [
                Expanded(
                  child: TextFormField(
                    controller: _longitude,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                    decoration: InputDecoration(hintText: 'Longitude'.tr()),
                  ),
                ),
                const SizedBox(width: 30),
                Expanded(
                  child: TextFormField(
                    controller: _latitude,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                    decoration: InputDecoration(hintText: 'Latitude'.tr()),
                  ),
                ),
              ]),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  foregroundColor: Colors.white,
                ),
                onPressed: _toggleInputMode,
                child: Text('SelectOnMap').tr(),
              ),
              const SizedBox(height: 20),
              Text('MaxParticipants',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 16))
                  .tr(),
              TextFormField(
                controller: _max_participants,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                  TextInputFormatter.withFunction((oldValue, newValue) {
                    try {
                      if (newValue.text.isEmpty) {
                        setState(() {
                          _max_participants.text = '';
                        });
                        return newValue;
                      }
                      final int val = int.parse(newValue.text);
                      if (val == 0) {
                        return TextEditingValue(); // 禁用输入值为0
                      }
                      return newValue;
                    } catch (e) {
                      return oldValue; // 如果输入无效，则保留原始值
                    }
                  }),
                ],
                decoration: InputDecoration(hintText: 'peoplewillattend'.tr()),
              ),
              const SizedBox(height: 20),
              Text('Description',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 16))
                  .tr(),
              TextFormField(
                controller: _description,
                decoration:
                    InputDecoration(hintText: 'Letattendeesexpect'.tr()),
              ),
              const SizedBox(height: 20),
              Text('IsPaidEvent?',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 16))
                  .tr(),
              Switch(
                  inactiveTrackColor: Theme.of(context).colorScheme.background,
                  activeTrackColor: Theme.of(context).colorScheme.secondary,
                  inactiveThumbColor: Theme.of(context).colorScheme.primary,
                  activeColor: Theme.of(context).colorScheme.primary,
                  value: is_event_pee,
                  onChanged: (value) {
                    setState(() {
                      is_event_pee = value;
                    });
                  }),
              Visibility(
                visible: is_event_pee,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Price',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        )).tr(),
                    TextFormField(
                      controller: _amount_event,
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d+\.?\d{0,2}')),
                        TextInputFormatter.withFunction((oldValue, newValue) {
                          try {
                            if (newValue.text.isEmpty) {
                              setState(() {
                                _amount_event.text = '';
                              });
                              return newValue;
                            }
                            final double? val = double.tryParse(newValue.text);
                            if (val == 0.0) {
                              return TextEditingValue(); // 禁用输入值为0
                            }
                            return newValue;
                          } catch (e) {
                            return oldValue; // 如果输入无效，则保留原始值
                          }
                        }),
                      ],
                      decoration: InputDecoration(hintText: 'AddPrice'.tr()),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text('Image',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 16))
                  .tr(),
              const SizedBox(height: 20),
              ImageSelector(
                  path: api.getCurrentUser(),
                  uploadImages: uploadImages,
                  onImagesChanged: _handleImagesChanged),
            ],
          ),
        ),
      ),
      const SizedBox(height: 50),
      TextButton(
        style: TextButton.styleFrom(
          padding:
              const EdgeInsets.only(top: 16, bottom: 16, left: 100, right: 100),
          primary: Colors.white,
          backgroundColor: Theme.of(context).colorScheme.secondary,
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        onPressed: () async {
          Map<String, dynamic> body = {
            "name": _name.text,
            "description": _description.text,
            "event_type": event_type,
            "date_started": _selectedStartedTime.year.toString() +
                '-' +
                _selectedStartedTime.month.toString() +
                '-' +
                _selectedStartedTime.day.toString() +
                ' ' +
                _startedtime.hour.toString() +
                ':' +
                _startedtime.minute.toString() +
                ':00',
            "date_end": _selectedEndTime.year.toString() +
                '-' +
                _selectedEndTime.month.toString() +
                '-' +
                _selectedEndTime.day.toString() +
                ' ' +
                _endtime.hour.toString() +
                ':' +
                _endtime.minute.toString() +
                ':00',
            "user_creator": api.getCurrentUser(),
            "longitud": double.parse(_longitude.text),
            "latitude": double.parse(_latitude.text),
            "max_participants": int.parse(_max_participants.text),
            "event_image_uris": uploadImages,
            "event_free": is_event_pee,
            "amount_event":
                is_event_pee ? 0.0 : double.parse(_amount_event.text),
          };

          var response = await api.postItem('/v3/events/', [], body);
          SnackBar snackBar;
          if (response.statusCode == 201) {
            snackBar = SnackBar(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              content: Text('eventcreated').tr(),
            );
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        //todo: editar aqui
                        // CreationSucess(image: _imageContent.toString())));
                        CreationSucess(image: uploadImages[0])));
          } else if (response.statusCode == 400) {
            snackBar = SnackBar(
              backgroundColor: Theme.of(context).colorScheme.error,
              content: Text('BadRequest'.tr() +
                  json.decode(response.body)["error_message"]),
            );
          } else {
            snackBar = SnackBar(
              backgroundColor: Theme.of(context).colorScheme.error,
              content: Text('Somethingwrong').tr(),
            );
          }

          // // Find the ScaffoldMessenger in the widget tree
          // // and use it to show a SnackBar.
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        },
        child: Text('Create').tr(),
      ),
      const SizedBox(height: 50),
    ]);
  }
}
