import 'dart:async';
import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';

@Component(
  selector: 'app-policy-chooser-dialog',
  styleUrls: const ['policy-chooser-dialog.scss.css'],
  templateUrl: 'policy-chooser-dialog.html',
  directives: const [CORE_DIRECTIVES, materialDirectives],
  providers: const [materialProviders],
)
class PolicyChooserDialogComponent implements OnInit {
  String loyalistPolicyImgUrl = '/assets/images/policy/loyalistPolicy.gif';
  String separatistPolicyImgUrl = '/assets/images/policy/seperatistPolicy.gif';

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
    print('discard');

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
