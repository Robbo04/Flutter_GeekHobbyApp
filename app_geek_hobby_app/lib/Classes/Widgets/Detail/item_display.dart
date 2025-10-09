import 'package:flutter/material.dart';

class ItemDisplay extends StatelessWidget {
  final String title;
  final List<Widget> details;
  final String? imageUrl;

  const ItemDisplay({
    super.key,
    required this.title,
    required this.details,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: const Color.fromARGB(255, 219, 167, 227),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            if (imageUrl != null && imageUrl!.isNotEmpty)
              Center(
                child: Image.network(imageUrl!, height: 200),
              ),
            const SizedBox(height: 16),
            ...details,
          ],
        ),
      ),
    );
  }
}