
class SocketIoEvents {
  // Server to Client
  static const String lobbyCreated = 'lobby-created';
  static const String gameStarted = 'game-started';
  static const String presidentSet = 'president-set';
  static const String chancellorSet = 'chancellor-set';
  static const String playerFinishedVoting = 'player-finished-voting';
  static const String voteFinished = 'vote-finished';
  static const String policyRevealed = 'policy-revealed';
  static const String chancellorIsHitler = 'chancellor-hitler';
  static const String presidentChoosing = 'president-choosing';
  static const String chancellorChoosing = 'chancellor-choosing';
  static const String policiesDrawn = 'policies-drawn';
  static const String liberalsWon = 'liberals-won';
  static const String fascistWon = 'fascists-won';
  static const String playerKilled = 'player-killed';
  static const String presidentExamining = 'president-examining';
  static const String presidentExamined = 'president-examined';
  static const String presidentInvestigating = 'president-investigating';
  static const String presidentInvestigated = 'president-investigated';
  static const String presidentPickingNextPresident = 'president-picking-next-president';

  // Client to Server 
  static const String setName = 'set-name';
  static const String createLobby = 'create-lobby';
  static const String joinLobby = 'join-lobby';
  static const String startGame = 'start-game';
  static const String chooseChancellor = 'choose-chancellor';
  static const String vote = 'vote';
  static const String discardPolicy = 'discard-policy';
  static const String killPlayer = 'kill-player';
  static const String investigatePlayer = 'investigate-player';
  static const String pickNextPresident = 'pick-next-president';
}