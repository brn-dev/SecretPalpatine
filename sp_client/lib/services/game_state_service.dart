import 'package:angular/core.dart';

import 'package:sp_shared/sp_shared.dart';


@Injectable()
class GameStateService {
  Player player;
  Lobby lobby;

  // Board State
  int seperatistEnactedPolicies;
  int loyalistEnactedPolicies;

  // Information
  Role role;
  List<Player> fellowSeperatists;
  Player palpatine;

  // Players
  Player viceChair;
  Player chancellor;
  List<Player> killedPlayers;
  List<Player> get players => lobby?.players;
  List<Player> get alivePlayers => players?.where((player) => !killedPlayers.contains(player));

  // Vote
  Map<Player, bool> votes;
  bool get voteResult => evaluateVote();

  GameStateService() {
    reset();
  }

  void reset() {
    player = null;
    seperatistEnactedPolicies = 0;
    loyalistEnactedPolicies = 0;
    role = null;
    fellowSeperatists = null;
    palpatine = null;
    viceChair = null;
    chancellor = null;
    killedPlayers = new List<Player>();
  }

  void addSeperatistPolicy() => seperatistEnactedPolicies++;

  void addLoyalistPolicy() => loyalistEnactedPolicies++;

  Player getPlayerById(int playerId) =>
      players.singleWhere((player) => player.id == playerId);

  void setViceChairById(int playerId) => viceChair = getPlayerById(playerId);

  void setChancellorById(int playerId) => chancellor = getPlayerById(playerId);

  void setPalpatineById(int playerId) => palpatine = getPlayerById(playerId);

  void setFellowSeperatistByPlayerIds(List<int> playerIds) {
    if (playerIds == null) {
      fellowSeperatists = null;
      return;
    }
    
    fellowSeperatists =
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
