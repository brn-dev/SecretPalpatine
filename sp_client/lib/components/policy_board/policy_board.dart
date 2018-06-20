import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:sp_client/services/game_state_service.dart';

@Component(
  selector: 'app-policy-board',
  styleUrls: const ['policy_board.scss.css'],
  templateUrl: 'policy_board.html',
  directives: const [CORE_DIRECTIVES, materialDirectives],
  providers: const [materialProviders],
)
class PolicyBoardComponent implements OnInit {
  GameStateService gameStateService;

  List<String> get loyalistPolicyImgs => new List<String>.filled(
      gameStateService.loyalistEnactedPolicies,
      './assets/images/policy/loyalistPolicy.gif');

  List<String> get separatistPolicyImgs => new List<String>.filled(
      gameStateService.separatistEnactedPolicies,
      './assets/images/policy/separatistPolicy.gif');

  String get separatistBoardImgUrl {
    if (gameStateService.players.length < 7) {
      return 'assets/images/board/separatistBoard5-6.gif';
    }
    if (gameStateService.players.length < 9) {
      return 'assets/images/board/separatistBoard7-8.gif';
    }
    return 'assets/images/board/separatistBoard9-10.gif';
  }

  PolicyBoardComponent(this.gameStateService);

  @override
  ngOnInit() async {}
}
