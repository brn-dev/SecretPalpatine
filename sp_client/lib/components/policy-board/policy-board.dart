import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';

@Component(
  selector: 'app-policy-board',
  styleUrls: const ['policy-board.css'],
  templateUrl: 'policy-board.html',
  directives: const [materialDirectives],
  providers: const [materialProviders],
)
class PolicyBoardComponent implements OnInit {
  @override
  ngOnInit() async {}
}