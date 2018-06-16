import 'dart:async';
import 'dart:convert';
import 'package:angular/core.dart';

import 'package:sp_client/services/game_state_service.dart';
import 'package:sp_shared/sp_shared.dart';
import 'package:socket_io_client/socket_io_client.dart';

typedef void VoidCallback();
typedef void LobbiesCallback(List<Lobby> lobbies);
typedef void PlayerCallback(Player player);
typedef void BoolCallback(bool value);
typedef void PoliciesCallback(List<bool> policies);

@Injectable()
class SocketIoService {
  String serverUrl = 'http://localhost:88';

  Socket socket;
  GameStateService gameStateService;

  SocketIoService(this.gameStateService) {
    socket = io(serverUrl);
  }

  void reconnectTo(String url) {
    socket.disconnect();
    socket.close();
    socket = io(serverUrl);
  }

  void setName(String name) =>
      socket.emit(SocketIoEvents.setName, JSON.encode(name));

  void createLobby(String name) =>
      socket.emit(SocketIoEvents.createLobby, name);

  void joinLobby(int lobbyId) => socket.emit(SocketIoEvents.joinLobby, lobbyId);

  void startGame() => socket.emit(SocketIoEvents.startGame);

  void chooseChancellor(int playerId) {
    gameStateService.setChancellorById(playerId);
    socket.emit(SocketIoEvents.chooseChancellor, playerId);
  }

  void vote(bool vote) {
    gameStateService.votes[gameStateService.player] = vote;
    socket.emit(SocketIoEvents.vote, vote);
  }

  void discardPolicy(bool policy) =>
      socket.emit(SocketIoEvents.discardPolicy, policy);

  void killPlayer(int playerId) {
    gameStateService.killPlayer(gameStateService.getPlayerById(playerId));
    socket.emit(SocketIoEvents.killPlayer, playerId);
  }

  void investigatePlayer(int playerId) =>
      socket.emit(SocketIoEvents.investigatePlayer, playerId);

  void pickNextViceChair(int playerId) =>
      socket.emit(SocketIoEvents.pickNextViceChair, playerId);

  Future<Lobby> whenLobbyJoined() async {
    var completer = new Completer<Lobby>();
    socket.once(SocketIoEvents.lobbyJoined, (String lobbyJson) {
      Lobby lobby = new Lobby.fromJsonString(lobbyJson);
      gameStateService.lobby = lobby;
      completer.complete(lobby);
    });
    return completer.future;
  }

  Future<Role> whenGameStarted() async {
    var completer = new Completer<Role>();
    socket.once(SocketIoEvents.gameStarted, (String gameInfoJson) {
      GameInfo gameInfo = new GameInfo.fromJsonString(gameInfoJson);
      gameStateService.role = gameInfo.role;
      if (gameInfo.separatistsIds != null) {
        gameStateService
            .setFellowSeparatistByPlayerIds(gameInfo.separatistsIds);
      }
      if (gameInfo.palpatineId != null) {
        gameStateService.setPalpatineById(gameInfo.palpatineId);
      }
      completer.complete(gameStateService.role);
    });
    return completer.future;
  }

  Future<Player> whenViceChairSet() async {
    var completer = new Completer<Player>();
    socket.once(SocketIoEvents.viceChairSet, (int viceChairId) {
      gameStateService.setViceChairById(viceChairId);
      completer.complete(gameStateService.viceChair);
    });
    return completer.future;
  }

  Future<Player> whenChancellorSet() async {
    var completer = new Completer<Player>();
    socket.once(SocketIoEvents.chancellorSet, (int viceChairId) {
      gameStateService.setChancellorById(viceChairId);
      completer.complete(gameStateService.chancellor);
    });
    return completer.future;
  }

  Future<bool> whenVoteFinished() async {
    var completer = new Completer<bool>();
    socket.once(SocketIoEvents.voteFinished, (String voteResultJson) {
      Map<int, bool> voteResult = JSON.decode(voteResultJson);
      Map<Player, bool> playerVotes = new Map<Player, bool>();
      voteResult.forEach((playerId, vote) =>
          playerVotes[gameStateService.getPlayerById(playerId)] = vote);
      gameStateService.votes = playerVotes;
      completer.complete(gameStateService.evaluateVote());
    });
    return completer.future;
  }

