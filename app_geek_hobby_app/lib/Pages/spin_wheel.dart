import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:app_geek_hobby_app/Classes/game.dart';

class SpinWheelPage extends StatefulWidget {
  const SpinWheelPage({super.key});

  @override
  State<SpinWheelPage> createState() => _SpinWheelPageState();
}

class _WheelItem {
  final int id;
  final String name;
  final String? imageUrl;
  _WheelItem({required this.id, required this.name, this.imageUrl});
}

class _SpinWheelPageState extends State<SpinWheelPage> with SingleTickerProviderStateMixin {
  // Available collections (boxName -> friendly label)
  final Map<String, String> _collectionBoxes = {
    'games_owned_collection_id': 'Owned',
    'games_wishlist_collection_id': 'Wishlist',
    'games_backlog_collection_id': 'Backlog',
    'games_completed_collection_id': 'Completed',
  };

  String _selectedBox = 'games_owned_collection_id';
  List<_WheelItem> _items = [];
  bool _isLoading = true;

  // Spinning state
  late AnimationController _animCtrl;
  late Animation<double> _anim;
  double _rotation = 0.0; // current rotation in radians
  bool _isSpinning = false;

  // Winner
  _WheelItem? _winner;
  int? _winnerIndex;

  final Random _rand = Random();

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 3000));
    _anim = Tween<double>(begin: 0.0, end: 0.0).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.decelerate))
      ..addListener(() {
        setState(() {
          _rotation = _anim.value;
        });
      })
      ..addStatusListener((s) {
        if (s == AnimationStatus.completed) {
          _onSpinEnd();
        }
      });

    _loadCollection();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadCollection() async {
    setState(() {
      _isLoading = true;
      _winner = null;
      _winnerIndex = null;
    });

    try {
      // Open the selected collection id box (opens if necessary)
      final box = Hive.isBoxOpen(_selectedBox) ? Hive.box<int>(_selectedBox) : await Hive.openBox<int>(_selectedBox);
      final ids = box.keys.cast<int>().toList();

      // Try to open rawg_games to get cached Game info (if available)
      List<_WheelItem> items = [];
      if (ids.isNotEmpty) {
        if (Hive.isBoxOpen('rawg_games')) {
          final gamesBox = Hive.box<Game>('rawg_games');
          for (final id in ids) {
            if (gamesBox.containsKey(id)) {
              final g = gamesBox.get(id);
              items.add(_WheelItem(id: id, name: g?.name ?? 'Game $id', imageUrl: g?.imageUrl?.isNotEmpty == true ? g!.imageUrl : null));
            } else {
              items.add(_WheelItem(id: id, name: 'Game $id', imageUrl: null));
            }
          }
        } else {
          // rawg_games not open: just create placeholders
          for (final id in ids) {
            items.add(_WheelItem(id: id, name: 'Game $id', imageUrl: null));
          }
        }
      }

      setState(() {
        _items = items;
      });
    } catch (e) {
      debugPrint('Error loading collection $_selectedBox: $e');
      setState(() {
        _items = [];
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Gesture: user swipes the wheel area to start spinning.
  // We only respond if not currently spinning.
  void _onPanEnd(DragEndDetails details) {
    if (_isSpinning) return;
    if (_items.isEmpty) return;

    final velocity = details.velocity.pixelsPerSecond.distance;
    // Map finger velocity to spin magnitude:
    final baseSpin = (velocity / 1000.0) * (1.0 + _rand.nextDouble() * 0.6);

    // Always spin at least some amount; add several full rotations to make it feel good
    final fullRotations = 3 + _rand.nextInt(4); // 3..6 full rotations
    final spinDistance = baseSpin * 6.0 + fullRotations * 2 * pi;

    _startSpin(spinDistance);
  }

  // Start spin animation by animating rotation from current to current + delta
  void _startSpin(double deltaRadians) {
    if (_isSpinning) return;
    setState(() {
      _isSpinning = true;
      _winner = null;
      _winnerIndex = null;
    });

    final start = _rotation;
    final end = _rotation + deltaRadians;

    _anim = Tween<double>(begin: start, end: end).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.decelerate));
    _animCtrl.duration = Duration(milliseconds: (2000 + (deltaRadians / (2 * pi) * 400)).clamp(1200, 6000).toInt());
    _animCtrl.forward(from: 0.0);
  }

  // Called when the animation completes (spin finished)
  void _onSpinEnd() {
    final n = _items.isEmpty ? 1 : _items.length;
    final slice = 2 * pi / n;
    final pointerAngle = -pi / 2;

    // Find the segment whose center (mid-angle) is closest to the pointer angle after rotation.
    double bestDiff = double.infinity;
    int bestIndex = 0;

    for (int i = 0; i < n; i++) {
      // segment mid angle before rotation
      final mid = -pi / 2 + i * slice + slice / 2;
      // position after applying wheel rotation
      final pos = mid + _rotation;

      // compute minimal signed angular difference between pos and pointerAngle
      double diff = (pos - pointerAngle) % (2 * pi);
      if (diff > pi) diff -= 2 * pi; // normalize to (-pi, pi]

      final adiff = diff.abs();
      if (adiff < bestDiff) {
        bestDiff = adiff;
        bestIndex = i;
      }
    }

    setState(() {
      _isSpinning = false;
      _winnerIndex = _items.isEmpty ? null : bestIndex;
      _winner = (_items.isEmpty ? null : _items[bestIndex]);
    });
  }

  void _onTapDismissWinner() {
    setState(() {
      _winner = null;
      _winnerIndex = null;
    });
  }

  // Utility draw colors
  Color _colorForIndex(int i) {
    final base = Colors.primaries[i % Colors.primaries.length];
    return base.withOpacity(0.85);
  }

  @override
  Widget build(BuildContext context) {
    final wheelSize = min(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height) * 0.95;
    final pointerSize = wheelSize * 0.14;

    return Scaffold(
      appBar: AppBar(title: const Text('Spin the Wheel')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  // Collection dropdown (always present)
                  Row(
                    children: [
                      const SizedBox(width: 8),
                      const Text('Collection:'),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButton<String>(
                          value: _selectedBox,
                          isExpanded: true,
                          items: _collectionBoxes.entries
                              .map((e) => DropdownMenuItem<String>(value: e.key, child: Text(e.value)))
                              .toList(),
                          onChanged: (val) async {
                            if (val == null) return;
                            setState(() {
                              _selectedBox = val;
                            });
                            await _loadCollection();
                          },
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        tooltip: 'Reload',
                        onPressed: () => _loadCollection(),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Wheel area - detect swipes (pan end)
                  Expanded(
                    child: Center(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onPanEnd: _isSpinning ? null : _onPanEnd,
                        onPanCancel: () {},
                        onTap: () {},
                        child: SizedBox(
                          width: wheelSize,
                          height: wheelSize,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Rotating wheel (painter draws segments + names inside segments)
                              Transform.rotate(
                                angle: _rotation,
                                child: CustomPaint(
                                  size: Size(wheelSize, wheelSize),
                                  painter: _WheelPainter(
                                    itemsCount: _items.isEmpty ? 1 : _items.length,
                                    colorForIndex: _colorForIndex,
                                    labels: _items.isEmpty ? ['No items'] : _items.map((e) => e.name).toList(),
                                    textStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white) ??
                                        const TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),

                              // Pointer overlapping top center of wheel
                              Positioned(
                                top: -pointerSize * 0.45,
                                child: Container(
                                  width: pointerSize,
                                  height: pointerSize,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).cardColor,
                                    shape: BoxShape.circle,
                                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 6)],
                                  ),
                                  child: Icon(Icons.keyboard_arrow_down, size: pointerSize * 0.7, color: Colors.black87),
                                ),
                              ),

                              // Winner highlight overlay (if a winner is available)
                              if (_winnerIndex != null)
                                CustomPaint(
                                  size: Size(wheelSize, wheelSize),
                                  painter: _WinnerPainter(
                                    itemsCount: _items.length,
                                    winnerIndex: _winnerIndex!,
                                    color: Colors.white.withOpacity(0.28),
                                  ),
                                ),

                              // When spinning: block input but do NOT dim the wheel.
                              // When a winner is shown: block input and dim the wheel.
                              if (_isSpinning)
                                Positioned.fill(
                                  child: AbsorbPointer(
                                    absorbing: true,
                                    // transparent container so there's no grey overlay while spinning
                                    child: Container(color: Colors.transparent),
                                  ),
                                ),

                              if (_winner != null)
                                Positioned.fill(
                                  child: AbsorbPointer(
                                    absorbing: true,
                                    child: AnimatedOpacity(
                                      duration: const Duration(milliseconds: 200),
                                      opacity: 0.55,
                                      child: Container(color: Colors.black),
                                    ),
                                  ),
                                ),

                              // Winner modal card (centered) when finished
                              if (_winner != null)
                                Center(
                                  child: GestureDetector(
                                    onTap: _onTapDismissWinner,
                                    child: Card(
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      elevation: 16,
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            if (_winner!.imageUrl != null && _winner!.imageUrl!.isNotEmpty)
                                              ClipRRect(
                                                borderRadius: BorderRadius.circular(8),
                                                child: Image.network(_winner!.imageUrl!,
                                                    width: wheelSize * 0.42, height: wheelSize * 0.28, fit: BoxFit.cover),
                                              )
                                            else
                                              Container(
                                                width: wheelSize * 0.42,
                                                height: wheelSize * 0.28,
                                                color: Colors.grey[200],
                                                child: Center(child: Text('#${_winner!.id}', style: TextStyle(fontSize: wheelSize * 0.06))),
                                              ),
                                            const SizedBox(height: 12),
                                            Text(_winner!.name, style: TextStyle(fontSize: wheelSize * 0.045, fontWeight: FontWeight.bold)),
                                            const SizedBox(height: 8),
                                            ElevatedButton(
                                              onPressed: () {
                                                _onTapDismissWinner();
                                              },
                                              child: const Text('Close'),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),
                  // Helper row: spin state and reload collection
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_isSpinning) const Text('Spinning...', style: TextStyle(fontWeight: FontWeight.bold)),
                      if (!_isSpinning) Text('Ready', style: TextStyle(color: Colors.green[700])),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: _isSpinning ? null : () => _loadCollection(),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Reload collection'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
    );
  }
}

class _WheelPainter extends CustomPainter {
  final int itemsCount;
  final Color Function(int) colorForIndex;
  final List<String> labels;
  final TextStyle textStyle;

  _WheelPainter({
    required this.itemsCount,
    required this.colorForIndex,
    required this.labels,
    required this.textStyle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;

    final segmentAngle = 2 * pi / max(1, itemsCount);

    // Draw segments
    for (int i = 0; i < itemsCount; i++) {
      paint.color = colorForIndex(i);
      final start = -pi / 2 + i * segmentAngle;
      final path = Path()
        ..moveTo(center.dx, center.dy)
        ..arcTo(Rect.fromCircle(center: center, radius: radius), start, segmentAngle, false)
        ..close();
      canvas.drawPath(path, paint);
    }

    // Draw dividing lines
    final border = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.white
      ..strokeWidth = 2;

    for (int i = 0; i < itemsCount; i++) {
      final angle = -pi / 2 + i * segmentAngle;
      final dx = cos(angle) * radius + center.dx;
      final dy = sin(angle) * radius + center.dy;
      canvas.drawLine(center, Offset(dx, dy), border);
    }

    // Draw labels starting near the outside and extending outward (radial orientation).
    final tp = TextPainter(textDirection: TextDirection.ltr);

    for (int i = 0; i < itemsCount; i++) {
      final midAngle = -pi / 2 + i * segmentAngle + segmentAngle / 2;
      final rawLabel = labels.length > i ? labels[i] : 'Item ${i + 1}';
      final label = rawLabel.trim();

      // New radial placement: start much closer to outer rim
      // startRadius = where text begins (closer to outer edge)
      // endRadius = how far outward text can go (slightly past start, but kept within wheel visual)
      final double startRadius = radius * 0.60; // moved outward (was ~0.12)
      final double endRadius = radius * 0.92; // near the outer rim
      final double maxRadialLength = max(8.0, endRadius - startRadius);

      // Base font size relative to wheel radius (slightly increased to suit larger wheel)
      double fontSize = max(10.0, radius * 0.085);

      // Layout and scale to fit radial length
      tp.text = TextSpan(text: label, style: textStyle.copyWith(fontSize: fontSize));
      tp.layout();

      const double minFont = 8.0;
      if (tp.width > maxRadialLength) {
        while (tp.width > maxRadialLength && fontSize > minFont) {
          fontSize *= 0.90;
          tp.text = TextSpan(text: label, style: textStyle.copyWith(fontSize: fontSize));
          tp.layout();
        }
      }

      // If still too wide, truncate and relayout
      String drawText = label;
      if (tp.width > maxRadialLength) {
        final approxChars = max(3, (label.length * (maxRadialLength / tp.width)).floor());
        final safe = min(label.length, approxChars);
        drawText = label.substring(0, safe) + '…';
        tp.text = TextSpan(text: drawText, style: textStyle.copyWith(fontSize: fontSize));
        tp.layout();
      }

      // Compute anchor point near outer radial location
      final anchorX = center.dx + cos(midAngle) * startRadius;
      final anchorY = center.dy + sin(midAngle) * startRadius;

      // Determine rotation so x-axis points outward along the radius
      double rotation = midAngle;

      // If rotation would cause the glyphs to be upside-down (left half), flip by pi and draw anchored on right edge
      final bool flip = (rotation > pi / 2 && rotation < 3 * pi / 2);

      canvas.save();
      canvas.translate(anchorX, anchorY);

      if (flip) {
        canvas.rotate(rotation + pi);
        tp.paint(canvas, Offset(-tp.width, -tp.height / 2));
      } else {
        canvas.rotate(rotation);
        tp.paint(canvas, Offset(0, -tp.height / 2));
      }

      canvas.restore();
    }

    // Outer circle edge
    final edge = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.black.withOpacity(0.2)
      ..strokeWidth = 3;
    canvas.drawCircle(center, radius, edge);
  }

  @override
  bool shouldRepaint(covariant _WheelPainter oldDelegate) {
    return oldDelegate.itemsCount != itemsCount || oldDelegate.labels != labels;
  }
}

class _WinnerPainter extends CustomPainter {
  final int itemsCount;
  final int winnerIndex;
  final Color color;

  _WinnerPainter({required this.itemsCount, required this.winnerIndex, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (itemsCount <= 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;
    final segmentAngle = 2 * pi / max(1, itemsCount);

    final start = -pi / 2 + winnerIndex * segmentAngle;
    final path = Path()
      ..moveTo(center.dx, center.dy)
      ..arcTo(Rect.fromCircle(center: center, radius: radius), start, segmentAngle, false)
      ..close();

    final fill = Paint()
      ..style = PaintingStyle.fill
      ..color = color;
    canvas.drawPath(path, fill);

    final outline = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.white.withOpacity(0.95)
      ..strokeWidth = max(2.0, radius * 0.04);
    canvas.drawPath(path, outline);
  }

  @override
  bool shouldRepaint(covariant _WinnerPainter old) {
    return old.winnerIndex != winnerIndex || old.itemsCount != itemsCount || old.color != color;
  }
}