import 'package:sp_shared/sp_shared.dart';
import 'package:test/test.dart';

import 'dart:convert';


void main() {

  group('player', () {
    Player testPerson;
    String testPersonString;

    setUp(() {
      testPerson = new Player(1, 'Brn');
      testPersonString = '{"id":1,"name":"Brn"}';
    });

    test('serialization', () {
      var jsonString = JSON.encode(testPerson);
      expect(jsonString, testPersonString);
    });

    test('deserialization', () {
      var player = new Player.fromJsonString(testPersonString);
      expect(player.id, testPerson.id);
      expect(player.name, testPerson.name);
    });

    test('deserialization empty', () {
      var json = '{}';
      var player = new Player.fromJsonString(json);
      expect(player.id, null);
      expect(player.name, null);
    });

    test('equals', () {
      expect(testPerson == testPerson, true);
      expect(testPerson == new Player(testPerson.id), true);
      expect(testPerson == new Player(testPerson.id + 1), false);
      expect(testPerson == new Lobby(testPerson.id), false);
    });
  });

  group('lobby', () {
    Lobby testLobby;
    Player testPerson1;
    Player testPerson2;
    String testLobbyJson;

    setUp(() {
      testPerson1 = new Player(1, 'Brn');
      testPerson2 = new Player(2, 'Haiden');
      testLobby = new Lobby.withPlayers(1, 'Lobby 1', [testPerson1, testPerson2]);
      testLobbyJson = '{"id":1,"name":"Lobby 1","players":[{"id":1,"name":"Brn"},{"id":2,"name":"Haiden"}],"open":true}';
    });

    test('serialization', () {
      var json = JSON.encode(testLobby);
      expect(json, testLobbyJson);
    });

    test('deserialization', () {
      var lobby = new Lobby.fromJsonString(testLobbyJson);
      expect(lobby.id, testLobby.id);
      expect(lobby.name, testLobby.name);
      expect(lobby.players.length, 2);
      expect(lobby.players[0].id, testPerson1.id);
      expect(lobby.players[0].name, testPerson1.name);
      expect(lobby.players[1].id, testPerson2.id);
      expect(lobby.players[1].name, testPerson2.name);
    });

    test('deserialization empty', () {
      var lobby = new Lobby.fromJsonString('{}');
      expect(lobby.id, null);
      expect(lobby.name, null);
      expect(lobby.players, []);
    });

    test('equals', () {
      expect(testLobby == testLobby, true);
      expect(testLobby == new Lobby(testLobby.id), true);
      expect(testLobby == new Lobby(testLobby.id + 1), false);
      expect(testLobby == new Player(testLobby.id), false);
    });
  });

  group('role', () {
    Role testRole;
    String testRoleJson;

    setUp(() {
      testRole = new Role(1, false, 'Palpatine', '');
      testRoleJson = '{"id":1,"membership":false,"name":"Palpatine","imageUrl":""}';
    });

    test('serialization', () {
      var json = JSON.encode(testRole);
      expect(json, testRoleJson);
    });

    test('deserialization', () {
      var role = new Role.fromJsonString(testRoleJson);
      expect(role.id, testRole.id);
      expect(role.membership, testRole.membership);
      expect(role.name, testRole.name);
      expect(role.imageUrl, testRole.imageUrl);
    });

    test('deserialization empty',() {
      var role = new Role.fromJsonString('{}');
      expect(role.id, null);
      expect(role.membership, null);
      expect(role.name, null);
      expect(role.imageUrl, null);
    });

    test('equals', () {
      expect(testRole == testRole, true);
      expect(testRole == new Role(testRole.id), true);
      expect(testRole == new Role(testRole.id + 1), false);
      expect(testRole == new Player(testRole.id), false);
    });

  });

  group('game-info', () {
    Role testRole;
    GameInfo testGameInfo;
    String testGameInfoJson;

    setUp(() {
      testRole = new Role(1, false, 'Palpatine', '');
      testGameInfo = new GameInfo(testRole, [2, 3], 3);
      testGameInfoJson = '{"role":{"id":1,"membership":false,"name":"Palpatine","imageUrl":""},"separatistsIds":[2,3],"palpatineId":3}';
    });

    test('serialization', () {
      var json = JSON.encode(testGameInfo);
      expect(json, testGameInfoJson);
    });

    test('deserlialization', () {
      var gi = new GameInfo.fromJsonString(testGameInfoJson);
      expect(gi.role.id, testRole.id);
      expect(gi.role.membership, testRole.membership);
      expect(gi.role.name, testRole.name);
      expect(gi.role.imageUrl, testRole.imageUrl);
      expect(gi.separatistsIds.length, testGameInfo.separatistsIds.length);
      for (var i = 0; i < gi.separatistsIds.length; i++) {
        expect(gi.separatistsIds[i], testGameInfo.separatistsIds[i]);
      }
      expect(gi.palpatineId, testGameInfo.palpatineId);
    });

    test('deserialization empty', () {
      var gi = new GameInfo.fromJsonString('{}');
      expect(gi.role, null);
      expect(gi.separatistsIds, null);
      expect(gi.palpatineId, null);
    });
  });
}
