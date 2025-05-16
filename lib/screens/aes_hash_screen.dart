import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/material.dart';

/// Service to do AES encrypt/decrypt using 'encrypt' package with prefix `encrypt`
class AESService {
  final encrypt.Key key;
  final encrypt.IV iv;

  AESService(String keyString)
    : key = encrypt.Key.fromUtf8(_formatKey(keyString)),
      iv = encrypt.IV.fromLength(16); // fixed IV length for simplicity

  // Pad or trim the key to 32 bytes (AES-256)
  static String _formatKey(String key) {
    if (key.length > 32) return key.substring(0, 32);
    return key.padRight(32, '0');
  }

  String encryptText(String plainText) {
    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    final encrypted = encrypter.encrypt(plainText, iv: iv);
    return encrypted.base64;
  }

  String decryptText(String cipherText) {
    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    final decrypted = encrypter.decrypt64(cipherText, iv: iv);
    return decrypted;
  }
}

/// Service to compute SHA-256 hash
class HashService {
  static String sha256Hash(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}

/// Main screen widget
class AESHashScreen extends StatefulWidget {
  @override
  _AESHashScreenState createState() => _AESHashScreenState();
}

class _AESHashScreenState extends State<AESHashScreen> {
  final _textController = TextEditingController();
  final _keyController = TextEditingController();
  String _aesResult = '';
  String _hashResult = '';

  void _encrypt() {
    final aes = AESService(_keyController.text);
    final encrypted = aes.encryptText(_textController.text);
    setState(() {
      _aesResult = encrypted;
      _hashResult = ''; // clear hash result when encrypting
    });
  }

  void _decrypt() {
    try {
      final aes = AESService(_keyController.text);
      final decrypted = aes.decryptText(_aesResult);
      setState(() {
        _aesResult = decrypted;
        _hashResult = ''; // clear hash result when decrypting
      });
    } catch (e) {
      setState(() {
        _aesResult = 'Decryption failed: ${e.toString()}';
        _hashResult = '';
      });
    }
  }

  void _hash() {
    final hashed = HashService.sha256Hash(_textController.text);
    setState(() {
      _hashResult = hashed;
      _aesResult = ''; // clear AES result when hashing
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _keyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('AES Encryption & SHA-256 Hashing')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _textController,
              decoration: InputDecoration(
                labelText: 'Input Text',
                border: OutlineInputBorder(),
              ),
              maxLines: null,
            ),
            SizedBox(height: 12),
            TextField(
              controller: _keyController,
              decoration: InputDecoration(
                labelText: 'AES Key (min 1 char)',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(onPressed: _encrypt, child: Text('Encrypt')),
                ElevatedButton(onPressed: _decrypt, child: Text('Decrypt')),
                ElevatedButton(onPressed: _hash, child: Text('SHA-256 Hash')),
              ],
            ),
            SizedBox(height: 24),
            if (_aesResult.isNotEmpty) ...[
              Text(
                'AES Result:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 8),
              SelectableText(_aesResult),
            ],
            if (_hashResult.isNotEmpty) ...[
              Text(
                'SHA-256 Hash:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 8),
              SelectableText(_hashResult),
            ],
          ],
        ),
      ),
    );
  }
}
