import 'package:flutter/material.dart';
import '../services/rsa_generator.dart';

class RSAScreen extends StatefulWidget {
  @override
  _RSAScreenState createState() => _RSAScreenState();
}

class _RSAScreenState extends State<RSAScreen> {
  RSAKeyPair? _keyPair;
  String _result = '';
  final _plainController = TextEditingController();
  String _encrypted = '';
  String _decrypted = '';

  void _generateKeys() {
    final keyPair = RSAGenerator.generateKeyPair();
    setState(() {
      _keyPair = keyPair;
      _encrypted = '';
      _decrypted = '';
      _result = '''
🔐 RSA Key Pair Generated

🧮 Prime Numbers:
• p = ${keyPair.p}
• q = ${keyPair.q}

🔢 Key Values:
• n = p × q = ${keyPair.n}
• φ(n) = (p−1)×(q−1) = ${keyPair.phi}

🗝️ Public Key:
• (e, n) = (${keyPair.e}, ${keyPair.n})

🔐 Private Key:
• (d, n) = (${keyPair.d}, ${keyPair.n})
''';
    });
  }

  void _encrypt() {
    if (_keyPair == null) return;
    final text = _plainController.text.trim();
    if (text.isEmpty || text.codeUnits.any((c) => c > 255)) {
      setState(() => _encrypted = '❌ Only basic ASCII supported.');
      return;
    }

    final encryptedCodes = text.codeUnits.map(_keyPair!.encrypt).toList();
    setState(() {
      _encrypted = encryptedCodes.join(' ');
    });
  }

  void _decrypt() {
    if (_keyPair == null || _encrypted.isEmpty) return;

    try {
      final codes = _encrypted.split(' ').map(int.parse).toList();
      final decryptedChars =
          codes
              .map(_keyPair!.decrypt)
              .map((c) => String.fromCharCode(c))
              .join();
      setState(() {
        _decrypted = decryptedChars;
      });
    } catch (e) {
      setState(() => _decrypted = '❌ Decryption failed.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🔐 RSA Encryption')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            ElevatedButton.icon(
              icon: Icon(Icons.vpn_key),
              label: Text('Generate RSA Keys'),
              onPressed: _generateKeys,
            ),
            SizedBox(height: 20),
            SelectableText(_result, style: TextStyle(fontFamily: 'Courier')),
            Divider(height: 30),
            TextField(
              controller: _plainController,
              decoration: InputDecoration(
                labelText: 'Message to Encrypt (ASCII only)',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.lock),
                    label: Text('Encrypt'),
                    onPressed: _encrypt,
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.lock_open),
                    label: Text('Decrypt'),
                    onPressed: _decrypt,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              '🔐 Encrypted:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SelectableText(_encrypted),
            SizedBox(height: 10),
            Text(
              '🔓 Decrypted:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SelectableText(_decrypted),
          ],
        ),
      ),
    );
  }
}
