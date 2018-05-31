import 'dart:mirrors';
import 'dart:convert';

abstract class Serializable {
  ClassMirror _serializableClassMirror = reflectClass(Serializable);

  Serializable();

  Serializable.fromJsonString(String jsonString)
      : this.fromJson(JSON.decode(jsonString));

  Serializable.fromJson(Map<String, dynamic> jsonMap) {
    InstanceMirror instanceMirror = reflect(this);
    ClassMirror classMirror = instanceMirror.type;
    var declarations = classMirror.declarations.values
        .where((declarationMirror) => declarationMirror is VariableMirror)
        .toList();
    declarations.forEach((declarationMirror) {
      var jsonValue = jsonMap[_getSymbolName(declarationMirror.simpleName)];
      if (jsonValue == null) {
        return;
      }

      if (jsonValue is List) {
        TypeMirror listGenericType =
            (declarationMirror as VariableMirror).type.typeArguments[0];
        List parsedList = new List();
        if (listGenericType.isSubtypeOf(_serializableClassMirror)) {
          jsonValue.forEach((elem) {
            var newValue = reflectClass(listGenericType.reflectedType)
                .newInstance(new Symbol('fromJson'), [elem]).reflectee;
            parsedList.add(newValue);
          });
        } else {
          jsonValue.forEach((elem) {
            parsedList.add(elem);
          });
        }
        instanceMirror.setField(declarationMirror.simpleName, parsedList);
      } else if ((declarationMirror as VariableMirror)
          .type
          .isSubtypeOf(_serializableClassMirror)) {
        var value = reflectClass(
                (declarationMirror as VariableMirror).type.reflectedType)
            .newInstance(new Symbol('fromJson'), [jsonValue]).reflectee;
        instanceMirror.setField(declarationMirror.simpleName, value);
      } else {
        instanceMirror.setField(declarationMirror.simpleName, jsonValue);
      }
    });
  }

  Map<String, dynamic> toJson() {
    var jsonMap = new Map<String, dynamic>();
    InstanceMirror instanceMirror = reflect(this);
    ClassMirror classMirror = instanceMirror.type;
    var declarations = classMirror.declarations.values
        .where((declarationMirror) => declarationMirror is VariableMirror);
    declarations.forEach((declarationMirror) {
      var key = MirrorSystem.getName(declarationMirror.simpleName);
      var value =
          instanceMirror.getField(declarationMirror.simpleName).reflectee;
      jsonMap[key] = value;
    });
    return jsonMap;
  }

  _getSymbolName(Symbol symbol) {
    return symbol.toString().split('"')[1];
  }
}
