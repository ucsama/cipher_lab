import 'dart:convert';
import 'package:encrypt/encrypt.dart';

class AESService {
  final Key key;

  AESService(String keyString) : key = Key.fromUtf8(_formatKey(keyString));

  // Pad or trim the key to 32 bytes (AES-256)
  static String _formatKey(String key) {
    if (key.length > 32) return key.substring(0, 32);
    return key.padRight(32, '0');
  }

  /// Encrypts the plainText using AES-256 with a random IV
  /// Returns base64 string: IV + ciphertext
  String encrypt(String plainText) {
    final iv = IV.fromSecureRandom(16); // Random 16-byte IV
    final encrypter = Encrypter(AES(key, mode: AESMode.cbc)); // CBC mode
    final encrypted = encrypter.encrypt(plainText, iv: iv);

    // Combine IV + CipherText in base64
    final combinedBytes = iv.bytes + encrypted.bytes;
    return base64Encode(combinedBytes);
  }

  /// Decrypts the base64 (IV + ciphertext) string back to plainText
  String decrypt(String combinedBase64) {
    final combinedBytes = base64Decode(combinedBase64);

    // Extract IV (first 16 bytes) and ciphertext
    final iv = IV(combinedBytes.sublist(0, 16));
    final cipherBytes = combinedBytes.sublist(16);

    final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
    final decrypted = encrypter.decrypt(Encrypted(cipherBytes), iv: iv);

    return decrypted;
  }
}
