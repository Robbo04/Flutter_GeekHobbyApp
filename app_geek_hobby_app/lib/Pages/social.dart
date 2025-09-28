import 'package:flutter/material.dart';

class SocialPage extends StatelessWidget {
  const SocialPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Social'),
        backgroundColor: const Color.fromARGB(255, 219, 167, 227),
      ),
      body: const Center(
        child: Text('Social Page Content Here'),
      ),
    );
  }
}
