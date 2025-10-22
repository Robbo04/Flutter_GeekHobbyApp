import 'package:flutter/material.dart';
import 'package:app_geek_hobby_app/Classes/Widgets/swipable_itemcard.dart';

class SuggestionsPage extends StatefulWidget {
  const SuggestionsPage({super.key});

  @override
  State<SuggestionsPage> createState() => _SuggestionsPageState();
}

class _SuggestionsPageState extends State<SuggestionsPage> {
  // Replace with your real item type (Game/Item). Use unique id for ValueKey.
  final List<String> _items = ['TEST A', 'TEST B', 'TEST C', 'TEST D'];

  Offset _cardOffset = Offset.zero;

  void _removeTop(bool liked) {
    if (_items.isEmpty) return;
    final removed = _items.removeAt(0);
    setState(() {
      _cardOffset = Offset.zero;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(liked ? 'Liked $removed' : 'Skipped $removed')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final boxWidth = 180.0;
    final boxHeight = 250.0;

    return Scaffold(
      appBar: AppBar(title: const Text('Suggestions')),
      body: _items.isEmpty
          ? const Center(child: Text('No more suggestions'))
          : LayoutBuilder(builder: (context, constraints) {
              // make the "upper half" area ~60% of available height and center the card inside it
              final topAreaHeight = constraints.maxHeight * 0.60;
              final centerTop = (topAreaHeight - boxHeight) / 2; // vertical center within top area
              final centerLeft = (constraints.maxWidth - boxWidth) / 2; // horizontal center

              return Column(
                children: [
                  // TOP AREA (60%): card stack centered horizontally & vertically within this area
                  SizedBox(
                    height: topAreaHeight,
                    width: constraints.maxWidth,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // background color feedback for drag direction
                        Positioned.fill(
                          child: IgnorePointer(
                            child: Container(
                              color: _cardOffset.dx < 0
                                  ? Colors.green.withOpacity((_cardOffset.dx.abs() / 200).clamp(0.0, 1.0))
                                  : _cardOffset.dx > 0
                                      ? Colors.red.withOpacity((_cardOffset.dx.abs() / 200).clamp(0.0, 1.0))
                                      : Colors.transparent,
                            ),
                          ),
                        ),

                        // stacked background cards (up to 3) - centered
                        for (var i = _items.length - 1; i >= 0 && i >= _items.length - 3; i--)
                          Positioned(
                            top: centerTop + (_items.length - 1 - i) * 8,
                            left: centerLeft,
                            child: SizedBox(
                              width: boxWidth,
                              height: boxHeight,
                              child: Card(
                                elevation: i == 0 ? 10 : 4,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                child: Center(child: Text(_items[i])),
                              ),
                            ),
                          ),

                        // top interactive card - centered
                        if (_items.isNotEmpty)
                          Positioned(
                            top: centerTop,
                            left: centerLeft,
                            child: SwipeCard(
                              key: ValueKey(_items.first), // important: tie state to item
                              width: boxWidth,
                              height: boxHeight,
                              onDrag: (off) => setState(() => _cardOffset = off),
                              onSwipeRight: () => _removeTop(true),
                              onSwipeLeft: () => _removeTop(false),
                              child: Container(
                                color: Colors.grey[300],
                                child: Center(child: Text(_items.first, style: const TextStyle(fontSize: 18))),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // BOTTOM AREA (remaining space) - can hold metadata / controls
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(_items.first, style: Theme.of(context).textTheme.headlineSmall),
                          const SizedBox(height: 8),
                          Text('Available on: Steam', style: Theme.of(context).textTheme.bodySmall),
                          const SizedBox(height: 12),
                          const Text('Swipe left to skip, swipe right to keep.'),
                          // add additional controls/metadata here
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              );
            }),
    );
  }
}
