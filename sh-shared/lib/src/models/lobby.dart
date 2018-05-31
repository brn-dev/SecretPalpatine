import 'player.dart';
import 'serializable.dart';

class Lobby extends Serializable {
  int id;
  String name;
  List<Player> _players = new List<Player>();
  bool open = true;

  Lobby([this.id, this.name]);

  Lobby.fromJson(Map<String, dynamic> jsonMap) : super.fromJson(jsonMap);

  Lobby.fromJsonString(String json) : super.fromJsonString(json);

  List<Player> get player => _players;

  void removePlayerWithId(int playerId) =>
      _players.removeWhere((player) => player.id == playerId);

  void addPlayer(Player player) {
    if (!open) {
      throw new Exception('Lobby is not open anymore - player can\'t join');
    }
    _players.add(player);
  }
}
