import 'dart:convert';
import 'game_handler.dart';
import 'lobby_manager.dart';
import 'models/player_socket.dart';
import 'package:sp_shared/sp_shared.dart';
import 'package:socket_io/socket_io.dart';
import 'player_manager.dart';

class SPServer {
  final int port;
  Server io;

  final PlayerManager _playerManager = new PlayerManager();
  final LobbyManager _lobbyManager = new LobbyManager();
  final Map<int, GameHandler> _gameHandlers = new Map<int, GameHandler>();

  SPServer([this.port = 88]) {
    createServer();
  }

  void createServer() {
    io = new Server();
    io.on('connection', handleClient);
  }

  void handleClient(Socket client) {
    print('client connected');

    client.on(SocketIoEvents.getLobbies, (_) {
      print('sending ${JSON.encode(_lobbyManager.openLobbies)}');
      client.emit(
          SocketIoEvents.lobbies, JSON.encode(_lobbyManager.openLobbies));
    });

    client.once(SocketIoEvents.setName, (String playerName) {
      PlayerSocket playerSocket =
          new PlayerSocket(_playerManager.createPlayer(playerName), client);
      client.once(SocketIoEvents.createLobby, (String lobbyName) {
        createLobby(playerSocket, lobbyName);
        client.off(SocketIoEvents.joinLobby);
      });
      client.once(SocketIoEvents.joinLobby, (int lobbyId) {
        onJoinLobby(playerSocket, lobbyId);
        client.off(SocketIoEvents.createLobby);
      });
    });
  }

  void createLobby(PlayerSocket hostPlayer, String lobbyName) {
    Lobby lobby = _lobbyManager.createLobby(lobbyName);
    GameHandler gameHandler =
        new GameHandler(io, lobby, hostPlayer, whenEmpty: () {
      _lobbyManager.removeLobby(lobby.id);
      _gameHandlers.remove(lobby.id);
    });
    _gameHandlers[lobby.id] = gameHandler;
  }

  void onJoinLobby(PlayerSocket player, int lobbyId) {
    _gameHandlers[lobbyId].join(player);
  }

  void start() {
    io.listen(port);
    print("sh-server listening on port: ${port}");
  }
}
