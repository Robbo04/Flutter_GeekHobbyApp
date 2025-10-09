import 'package:flutter/material.dart';

class ItemDisplay extends StatelessWidget {
  final String title;
  final List<Widget> details;
  final String? imageUrl;
  final bool owned;
  final bool wishlisted;
  final ValueChanged<bool> onOwnedChanged;
  final ValueChanged<bool> onWishlistChanged;

  const ItemDisplay({
    super.key,
    required this.title,
    required this.details,
    this.imageUrl,
    required this.owned,
    required this.wishlisted,
    required this.onOwnedChanged,
    required this.onWishlistChanged,
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
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: SwitchListTile(
                    title: const Text('Owned'),
                    value: owned,
                    onChanged: (val) {
                      if (!owned) {
                        onOwnedChanged(val);
                        if (wishlisted) {
                          onWishlistChanged(false);
                        }
                      } else {
                        onOwnedChanged(val);
                      }
                    },
                  ),
                ),
                Expanded(
                  child: SwitchListTile(
                    title: const Text('Wishlist'),
                    value: wishlisted,
                    onChanged: owned
                        ? null // Disable if owned
                        : (val) => onWishlistChanged(val),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}