import 'package:flutter/material.dart';

class SwipeCard extends StatefulWidget {
  final Widget child;
  final double width;
  final double height;
  final VoidCallback? onSwipeRight;
  final VoidCallback? onSwipeLeft;
  final ValueChanged<Offset>? onDrag; // <-- added

  const SwipeCard({
    super.key,
    required this.child,
    this.width = 260,
    this.height = 380,
    this.onSwipeRight,
    this.onSwipeLeft,
    this.onDrag,
  });

  @override
  State<SwipeCard> createState() => _SwipeCardState();
}

class _SwipeCardState extends State<SwipeCard> with SingleTickerProviderStateMixin {
  Offset _offset = Offset.zero;
  late AnimationController _ctrl;
  late Animation<Offset> _anim;
  double get _rotation => (_offset.dx / (MediaQuery.of(context).size.width)) * 0.5; // radians

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _anim = Tween<Offset>(begin: Offset.zero, end: Offset.zero).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut))
      ..addListener(() {
        setState(() {
          _offset = _anim.value;
          // notify parent about current drag offset while animating
          widget.onDrag?.call(_offset);
        });
      })
      ..addStatusListener((s) {
        if (s == AnimationStatus.completed) {
          final screenW = MediaQuery.of(context).size.width;
          if (_offset.dx.abs() > screenW * 0.6) {
            if (_offset.dx > 0) widget.onSwipeRight?.call();
            else widget.onSwipeLeft?.call();
            // ensure parent knows drag ended
            widget.onDrag?.call(Offset.zero);
          } else {
            // animation returned to zero
            widget.onDrag?.call(Offset.zero);
          }
        }
      });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _resetPosition() {
    _anim = Tween<Offset>(begin: _offset, end: Offset.zero).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward(from: 0);
  }

  void _flyAway(Offset velocity) {
    final screenW = MediaQuery.of(context).size.width;
    final sign = _offset.dx + velocity.dx > 0 ? 1 : -1;
    final target = Offset(sign * screenW * 1.5, _offset.dy + velocity.dy.abs());
    _anim = Tween<Offset>(begin: _offset, end: target).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: _offset,
      child: Transform.rotate(
        angle: _rotation,
        child: SizedBox(
          width: widget.width,
          height: widget.height,
          child: GestureDetector(
            onPanUpdate: (details) {
              setState(() {
                _offset += details.delta;
              });
              widget.onDrag?.call(_offset); // notify parent while dragging
            },
            onPanEnd: (details) {
              final vx = details.velocity.pixelsPerSecond.dx;
              final screenW = MediaQuery.of(context).size.width;
              final shouldSwipe = _offset.dx.abs() > screenW * 0.25 || vx.abs() > 800;

              if (shouldSwipe) {
                _flyAway(details.velocity.pixelsPerSecond);
              } else {
                _resetPosition();
              }
            },
            onPanCancel: () {
              _resetPosition();
            },
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              clipBehavior: Clip.antiAlias,
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}