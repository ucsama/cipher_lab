import 'package:cipher_lab/services/transposition_cipher.dart';
import 'package:flutter/material.dart';
// import your helper class here

class TranspositionScreen extends StatefulWidget {
  @override
  _TranspositionScreenState createState() => _TranspositionScreenState();
}

class _TranspositionScreenState extends State<TranspositionScreen> {
  final _textController = TextEditingController();
  final _keyController = TextEditingController();
  String _result = '';
  String _error = '';

  void _encrypt() {
    setState(() {
      _error = '';
      if (!_validateInputs()) return;

      _result = TranspositionCipher.encrypt(
        _textController.text.trim(),
        _keyController.text.trim(),
      );
    });
  }

  void _decrypt() {
    setState(() {
      _error = '';
      if (!_validateInputs()) return;

      _result = TranspositionCipher.decrypt(
        _textController.text.trim(),
        _keyController.text.trim(),
      );
    });
  }

  bool _validateInputs() {
    if (_textController.text.trim().isEmpty) {
      _error = 'Please enter text or cipher to process.';
      return false;
    }
    if (_keyController.text.trim().isEmpty) {
      _error = 'Please enter a numeric key.';
      return false;
    }
    final key = _keyController.text.trim();
    if (!RegExp(r'^[1-9][0-9]*$').hasMatch(key)) {
      _error = 'Key must be numeric digits only (e.g., 3142).';
      return false;
    }
    final digits = key.split('');
    final uniqueDigits = digits.toSet();
    if (digits.length != uniqueDigits.length) {
      _error = 'Key digits must be unique (no repeats).';
      return false;
    }
    return true;
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
      appBar: AppBar(title: Text('Transposition Cipher')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'What is Transposition Cipher?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 6),
            Text(
              'A transposition cipher encrypts by rearranging characters according to a key. '
              'The key is a numeric sequence that indicates the column order in which text columns '
              'are read to form the ciphertext.\n\n'
              'How to use:\n'
              '1. Enter your plain text (for encryption) or ciphertext (for decryption).\n'
              '2. Enter a numeric key with unique digits, e.g., 3142.\n'
              '3. Tap "Encrypt" or "Decrypt".',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _textController,
              maxLines: null,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter Text or Cipher',
                hintText: 'Type your text here',
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _keyController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Numeric Key (e.g., 3142)',
                hintText: 'Digits must be unique',
              ),
              keyboardType: TextInputType.number,
            ),
            if (_error.isNotEmpty) ...[
              SizedBox(height: 12),
              Text(
                _error,
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _encrypt,
                  icon: Icon(Icons.lock),
                  label: Text('Encrypt'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _decrypt,
                  icon: Icon(Icons.lock_open),
                  label: Text('Decrypt'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  ),
                ),
              ],
            ),
            SizedBox(height: 30),
            Text(
              'Result:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: SelectableText(
                _result.isEmpty ? 'No result yet.' : _result,
                style: TextStyle(fontSize: 16, fontFamily: 'Courier'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
