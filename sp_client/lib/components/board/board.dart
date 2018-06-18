import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:sp_client/components/policy_board/policy_board.dart';
import 'package:sp_client/components/policy_pile/policy_pile.dart';
import 'package:sp_client/services/game_state_service.dart';

@Component(
  selector: 'app-board',
  styleUrls: const ['board.scss.css'],
  templateUrl: 'board.html',
  directives: const [CORE_DIRECTIVES, materialDirectives, PolicyBoardComponent, PolicyPileComponent],
  providers: const [materialProviders],
)
class BoardComponent implements OnInit {

  GameStateService gameStateService;

  BoardComponent(this.gameStateService);

  @override
  ngOnInit() async {}
}
