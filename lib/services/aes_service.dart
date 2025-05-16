import 'package:encrypt/encrypt.dart';

class AESService {
  final Key key;
  final IV iv;

  AESService(String keyString)
    : key = Key.fromUtf8(_formatKey(keyString)),
      iv = IV.fromLength(16); // Using fixed IV length 16 for simplicity

  // Pad or trim the key to 32 bytes (AES-256)
  static String _formatKey(String key) {
    if (key.length > 32) return key.substring(0, 32);
    return key.padRight(32, '0');
  }

  String encrypt(String plainText) {
    final encrypter = Encrypter(AES(key));
    final encrypted = encrypter.encrypt(plainText, iv: iv);
    return encrypted.base64;
  }

  String decrypt(String cipherText) {
    final encrypter = Encrypter(AES(key));
    final decrypted = encrypter.decrypt64(cipherText, iv: iv);
    return decrypted;
  }
}
