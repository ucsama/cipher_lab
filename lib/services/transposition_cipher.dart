class TranspositionCipher {
  /// Encrypts using columnar transposition cipher
  static String encrypt(String text, String key) {
    final int cols = key.length;
    final int rows = (text.length / cols).ceil();

    // Fill grid row-wise
    final grid = List.generate(rows, (_) => List.filled(cols, ''));
    for (int i = 0; i < text.length; i++) {
      final row = i ~/ cols;
      final col = i % cols;
      grid[row][col] = text[i];
    }

    // Determine column order based on key
    final List<int> colOrder = _getKeyOrder(key);

    // Read columns by order and build encrypted string
    final encrypted = StringBuffer();
    for (final col in colOrder) {
      for (int row = 0; row < rows; row++) {
        encrypted.write(grid[row][col]);
      }
    }

    return encrypted.toString();
  }

  /// Decrypts using columnar transposition cipher
  static String decrypt(String cipher, String key) {
    final int cols = key.length;
    final int rows = (cipher.length / cols).ceil();
    final List<int> colOrder = _getKeyOrder(key);

    // Prepare empty grid
    final grid = List.generate(rows, (_) => List.filled(cols, ''));

    // Calculate how many columns are shorter due to incomplete last row
    final int totalCells = cols * rows;
    final int shortCols = totalCells - cipher.length;

    // Determine height of each column
    final colHeights = List<int>.filled(cols, rows);
    for (int i = cols - shortCols; i < cols; i++) {
      colHeights[colOrder.indexOf(i)] = rows - 1;
    }

    // Fill ciphertext into columns in key-specified order
    int cipherIndex = 0;
    for (int k = 0; k < cols; k++) {
      final currentCol = colOrder[k];
      for (int r = 0; r < colHeights[k]; r++) {
        if (cipherIndex < cipher.length) {
          grid[r][currentCol] = cipher[cipherIndex++];
        }
      }
    }

    // Read row-wise to reconstruct plaintext
    final decrypted = StringBuffer();
    for (final row in grid) {
      decrypted.write(row.join());
    }

    return decrypted.toString();
  }

  /// Converts key string like "3142" into column order [2, 0, 3, 1]
  static List<int> _getKeyOrder(String key) {
    final indexed =
        key
            .split('')
            .asMap()
            .entries
            .map((entry) => MapEntry(entry.key, int.parse(entry.value)))
            .toList();

    indexed.sort((a, b) => a.value.compareTo(b.value));
    return indexed.map((entry) => entry.key).toList();
  }

  /// Helper function to validate key (optional but recommended)
  static bool isValidKey(String key) {
    if (key.isEmpty) return false;

    // Check if all characters are digits
    if (!RegExp(r'^\d+$').hasMatch(key)) return false;

    // Check if key contains all numbers from 1 to N without duplicates
    final numbers = key.split('').map(int.parse).toList();
    final expected = List.generate(numbers.length, (i) => i + 1);
    return numbers.toSet().length == numbers.length &&
        numbers.every(expected.contains);
  }
}
