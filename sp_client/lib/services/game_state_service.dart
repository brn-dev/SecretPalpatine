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

    // DEBUG
    player = new Player(1, 'Brn');
    role = Roles.separatist1;
    fellowSeparatists = [
      new Player(2, 'Josh')
    ];
    palpatine = new Player(2, 'Josh');
    lobby = new Lobby.withPlayers(1, 'Lob', [
      new Player(1, 'Brn'),
      new Player(2, 'Josh'),
      new Player(3, 'Dnl'),
      new Player(4, 'Kevin'),
      new Player(5, 'Martin'),
      new Player(6, 'Kruki'),
      new Player(7, 'Thomas'),
      new Player(8, 'Jess'),
      new Player(9, 'Seiberl'),
      new Player(10, 'Christian Krause'),
    ]);
    viceChair = lobby.players[0];
    chancellor = lobby.players[1];
    prevViceChair = lobby.players[2];
    prevChancellor = lobby.players[0];
    votes = {
      lobby.players[0]: true,
      lobby.players[1]: true,
      lobby.players[2]: false,
      lobby.players[3]: false,
      lobby.players[4]: true,
      lobby.players[5]: false,
      lobby.players[6]: true,
      lobby.players[7]: false,
      lobby.players[8]: true,
      lobby.players[9]: false,
    };
  }

  void addSeparatistPolicy() => separatistEnactedPolicies++;

  void addLoyalistPolicy() => loyalistEnactedPolicies++;

  Player getPlayerById(int playerId) =>
      players.singleWhere((player) => player.id == playerId);

  void setViceChairById(int playerId) => viceChair = getPlayerById(playerId);

  void setChancellorById(int playerId) => chancellor = getPlayerById(playerId);

  void setPalpatineById(int playerId) => palpatine = getPlayerById(playerId);

  void setFellowSeparatistByPlayerIds(List<int> playerIds) {
    if (playerIds == null) {
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
