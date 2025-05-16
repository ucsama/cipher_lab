class ModularInverseCalculator {
  /// Euclidean algorithm for GCD
  static int gcd(int a, int b) {
    while (b != 0) {
      int temp = b;
      b = a % b;
      a = temp;
    }
    return a;
  }

  /// Extended Euclidean Algorithm to find modular inverse
  /// Returns null if inverse doesn't exist
  static int? modInverse(int a, int m) {
    int m0 = m;
    int y = 0, x = 1;

    if (m == 1) return null;

    while (a > 1) {
      int q = a ~/ m;
      int t = m;

      m = a % m;
      a = t;
      t = y;

      y = x - q * y;
      x = t;
    }

    if (x < 0) x += m0;

    return x;
  }
}
