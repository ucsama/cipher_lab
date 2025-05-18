import 'package:flutter/material.dart';
import 'screens/welcome_screen.dart';

void main() {
  runApp(CipherLabApp());
}

class CipherLabApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cipher Lab',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.indigo[50],
      ),
      home: WelcomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
