class Chat {
  String? id;
  String? name;
  String? type;
  String? created_at;
  String? creator_id;
  Chat({this.id, this.name, this.type, this.created_at, this.creator_id});
  Chat.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    type = json['type'];
    created_at = json['created_at'];
    creator_id = json['creator_id'];
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['type'] = type;
    data['created_at'] = created_at;
    data['creator_id'] = creator_id;
    return data;
  }
}

class ListChat {
  List<Chat>? chats;

  ListChat({this.chats});

  ListChat.fromJson(Map<String, dynamic> json) {
    if (json['chats'] != null) {
      chats = <Chat>[];
      json['chats'].forEach((v) {
        chats!.add(Chat.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (chats != null) {
      data['chats'] = chats!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
