import 'dart:math';
import 'package:flutter/material.dart';
import '../services/vernam_cipher.dart';

class VernamScreen extends StatefulWidget {
  @override
  _VernamScreenState createState() => _VernamScreenState();
}

class _VernamScreenState extends State<VernamScreen> {
  final _textController = TextEditingController();
  final _keyController = TextEditingController();
  String _result = '';
  String? _error;

  void _encrypt() {
    final text = _textController.text.trim().toUpperCase();
    final key = _keyController.text.trim().toUpperCase();

    final result = VernamCipher.encrypt(text, key);
    setState(() {
      if (result.startsWith('Error')) {
        _error = result;
        _result = '';
      } else {
        _error = null;
        _result = result;
      }
    });
  }

  void _decrypt() {
    final text = _textController.text.trim().toUpperCase();
    final key = _keyController.text.trim().toUpperCase();

    final result = VernamCipher.decrypt(text, key);
    setState(() {
      if (result.startsWith('Error')) {
        _error = result;
        _result = '';
      } else {
        _error = null;
        _result = result;
      }
    });
  }

  void _generateKey() {
    final text = _textController.text.trim().toUpperCase();
    if (text.isEmpty) {
      setState(() {
        _error = 'Enter text first to generate key.';
        _result = '';
      });
      return;
    }
    if (!RegExp(r'^[A-Z]+$').hasMatch(text)) {
      setState(() {
        _error = 'Text must only contain A-Z characters.';
        _result = '';
      });
      return;
    }

    final key = generateRandomKey(text.length);
    setState(() {
      _keyController.text = key;
      _error = null;
    });
  }

  String generateRandomKey(int length) {
    final rand = Random();
    const alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    return List.generate(length, (_) => alphabet[rand.nextInt(26)]).join();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Vernam Cipher')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              'The Vernam Cipher is a symmetric key cipher where the key must be the same length as the plaintext.\n'
              'Each character is XORed with the corresponding key character.\n\n'
              '⚠️ Instructions:\n'
              '- Use only uppercase alphabetic characters (A-Z).\n'
              '- The plaintext and key must be the same length.\n\n'
              '✔️ Example:\n  Text: HELLO\n  Key: XMCKL',
              style: TextStyle(fontSize: 14, color: Colors.grey[800]),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _textController,
              decoration: InputDecoration(
                labelText: 'Text (A-Z only)',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _keyController,
              decoration: InputDecoration(
                labelText: 'Key (same length as text, A-Z only)',
                border: OutlineInputBorder(),
              ),
            ),
            TextButton.icon(
              icon: Icon(Icons.sync),
              label: Text('Generate Random Key'),
              onPressed: _generateKey,
            ),
            SizedBox(height: 16),
            if (_error != null)
              Text(
                _error!,
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(onPressed: _encrypt, child: Text('Encrypt')),
                ElevatedButton(onPressed: _decrypt, child: Text('Decrypt')),
              ],
            ),
            SizedBox(height: 24),
            Text('Result:', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            SelectableText(
              _result.isEmpty ? 'No result yet' : _result,
              style: TextStyle(fontSize: 16, color: Colors.blue[800]),
            ),
          ],
        ),
      ),
    );
  }
}
