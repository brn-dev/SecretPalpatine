
class SocketIoEvents {
  // Server to Client
  static const String playerCreated = 'player-created';
  static const String lobbyJoined = 'lobby-joined';
  static const String lobbies = 'lobbies';
  static const String playerJoined = 'player-joined';
  static const String gameStarted = 'game-started';
  static const String viceChairSet = 'viceChair-set';
  static const String chancellorSet = 'chancellor-set';
  static const String playerFinishedVoting = 'player-finished-voting';
  static const String voteFinished = 'vote-finished';
  static const String policyRevealed = 'policy-revealed';
  static const String chancellorIsPalpatine = 'chancellor-palpatine';
  static const String viceChairChoosing = 'viceChair-choosing';
  static const String chancellorChoosing = 'chancellor-choosing';
  static const String policiesDrawn = 'policies-drawn';
  static const String loyalistsWon = 'loyalists-won';
  static const String separatistsWon = 'separatists-won';
  static const String playerKilled = 'player-killed';
  static const String playerInvestigated = 'player-investigated';
  static const String viceChairInvestigated = 'viceChair-investigated';
  static const String viceChairPickingNextViceChair = 'viceChair-picking-next-viceChair';
  static const String lobbyCreated = "lobby-created";
  static const String governmentVetoed = 'government-vetoed';
  static const String palpatineKilled = 'palpatine-killed';
  static const String playerLeft = 'player-left';

  // Client to Server 
  static const String setName = 'set-name';
  static const String createLobby = 'create-lobby';
  static const String getLobbies = 'get-lobbies';
  static const String joinLobby = 'join-lobby';
  static const String startGame = 'start-game';
  static const String chooseChancellor = 'choose-chancellor';
  static const String vote = 'vote';
  static const String discardPolicy = 'discard-policy';
  static const String killPlayer = 'kill-player';
  static const String investigatePlayer = 'investigate-player';
  static const String pickNextViceChair = 'pick-next-viceChair';
  static const String finishedPolicyPeek = 'finished-policy-peek';
  static const String veto = 'veto';
}