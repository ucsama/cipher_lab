class CaesarCipher {
  static String encrypt(String text, int shift) {
    final filtered = text.codeUnits.where((char) {
      // Only keep alphabets (A-Z or a-z)
      return (char >= 65 && char <= 90) || (char >= 97 && char <= 122);
    });

    return String.fromCharCodes(
      filtered.map((char) {
        if (char >= 65 && char <= 90) {
          return ((char - 65 + shift) % 26) + 65;
        } else if (char >= 97 && char <= 122) {
          return ((char - 97 + shift) % 26) + 97;
        } else {
          // Should never reach here due to filtering
          return char;
        }
      }),
    );
  }

  static String decrypt(String text, int shift) {
    return encrypt(text, 26 - (shift % 26));
  }
}
