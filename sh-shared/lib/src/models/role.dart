import 'package:exportable/exportable.dart';
import 'serializable.dart';

@export
class Role extends Serializable {
    int id;
    bool membership; //true=liberal, false=fascist
    String name;
    String imageUrl;

    Role([this.id, this.membership, this.name, this.imageUrl]);

    Role.fromJson(Map<String, dynamic> jsonMap) : super.fromJson(jsonMap);

    Role.fromJsonString(String json) : super.fromJsonString(json);
}