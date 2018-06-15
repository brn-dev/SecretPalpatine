import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';

@Component(
  selector: 'app-policy-pile',
  styleUrls: const ['policy_pile.scss.css'],
  templateUrl: 'policy_pile.html',
  directives: const [materialDirectives, CORE_DIRECTIVES],
  providers: const [materialProviders],
)
class PolicyPileComponent implements OnInit {
  @Input()
  String backgroundImgUrl;
  @Input()
  String policyImgUrl;
  @Input()
  int policyCount;

  @override
  ngOnInit() async {}
}
