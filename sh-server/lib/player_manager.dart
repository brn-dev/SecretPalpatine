import 'id_manager.dart';
import 'package:sh_shared/sh_shared.dart';

class PlayerManager {
  final IDManager _playerIdManager = new IDManager();

  final List<Player> _players = new List<Player>();

  List<Player> get players => _players;

  Player createPlayer(String name) {
    Player newPlayer = new Player(_playerIdManager.getNextId(), name);
    _players.add(newPlayer);
    return newPlayer;
  }

  bool doesPlayerExist(int playerId) =>
      _players.any((player) => player.id == playerId);

  Player getPlayer(int playerId) => _players
      .firstWhere((player) => player.id == playerId, orElse: () => null);

  void removePlayer(playerId) =>
      _players.removeWhere((player) => player.id == playerId);
}
