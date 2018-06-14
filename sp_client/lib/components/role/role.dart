import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:sp_client/services/game_state_service.dart';

@Component(
  selector: 'app-role',
  styleUrls: const ['role.scss.css'],
  templateUrl: 'role.html',
  directives: const [materialDirectives],
  providers: const [materialProviders, GameStateService],
)
class RoleComponent implements OnInit {
  GameStateService gameStateService;

  RoleComponent(this.gameStateService);

  @override
  ngOnInit() async {}
}
