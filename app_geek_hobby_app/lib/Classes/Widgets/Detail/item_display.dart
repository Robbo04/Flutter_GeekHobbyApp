import 'package:app_geek_hobby_app/Classes/Widgets/user_rating_bar.dart';
import 'package:flutter/material.dart';

class ItemDisplay extends StatelessWidget {
  final String title;
  final List<Widget> details;
  final String? imageUrl;
  final bool owned;
  final bool wishlisted;
  final ValueChanged<bool> onOwnedChanged;
  final ValueChanged<bool> onWishlistChanged;
  final int userRating;
  final ValueChanged<int> onUserRatingChanged;

  const ItemDisplay({
    super.key,
    required this.title,
    required this.details,
    this.imageUrl,
    required this.owned,
    required this.wishlisted,
    required this.onOwnedChanged,
    required this.onWishlistChanged,
    required this.userRating,
    required this.onUserRatingChanged,
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
            // --- Add the toggles here ---
            Column(
              children: [
                SwitchListTile(
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
                if (!owned)
                  SwitchListTile(
                    title: const Text('Wishlisted'),
                    value: wishlisted,
                    onChanged: onWishlistChanged,
                  ),  
              ],
            ),
            const SizedBox(height: 16),
            ...details,
            Divider(height: 32, color: Colors.grey[400]),
            UserRatingSlider(
              initialRating: userRating,
              onChanged: onUserRatingChanged,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}