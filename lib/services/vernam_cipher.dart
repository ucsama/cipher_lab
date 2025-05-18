class VernamCipher {
  static List<int> encrypt(String plaintext, String key) {
    if (plaintext.length != key.length) {
      throw ArgumentError('Plaintext and key must be the same length.');
    }

    List<int> result = [];
    for (int i = 0; i < plaintext.length; i++) {
      int p = plaintext.codeUnitAt(i);
      int k = key.codeUnitAt(i);
      result.add(p ^ k); // XOR using full ASCII
    }
    return result; // Return list of int values
  }

  static String decrypt(List<int> ciphertext, String key) {
    if (ciphertext.length != key.length) {
      throw ArgumentError('Ciphertext and key must be the same length.');
    }

    List<int> result = [];
    for (int i = 0; i < ciphertext.length; i++) {
      int k = key.codeUnitAt(i);
      result.add(ciphertext[i] ^ k); // XOR again to decrypt
    }
    return String.fromCharCodes(result); // Convert back to text
  }
}
