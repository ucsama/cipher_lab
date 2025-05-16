import 'package:flutter/material.dart';
import '../services/affine_cipher.dart';

class AffineScreen extends StatefulWidget {
  @override
  _AffineScreenState createState() => _AffineScreenState();
}

class _AffineScreenState extends State<AffineScreen> {
  final _textController = TextEditingController();
  final _aController = TextEditingController();
  final _bController = TextEditingController();
  String _result = '';
  String? _error;

  void _encrypt() {
    final text = _textController.text.trim();
    final a = int.tryParse(_aController.text.trim());
    final b = int.tryParse(_bController.text.trim());

    if (text.isEmpty || a == null || b == null) {
      setState(() {
        _error = 'Please enter valid text and integer keys a and b.';
        _result = '';
      });
      return;
    }

    // Check that 'a' and 26 are coprime (affine cipher requirement)
    if (_gcd(a, 26) != 1) {
      setState(() {
        _error = 'Key "a" must be coprime with 26 (gcd(a,26) = 1).';
        _result = '';
      });
      return;
    }

    setState(() {
      _result = AffineCipher.encrypt(text, a, b);
      _error = null;
    });
  }

  void _decrypt() {
    final text = _textController.text.trim();
    final a = int.tryParse(_aController.text.trim());
    final b = int.tryParse(_bController.text.trim());

    if (text.isEmpty || a == null || b == null) {
      setState(() {
        _error = 'Please enter valid text and integer keys a and b.';
        _result = '';
      });
      return;
    }

    if (_gcd(a, 26) != 1) {
      setState(() {
        _error = 'Key "a" must be coprime with 26 (gcd(a,26) = 1).';
        _result = '';
      });
      return;
    }

    setState(() {
      _result = AffineCipher.decrypt(text, a, b);
      _error = null;
    });
  }

  // Helper to compute gcd (greatest common divisor)
  int _gcd(int x, int y) {
    while (y != 0) {
      int temp = y;
      y = x % y;
      x = temp;
    }
    return x;
  }

  @override
  void dispose() {
    _textController.dispose();
    _aController.dispose();
    _bController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Affine Cipher')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              'Affine Cipher is a substitution cipher using the function: E(x) = (a*x + b) mod 26.\n\n'
              'Instructions:\n'
              '- Enter the text (only alphabets will be processed).\n'
              '- Enter integer key "a" (must be coprime with 26).\n'
              '- Enter integer key "b".\n'
              '- Press Encrypt to encode, Decrypt to decode.\n',
              style: TextStyle(fontSize: 14, color: Colors.grey[800]),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _textController,
              decoration: InputDecoration(
                labelText: 'Enter Text',
                border: OutlineInputBorder(),
              ),
              maxLines: null,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _aController,
              decoration: InputDecoration(
                labelText: 'Key a (must be coprime with 26)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _bController,
              decoration: InputDecoration(
                labelText: 'Key b',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
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
