import 'role.dart';
import 'serializable.dart';


class GameInfo extends Serializable {
  Role role;
  List<int> alliesIds;
  int hitlerId;

  GameInfo([this.role, this.alliesIds, this.hitlerId]);

  GameInfo.fromJson(Map<String, dynamic> jsonMap) : super.fromJson(jsonMap);

  GameInfo.fromJsonString(String json) : super.fromJsonString(json);
}