import 'role.dart';

class Roles {
  static final Role hitler = new Role(1, false, 'Hitler', null);

  static final Role fascist1 = new Role(11, false, 'Fascist', null);
  static final Role fascist2 = new Role(12, false, 'Fascist', null);
  static final Role fascist3 = new Role(13, false, 'Fascist', null);

  static final Role liberal1 = new Role(21, true, 'Liberal', null);
  static final Role liberal2 = new Role(22, true, 'Liberal', null);
  static final Role liberal3 = new Role(23, true, 'Liberal', null);
  static final Role liberal4 = new Role(24, true, 'Liberal', null);
  static final Role liberal5 = new Role(25, true, 'Liberal', null);
  static final Role liberal6 = new Role(26, true, 'Liberal', null);

  static final List<Role> roles5Players = [
    hitler,
    fascist1,
    liberal1,
    liberal2,
    liberal3,
  ];

  static final List<Role> roles6Players = [
    hitler,
    fascist1,
    liberal1,
    liberal2,
    liberal3,
    liberal4,
  ];

  static final List<Role> roles7Players = [
    hitler,
    fascist1,
    fascist2,
    liberal1,
    liberal2,
    liberal3,
    liberal4,
  ];

  static final List<Role> roles8Players = [
    hitler,
    fascist1,
    fascist2,
    liberal1,
    liberal2,
    liberal3,
    liberal4,
    liberal5,
  ];

  static final List<Role> roles9Players = [
    hitler,
    fascist1,
    fascist2,
    fascist3,
    liberal1,
    liberal2,
    liberal3,
    liberal4,
    liberal5,
  ];

  static final List<Role> roles10Players = [
    hitler,
    fascist1,
    fascist2,
    fascist3,
    liberal1,
    liberal2,
    liberal3,
    liberal4,
    liberal5,
    liberal6,
  ];

  static final List<List<Role>> _rolesForPlayerAmounts = [
    roles5Players,
    roles6Players,
    roles7Players,
    roles8Players,
    roles9Players,
    roles10Players,
  ];

  static List<Role> getRolesForPlayerAmount(int amountOfPlayers) =>
      _rolesForPlayerAmounts[amountOfPlayers - 5];
}
