import 'package:flutter/material.dart';

class SuggestionsPage extends StatelessWidget {
  const SuggestionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Suggestions'),
        backgroundColor: const Color.fromARGB(255, 219, 167, 227),
      ),
      body: const Center(
        child: Text('Suggestions Page Content Here'),
      ),
    );
  }
}
