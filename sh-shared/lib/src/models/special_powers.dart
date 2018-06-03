
class SpecialPowers {
  static const int policyPeek = 1;
  static const int loyaltyInvestigation = 2;
  static const int specialElection = 3;
  static const int execution = 4;

  static final List<int> specialPowers5And6Players = [
    null,
    null,
    policyPeek,
    execution,
    execution,
    null
  ];

  static final List<int> specialPowers7And8Players = [
    null,
    loyaltyInvestigation,
    specialElection,
    execution,
    execution,
    null
  ];

  static final List<int> specialPowers9And10Players = [
    loyaltyInvestigation,
    loyaltyInvestigation,
    specialElection,
    execution,
    execution,
    null
  ];

  static List<int> getSpecialPowersForPlayerAmount(int amountOfPlayers) {
    if (amountOfPlayers < 7) {
      return specialPowers5And6Players;
    } 
    if (amountOfPlayers < 9) {
      return specialPowers7And8Players;
    }
    return specialPowers9And10Players;
  }
  
}