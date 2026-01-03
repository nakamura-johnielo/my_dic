import 'package:uuid/uuid.dart';


class MyUUID {
    static final Uuid uuid = Uuid();
  static String generate() {
    return uuid.v4();
  }
}
