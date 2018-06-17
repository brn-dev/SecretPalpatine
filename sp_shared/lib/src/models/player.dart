import 'dart:convert';
import 'identifiable.dart';

class Player extends Identifiable {
  String name;

  Player([int id, this.name]) : super(id);

  Player.fromJsonString(String json) : this.fromJson(JSON.decode(json));

  Player.fromJson(Map<String, dynamic> jsonMap) : super(jsonMap['id']) {
    this.name = jsonMap['name'];
  }

  Map<String, dynamic> toJson() {
    var map = new Map<String, dynamic>();
    map['id'] = id;
    map['name'] = name;
    return map;
  }
}