import 'dart:async';
import 'dart:math';
import 'package:angular/angular.dart' show CORE_DIRECTIVES, Component, OnInit;
import 'package:angular_components/angular_components.dart';
import 'package:sp_client/components/board/board.dart';
import 'package:sp_client/components/membership_dialog/membership_dialog.dart';
import 'package:sp_client/components/player/player.dart';
import 'package:sp_client/components/policy_discard_dialog/policy_discard_dialog.dart';
import 'package:sp_client/components/role/role.dart';
import 'package:sp_client/components/vote_dialog/vote_dialog.dart';
import 'package:sp_client/services/game_state_service.dart';
import 'package:sp_client/services/socket_io_service.dart';
import 'package:sp_shared/sp_shared.dart';

@Component(
  selector: 'app-game',
  styleUrls: const [
    'package:angular_components/app_layout/layout.scss.css',
    'game.scss.css'
  ],
  templateUrl: 'game.html',
  directives: const [
    CORE_DIRECTIVES,
    materialDirectives,
    BoardComponent,
    RoleComponent,
    PlayerComponent,
    PolicyDiscardDialogComponent,
    VoteDialogComponent,
    MembershipDialogComponent
  ],
  providers: const [materialProviders],
)
class GameComponent implements OnInit {
  GameStateService gameStateService;
  SocketIoService socketIoService;

  GameComponent(this.gameStateService, this.socketIoService);

  @override
  ngOnInit() async {
    handleGame();
  }

  //player chooser dialog

  bool isPlayerChooser = false;
  List<Player> selectablePlayers = null;
  Completer<Player> playerChooserCompleter;

  bool isPlayerSelectable(Player p) {
    return selectablePlayers.contains(p);
  }

  Future<Player> doPlayerChooserDialog(List<Player> selectablePlayers) async {
    this.selectablePlayers = selectablePlayers;
    isPlayerChooser = true;
    playerChooserCompleter = new Completer<Player>();
    return playerChooserCompleter.future;
  }

  void onSelectablePlayerClick(Player p) {
    isPlayerChooser = false;
    selectablePlayers = null;
    playerChooserCompleter.complete(p);
    print(p.name);
  }

  // vote dialog
  bool showVoteDialog = false;
  Completer<bool> voteCompleter;

  Future<bool> getVote() {
    voteCompleter = new Completer<bool>();
    showVoteDialog = true;
    return voteCompleter.future;
  }

  void onFinishedVoting(bool vote) {
    voteCompleter.complete(vote);
    showVoteDialog = false;
  }

  // policy dialog
  bool showPolicyDialog = false;
  List<bool> shownPolicies;
  bool isPolicyPeek;
  Completer<bool> policyDialogCompleter;

  Future<bool> doPolicyDialog(List<bool> shownPolicies, bool isPolicyPeek) {
    this.shownPolicies = shownPolicies;
    this.isPolicyPeek = isPolicyPeek;
    policyDialogCompleter = new Completer<bool>();
    showPolicyDialog = true;
    return policyDialogCompleter.future;
  }

  void onPolicyDialogFinished(bool resultPolicies) {
    showPolicyDialog = false;
    policyDialogCompleter.complete(resultPolicies);
  }

  // membership dialog
  bool showMembershipDialog;
  bool membershipDialogMembership;
  Player membershipDialogPlayer;

  void doMembershipDialog(Player p, bool membership) {
    membershipDialogPlayer = p;
    membershipDialogMembership = membership;
    showMembershipDialog = true;
  }

  // game logic
  Future<Null> handleGame() async {
    while (!gameStateService.hasGameEnded) {
      bool voteResult;
      do {
        await formGovernment();
        gameStateService.resetVotes();
        voteResult = await voteForGovernment();
        if (!voteResult) {
          handleFailedGovernment();
          if (gameStateService.hasGameEnded) {
            return;
          }
        }
      } while (!voteResult);
      await handleGovernment();
    }
  }

  Future<Null> formGovernment() async {
    await socketIoService.whenViceChairSet();
    if (gameStateService.isPlayerViceChair) {
      var chosenChancellor =
          await doPlayerChooserDialog(gameStateService.eligiblePlayers);
      socketIoService.chooseChancellor(chosenChancellor.id);
    } else {
      await socketIoService.whenChancellorSet();
    }
  }

