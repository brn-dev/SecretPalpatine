import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:sp_client/services/game_state_service.dart';
import 'package:sp_shared/sp_shared.dart';

@Component(
  selector: 'app-player',
  styleUrls: const ['player.scss.css'],
  templateUrl: 'player.html',
  directives: const [
    CORE_DIRECTIVES,
    materialDirectives,
  ],
  providers: const [materialProviders],
)
class PlayerComponent {
  @Input()
  Player player;

  GameStateService gameStateService;

  String _currViceChairImgUrl = './assets/images/board/vicechair_icon.gif';
  String _currChancellorImgUrl = './assets/images/board/supremechancellor_icon.gif';
  String _termLimitedImgUrl = './assets/images/board/term_limited_icon.gif';

  String _viceChairTooltip = 'This player is currently the Vice Chair of the government';
  String _chancellorTooltip = 'This player is currently the Supreme Chancellor of the government';
  String _termLimitedTooltip = 'This player is term-limited for the next legislative session';

  String _yesVoteImgUrl = './assets/images/vote/arrow_up_icon.gif';
  String _noVoteImgUrl = './assets/images/vote/arrow_down_icon.gif';
  String _unknownVoteImgUrl = './assets/images/vote/unknown_icon.gif';

  String _yesVoteTooltip = 'this player voted yes in the last election';
  String _noVoteTooltip = 'this player voted no in the last election';
  String _unknownVoteTooltip = 'this player has finished voting';

  String get voteImgUrl {
    if (gameStateService.votes.containsKey(player)) {
        var voteOfPlayer = gameStateService.votes[player];
        if (voteOfPlayer == null) {
          return _unknownVoteImgUrl;
        }
        if (voteOfPlayer) {
          return _yesVoteImgUrl;
        }
        return _noVoteImgUrl;
    }
    return null;
  }

  String get voteTooltip {
    if (gameStateService.votes.containsKey(player)) {
      var voteOfPlayer = gameStateService.votes[player];
      if (voteOfPlayer == null) {
        return _unknownVoteTooltip;
      }
      if (voteOfPlayer) {
        return _yesVoteTooltip;
      }
      return _noVoteTooltip;
    }
    return null;
  }

  String get currentPositionImgUrl {
    if (player == gameStateService.viceChair) {
      return _currViceChairImgUrl;
    }
    if (player == gameStateService.chancellor) {
      return _currChancellorImgUrl;
    }
    return null;
  }

  String get previousPositionImgUrl {
    if (player == gameStateService.prevViceChair ||
        player == gameStateService.prevChancellor) {
      return _termLimitedImgUrl;
    }
    return null;
  }

  String get currentPositionTooltip {
    if (player == gameStateService.viceChair) {
      return _viceChairTooltip;
    }
    if (player == gameStateService.chancellor) {
      return _chancellorTooltip;
    }
    return null;
  }

  String get previousPositionTooltip {
    if (player == gameStateService.prevViceChair ||
        player == gameStateService.prevChancellor) {
      return _termLimitedTooltip;
    }
    return null;
  }

  bool get isAlive => gameStateService.alivePlayers.contains(player);

  PlayerComponent(this.gameStateService);
}
