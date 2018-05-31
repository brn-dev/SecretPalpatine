
class IDManager {
  int _id = 0;

  int getNextId() {
    return ++_id;
  }

  void resetId() {
    _id = 0;
  }
}