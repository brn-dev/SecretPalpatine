import 'dart:convert';
import 'dart:math';
import 'models/player-socket.dart';
import 'package:sh_shared/sh_shared.dart';
import 'package:socket_io/socket_io.dart';
import 'package:socket_io/src/namespace.dart';

class GameHandler {
  static const String lobbyPrefix = 'lobby-';

  final Server io;
  final Lobby lobby;
  final List<PlayerSocket> players = new List<PlayerSocket>();

  PlayerSocket host;
  Function whenEmpty;

  String roomId;
  Namespace get room => io.to(roomId);

  Random random = new Random();

  PlayerSocket _president;
  PlayerSocket _chancellor;
  List<PlayerSocket> killedPlayers = new List<PlayerSocket>();

  PlayerSocket get president => _president;
  set president(PlayerSocket player) {
    president = player;
    room.emit(SocketIoEvents.presidentSet, player.player.id);
  }

  PlayerSocket get chancellor => _chancellor;
  set chancellor(PlayerSocket player) {
    _chancellor = player;
    room.emit(SocketIoEvents.chancellorSet, player.player.id);
  }
  

  GameHandler(this.io, this.lobby, this.host, {Function whenEmpty = null}) {
    this.whenEmpty = whenEmpty;
    roomId = lobbyPrefix + lobby.id.toString();
    join(host);
    host.socket.once(SocketIoEvents.startGame, (_) => _startGame());
    host.socket.emit(SocketIoEvents.lobbyCreated, JSON.encode(lobby));
  }

  void _startGame() {
    if (players.length < 5 || players.length > 10) {
      print(
          'Error: lobby ${lobby.id} tried to start with ${players.length} players');
      host.socket.on(SocketIoEvents.startGame, (_) => _startGame());
      return;
    }
    _sendRoles();
    president = players[random.nextInt(players.length)];
  }

  void _sendRoles() {
    var playersWithRoles = _randomlyAssignRoles();
    var fascistPlayerIds = new List<int>();
    var hitlerPlayerId = -1;
    var hitlerRoleId = Roles.hitler.id;
    var hitlerKnowsFascists = players.length <= 6;
    playersWithRoles.forEach((player, role) {
      if (!role.membership) {
        fascistPlayerIds.add(player.player.id);
      }
      if (role.id == hitlerRoleId) {
        hitlerPlayerId = player.player.id;
      }
    });
    playersWithRoles.forEach((player, role) {
      var gameInfo = new GameInfo(role, [], null);
      if (!role.membership &&
          (role.id != hitlerRoleId || hitlerKnowsFascists)) {
        gameInfo.fascistsIds = fascistPlayerIds;
      }
      if (!role.membership) {
        gameInfo.hitlerId = hitlerPlayerId;
      }
      player.socket.emit(SocketIoEvents.gameStarted, gameInfo);
    });
  }

  Map<PlayerSocket, Role> _randomlyAssignRoles() {
    var roles = Roles.getRolesForPlayerAmount(players.length);
    var map = new Map<PlayerSocket, Role>();
    players.forEach((player) {
      var randomRole = roles.removeAt(random.nextInt(roles.length));
      map[player] = randomRole;
    });
    return map;
  }

  join(PlayerSocket playerSocket) {
    lobby.addPlayer(playerSocket.player);
    players.add(playerSocket);
    playerSocket.socket.join(roomId);

    playerSocket.socket
        .to(roomId)
        .emit(SocketIoEvents.playerJoined, JSON.encode(playerSocket.player));

    playerSocket.socket.on('disconnect', (_) {
      leave(playerSocket);
    });
  }

  leave(PlayerSocket playerSocket) {
    lobby.removePlayerWithId(playerSocket.player.id);
    players.remove(playerSocket);
    playerSocket.socket.leave(roomId, null);

    if (playerSocket == host && players.isNotEmpty) {
      host = players[0];
    }

    if (players.isEmpty && whenEmpty != null) {
      whenEmpty();
    }
  }

  stopHandling() {
    host.socket.off(SocketIoEvents.startGame);
  }
}
