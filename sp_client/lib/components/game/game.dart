import 'package:angular/angular.dart' show CORE_DIRECTIVES, Component, OnInit;
import 'package:angular_components/angular_components.dart';
import 'package:sp_client/components/board/board.dart';
import 'package:sp_client/components/membership_dialog/membership_dialog.dart';
import 'package:sp_client/components/player/player.dart';
import 'package:sp_client/components/policy_discard_dialog/policy_discard_dialog.dart';
import 'package:sp_client/components/role/role.dart';
import 'package:sp_client/components/vote_dialog/vote_dialog.dart';
import 'package:sp_client/services/game_state_service.dart';

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

  GameComponent(this.gameStateService);

  @override
  ngOnInit() async {}
}
