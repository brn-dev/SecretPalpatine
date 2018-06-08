import 'dart:convert';

class Role {
  int id;
  bool membership; //true=loyalist, false=seperatist
  String name;
  String imageUrl;

  Role([this.id, this.membership, this.name, this.imageUrl]);

  Role.fromJsonString(String json) : this.fromJson(JSON.decode(json));

  Role.fromJson(Map<String, dynamic> jsonMap) {
    id = jsonMap['id'];
    membership = jsonMap['membership'];
    name = jsonMap['name'];
    imageUrl = jsonMap['imageUrl'];
  }

  Map<String, dynamic> toJson() {
    var map = new Map<String, dynamic>();
    map['id'] = id;
    map['membership'] = membership;
    map['name'] = name;
    map['imageUrl'] = imageUrl;
    return map;
  }
}
