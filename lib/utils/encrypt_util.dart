import 'package:encrypt/encrypt.dart';

class Encryption {
  static final key = Key.fromBase64('f3ChNqKb/MumOr5XzvtWrTyh0YZsc2cw+VyoILwvBm8=');
  static final iv = IV.fromUtf8('5fMvfY1JL+YuUxsj');

  static String encryptText(String plainText) {
    final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
    final encrypted = encrypter.encrypt(plainText, iv: iv);
    return encrypted.base64;
  }

  static String decryptText(String encryptedText) {
    final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
    final decrypted = encrypter.decrypt64(encryptedText, iv: iv);
    return decrypted;
  }
}