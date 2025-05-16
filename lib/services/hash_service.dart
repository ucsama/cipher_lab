import 'dart:convert';
import 'package:crypto/crypto.dart';

class HashService {
  static String sha256Hash(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
