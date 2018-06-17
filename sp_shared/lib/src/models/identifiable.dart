class Identifiable {
  int id;

  Identifiable(this.id);

  bool equals(Object o) {
    return o is Identifiable 
      && runtimeType == o.runtimeType
      && id == o.id;
  }

  bool operator ==(o) => equals(o);
  int get hashCode => id;
}