  Future<Null> handleFailedGovernment() async {
    gameStateService.failedGovernmentCounter++;
    if (gameStateService.failedGovernmentCounter == 4) {
      await socketIoService.whenPolicyRevealed();
      gameStateService.failedGovernmentCounter = 0;
      gameStateService.prevViceChair = null;
      gameStateService.prevChancellor = null;
    }
  }

  Future<bool> voteForGovernment() async {
    socketIoService.listenForPlayersVoting();
    if (gameStateService.isPlayerAlive) {
      bool vote = await getVote();
      socketIoService.vote(vote);
    }
    return socketIoService.whenVoteFinished();
  }

  Future<Null> handleGovernment() async {
    await handleViceChairPhase();
    await handleChancellorPhase();
    await handleLegislativeSessionResult();
  }

  Future<Null> handleViceChairPhase() async {
    if (gameStateService.player == gameStateService.viceChair) {
      await drawAndDiscardPolicy();
    } else {
      await socketIoService.whenViceChairChoosing();
      // TODO: display something
    }
  }

  Future<Null> handleChancellorPhase() async {
    if (gameStateService.player == gameStateService.chancellor) {
      await drawAndDiscardPolicy();
    } else {
      await socketIoService.whenChancellorChoosing();
      // TODO: display something
    }
  }

  Future<Null> drawAndDiscardPolicy() async {
    var drawnPolicies = await socketIoService.whenPoliciesDrawn();
    var discardedPolicy = await doPolicyDialog(drawnPolicies, false);
    socketIoService.discardPolicy(discardedPolicy);
  }

  Future<Null> handleLegislativeSessionResult() async {
    var resultPolicy = await socketIoService.whenPolicyRevealed();
    if (!resultPolicy) {
      await handleSpecialPower();
    }
  }

  Future<Null> handleSpecialPower() async {
    var specialPowers = SpecialPowers
        .getSpecialPowersForPlayerAmount(gameStateService.players.length);
    var currSpecialPower =
        specialPowers[gameStateService.separatistEnactedPolicies - 1];
    switch (currSpecialPower) {
      case SpecialPower.PolicyPeek:
        await handlePolicyPeek();
        break;
      case SpecialPower.LoyaltyInvestigation:
        await handleLoyaltyInvestigation();
        break;
      case SpecialPower.SpecialElection:
        await handleSpecialElection();
        break;
      case SpecialPower.Execution:
        await handleExecution();
        break;
    }
  }

  Future<Null> handlePolicyPeek() async {
    if (gameStateService.isPlayerViceChair) {
      var peekedPolicies = await socketIoService.whenPoliciesDrawn();
      await doPolicyDialog(peekedPolicies, true);
    }
  }

  Future<Null> handleLoyaltyInvestigation() async {
    if (gameStateService.isPlayerViceChair) {
      var playerForInvestigation =
          await doPlayerChooserDialog(gameStateService.alivePlayers);
      socketIoService.investigatePlayer(playerForInvestigation.id);
      var membership = await socketIoService.whenMembershipInvestigated();
      doMembershipDialog(playerForInvestigation, membership);
    } else {
      var investigatedPlayer =
          await socketIoService.whenViceChairInvestigated();
      print('player "${investigatedPlayer.name}" got investigated');
      // display investigated player
    }
  }

  Future<Null> handleSpecialElection() async {
    if (gameStateService.isPlayerViceChair) {
      var nextViceChair =
          await doPlayerChooserDialog(gameStateService.alivePlayers);
      socketIoService.pickNextViceChair(nextViceChair.id);
    }
  }

  Future<Null> handleExecution() async {
    if (gameStateService.isPlayerViceChair) {
      var playerToBeKilled = await doPlayerChooserDialog(gameStateService
          .alivePlayers
          .where((p) => p != gameStateService.player));
      socketIoService.killPlayer(playerToBeKilled.id);
    } else {
      await socketIoService.whenPlayerKilled();
    }
  }
}
