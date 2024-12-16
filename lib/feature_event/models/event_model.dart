import 'package:easy_localization/easy_localization.dart';

class EventModel {
  String? id;
  String? name;
  String? description;
  DateTime? date_started;
  DateTime? date_end;
  DateTime? date_creation;
  String? user_creator;
  double? longitud;
  double? latitude;
  int? max_participants;
  late List<String> event_image_uris;
  String? chat_id;
  double? amountevent;
  bool? is_event_free;
  EventType? event_type;
  EventModel({
    this.id,
    this.name,
    this.description,
    this.date_started,
    this.date_end,
    this.date_creation,
    this.user_creator,
    this.longitud,
    this.latitude,
    this.max_participants,
    this.event_image_uris = const [],
    this.chat_id,
    this.amountevent,
    this.is_event_free,
    this.event_type,
  });
  EventModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    description = json['description'];

    var dateFormat = DateFormat('EEE, dd MMM yyyy HH:mm:ss \'GMT\'');
    date_started = dateFormat.parse(json["date_started"]);
    date_end = dateFormat.parse(json["date_end"]);
    date_creation = dateFormat.parse(json["date_creation"]);
    user_creator = json['user_creator'];
    longitud = json['longitud'];
    latitude = json['latitude'];
    max_participants = json['max_participants'];
    event_image_uris =
        (json['event_image_uris'] as List<dynamic>).cast<String>();
    chat_id = json['chat_id'];
    amountevent = json['amountevent'];
    is_event_free = json['is_event_free'];
    String eventType = json['event_type'];
    if (event_type == 'PUBLIC') {
      event_type = EventType.PUBLIC;
    } else if (event_type == 'FRIENDS') {
      event_type = EventType.FRIENDS;
    } else if (event_type == 'PRIVATE') {
      event_type = EventType.PRIVATE;
    }
    // event_type = json['event_type'];
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['description'] = description;
    data['date_started'] = date_started.toString();
    data['date_end'] = date_end.toString();
    data['date_creation'] = date_creation.toString();
    data['user_creator'] = user_creator;
    data['longitud'] = longitud;
    data['latitude'] = latitude;
    data['max_participants'] = max_participants;
    data['event_image_uris'] = event_image_uris;
    data['chat_id'] = chat_id;
    data['amountevent'] = amountevent;
    data['is_event_free'] = is_event_free;
    data['event_type'] = event_type;
    return data;
  }
}

enum EventType {
  PUBLIC,
  FRIENDS,
  PRIVATE,
}
