import 'package:angular/core.dart';

import 'package:sp_shared/sp_shared.dart';

@Injectable()
class GameStateService {
  Player player;
  Lobby lobby;

  // Board State
  int separatistEnactedPolicies;
  int loyalistEnactedPolicies;
  int policyDrawCount;
  int policyDiscardCount;

  // Information
  Role role;
  List<Player> fellowSeparatists;
  Player palpatine;

  // Players
  Player viceChair;
  Player chancellor;
  Player prevViceChair;
  Player prevChancellor;
  List<Player> killedPlayers;
  List<Player> get players => lobby?.players ?? new List<Player>();
  List<Player> get alivePlayers =>
      players?.where((player) => !killedPlayers.contains(player));

  // Vote
  Map<Player, bool> votes;
  bool get voteResult => evaluateVote();

  GameStateService() {
    print('in constructor');
    reset();
  }

  void reset() {
    player = null;
    separatistEnactedPolicies = 0;
    loyalistEnactedPolicies = 0;
    policyDrawCount = 17;
    policyDiscardCount = 0;
    role = null;
    fellowSeparatists = null;
    palpatine = null;
    viceChair = null;
    chancellor = null;
    prevViceChair = null;
    prevChancellor = null;
    killedPlayers = new List<Player>();
    votes = new Map<Player, bool>();
  }

  void addSeparatistPolicy() => separatistEnactedPolicies++;

  void addLoyalistPolicy() => loyalistEnactedPolicies++;

  Player getPlayerById(int playerId) {
      print(playerId);
      players.singleWhere((player) => player.id == playerId);
      }

  void setViceChairById(int playerId) => viceChair = getPlayerById(playerId);

  void setChancellorById(int playerId) => chancellor = getPlayerById(playerId);

  void setPalpatineById(int playerId) => palpatine = getPlayerById(playerId);

  void setFellowSeparatistByPlayerIds(List<int> playerIds) {
    if (playerIds == null || playerIds.length == 0) {
      fellowSeparatists = null;
      return;
    }
    fellowSeparatists =
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
