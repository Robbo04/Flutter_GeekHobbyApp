import 'package:flutter/material.dart';

class AppTitleText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign textAlign;
  final int? maxLines;
  final bool selectable;
  final bool showTooltip;
  final TextOverflow overflow;

  const AppTitleText(
    this.text, {
    super.key,
    this.style,
    this.textAlign = TextAlign.start,
    this.maxLines,
    this.selectable = false,
    this.showTooltip = true,
    this.overflow = TextOverflow.ellipsis,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveStyle = style ?? Theme.of(context).textTheme.titleMedium;

    final Widget textWidget = selectable
        ? SelectableText(
            text,
            textAlign: textAlign,
            maxLines: maxLines,
            style: effectiveStyle,
          )
        : Text(
            text,
            textAlign: textAlign,
            maxLines: maxLines,
            overflow: overflow,
            softWrap: true,
            style: effectiveStyle,
          );

    if (!showTooltip) {
      return textWidget;
    }

    return Tooltip(
      message: text,
      child: textWidget,
    );
  }
}
