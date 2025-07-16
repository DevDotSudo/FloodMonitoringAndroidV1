import 'package:bcrypt/bcrypt.dart';

class HashPassword {
  String? hashedPassword;
  final salt = BCrypt.gensalt();

  String hashPassword(String password) {
    return hashedPassword = BCrypt.hashpw(password, salt);
  }

  bool isValid(String password, String hashed) {
    if (BCrypt.checkpw(password, hashed)) {
      return true;
    }
    return false;
  }
}
