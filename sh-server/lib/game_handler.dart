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

  Map<PlayerSocket, Role> rolesForPlayers = new Map<PlayerSocket, Role>();
  PlayerSocket _president;
  PlayerSocket _chancellor;
  PlayerSocket previousPresident;
  PlayerSocket previousChancellor;
  List<PlayerSocket> killedPlayers = new List<PlayerSocket>();
  List<bool> policyDrawPile = new List<bool>();
  List<bool> policyDiscardPile = new List<bool>();
  int failedGovernmentCounter = 0;
  int liberalEnactedPolicyCount = 0;
  int fascistEnactedPolicyCount = 0;
  List<Function> specialPowers;

  Map<int, Function> specialPowersFunctionMapping;

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
    host.socket.emit(SocketIoEvents.lobbyCreated, JSON.encode(lobby));

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
    handleGovernmentForming();
  }
  
  void setupSpecialPowers() {
    List<int> specialPowersForCurrPlayerCount = SpecialPowers.getSpecialPowersForPlayerAmount(players.length);
    for (var specialPower in specialPowersForCurrPlayerCount) {
      if (specialPower == null) {
        specialPowers.add(null);
      } else {
        specialPowers.add(specialPowersFunctionMapping[specialPower]);
      }
    }
  }

  void setupPolicies() {
    policyDrawPile = new List<bool>();
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

  void handleGovernmentForming() {
    formGovernment();
    handleVote();
  }

  void formGovernment() {
    president.socket.once(SocketIoEvents.chooseChancellor, (int playerId) {
      var selectedChancellor = getPlayerById(playerId);
      if (!isPlayerValidForChancellor(selectedChancellor)) {
        print(
            'Error: Player ${selectedChancellor.player.name} (id: ${selectedChancellor.player.id} is not allowed to be chancellor!');
      }
      chancellor = selectedChancellor;
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
      });
    });
  }

  void handleLegislativeSession() {
    if (isHitlerWin()) {
      room.emit(SocketIoEvents.chancellorIsHitler);
      fascistWin();
      return;
    }
    List<bool> drawnPolicies = drawThreePolicies();
    refillPoliciesIfNecessary();
    president.socket
        .emit(SocketIoEvents.policiesDrawn, JSON.encode(drawnPolicies));
    president.socket.to(roomId).emit(SocketIoEvents.presidentChoosing);
    president.socket.once(SocketIoEvents.discardPolicy, (bool policy) {
      drawnPolicies.remove(policy);
      policyDiscardPile.add(policy);

      chancellor.socket
          .emit(SocketIoEvents.policiesDrawn, JSON.encode(drawnPolicies));
      chancellor.socket.to(roomId).emit(SocketIoEvents.chancellorChoosing);
      chancellor.socket.once(SocketIoEvents.discardPolicy, (bool policy) {
        drawnPolicies.remove(policy);
        policyDiscardPile.add(policy);

        bool finalPolicy = drawnPolicies[0];
        handlePolicy(finalPolicy);
        setNextPlayerAsPresident();
        handleGovernmentForming();
      });
    });
  }

  void setNextPlayerAsPresident() {
    int currentPresidentIndex = players.indexOf(president);
    int nextPresidentIndex = (currentPresidentIndex + 1) % players.length;
    president = players[nextPresidentIndex];
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
    }
  }

  void enactFascistPolicy([bool ingnorePresidentalSpecialPower = false]) {
    fascistEnactedPolicyCount++;
    if (fascistEnactedPolicyCount == fascistPolicyWinCount) {
      fascistWin();
    }
    if (!ingnorePresidentalSpecialPower) {
      handleSpecialPower();
    }
  }

  void handleSpecialPower() {
    var specialPower = specialPowers[fascistEnactedPolicyCount];
    if (specialPower != null) {
      specialPower();
    }
  }

  void handlePolicyPeek() {
    // TODO: implement policy peek
  }

  void handleLoyaltyInvestigation() {
    // TODO: implement loyalty investigation
  }

  void handleSpecialElection() {
    // TODO: implement special election
  }

  void handleExecution() {
    // TODO: implement execution
  }

  List<bool> drawThreePolicies() {
    var drawnPolicies = new List<bool>();
    for (var i = 0; i < 3; i++) {
      drawnPolicies.add(drawOnePolicy());
    }
    return drawnPolicies;
  }

  bool isHitlerWin() {
    return fascistEnactedPolicyCount >= 3 &&
        rolesForPlayers[chancellor].id == hitlerRoleId;
  }

  void revealFirstPolicy() {
    bool policy = drawOnePolicy();
    room.emit(SocketIoEvents.policyRevealed, JSON.encode(policy));
    if (policy) {
      enactLiberalPolicy();
    } else {
      enactFascistPolicy(true);
    }
    refillPoliciesIfNecessary();
  }

  void refillPoliciesIfNecessary() {
    if (policyDrawPile.length >= 3) {
      return;
    }
    policyDiscardPile.addAll(policyDrawPile);
    policyDrawPile = policyDiscardPile;
    policyDiscardPile = new List<bool>();
    policyDrawPile.shuffle();
  }

  void fascistWin() {
    room.emit(SocketIoEvents.fascistsWon);
  }

  void liberalWin() {
    room.emit(SocketIoEvents.liberalsWon);
  }

  void resetTermLimits() {
    previousChancellor = null;
    previousPresident = null;
  }

  bool drawOnePolicy() {
    return policyDrawPile.removeAt(policyDrawPile.length - 1);
  }

  void handleFailedGovernment() {
    failedGovernmentCounter++;
    if (failedGovernmentCounter == 4) {
      resetTermLimits();
      revealFirstPolicy();
      failedGovernmentCounter = 0;
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

  Map<PlayerSocket, Role> randomlyAssignRoles() {
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