  Future<bool> whenPolicyRevealed() async {
    var completer = new Completer<bool>();
    socket.once(SocketIoEvents.policyRevealed, (bool policy) {
      if (policy) {
        gameStateService.addLoyalistPolicy();
      } else {
        gameStateService.addSeparatistPolicy();
      }
      completer.complete(policy);
    });
    return completer.future;
  }

  Future<bool> whenIsChancellorPalpatine() async {
    var completer = new Completer<bool>();
    socket.once(SocketIoEvents.chancellorIsPalpatine, (bool isPalpatine) {
      gameStateService.palpatineWin = isPalpatine;
      completer.complete(isPalpatine);
    });
    return completer.future;
  }

  Future<Null> whenViceChairChoosing() async {
    var completer = new Completer<Null>();
    socket.once(SocketIoEvents.viceChairChoosing, (_) => completer.complete());
    return completer.future;
  }

  Future<Null> whenChancellorChoosing() async {
    var completer = new Completer<Null>();
    socket.once(SocketIoEvents.chancellorChoosing, (_) => completer.complete());
    return completer.future;
  }

  Future<List<bool>> whenPoliciesDrawn() async {
    var completer = new Completer<List<bool>>();
    socket.once(SocketIoEvents.policiesDrawn, (String policiesJson) {
      List<bool> policies = JSON.decode(policiesJson);
      completer.complete(policies);
    });
    return completer.future;
  }

  Future<Player> whenPlayerKilled() async {
    var completer = new Completer<Player>();
    socket.once(SocketIoEvents.playerKilled, (int playerId) {
      var killedPlayer = gameStateService.getPlayerById(playerId);
      gameStateService.killPlayer(killedPlayer);
      completer.complete(killedPlayer);
    });
    return completer.future;
  }

  Future<bool> whenMembershipInvestigated() async {
    var completer = new Completer<bool>();
    socket.once(SocketIoEvents.playerInvestigated, (bool membership) {
      completer.complete(membership);
    });
    return completer.future;
  }

  Future<Player> whenViceChairInvestigated() async {
    var completer = new Completer();
    socket.once(SocketIoEvents.viceChairInvestigated, (int playerId) {
      var player = gameStateService.getPlayerById(playerId);
      completer.complete(player);
    });
    return completer.future;
  }
  
  void listenForPlayersVoting() {
    socket.on(SocketIoEvents.playerFinishedVoting, (int playerId) {
      gameStateService.votes[gameStateService.getPlayerById(playerId)] = null;
      if (gameStateService.votes.length == gameStateService.alivePlayers.length) {
        socket.off(SocketIoEvents.playerFinishedVoting);
      }
    });
  }

  Future<List<Lobby>> getLobbies() async {
    var completer = new Completer();
    socket.emit(SocketIoEvents.getLobbies);
    socket.once(SocketIoEvents.lobbies, (String lobbiesJson) {
      List<Lobby> lobbies = JSON
          .decode(lobbiesJson)
          .map((lobbyJson) => new Lobby.fromJsonString(lobbyJson))
          .toList();
      completer.complete(lobbies);
    });
    return completer.future;
  }

  Completer<Player> _playerJoinedCompleter;

  Future<Player> whenPlayerJoined() async {
    stopOnPlayerJoined();
    _playerJoinedCompleter = new Completer();
    socket.once(SocketIoEvents.playerJoined, (String playerJson) {
      Player player = new Player.fromJsonString(playerJson);
      gameStateService.addPlayer(player);
      _playerJoinedCompleter.complete(player);
      _playerJoinedCompleter = null;
    });
    return _playerJoinedCompleter.future;
  }

  Future<Null> stopOnPlayerJoined() async {
    socket.off(SocketIoEvents.playerJoined);
    if (_playerJoinedCompleter != null) {
      _playerJoinedCompleter.completeError(null);
    }
  }
}
