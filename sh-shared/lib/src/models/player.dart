import 'serializable.dart';

class Player extends Serializable {
  int id;
  String name;

  Player([this.id, this.name]);

  Player.fromJson(Map<String, dynamic> jsonMap) : super.fromJson(jsonMap);

  Player.fromJsonString(String json) : super.fromJsonString(json);
}