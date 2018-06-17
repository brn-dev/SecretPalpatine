
enum SpecialPower {
  PolicyPeek,
  LoyaltyInvestigation,
  SpecialElection,
  Execution,
}

class SpecialPowers {

  static final List<SpecialPower> specialPowers5And6Players = [
    null,
    null,
    SpecialPower.PolicyPeek,
    SpecialPower.Execution,
    SpecialPower.Execution,
    null
  ];

  static final List<SpecialPower> specialPowers7And8Players = [
    null,
    SpecialPower.LoyaltyInvestigation,
    SpecialPower.SpecialElection,
    SpecialPower.Execution,
    SpecialPower.Execution,
    null
  ];

  static final List<SpecialPower> specialPowers9And10Players = [
    SpecialPower.LoyaltyInvestigation,
    SpecialPower.LoyaltyInvestigation,
    SpecialPower.SpecialElection,
    SpecialPower.Execution,
    SpecialPower.Execution,
    null
  ];

  static List<SpecialPower> getSpecialPowersForPlayerAmount(int amountOfPlayers) {
    if (amountOfPlayers < 7) {
      return specialPowers5And6Players;
    } 
    if (amountOfPlayers < 9) {
      return specialPowers7And8Players;
    }
    return specialPowers9And10Players;
  }
  
}