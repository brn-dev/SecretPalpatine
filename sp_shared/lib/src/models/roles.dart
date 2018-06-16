import 'role.dart';

class Roles {
  static final String _roleImageFolderPath = '/assets/images/roles/';

  static final Role palpatine = new Role(1, false, 'Palpatine', _roleImageFolderPath + 'palpatine.gif');

  static final Role separatist1 = new Role(11, false, 'Separatist', _roleImageFolderPath + 'separatist1.gif');
  static final Role separatist2 = new Role(12, false, 'Separatist', _roleImageFolderPath + 'separatist2.gif');
  static final Role separatist3 = new Role(13, false, 'Separatist', _roleImageFolderPath + 'separatist3.gif');

  static final Role loyalist1 = new Role(21, true, 'Loyalist', _roleImageFolderPath + 'loyalist1.gif');
  static final Role loyalist2 = new Role(22, true, 'Loyalist', _roleImageFolderPath + 'loyalist2.gif');
  static final Role loyalist3 = new Role(23, true, 'Loyalist', _roleImageFolderPath + 'loyalist3.gif');
  static final Role loyalist4 = new Role(24, true, 'Loyalist', _roleImageFolderPath + 'loyalist4.gif');
  static final Role loyalist5 = new Role(25, true, 'Loyalist', _roleImageFolderPath + 'loyalist5.gif');
  static final Role loyalist6 = new Role(26, true, 'Loyalist', _roleImageFolderPath + 'loyalist6.gif');

  static final List<Role> roles5Players = [
    palpatine,
    separatist1,
    loyalist1,
    loyalist2,
    loyalist3,
  ];

  static final List<Role> roles6Players = [
    palpatine,
    separatist1,
    loyalist1,
    loyalist2,
    loyalist3,
    loyalist4,
  ];

  static final List<Role> roles7Players = [
    palpatine,
    separatist1,
    separatist2,
    loyalist1,
    loyalist2,
    loyalist3,
    loyalist4,
  ];

  static final List<Role> roles8Players = [
    palpatine,
    separatist1,
    separatist2,
    loyalist1,
    loyalist2,
    loyalist3,
    loyalist4,
    loyalist5,
  ];

  static final List<Role> roles9Players = [
    palpatine,
    separatist1,
    separatist2,
    separatist3,
    loyalist1,
    loyalist2,
    loyalist3,
    loyalist4,
    loyalist5,
  ];

  static final List<Role> roles10Players = [
    palpatine,
    separatist1,
    separatist2,
    separatist3,
    loyalist1,
    loyalist2,
    loyalist3,
    loyalist4,
    loyalist5,
    loyalist6,
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
