import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AESHashScreen extends StatefulWidget {
  @override
  _AESHashScreenState createState() => _AESHashScreenState();
}

class _AESHashScreenState extends State<AESHashScreen> {
  final _textController = TextEditingController();
  final _keyController = TextEditingController();
  String _aesResult = '';
  String _hashResult = '';
  bool _showAdvanced = false;
  bool _isEncrypting = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AES & SHA-256'),
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline),
            onPressed: _showHelpDialog,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 2,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      'Cryptographic Operations',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    SizedBox(height: 8),
                    ToggleButtons(
                      isSelected: [_isEncrypting, !_isEncrypting],
                      onPressed: (int index) {
                        setState(() {
                          _isEncrypting = index == 0;
                          _aesResult = '';
                          _hashResult = '';
                        });
                      },
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text('AES'),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text('SHA-256'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _textController,
              decoration: InputDecoration(
                labelText: _isEncrypting ? 'Text to Encrypt' : 'Text to Hash',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () => _textController.clear(),
                ),
              ),
              maxLines: 3,
              minLines: 1,
            ),
            if (_isEncrypting) ...[
              SizedBox(height: 12),
              TextField(
                controller: _keyController,
                decoration: InputDecoration(
                  labelText: 'Encryption Key',
                  border: OutlineInputBorder(),
                  hintText: 'Enter secret key (min 8 characters)',
                ),
                obscureText: true,
                maxLines: 1,
              ),
            ],
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isEncrypting ? _performAESOperation : _hash,
              child: Text(
                _isEncrypting
                    ? (_aesResult.isEmpty ? 'Encrypt' : 'Decrypt')
                    : 'Generate Hash',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _isEncrypting
                        ? Colors.blue.shade800
                        : Colors.purple.shade800,
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            SizedBox(height: 24),
            if (_aesResult.isNotEmpty)
              _buildResultCard(
                _aesResult.startsWith('Error:')
                    ? 'Error'
                    : (_aesResult == _textController.text
                        ? 'Decrypted Text'
                        : 'Encrypted Result'),
                _aesResult,
                isError: _aesResult.startsWith('Error:'),
              ),
            if (_hashResult.isNotEmpty)
              _buildResultCard('SHA-256 Hash', _hashResult, isError: false),
            SizedBox(height: 16),
            ExpansionTile(
              title: Text('Advanced Options'),
              initiallyExpanded: false,
              children: [
                ListTile(
                  title: Text('Copy to Clipboard'),
                  trailing: Icon(Icons.copy),
                  onTap: () {
                    final text =
                        _aesResult.isNotEmpty ? _aesResult : _hashResult;
                    if (text.isNotEmpty) {
                      Clipboard.setData(ClipboardData(text: text));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Copied to clipboard')),
                      );
                    }
                  },
                ),
                ListTile(
                  title: Text('Clear All'),
                  trailing: Icon(Icons.clear_all),
                  onTap: _clearAll,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(
    String title,
    String content, {
    bool isError = false,
  }) {
    return Card(
      color: isError ? Colors.red.shade50 : Colors.grey.shade50,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isError ? Colors.red.shade900 : Colors.grey.shade900,
              ),
            ),
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: SelectableText(
                content,
                style: TextStyle(
                  fontFamily: 'monospace',
                  color: isError ? Colors.red.shade800 : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _performAESOperation() {
    if (_textController.text.isEmpty) {
      setState(() {
        _aesResult = 'Error: Please enter text to process';
      });
      return;
    }

    if (_keyController.text.isEmpty) {
      setState(() {
        _aesResult = 'Error: Please enter an encryption key';
      });
      return;
    }

    try {
      if (_aesResult.isEmpty) {
        // Encrypt
        final encrypted = _encryptText(
          _textController.text,
          _keyController.text,
        );
        setState(() {
          _aesResult = encrypted;
          _hashResult = '';
        });
      } else {
        // Decrypt
        final decrypted = _decryptText(_aesResult, _keyController.text);
        setState(() {
          _aesResult = decrypted;
          _hashResult = '';
        });
      }
    } catch (e) {
      setState(() {
        _aesResult = 'Error: ${e.toString()}';
      });
    }
  }

  String _encryptText(String plainText, String password) {
    final iv = encrypt.IV.fromSecureRandom(16);
    final key = _deriveKey(password);

    final encrypter = encrypt.Encrypter(
      encrypt.AES(key, mode: encrypt.AESMode.cbc),
    );

    final encrypted = encrypter.encrypt(plainText, iv: iv);
    final bytes = iv.bytes + encrypted.bytes;
    return base64.encode(bytes);
  }

  String _decryptText(String cipherTextWithIv, String password) {
    final combined = base64.decode(cipherTextWithIv);
    final iv = encrypt.IV(combined.sublist(0, 16));
    final cipherText = combined.sublist(16);
    final key = _deriveKey(password);

    final encrypter = encrypt.Encrypter(
      encrypt.AES(key, mode: encrypt.AESMode.cbc),
    );

    return encrypter.decrypt(encrypt.Encrypted(cipherText), iv: iv);
  }

  encrypt.Key _deriveKey(String password) {
    if (password.length < 8) {
      throw Exception('Key must be at least 8 characters');
    }
    // In production, use proper key derivation like PBKDF2
    return encrypt.Key.fromUtf8(password.padRight(32).substring(0, 32));
  }

  void _hash() {
    if (_textController.text.isEmpty) {
      setState(() {
        _hashResult = 'Error: Please enter text to hash';
      });
      return;
    }

    final hashed = sha256.convert(utf8.encode(_textController.text)).toString();
    setState(() {
      _hashResult = hashed;
      _aesResult = '';
    });
  }

  void _clearAll() {
    setState(() {
      _textController.clear();
      _keyController.clear();
      _aesResult = '';
      _hashResult = '';
    });
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('AES & SHA-256 Help'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'AES-256 Encryption:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('• Uses AES-256-CBC with random IV'),
                  Text('• IV is prepended to the ciphertext'),
                  Text('• Same key must be used for decryption'),
                  Text('• Minimum 8 character key recommended'),
                  SizedBox(height: 16),
                  Text(
                    'SHA-256 Hashing:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('• Produces 256-bit cryptographic hash'),
                  Text('• One-way function (cannot be reversed)'),
                  Text('• Same input always produces same output'),
                  SizedBox(height: 16),
                  Text(
                    'Security Notes:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text('• Never share your encryption keys'),
                  Text('• Store keys securely'),
                  Text('• This is a demonstration tool only'),
                ],
              ),
            ),
            actions: [
              TextButton(
                child: Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _keyController.dispose();
    super.dispose();
  }
}
