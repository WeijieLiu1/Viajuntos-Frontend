class User {
  String? id;
  String? username;
  String? email;
  String? description;
  String? hobbies;
  String? image_url;
  User(
      {this.id,
      this.username,
      this.email,
      this.description,
      this.hobbies,
      this.image_url});
  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    username = json['username'];
    email = json['email'];
    description = json['description'];
    hobbies = json['hobbies'];
    image_url = json['image_url'];
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['username'] = username;
    data['email'] = email;
    data['description'] = description;
    data['hobbies'] = hobbies;
    data['image_url'] = image_url;
    return data;
  }
}
