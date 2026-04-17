import 'package:flutter/material.dart';

/// Reusable loading widget with consistent styling across the app
class LoadingWidget extends StatelessWidget {
  /// Optional message to display below the spinner
  final String? message;
  
  /// Size of the loading indicator (defaults to standard size)
  final double? size;
  
  /// Stroke width of the circular progress indicator
  final double strokeWidth;
  
  /// Color of the loading indicator (defaults to theme primary color)
  final Color? color;
  
  /// Whether to center the widget (defaults to true)
  final bool centered;
  
  /// Optional fixed height constraint when centered
  final double? height;

  const LoadingWidget({
    super.key,
    this.message,
    this.size,
    this.strokeWidth = 4.0,
    this.color,
    this.centered = true,
    this.height,
  });

  /// Centered loading indicator (most common use case)
  const LoadingWidget.centered({
    super.key,
    this.message,
    this.size,
    this.strokeWidth = 4.0,
    this.color,
  })  : centered = true,
        height = null;

  /// Compact loading indicator with thinner stroke
  const LoadingWidget.compact({
    super.key,
    this.message,
    this.color,
  })  : size = null,
        strokeWidth = 2.0,
        centered = true,
        height = null;

  /// Inline loading indicator (no centering)
  const LoadingWidget.inline({
    super.key,
    this.size,
    this.strokeWidth = 4.0,
    this.color,
  })  : message = null,
        centered = false,
        height = null;

  /// Loading with fixed height container (useful for carousels/lists)
  const LoadingWidget.withHeight({
    super.key,
    required this.height,
    this.message,
    this.strokeWidth = 4.0,
    this.color,
  })  : size = null,
        centered = true;

  @override
  Widget build(BuildContext context) {
    final indicator = CircularProgressIndicator(
      strokeWidth: strokeWidth,
      color: color,
    );

    // Wrap indicator with size constraint if specified
    final Widget sizedIndicator = size != null
        ? SizedBox(
            width: size,
            height: size,
            child: indicator,
          )
        : indicator;

    final Widget loadingContent;
    
    if (message != null) {
      // Loading indicator with message
      loadingContent = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          sizedIndicator,
          const SizedBox(height: 12),
          Text(
            message!,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    } else {
      // Just the indicator
      loadingContent = sizedIndicator;
    }

    if (!centered) {
      return loadingContent;
    }

    if (height != null) {
      return SizedBox(
        height: height,
        child: Center(child: loadingContent),
      );
    }

    return Center(child: loadingContent);
  }
}
