import 'dart:convert';
import 'role.dart';

class GameInfo {
  Role role;
  List<int> separatistsIds;
  int palpatineId;

  GameInfo([this.role, this.separatistsIds, this.palpatineId]);

  GameInfo.fromJsonString(String json) : this.fromJson(JSON.decode(json));

  GameInfo.fromJson(Map<String, dynamic> jsonMap) {
    if (jsonMap['role'] != null) {
      role = new Role.fromJson(jsonMap['role']);
    }
    separatistsIds = jsonMap['separatistsIds'];
    palpatineId = jsonMap['palpatineId'];
  }

  Map<String, dynamic> toJson() {
    var map = new Map<String, dynamic>();
    map['role'] = role.toJson();
    map['separatistsIds'] = separatistsIds;
    map['palpatineId'] = palpatineId;
    return map;
  }
}
