import 'package:cipher_lab/screens/pgp_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:cipher_lab/screens/aes_hash_screen.dart';
import 'package:cipher_lab/screens/affine_cipher.dart';
import 'package:cipher_lab/screens/rsa_screen.dart';
import 'package:cipher_lab/screens/transpostion_screen.dart';
import 'package:cipher_lab/screens/vernam_screen.dart';
import 'caesar_screen.dart';

class HomeScreen extends StatelessWidget {
  final List<Map<String, dynamic>> tools = [
    {
      'title': 'Caesar Cipher',
      'icon': Icons.lock_outline,
      'screen': CaesarScreen(),
    },
    {'title': 'Affine Cipher', 'icon': Icons.code, 'screen': AffineScreen()},
    {'title': 'Vernam Cipher', 'icon': Icons.vpn_key, 'screen': VernamScreen()},
    {
      'title': 'RSA Key Generator',
      'icon': Icons.security,
      'screen': RSAScreen(),
    },
    {
      'title': 'Transposition Cipher',
      'icon': Icons.shuffle,
      'screen': TranspositionScreen(),
    },
    {
      'title': 'AES & SHA-256',
      'icon': Icons.fingerprint,
      'screen': AESHashScreen(),
    },
    {
      'title': 'PGP Email - Sender',
      'icon': Icons.send,
      'screen': const PgpHomeScreen(isSender: true),
    },
    {
      'title': 'PGP Email - Receiver',
      'icon': Icons.mail_lock,
      'screen': const PgpHomeScreen(isSender: false),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cipher Lab'),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 600;
            return GridView.count(
              crossAxisCount: isWide ? 3 : 1,
              mainAxisSpacing: 20,
              crossAxisSpacing: 20,
              childAspectRatio: 3.5,
              children:
                  tools.map((tool) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => tool['screen'],
                          ),
                        );
                      },
                      child: Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        color: Colors.white,
                        shadowColor: Colors.indigo.withOpacity(0.4),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                tool['icon'],
                                size: 40,
                                color: Colors.indigo,
                              ),
                              SizedBox(width: 20),
                              Expanded(
                                child: Text(
                                  tool['title'],
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.indigo[900],
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 18,
                                color: Colors.indigo[700],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
            );
          },
        ),
      ),
    );
  }
}
