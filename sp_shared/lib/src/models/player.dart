import 'dart:convert';

class Player {
  int id;
  String name;

  Player([this.id, this.name]);

  Player.fromJsonString(String json) : this.fromJson(JSON.decode(json));

  Player.fromJson(Map<String, dynamic> jsonMap) {
    this.id = jsonMap['id'];
    this.name = jsonMap['name'];
  }

  Map<String, dynamic> toJson() {
    var map = new Map<String, dynamic>();
    map['id'] = id;
    map['name'] = name;
    return map;
  }
}