import 'dart:convert';
import 'player.dart';

class Lobby {
  int id;
  String name;
  List<Player> players = new List<Player>();
  bool open = true;

  Lobby([this.id, this.name]);

  Lobby.withPlayers(this.id, this.name, this.players);

  Lobby.fromJsonString(String json) : this.fromJson(JSON.decode(json));

  Lobby.fromJson(Map<String, dynamic> jsonMap) {
    id = jsonMap['id'];
    name = jsonMap['name'];
    open = jsonMap['open'];
    if (jsonMap['players'] != null) {
      players = jsonMap['players'].map((playerJson) => new Player.fromJson(playerJson)).toList();
    }
  }

  void removePlayerWithId(int playerId) =>
      players.removeWhere((player) => player.id == playerId);

  void addPlayer(Player player) {
    if (!open) {
      throw new Exception('Lobby is not open anymore - player can\'t join');
    }
    players.add(player);
  }

  Map<String, dynamic> toJson() {
    var map = new Map<String, dynamic>();
    map['id'] = id;
    map['name'] = name;
    map['players'] = players.map((player) => player.toJson()).toList();
    map['open'] = open;
    return map;
  }
}
