import 'package:angular/angular.dart' show CORE_DIRECTIVES, Component, OnInit;
import 'package:angular_components/angular_components.dart';
import 'package:sp_client/components/board/board.dart';
import 'package:sp_client/components/player/player.dart';
import 'package:sp_client/components/policy-chooser-dialog/policy-chooser-dialog.dart';
import 'package:sp_client/components/role/role.dart';
import 'package:sp_client/services/game_state_service.dart';

@Component(
  selector: 'app-game',
  styleUrls: const [
    'package:angular_components/app_layout/layout.scss.css',
    'game.scss.css'
  ],
  templateUrl: 'game.html',
  directives: const [CORE_DIRECTIVES, materialDirectives, BoardComponent, RoleComponent, PlayerComponent, PolicyChooserDialogComponent],
  providers: const [materialProviders, GameStateService],
)
class GameComponent implements OnInit {

  GameStateService gameStateService;

  GameComponent(this.gameStateService);

  @override
  ngOnInit() async {}
}
