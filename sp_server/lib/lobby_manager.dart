import 'id_manager.dart';
import 'package:sp_shared/sp_shared.dart';

class LobbyManager {
  final IDManager _lobbyIdManager = new IDManager();

  final List<Lobby> _lobbies = new List<Lobby>();

  List<Lobby> get lobbies => _lobbies;

  List<Lobby> get openLobbies => _lobbies.where((lobby) => lobby.open).toList();

  Lobby createLobby(String name) {
    var newLobby = new Lobby(_lobbyIdManager.getNextId(), name);
    _lobbies.add(newLobby);
    return newLobby;
  }

  bool doesLobbyExist(int lobbyId) =>
      _lobbies.any((lobby) => lobby.id == lobbyId);

  Lobby getLobby(int lobbyId) =>
      _lobbies.firstWhere((lobby) => lobby.id == lobbyId, orElse: () => null);

  Lobby joinLobbyWithId(int lobbyId, Player player) {
    var lobby = getLobby(lobbyId);
    if (lobby == null) {
      throw new Exception('Lobby with id ${lobbyId} doesn\'t exist!');
    }
    if (!lobby.open) {
      throw new Exception(
          'can\'t join lobby (id: ${lobby.id}) because it isn\'t open anymore!');
    }
    lobby.addPlayer(player);
    return lobby;
  }

  void removeLobby(int lobbyId) =>
      _lobbies.removeWhere((lobby) => lobby.id == lobbyId);
}
