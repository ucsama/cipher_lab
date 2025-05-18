import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:openpgp/openpgp.dart';
import 'package:url_launcher/url_launcher.dart';

class PgpHomeScreen extends StatefulWidget {
  final bool isSender;

  const PgpHomeScreen({super.key, required this.isSender});

  @override
  State<PgpHomeScreen> createState() => _PgpHomeScreenState();
}

class _PgpHomeScreenState extends State<PgpHomeScreen> {
  // Persistent controllers
  static final TextEditingController _passphraseController =
      TextEditingController();
  static final TextEditingController _messageController =
      TextEditingController();
  static final TextEditingController _publicKeyController =
      TextEditingController();
  static final TextEditingController _privateKeyController =
      TextEditingController();
  static final TextEditingController _encryptedMessageController =
      TextEditingController();

  // Receiver email input (sender only)
  static final TextEditingController _receiverEmailController =
      TextEditingController();

  static String _generatedPublicKey = '';
  static String _generatedPrivateKey = '';
  static String _decryptedMessage = '';

  Future<void> _generateKeyPair() async {
    try {
      var keyOptions = KeyOptions()..rsaBits = 2048;
      var keyPair = await OpenPGP.generate(
        options:
            Options()
              ..name = 'User B'
              ..email = 'userb@example.com'
              ..passphrase = _passphraseController.text
              ..keyOptions = keyOptions,
      );

      setState(() {
        _generatedPublicKey = keyPair.publicKey;
        _generatedPrivateKey = keyPair.privateKey;
        _privateKeyController.text = keyPair.privateKey;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Key pair generated successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Key generation error: $e')));
    }
  }

  Future<void> _encryptMessage() async {
    try {
      final encrypted = await OpenPGP.encrypt(
        _messageController.text,
        _publicKeyController.text,
      );

      setState(() {
        _encryptedMessageController.text = encrypted;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Message encrypted successfully!')),
      );

      await _launchEmailApp(encrypted);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Encryption error: $e')));
    }
  }

  Future<void> _launchEmailApp(String encryptedMessage) async {
    final receiverEmail = _receiverEmailController.text.trim();
    if (receiverEmail.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter receiver\'s email')),
      );
      return;
    }

    final subject = Uri.encodeComponent('Encrypted PGP Message');
    final body = Uri.encodeComponent(
      'You have received an encrypted message:\n\n$encryptedMessage\n\nUse your PGP app to decrypt it.',
    );

    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: receiverEmail,
      query: 'subject=$subject&body=$body',
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not open email app')));
    }
  }

  Future<void> _decryptMessage() async {
    try {
      final decrypted = await OpenPGP.decrypt(
        _encryptedMessageController.text,
        _privateKeyController.text,
        _passphraseController.text,
      );

      setState(() {
        _decryptedMessage = decrypted;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Message decrypted successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Decryption error: $e')));
    }
  }

  void _copyToClipboard(String label, String text) {
    if (text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Nothing to copy for $label')));
      return;
    }
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$label copied to clipboard')));
  }

  void _clearAllFields() {
    setState(() {
      _passphraseController.clear();
      _messageController.clear();
      _publicKeyController.clear();
      _privateKeyController.clear();
      _encryptedMessageController.clear();
      _receiverEmailController.clear();

      _generatedPublicKey = '';
      _generatedPrivateKey = '';
      _decryptedMessage = '';
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('All fields cleared')));
  }

  @override
  Widget build(BuildContext context) {
    final isSender = widget.isSender;

    return Scaffold(
      appBar: AppBar(
        title: Text(isSender ? 'PGP Sender (User A)' : 'PGP Receiver (User B)'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isSender) ...[
              const Text(
                '🔐 Key Generation',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                'Enter a passphrase to protect your keys, then generate your key pair.',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passphraseController,
                decoration: const InputDecoration(
                  labelText: 'Passphrase',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _generateKeyPair,
                child: const Text('Generate Key Pair'),
              ),
              const SizedBox(height: 20),
              if (_generatedPublicKey.isNotEmpty) ...[
                const Text(
                  'Public Key:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.grey.shade100,
                  ),
                  child: SelectableText(_generatedPublicKey),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    icon: const Icon(Icons.copy),
                    label: const Text('Copy Public Key'),
                    onPressed:
                        () =>
                            _copyToClipboard('Public Key', _generatedPublicKey),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              if (_generatedPrivateKey.isNotEmpty) ...[
                const Text(
                  'Private Key:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.grey.shade100,
                  ),
                  child: SelectableText(_generatedPrivateKey),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    icon: const Icon(Icons.copy),
                    label: const Text('Copy Private Key'),
                    onPressed:
                        () => _copyToClipboard(
                          'Private Key',
                          _generatedPrivateKey,
                        ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
              ElevatedButton(
                onPressed: _clearAllFields,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Clear All Fields'),
              ),
              const Divider(height: 40),
            ],
            if (isSender) ...[
              const Text(
                '✉️ Encrypt Message',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                'Enter your message, the receiver\'s public key, and receiver\'s email to encrypt and send.',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _messageController,
                decoration: const InputDecoration(
                  labelText: 'Message',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _publicKeyController,
                decoration: const InputDecoration(
                  labelText: 'Receiver Public Key',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _receiverEmailController,
                decoration: const InputDecoration(
                  labelText: 'Receiver Email',
                  border: OutlineInputBorder(),
                  hintText: 'receiver@example.com',
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _encryptMessage,
                child: const Text('Encrypt & Send Email'),
              ),
              const SizedBox(height: 12),
              if (_encryptedMessageController.text.isNotEmpty) ...[
                const Text(
                  'Encrypted Message:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.grey.shade100,
                  ),
                  child: SelectableText(_encryptedMessageController.text),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    icon: const Icon(Icons.copy),
                    label: const Text('Copy Encrypted Message'),
                    onPressed:
                        () => _copyToClipboard(
                          'Encrypted Message',
                          _encryptedMessageController.text,
                        ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
              ElevatedButton(
                onPressed: _clearAllFields,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Clear All Fields'),
              ),
            ],
            if (!isSender) ...[
              const Text(
                '🔓 Decrypt Message',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                'Paste the encrypted message, your private key, and passphrase to decrypt the message.',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _encryptedMessageController,
                decoration: const InputDecoration(
                  labelText: 'Encrypted Message',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _privateKeyController,
                decoration: const InputDecoration(
                  labelText: 'Private Key',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passphraseController,
                decoration: const InputDecoration(
                  labelText: 'Passphrase',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _decryptMessage,
                child: const Text('Decrypt Message'),
              ),
              const SizedBox(height: 12),
              if (_decryptedMessage.isNotEmpty) ...[
                const Text(
                  'Decrypted Message:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.grey.shade100,
                  ),
                  child: SelectableText(_decryptedMessage),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    icon: const Icon(Icons.copy),
                    label: const Text('Copy Decrypted Message'),
                    onPressed:
                        () => _copyToClipboard(
                          'Decrypted Message',
                          _decryptedMessage,
                        ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
