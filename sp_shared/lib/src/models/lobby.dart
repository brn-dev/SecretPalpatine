import 'dart:convert';
import 'identifiable.dart';
import 'player.dart';

class Lobby extends Identifiable {
  String name;
  List<Player> players = new List<Player>();
  bool open = true;

  Lobby([int id, this.name]) : super(id);

  Lobby.withPlayers(int id, this.name, this.players) : super(id);

  Lobby.fromJsonString(String json) : this.fromJson(JSON.decode(json));

  Lobby.fromJson(Map<String, dynamic> jsonMap) : super(jsonMap['id']) {
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
