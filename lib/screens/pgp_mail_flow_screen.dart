import 'package:flutter/material.dart';
import 'pgp_home_screen.dart';

class PgpMailFlowScreen extends StatelessWidget {
  const PgpMailFlowScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      appBar: AppBar(title: const Text('PGP Mail Flow')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PgpHomeScreen(isSender: true),
                  ),
                );
              },
              child: const Text('Continue as Sender (User A)'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PgpHomeScreen(isSender: false),
                  ),
                );
              },
              child: const Text('Continue as Receiver (User B)'),
            ),
          ],
        ),
      ),
    );
  }
}
