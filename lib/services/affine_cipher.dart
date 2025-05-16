class AffineCipher {
  static const int m = 26;

  static int _modInverse(int a, int m) {
    a = a % m;
    for (int x = 1; x < m; x++) {
      if ((a * x) % m == 1) return x;
    }
    throw Exception('No modular inverse for a = $a and m = $m');
  }

  static String encrypt(String plaintext, int a, int b) {
    if (_gcd(a, m) != 1) {
      return 'Error: a must be coprime with $m';
    }

    return plaintext
        .split('')
        .map((char) {
          if (_isAlpha(char)) {
            int x = _charToIndex(char);
            int encrypted = (a * x + b) % m;
            return _indexToChar(encrypted, isUpper: _isUpperCase(char));
          }
          return char;
        })
        .join('');
  }

  static String decrypt(String ciphertext, int a, int b) {
    if (_gcd(a, m) != 1) {
      return 'Error: a must be coprime with $m';
    }

    int a_inv = _modInverse(a, m);
    return ciphertext
        .split('')
        .map((char) {
          if (_isAlpha(char)) {
            int y = _charToIndex(char);
            int decrypted = (a_inv * (y - b + m)) % m;
            return _indexToChar(decrypted, isUpper: _isUpperCase(char));
          }
          return char;
        })
        .join('');
  }

  static int _gcd(int a, int b) {
    while (b != 0) {
      int temp = b;
      b = a % b;
      a = temp;
    }
    return a;
  }

  static bool _isAlpha(String c) => RegExp(r'[a-zA-Z]').hasMatch(c);

  static bool _isUpperCase(String c) => c == c.toUpperCase();

  static int _charToIndex(String c) => c.toLowerCase().codeUnitAt(0) - 97;

  static String _indexToChar(int i, {bool isUpper = false}) {
    return String.fromCharCode((isUpper ? 65 : 97) + i);
  }
}
