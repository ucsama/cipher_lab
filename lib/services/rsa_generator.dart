import 'dart:math';
import 'modular_inverse.dart';

class RSAKeyPair {
  final int p, q, n, phi, e, d;
  RSAKeyPair({
    required this.p,
    required this.q,
    required this.n,
    required this.phi,
    required this.e,
    required this.d,
  });

  int encrypt(int plaintext) {
    return _modPow(plaintext, e, n);
  }

  int decrypt(int ciphertext) {
    return _modPow(ciphertext, d, n);
  }

  int _modPow(int base, int exp, int mod) {
    int result = 1;
    base = base % mod;
    while (exp > 0) {
      if (exp % 2 == 1) {
        result = (result * base) % mod;
      }
      exp = exp ~/ 2;
      base = (base * base) % mod;
    }
    return result;
  }
}

class RSAGenerator {
  static final _random = Random();

  static int _generatePrime() {
    // Larger primes to ensure n > 255
    final primes = [
      263,
      269,
      271,
      277,
      281,
      283,
      293,
      307,
      311,
      313,
      317,
      331,
      337,
      347,
      349,
      353,
      359,
      367,
    ];
    return primes[_random.nextInt(primes.length)];
  }

  static RSAKeyPair generateKeyPair() {
    int p = _generatePrime();
    int q = _generatePrime();
    while (q == p) {
      q = _generatePrime();
    }

    int n = p * q;
    int phi = (p - 1) * (q - 1);
    int e = 3;

    while (e < phi && ModularInverseCalculator.gcd(e, phi) != 1) {
      e += 2;
    }

    int? d = ModularInverseCalculator.modInverse(e, phi);
    if (d == null) throw Exception('No modular inverse for e = $e, phi = $phi');

    return RSAKeyPair(p: p, q: q, n: n, phi: phi, e: e, d: d);
  }
}
