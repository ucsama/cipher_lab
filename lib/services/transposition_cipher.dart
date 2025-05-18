import 'dart:math';

class TranspositionCipher {
  /// Encrypts using columnar transposition cipher with random padding.
  /// Returns ciphertext with the original length prefixed (e.g. '5|ciphertext')
  static String encrypt(String plaintext, String key) {
    final cols = key.length;
    final rows = (plaintext.length / cols).ceil();
    final totalLength = rows * cols;

    // Pad with random letters
    final paddedText = _padWithRandomChars(plaintext, totalLength);

    // Fill grid row-wise
    final grid = List.generate(
      rows,
      (r) => List.generate(cols, (c) => paddedText[r * cols + c]),
    );

    // Get column order from numeric key
    final colOrder = _getKeyOrder(key);

    // Read columns in order
    final encrypted = StringBuffer();
    for (final col in colOrder) {
      for (int row = 0; row < rows; row++) {
        encrypted.write(grid[row][col]);
      }
    }

    // Add original length prefix (e.g. "5|encryptedtext")
    return '${plaintext.length}|${encrypted.toString()}';
  }

  /// Decrypts the transposition cipher with random padding and length prefix.
  static String decrypt(String fullCiphertext, String key) {
    // Split out length prefix
    final separatorIndex = fullCiphertext.indexOf('|');
    final length = int.parse(fullCiphertext.substring(0, separatorIndex));
    final ciphertext = fullCiphertext.substring(separatorIndex + 1);

    final cols = key.length;
    final rows = (ciphertext.length / cols).ceil();

    final colOrder = _getKeyOrder(key);

    // Fill grid column-wise using order
    final grid = List.generate(rows, (_) => List.filled(cols, ''));
    int index = 0;
    for (final col in colOrder) {
      for (int row = 0; row < rows; row++) {
        grid[row][col] = ciphertext[index++];
      }
    }

    // Read row-wise
    final decrypted = StringBuffer();
    for (final row in grid) {
      decrypted.writeAll(row);
    }

    // Return only the original message length
    return decrypted.toString().substring(0, length);
  }

  static List<int> _getKeyOrder(String key) {
    final entries = key.split('').asMap().entries.toList();
    entries.sort((a, b) => int.parse(a.value).compareTo(int.parse(b.value)));
    return entries.map((e) => e.key).toList();
  }

  static String _padWithRandomChars(String text, int targetLength) {
    final random = Random.secure();
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    final paddingLength = targetLength - text.length;
    final padding =
        List.generate(
          paddingLength,
          (_) => chars[random.nextInt(chars.length)],
        ).join();
    return text + padding;
  }
}
