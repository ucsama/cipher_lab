import 'package:flutter/material.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'home_screen.dart';

class WelcomeScreen extends StatelessWidget {
  final List<String> ciphers = [
    'Caesar Cipher',
    'Affine Cipher',
    'Vernam Cipher',
    'RSA Key Generator',
    'Transposition Cipher',
    'AES & SHA-256',
    'PGP Email (Sender & Receiver)',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo[50],
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 40),
            Text(
              '🔐 Cipher Lab',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.indigo[900],
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Available Ciphers:',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Colors.indigo[800],
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: ciphers.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Icon(Icons.lock, color: Colors.indigo),
                    title: Text(
                      ciphers[index],
                      style: TextStyle(fontSize: 18, color: Colors.indigo[900]),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 30),
            SlideAction(
              outerColor: Colors.indigo,
              innerColor: Colors.white,
              sliderButtonIcon: Icon(Icons.arrow_forward, color: Colors.indigo),
              text: 'Slide to Continue',
              textStyle: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              onSubmit: () {
                Future.delayed(Duration(milliseconds: 300), () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => HomeScreen()),
                  );
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
