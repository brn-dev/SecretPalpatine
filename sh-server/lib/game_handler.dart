import 'dart:convert';
import 'dart:math';
import 'models/player_socket.dart';
import 'models/policy_pile.dart';
import 'package:sh_shared/sh_shared.dart';
import 'package:socket_io/socket_io.dart';
import 'package:socket_io/src/namespace.dart';

typedef void SpecialPowerFunction(Function callback);

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

  Map<PlayerSocket, Role> rolesForPlayers = new Map<PlayerSocket, Role>();
  PlayerSocket _president;
  PlayerSocket _chancellor;
  PlayerSocket previousPresident;
  PlayerSocket previousChancellor;
  PlayerSocket presidentBeforeSpecialElection = null;
  List<PlayerSocket> killedPlayers = new List<PlayerSocket>();
  PolicyPile policyDrawPile = new PolicyPile();
  PolicyPile policyDiscardPile = new PolicyPile();
  int failedGovernmentCounter = 0;
  int liberalEnactedPolicyCount = 0;
  int fascistEnactedPolicyCount = 0;
  List<SpecialPowerFunction> specialPowers;

  Map<int, SpecialPowerFunction> specialPowersFunctionMapping;

  static const int liberalPolicyWinCount = 5;
  static const int fascistPolicyWinCount = 6;
  static final int hitlerRoleId = Roles.hitler.id;

  bool get hitlerKnowsFascists => players.length <= 6;

  List<PlayerSocket> get alivePlayers =>
      players.where((player) => !killedPlayers.contains(player)).toList();

  PlayerSocket get president => _president;
  set president(PlayerSocket player) {
    _president = player;
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
    host.socket.once(SocketIoEvents.startGame, (_) => startGame());

    specialPowersFunctionMapping = {
      SpecialPowers.policyPeek: handlePolicyPeek,
      SpecialPowers.loyaltyInvestigation: handleLoyaltyInvestigation,
      SpecialPowers.specialElection: handleSpecialElection,
      SpecialPowers.execution: handleExecution
    };
  }

  PlayerSocket getPlayerById(int playerId) {
    for (var player in players) {
      if (player.player.id == playerId) {
        return player;
      }
    }
    return null;
  }

  PlayerSocket getNextPlayer(PlayerSocket relativeTo) {
    int currIndex = players.indexOf(relativeTo);
    do {
      currIndex = (currIndex + 1) % players.length;
    } while (!isAlive(players[currIndex]));
    return players[currIndex];
  }

  PlayerSocket getNextPresident() {
    return getNextPlayer(president);
  }

  bool isAlive(PlayerSocket player) {
    return !killedPlayers.contains(player);
  }

  bool isHitlerWin() {
    return fascistEnactedPolicyCount >= 3 &&
        rolesForPlayers[chancellor].id == hitlerRoleId;
  }

  bool isPlayerValidForChancellor(PlayerSocket player) {
    if (!alivePlayers.contains(player)) {
      return false;
    }
    if (player == previousPresident || player == previousChancellor) {
      return false;
    }
    return true;
  }

  bool isValidPlayerCount() {
    return players.length >= 5 && players.length <= 10;
  }

  void resetTermLimits() {
    previousChancellor = null;
    previousPresident = null;
  }

  GameInfo createGameInfo(
      Role role, List<int> fascistPlayerIds, int hitlerPlayerId) {
    var gameInfo = new GameInfo(role, [], null);
    if (!role.membership && (role.id != hitlerRoleId || hitlerKnowsFascists)) {
      gameInfo.fascistsIds = fascistPlayerIds;
    }
    if (!role.membership) {
      gameInfo.hitlerId = hitlerPlayerId;
    }
    return gameInfo;
  }

  void refillPoliciesIfNecessary() {
    if (policyDrawPile.length >= 3) {
      return;
    }
    policyDrawPile.addAllFromPile(policyDiscardPile);
    policyDiscardPile.clear();
    policyDrawPile.shuffle();
  }

  join(PlayerSocket playerSocket) {
    lobby.addPlayer(playerSocket.player);
    players.add(playerSocket);
    playerSocket.socket.join(roomId);

    playerSocket.socket.emit(SocketIoEvents.lobbyJoined, JSON.encode(lobby));

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

  void startGame() {
    if (!isValidPlayerCount()) {
      print(
          'Error: lobby ${lobby.id} tried to start with ${players.length} players');
      host.socket.on(SocketIoEvents.startGame, (_) => startGame());
      return;
    }
    failedGovernmentCounter = 0;
    setupPolicies();
    setupSpecialPowers();
    assignRoles();
    president = players[random.nextInt(players.length)];
    formGovernment();
  }

  void setupPolicies() {
    policyDrawPile = new PolicyPile();
    var fascistPolicyCount = 11;
    var liberalPolicyCount = 6;
    for (var i = 0; i < fascistPolicyCount; i++) {
      policyDrawPile.add(false);
    }
    for (var i = 0; i < liberalPolicyCount; i++) {
      policyDrawPile.add(true);
    }
    policyDrawPile.shuffle();
  }

  void setupSpecialPowers() {
    List<int> specialPowersForCurrPlayerCount =
        SpecialPowers.getSpecialPowersForPlayerAmount(players.length);
    for (var specialPower in specialPowersForCurrPlayerCount) {
      if (specialPower == null) {
        specialPowers.add(null);
      } else {
        specialPowers.add(specialPowersFunctionMapping[specialPower]);
      }
    }
  }

  void assignRoles() {
    rolesForPlayers = randomlyAssignRoles();
    var fascistPlayerIds = new List<int>();
    var hitlerPlayerId = -1;
    rolesForPlayers.forEach((player, role) {
      if (!role.membership) {
        fascistPlayerIds.add(player.player.id);
      }
      if (role.id == hitlerRoleId) {
        hitlerPlayerId = player.player.id;
      }
    });
    rolesForPlayers.forEach((player, role) {
      var gameInfo = createGameInfo(role, fascistPlayerIds, hitlerPlayerId);
      player.socket.emit(SocketIoEvents.gameStarted, gameInfo);
    });
  }

  Map<PlayerSocket, Role> randomlyAssignRoles() {
    var roles = Roles.getRolesForPlayerAmount(players.length);
    var map = new Map<PlayerSocket, Role>();
    players.forEach((player) {
      var randomRole = roles.removeAt(random.nextInt(roles.length));
      map[player] = randomRole;
    });
    return map;
  }

  void formGovernment() {
    president.socket.once(SocketIoEvents.chooseChancellor, (int playerId) {
      var selectedChancellor = getPlayerById(playerId);
      if (!isPlayerValidForChancellor(selectedChancellor)) {
        print(
            'Error: Player ${selectedChancellor.player.name} (id: ${selectedChancellor.player.id} is not allowed to be chancellor!');
      }
      chancellor = selectedChancellor;
      handleVote();
    });
  }

  void handleVote() {
    Map<int, bool> votePerPlayer = new Map<int, bool>();
    players.forEach((player) {
      player.socket.once(SocketIoEvents.vote, (bool vote) {
        votePerPlayer[player.player.id] = vote;
        player.socket.to(roomId).emit(
            SocketIoEvents.playerFinishedVoting, JSON.encode(player.player.id));
        if (votePerPlayer.length == players.length) {
          finishVote(votePerPlayer);
        }
      });
    });
  }

  void finishVote(Map<int, bool> votePerPlayer) {
    room.emit(SocketIoEvents.voteFinished, votePerPlayer);
    bool voteResult = evaluateVote(votePerPlayer);
    if (voteResult) {
      previousPresident = president;
      previousChancellor = chancellor;
      handleLegislativeSession();
      failedGovernmentCounter = 0;
    } else {
      handleFailedGovernment();
    }
  }

  bool evaluateVote(Map<int, bool> votePerPlayer) {
    int amountOfYesVotes = 0;
    int amountOfNOVotes = 0;
    votePerPlayer.forEach((player, vote) {
      if (vote == null) {
        return;
      } else if (vote) {
        amountOfYesVotes++;
      } else {
        amountOfNOVotes++;
      }
    });
    bool voteResult = amountOfYesVotes > amountOfNOVotes;
    return voteResult;
  }

  void handleFailedGovernment() {
    failedGovernmentCounter++;
    if (failedGovernmentCounter == 4) {
      resetTermLimits();
      revealFirstPolicy();
      failedGovernmentCounter = 0;
    }
    setNextPlayerAsPresident();
    formGovernment();
  }

  void revealFirstPolicy() {
    bool policy = policyDrawPile.draw();
    room.emit(SocketIoEvents.policyRevealed, JSON.encode(policy));
    if (policy) {
      enactLiberalPolicy();
    } else {
      enactFascistPolicy(true);
    }
    refillPoliciesIfNecessary();
  }

  void setNextPlayerAsPresident() {
    if (presidentBeforeSpecialElection == null) {
      president = getNextPresident();
    } else {
      president = getNextPlayer(presidentBeforeSpecialElection);
      presidentBeforeSpecialElection = null;
    }
  }

  void handleLegislativeSession() {
    if (isHitlerWin()) {
      room.emit(SocketIoEvents.chancellorIsHitler);
      fascistWin();
      return;
    }
    List<bool> drawnPolicies = policyDrawPile.drawMany(3);
    refillPoliciesIfNecessary();
    handlePresidentsDiscard(drawnPolicies);
  }

  void handlePresidentsDiscard(List<bool> drawnPolicies) {
    president.socket
        .emit(SocketIoEvents.policiesDrawn, JSON.encode(drawnPolicies));
    president.socket.to(roomId).emit(SocketIoEvents.presidentChoosing);
    president.socket.once(SocketIoEvents.discardPolicy, (bool policy) {
      drawnPolicies.remove(policy);
      policyDiscardPile.add(policy);

      handleChancellorDiscard(drawnPolicies);
    });
  }

  void handleChancellorDiscard(List<bool> drawnPolicies) {
    chancellor.socket
        .emit(SocketIoEvents.policiesDrawn, JSON.encode(drawnPolicies));
    chancellor.socket.to(roomId).emit(SocketIoEvents.chancellorChoosing);
    chancellor.socket.once(SocketIoEvents.discardPolicy, (bool policy) {
      drawnPolicies.remove(policy);
      policyDiscardPile.add(policy);

      bool finalPolicy = drawnPolicies[0];
      handlePolicy(finalPolicy);
    });
  }

  void handlePolicy(bool policy) {
    if (policy) {
      enactLiberalPolicy();
    } else {
      enactFascistPolicy();
    }
  }

  void enactLiberalPolicy() {
    liberalEnactedPolicyCount++;
    if (liberalEnactedPolicyCount == liberalPolicyWinCount) {
      liberalWin();
      return;
    }
    setNextPlayerAsPresident();
    formGovernment();
  }

  void enactFascistPolicy([bool ingnorePresidentalSpecialPower = false]) {
    fascistEnactedPolicyCount++;
    if (fascistEnactedPolicyCount == fascistPolicyWinCount) {
      fascistWin();
      return;
    }
    var callback = () {
      setNextPlayerAsPresident();
      formGovernment();
    };
    if (!ingnorePresidentalSpecialPower) {
      handleSpecialPower(callback);
    }
    callback();
  }

  void handleSpecialPower(Function callback) {
    var specialPower = specialPowers[fascistEnactedPolicyCount];
    if (specialPower != null) {
      specialPower(callback);
    }
  }

  void handlePolicyPeek(Function callback) {
    List<bool> peekedPolicies = policyDrawPile.peekMany(3);
    president.socket
        .emit(SocketIoEvents.policiesDrawn, JSON.encode(peekedPolicies));
    callback();
  }

  void handleLoyaltyInvestigation(Function callback) {
    president.socket.once(SocketIoEvents.investigatePlayer, (int playerId) {
      PlayerSocket chosenPlayer = getPlayerById(playerId);
      president.socket.emit(SocketIoEvents.playerInvestigated,
          JSON.encode(rolesForPlayers[chosenPlayer].membership));
      president.socket.to(roomId).emit(SocketIoEvents.presidentInvestigated);
      callback();
    });
  }

  void handleSpecialElection(Function callback) {
    president.socket.once(SocketIoEvents.pickNextPresident, (int playerId) {
      presidentBeforeSpecialElection = president;
      president = getPlayerById(playerId);
      formGovernment();
    });
  }

  void handleExecution(Function callback) {
    president.socket.once(SocketIoEvents.killPlayer, (int playerId) {
      var killedPlayer = getPlayerById(playerId);
      killedPlayers.add(killedPlayer);
      president.socket.to(roomId).emit(
          SocketIoEvents.playerKilled, JSON.encode(killedPlayer.player.id));
      callback();
    });
  }

  void fascistWin() {
    room.emit(SocketIoEvents.fascistsWon);
  }

  void liberalWin() {
    room.emit(SocketIoEvents.liberalsWon);
  }
}
