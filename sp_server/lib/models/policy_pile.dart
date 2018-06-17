
class PolicyPile {
  List<bool> policies = new List<bool>();

  void add(bool policy) => policies.add(policy);

  void addAll(List<bool> policies) => this.policies.addAll(policies);

  void addAllFromPile(PolicyPile pile) => addAll(pile.policies);

  bool peek() => policies.last;

  List<bool> peekMany(int count) {
    List<bool> peekedPolicies = new List<bool>();
    var toIndex = policies.length - count;
    for (var i = policies.length - 1; i >= toIndex; i--) {
      peekedPolicies.add(policies[i]);
    }
    return peekedPolicies;
  }

  bool draw() => policies.removeLast();

  List<bool> drawMany(int count) {
    List<bool> drawnPolicies = new List<bool>();
    for (var i = 0; i < count; i++) {
      drawnPolicies.add(draw());
    }
    return drawnPolicies;
  }

  void shuffle() => policies.shuffle();

  void clear() => policies.clear();

  int get length => policies.length;
}