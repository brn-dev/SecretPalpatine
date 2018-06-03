import 'dart:convert';
import 'role.dart';

class GameInfo {
  Role role;
  List<int> fascistsIds;
  int hitlerId;

  GameInfo([this.role, this.fascistsIds, this.hitlerId]);

  GameInfo.fromJsonString(String json) : this.fromJson(JSON.decode(json));

  GameInfo.fromJson(Map<String, dynamic> jsonMap) {
    if (jsonMap['role'] != null) {
      role = new Role.fromJson(jsonMap['role']);
    }
    fascistsIds = jsonMap['fascistsIds'];
    hitlerId = jsonMap['hitlerId'];
  }

  Map<String, dynamic> toJson() {
    var map = new Map<String, dynamic>();
    map['role'] = role.toJson();
    map['fascistsIds'] = fascistsIds;
    map['hitlerId'] = hitlerId;
    return map;
  }
}
