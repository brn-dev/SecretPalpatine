import 'package:angular/core.dart';

import 'package:sh_shared/sh_shared.dart';

@Injectable()
class GameStateService {
  Player player;
  Lobby lobby;

  // Board State
  int fascistEnactedPolicies;
  int liberalEnactedPolicies;

  // Information
  Role role;
  List<Player> fellowFascists;
  Player hitler;

  // Players
  Player president;
  Player chancellor;
  List<Player> killedPlayers;
  List<Player> get players => lobby?.players ?? null;
  List<Player> get alivePlayers => players?.where((player) => !killedPlayers.contains(player)) ?? null;

  // Vote
  Map<Player, bool> votes;
  bool get voteResult => evaluateVote();

  GameStateService() {
    reset();
  }

  void reset() {
    player = null;
    fascistEnactedPolicies = 0;
    liberalEnactedPolicies = 0;
    role = null;
    fellowFascists = null;
    hitler = null;
    president = null;
    chancellor = null;
    killedPlayers = new List<Player>();
  }

  void addFascistPolicy() => fascistEnactedPolicies++;

  void addLiberalPolicy() => liberalEnactedPolicies++;

  Player getPlayerById(int playerId) =>
      players.singleWhere((player) => player.id == playerId);

  void setPresidentById(int playerId) => president = getPlayerById(playerId);

  void setChancellorById(int playerId) => chancellor = getPlayerById(playerId);

  void setHitlerById(int playerId) => hitler = getPlayerById(playerId);

  void setFellowFascistByPlayerIds(List<int> playerIds) {
    if (playerIds == null) {
      fellowFascists = null;
      return;
    }
    fellowFascists =
        playerIds.map((playerId) => getPlayerById(playerId)).toList();
  }

  void addPlayer(Player player) {
    lobby.addPlayer(player);
  }

  bool evaluateVote() {
    if (votes == null) {
      return null;
    }
    var yesCount = 0;
    var noCount = 0;
    votes.forEach((player, vote) {
      if (vote) {
        yesCount++;
      } else {
        noCount++;
      }
    });
    return yesCount > noCount;
  }

  void killPlayer(Player player) => killedPlayers.add(player);
}
