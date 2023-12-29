import 'package:easy_localization/easy_localization.dart';

class Post {
  int? id;
  int? parent_post_id;
  String? event_id;
  String? user_id;
  DateTime? datetime;
  String? text;
  List<String?>? post_image_uris; // Updated here
  int? likes;

  Post({
    this.id,
    this.parent_post_id,
    this.event_id,
    this.user_id,
    this.datetime,
    this.text,
    this.post_image_uris,
    this.likes,
  });

  Post.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    parent_post_id = json['parent_post_id'];
    event_id = json['event_id'];
    user_id = json['user_id'];
    var dateFormat = DateFormat('EEE, dd MMM yyyy HH:mm:ss \'GMT\'');
    datetime = dateFormat.parse(json["datetime"]);
    // datetime = json['datetime'];
    text = json['text'];
    post_image_uris =
        List<String?>.from(json['post_image_uris'] ?? []); // Updated here
    likes = json['likes'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['parent_post_id'] = parent_post_id;
    data['event_id'] = event_id;
    data['user_id'] = user_id;
    data['datetime'] = datetime.toString();
    data['text'] = text;
    data['post_image_uris'] = post_image_uris;
    data['likes'] = likes;
    return data;
  }
}
