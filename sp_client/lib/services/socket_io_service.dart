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

  void chooseChancellor(int playerId) =>
      socket.emit(SocketIoEvents.chooseChancellor, playerId);

  void vote(bool vote) => socket.emit(SocketIoEvents.vote, vote);

  void discardPolicy(bool policy) =>
      socket.emit(SocketIoEvents.discardPolicy, policy);

  void killPlayer(int playerId) =>
      socket.emit(SocketIoEvents.killPlayer, playerId);

  void investigatePlayer(int playerId) =>
      socket.emit(SocketIoEvents.investigatePlayer, playerId);

  void pickNextViceChair(int playerId) =>
      socket.emit(SocketIoEvents.pickNextViceChair, playerId);

  void whenLobbyJoined(VoidCallback callback) =>
      socket.once(SocketIoEvents.lobbyJoined, (String lobbyJson) {
        Lobby lobby = new Lobby.fromJsonString(lobbyJson);
        gameStateService.lobby = lobby;
        callback();
      });

  void whenGameStarted(VoidCallback callback) =>
      socket.once(SocketIoEvents.gameStarted, (String gameInfoJson) {
        GameInfo gameInfo = new GameInfo.fromJsonString(gameInfoJson);
        gameStateService.role = gameInfo.role;
        if (gameInfo.seperatistsIds != null) {
          gameStateService.setFellowSeperatistByPlayerIds(gameInfo.seperatistsIds);
        }
        if (gameInfo.palpatineId != null) {
          gameStateService.setPalpatineById(gameInfo.palpatineId);
        }
      });

  void whenViceChairSet(VoidCallback callback) =>
      socket.once(SocketIoEvents.viceChairSet, (int viceChairId) {
        gameStateService.setViceChairById(viceChairId);
        callback();
      });

  void whenChancellorSet(VoidCallback callback) =>
      socket.once(SocketIoEvents.chancellorSet, (int viceChairId) {
        gameStateService.setChancellorById(viceChairId);
        callback();
      });

  void whenVoteFinished(VoidCallback callback) =>
      socket.once(SocketIoEvents.voteFinished, (String voteResultJson) {
        Map<int, bool> voteResult = JSON.decode(voteResultJson);
        Map<Player, bool> playerVotes = new Map<Player, bool>();
        voteResult.forEach((playerId, vote) =>
            playerVotes[gameStateService.getPlayerById(playerId)] = vote);
        gameStateService.votes = playerVotes;
        callback();
      });

  void whenPolicyRevealed(BoolCallback policyCallback) =>
      socket.once(SocketIoEvents.policyRevealed, (bool policy) {
        if (policy) {
          gameStateService.addLoyalistPolicy();
        } else {
          gameStateService.addSeperatistPolicy();
        }
        policyCallback(policy);
      });

  void whenChancellorIsPalpatine(BoolCallback isPalpatineCallback) => socket.once(
      SocketIoEvents.chancellorIsPalpatine,
      (bool isPalpatine) => isPalpatineCallback(isPalpatine));

  void whenViceChairChoosing(VoidCallback callback) =>
      socket.once(SocketIoEvents.viceChairChoosing, (_) => callback());

  void whenChancellorChoosing(VoidCallback callback) =>
      socket.once(SocketIoEvents.chancellorChoosing, (_) => callback());

  void whenPoliciesDrawn(PoliciesCallback callback) =>
      socket.once(SocketIoEvents.policiesDrawn, (String policiesJson) {
        List<bool> policies = JSON.decode(policiesJson);
        callback(policies);
      });

  void whenPlayerKilled(PlayerCallback callback) =>
      socket.once(SocketIoEvents.playerKilled, (int playerId) {
        var killedPlayer = gameStateService.getPlayerById(playerId);
        gameStateService.killPlayer(killedPlayer);
        callback(killedPlayer);
      });

  void whenPlayerInvestigated(BoolCallback membershipCallback) =>
      socket.once(SocketIoEvents.playerInvestigated, (bool membership) {
        membershipCallback(membership);
      });

  void whenViceChairInvestigated(PlayerCallback callback) =>
      socket.once(SocketIoEvents.viceChairInvestigated, (int playerId) {
        var player = gameStateService.getPlayerById(playerId);
        callback(player);
      });

  void getLobbies(LobbiesCallback callback) {
    socket.emit(SocketIoEvents.getLobbies);
    socket.once(SocketIoEvents.lobbies, (String lobbiesJson) {
      List<Lobby> lobbies = JSON
          .decode(lobbiesJson)
          .map((lobbyJson) => new Lobby.fromJsonString(lobbyJson))
          .toList();
      callback(lobbies);
    });
  }

  void onPlayerJoined(PlayerCallback callback) =>
      socket.on(SocketIoEvents.playerJoined, (String playerJson) {
        Player player = new Player.fromJsonString(playerJson);
        gameStateService.addPlayer(player);
        callback(player);
      });

  void stopOnPlayerJoined() {
    socket.off(SocketIoEvents.playerJoined);
  }
}
