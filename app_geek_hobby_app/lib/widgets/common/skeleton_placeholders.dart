import 'package:flutter/material.dart';

class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 12,
  });

  final double width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.55, end: 0.95),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Opacity(opacity: value, child: child);
      },
      onEnd: () {},
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class CarouselSkeleton extends StatelessWidget {
  const CarouselSkeleton({
    super.key,
    this.itemCount = 3,
    this.itemWidth = 112,
    this.imageHeight = 170,
    this.titleWidth = 140,
  });

  final int itemCount;
  final double itemWidth;
  final double imageHeight;
  final double titleWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 225,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBox(width: titleWidth, height: 18, borderRadius: 8),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemBuilder: (_, __) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBox(width: itemWidth, height: imageHeight),
                  const SizedBox(height: 8),
                  SkeletonBox(width: itemWidth * 0.8, height: 12, borderRadius: 6),
                ],
              ),
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemCount: itemCount,
            ),
          ),
        ],
      ),
    );
  }
}

class SuggestionCardSkeleton extends StatelessWidget {
  const SuggestionCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final baseWidth = MediaQuery.of(context).size.width * 0.55;
        final maxWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth * 0.8
            : 320.0;
        var cardWidth = baseWidth.clamp(160.0, maxWidth.clamp(160.0, 320.0));

        const fixedHeight = 16.0 + 18.0 + 10.0 + 14.0 + 20.0 + 58.0;
        const verticalPadding = 40.0;
        final availableHeight = constraints.maxHeight.isFinite
            ? (constraints.maxHeight - fixedHeight - verticalPadding).clamp(140.0, 460.0)
            : 360.0;

        var cardHeight = (cardWidth * 1.45).clamp(140.0, availableHeight);
        cardWidth = (cardHeight / 1.45).clamp(160.0, maxWidth.clamp(160.0, 320.0));

        return Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SkeletonBox(width: cardWidth, height: cardHeight, borderRadius: 14),
                const SizedBox(height: 16),
                SkeletonBox(width: cardWidth * 0.7, height: 18, borderRadius: 8),
                const SizedBox(height: 10),
                SkeletonBox(width: cardWidth * 0.5, height: 14, borderRadius: 8),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    SkeletonBox(width: 50, height: 50, borderRadius: 25),
                    SizedBox(width: 20),
                    SkeletonBox(width: 58, height: 58, borderRadius: 29),
                    SizedBox(width: 20),
                    SkeletonBox(width: 50, height: 50, borderRadius: 25),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
