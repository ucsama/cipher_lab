import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

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
      ),
      home: HomeScreen(),
    );
  }
}
