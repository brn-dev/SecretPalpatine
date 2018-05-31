import 'player.dart';
import 'serializable.dart';

class Lobby extends Serializable {
  int id;
  String name;
  List<Player> players;


  Lobby([int id, String name]) : this.withPlayers(id, name, new List<Player>());

  Lobby.withPlayers(this.id, this.name, this.players);

  Lobby.fromJson(Map<String, dynamic> jsonMap) : super.fromJson(jsonMap);

  Lobby.fromJsonString(String json) : super.fromJsonString(json);
}