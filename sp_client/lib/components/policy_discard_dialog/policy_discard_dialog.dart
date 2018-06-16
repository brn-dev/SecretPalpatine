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
  String hiddenPolicyImgUrl = '/assets/images/policy/galacticPolicy.gif';

  bool showPolicies = false;

  final _finished = new StreamController<bool>();

  @Output()
  Stream<bool> get finished => _finished.stream;

  @Input()
  List<bool> policies;

  @Input()
  bool showDialog = false;

  @Input()
  bool hideOnFinished = true;

  @Input()
  bool isPolicyPeek = false;

  @override
  ngOnInit() async {}

  void discardPolicy(bool policy) {
    if (isPolicyPeek || !showPolicies) {
      return;
    }

    _finished.add(policy);

    if (hideOnFinished) {
      showDialog = false;
    }
  }

  void onOk() {
    showDialog = false;
    _finished.add(null);
  }
}
