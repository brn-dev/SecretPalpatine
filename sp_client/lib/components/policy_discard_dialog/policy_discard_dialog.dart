import 'dart:async';
import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';

@Component(
  selector: 'app-policy-discard-dialog',
  styleUrls: const ['policy_discard_dialog.scss.css'],
  templateUrl: 'policy_discard_dialog.html',
  directives: const [CORE_DIRECTIVES, materialDirectives],
  providers: const [materialProviders],
)
class PolicyDiscardDialogComponent implements OnInit {
  String loyalistPolicyImgUrl = '/assets/images/policy/loyalistPolicy.gif';
  String separatistPolicyImgUrl = '/assets/images/policy/separatistPolicy.gif';

  final _finishedDiscarding = new StreamController<List<bool>>();

  @Output()
  Stream<List<bool>> get finishedDiscarding => _finishedDiscarding.stream;

  @Input()
  List<bool> policies;

  @Input()
  bool showDialog = false;

  @Input()
  bool hideOnFinished = true;

  @override
  ngOnInit() async {}

  void discardPolicy(bool policy) {
    var found = false;
    var remainingPolicies = policies.sublist(0);
    remainingPolicies.removeWhere((bool policyElem) {
      if (!found && policyElem == policy) {
        found = true;
        return true;
      }
      return false;
    });
    _finishedDiscarding.add(remainingPolicies);

    if (hideOnFinished) {
      showDialog = false;
    }
  }
}
