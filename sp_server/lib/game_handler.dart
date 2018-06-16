import 'dart:convert';
import 'dart:math';
import 'models/player_socket.dart';
import 'models/policy_pile.dart';
import 'package:sp_shared/sp_shared.dart';
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
  PlayerSocket _viceChair;
  PlayerSocket _chancellor;
  PlayerSocket previousViceChair;
  PlayerSocket previousChancellor;
  PlayerSocket viceChairBeforeSpecialElection = null;
  List<PlayerSocket> killedPlayers = new List<PlayerSocket>();
  PolicyPile policyDrawPile = new PolicyPile();
  PolicyPile policyDiscardPile = new PolicyPile();
  int failedGovernmentCounter = 0;
  int loyalistEnactedPolicyCount = 0;
  int separatistEnactedPolicyCount = 0;
  List<SpecialPowerFunction> specialPowers;

  Map<int, SpecialPowerFunction> specialPowersFunctionMapping;

  static const int loyalistPolicyWinCount = 5;
  static const int separatistPolicyWinCount = 6;
  static final int palpatineRoleId = Roles.palpatine.id;

  bool get palpatineKnowsSeparatists => players.length <= 6;

  List<PlayerSocket> get alivePlayers =>
      players.where((player) => !killedPlayers.contains(player)).toList();

  PlayerSocket get viceChair => _viceChair;
  set viceChair(PlayerSocket player) {
    _viceChair = player;
    room.emit(SocketIoEvents.viceChairSet, player.player.id);
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

  PlayerSocket getNextViceChair() {
    return getNextPlayer(viceChair);
  }

  bool isAlive(PlayerSocket player) {
    return !killedPlayers.contains(player);
  }

  bool isPalpatineWin() {
    return separatistEnactedPolicyCount >= 3 &&
        rolesForPlayers[chancellor].id == palpatineRoleId;
  }

  bool isPlayerValidForChancellor(PlayerSocket player) {
    if (!alivePlayers.contains(player)) {
      return false;
    }
    if (player == previousViceChair || player == previousChancellor) {
      return false;
    }
    return true;
  }

  bool isValidPlayerCount() {
    return players.length >= 5 && players.length <= 10;
  }

  void resetTermLimits() {
    previousChancellor = null;
    previousViceChair = null;
  }

  GameInfo createGameInfo(
      Role role, List<int> separatistPlayerIds, int palpatinePlayerId) {
    var gameInfo = new GameInfo(role, [], null);
    if (!role.membership && (role.id != palpatineRoleId || palpatineKnowsSeparatists)) {
      gameInfo.separatistsIds = separatistPlayerIds;
    }
    if (!role.membership) {
      gameInfo.palpatineId = palpatinePlayerId;
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
    viceChair = players[random.nextInt(players.length)];
    formGovernment();
    
  }

  void setupPolicies() {
    policyDrawPile = new PolicyPile();
    var separatistPolicyCount = 11;
    var loyalistPolicyCount = 6;
    for (var i = 0; i < separatistPolicyCount; i++) {
      policyDrawPile.add(false);
    }
    for (var i = 0; i < loyalistPolicyCount; i++) {
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
    var separatistPlayerIds = new List<int>();
    var palpatinePlayerId = -1;
    rolesForPlayers.forEach((player, role) {
      if (!role.membership) {
        separatistPlayerIds.add(player.player.id);
      }
      if (role.id == palpatineRoleId) {
        palpatinePlayerId = player.player.id;
      }
    });
    rolesForPlayers.forEach((player, role) {
      var gameInfo = createGameInfo(role, separatistPlayerIds, palpatinePlayerId);
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
    viceChair.socket.once(SocketIoEvents.chooseChancellor, (int playerId) {
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
      previousViceChair = viceChair;
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
    setNextPlayerAsViceChair();
    formGovernment();
  }

  void revealFirstPolicy() {
    bool policy = policyDrawPile.draw();
    room.emit(SocketIoEvents.policyRevealed, JSON.encode(policy));
    if (policy) {
      enactLoyalistPolicy();
    } else {
      enactSeparatistPolicy(true);
    }
    refillPoliciesIfNecessary();
  }

  void setNextPlayerAsViceChair() {
    if (viceChairBeforeSpecialElection == null) {
      viceChair = getNextViceChair();
    } else {
      viceChair = getNextPlayer(viceChairBeforeSpecialElection);
      viceChairBeforeSpecialElection = null;
    }
  }

  void handleLegislativeSession() {
    if (isPalpatineWin()) {
      room.emit(SocketIoEvents.chancellorIsPalpatine);
      separatistWin();
      return;
    }
    List<bool> drawnPolicies = policyDrawPile.drawMany(3);
    refillPoliciesIfNecessary();
    handleViceChairsDiscard(drawnPolicies);
  }

  void handleViceChairsDiscard(List<bool> drawnPolicies) {
    viceChair.socket
        .emit(SocketIoEvents.policiesDrawn, JSON.encode(drawnPolicies));
    viceChair.socket.to(roomId).emit(SocketIoEvents.viceChairChoosing);
    viceChair.socket.once(SocketIoEvents.discardPolicy, (bool policy) {
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
      enactLoyalistPolicy();
    } else {
      enactSeparatistPolicy();
    }
  }

  void enactLoyalistPolicy() {
    loyalistEnactedPolicyCount++;
    if (loyalistEnactedPolicyCount == loyalistPolicyWinCount) {
      loyalistWin();
      return;
    }
    setNextPlayerAsViceChair();
    formGovernment();
  }

  void enactSeparatistPolicy([bool ingnoreViceChairalSpecialPower = false]) {
    separatistEnactedPolicyCount++;
    if (separatistEnactedPolicyCount == separatistPolicyWinCount) {
      separatistWin();
      return;
    }
    var callback = () {
      setNextPlayerAsViceChair();
      formGovernment();
    };
    if (!ingnoreViceChairalSpecialPower) {
      handleSpecialPower(callback);
    }
    callback();
  }

  void handleSpecialPower(Function callback) {
    var specialPower = specialPowers[separatistEnactedPolicyCount];
    if (specialPower != null) {
      specialPower(callback);
    }
  }

  void handlePolicyPeek(Function callback) {
    List<bool> peekedPolicies = policyDrawPile.peekMany(3);
    viceChair.socket
        .emit(SocketIoEvents.policiesDrawn, JSON.encode(peekedPolicies));
    callback();
  }

  void handleLoyaltyInvestigation(Function callback) {
    viceChair.socket.once(SocketIoEvents.investigatePlayer, (int playerId) {
      PlayerSocket chosenPlayer = getPlayerById(playerId);
      viceChair.socket.emit(SocketIoEvents.playerInvestigated,
          JSON.encode(rolesForPlayers[chosenPlayer].membership));
      viceChair.socket.to(roomId).emit(SocketIoEvents.viceChairInvestigated);
      callback();
    });
  }

  void handleSpecialElection(Function callback) {
    viceChair.socket.once(SocketIoEvents.pickNextViceChair, (int playerId) {
      viceChairBeforeSpecialElection = viceChair;
      viceChair = getPlayerById(playerId);
      formGovernment();
    });
  }

  void handleExecution(Function callback) {
    viceChair.socket.once(SocketIoEvents.killPlayer, (int playerId) {
      var killedPlayer = getPlayerById(playerId);
      killedPlayers.add(killedPlayer);
      viceChair.socket.to(roomId).emit(
          SocketIoEvents.playerKilled, JSON.encode(killedPlayer.player.id));
      callback();
    });
  }

  void separatistWin() {
    room.emit(SocketIoEvents.separatistsWon);
  }

  void loyalistWin() {
    room.emit(SocketIoEvents.loyalistsWon);
  }
}
