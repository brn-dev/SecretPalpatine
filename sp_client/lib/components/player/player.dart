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

  String _currViceChairImgUrl = '/assets/images/board/vicechair_icon.gif';
  String _currChancellorImgUrl = '/assets/images/board/supremechancellor_icon.gif';
  String _termLimitedImgUrl = '/assets/images/board/term_limited_icon.gif';

  String _viceChairTooltip = 'This player is currently the Vice Chair of the government';
  String _chancellelorTooltip = 'This player is currently the Supreme Chancellor of the government';
  String _termLimitedTooltip = 'This player is currently not eligible to be Supreme Chancellor';


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
      return _chancellelorTooltip;
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

  PlayerComponent(this.gameStateService);
}
