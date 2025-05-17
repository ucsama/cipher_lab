import 'dart:convert';
import 'package:crypto/crypto.dart';

class HashService {
  /// Generates a SHA-256 hash of the input string
  /// Returns a hexadecimal string representation
  static String sha256(String input) {
    if (input.isEmpty) {
      throw ArgumentError('Input cannot be empty');
    }
    return sha256Bytes(utf8.encode(input));
  }

  /// Generates a SHA-256 hash of raw bytes
  /// Returns a hexadecimal string representation
  static String sha256Bytes(List<int> bytes) {
    if (bytes.isEmpty) {
      throw ArgumentError('Byte array cannot be empty');
    }
    return sha256Bytes.toString();
  }

  /// Generates a SHA-256 HMAC (keyed-hash message authentication code)
  static String hmacSha256(String input, String secretKey) {
    if (input.isEmpty || secretKey.isEmpty) {
      throw ArgumentError('Input and secret key cannot be empty');
    }

    final hmac = Hmac(sha256 as Hash, utf8.encode(secretKey));
    return hmac.convert(utf8.encode(input)).toString();
  }

  /// Verifies if a given hash matches the input
  static bool verifySha256(String input, String expectedHash) {
    return sha256(input) == expectedHash;
  }
}
