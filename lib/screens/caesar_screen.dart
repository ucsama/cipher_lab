import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/caesar_cipher.dart';

class CaesarScreen extends StatefulWidget {
  @override
  _CaesarScreenState createState() => _CaesarScreenState();
}

class _CaesarScreenState extends State<CaesarScreen> {
  final _formKey = GlobalKey<FormState>();
  final _textController = TextEditingController();
  final _shiftController = TextEditingController();

  String _result = '';

  // Check if form input is valid
  bool get _isValidInput {
    final shift = int.tryParse(_shiftController.text.trim());
    return _formKey.currentState?.validate() == true && shift != null;
  }

  void _encrypt() {
    if (!_isValidInput) return;

    final text = _textController.text.trim();
    final shift = int.parse(_shiftController.text.trim());

    setState(() {
      _result = CaesarCipher.encrypt(text, shift);
    });
  }

  void _decrypt() {
    if (!_isValidInput) return;

    final text = _textController.text.trim();
    final shift = int.parse(_shiftController.text.trim());

    setState(() {
      _result = CaesarCipher.decrypt(text, shift);
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _shiftController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Caesar Cipher')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              'Caesar Cipher is a simple substitution cipher where each letter in the plaintext '
              'is shifted a fixed number of places down the alphabet.\n\n'
              'Instructions:\n'
              '- Enter the text you want to encrypt or decrypt.\n'
              '- Enter a numeric shift value (e.g., 3).\n'
              '- Press Encrypt to encode the text.\n'
              '- Press Decrypt to decode the text.\n\n'
              'Only English alphabetic characters will be shifted; other characters remain unchanged.',
              style: TextStyle(fontSize: 14, color: Colors.grey[800]),
            ),
            SizedBox(height: 20),
            Form(
              key: _formKey,
              onChanged: () => setState(() {}),
              child: Column(
                children: [
                  TextFormField(
                    controller: _textController,
                    decoration: InputDecoration(
                      labelText: 'Enter Text',
                      border: OutlineInputBorder(),
                      suffixIcon:
                          _textController.text.isNotEmpty
                              ? IconButton(
                                icon: Icon(Icons.clear),
                                onPressed: () {
                                  _textController.clear();
                                  setState(() {
                                    _result = '';
                                  });
                                },
                              )
                              : null,
                    ),
                    maxLines: null,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Text cannot be empty';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _shiftController,
                    decoration: InputDecoration(
                      labelText: 'Shift Value (integer)',
                      border: OutlineInputBorder(),
                      suffixIcon:
                          _shiftController.text.isNotEmpty
                              ? IconButton(
                                icon: Icon(Icons.clear),
                                onPressed: () {
                                  _shiftController.clear();
                                  setState(() {
                                    _result = '';
                                  });
                                },
                              )
                              : null,
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Shift value is required';
                      }
                      if (int.tryParse(value.trim()) == null) {
                        return 'Shift must be an integer';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _isValidInput ? _encrypt : null,
                  child: Text('Encrypt'),
                ),
                ElevatedButton(
                  onPressed: _isValidInput ? _decrypt : null,
                  child: Text('Decrypt'),
                ),
              ],
            ),
            SizedBox(height: 24),
            Text('Result:', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            SelectableText(
              _result.isEmpty ? 'No result yet' : _result,
              style: TextStyle(fontSize: 16, color: Colors.blue[800]),
            ),
            if (_result.isNotEmpty) ...[
              SizedBox(height: 12),
              ElevatedButton.icon(
                icon: Icon(Icons.copy),
                label: Text('Copy Result'),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: _result));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Result copied to clipboard')),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
