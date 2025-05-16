class VernamCipher {
  static String encrypt(String plaintext, String key) {
    plaintext = plaintext.toUpperCase();
    key = key.toUpperCase();

    if (!_isValid(plaintext) || !_isValid(key)) {
      return 'Error: Only letters A-Z are allowed.';
    }

    if (plaintext.length != key.length) {
      return 'Error: Plaintext and key must be the same length.';
    }

    return _xorStrings(plaintext, key);
  }

  static String decrypt(String ciphertext, String key) {
    return encrypt(ciphertext, key); // Same operation as XOR
  }

  static String _xorStrings(String a, String b) {
    List<int> result = [];
    for (int i = 0; i < a.length; i++) {
      int xored = (a.codeUnitAt(i) - 65) ^ (b.codeUnitAt(i) - 65);
      result.add((xored % 26) + 65); // Keep it in A-Z range
    }
    return String.fromCharCodes(result);
  }

  static bool _isValid(String s) {
    return RegExp(r'^[A-Z]+$').hasMatch(s);
  }
}
