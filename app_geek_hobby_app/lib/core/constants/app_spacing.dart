import 'package:flutter/material.dart';

/// Standardized spacing constants with responsive scaling for different screen sizes
/// 
/// Usage examples:
/// - Fixed spacing: `AppSpacing.md` or `AppSpacing.verticalMd`
/// - Responsive spacing: `AppSpacing.mdResponsive(context)` or `AppSpacing.verticalMdResponsive(context)`
/// - Padding: `AppSpacing.paddingAll16` (fixed) or `AppSpacing.paddingAll16Responsive(context)`
/// 
/// Responsive scaling:
/// - Base: 375px width (standard mobile)
/// - Scales linearly up to 1.5x on tablets/desktop
/// - Use responsive methods when layout should adapt to screen size
/// - Use fixed values for const constructors or consistent spacing
class AppSpacing {
  AppSpacing._(); // Private constructor to prevent instantiation

  // Base screen width for responsive calculations (iPhone standard)
  static const double _baseWidth = 375.0;
  static const double _minScale = 1.0;
  static const double _maxScale = 1.5;

  /// Get responsive scaling factor based on screen width
  /// - Returns 1.0 for screens <= 375px
  /// - Scales up to 1.5x for larger screens (tablets/desktop)
  static double _getScaleFactor(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return (width / _baseWidth).clamp(_minScale, _maxScale);
  }

  // ════════════════════════════════════════════════════════════════════════
  // FIXED BASE VALUES (for const constructors and consistent spacing)
  // ════════════════════════════════════════════════════════════════════════
  
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;

  // ════════════════════════════════════════════════════════════════════════
  // RESPONSIVE VALUES (scale with screen size)
  // ════════════════════════════════════════════════════════════════════════
  
  static double xsResponsive(BuildContext context) => xs * _getScaleFactor(context);
  static double smResponsive(BuildContext context) => sm * _getScaleFactor(context);
  static double mdResponsive(BuildContext context) => md * _getScaleFactor(context);
  static double lgResponsive(BuildContext context) => lg * _getScaleFactor(context);
  static double xlResponsive(BuildContext context) => xl * _getScaleFactor(context);
  static double xxlResponsive(BuildContext context) => xxl * _getScaleFactor(context);

  // ════════════════════════════════════════════════════════════════════════
  // FIXED VERTICAL SPACING WIDGETS
  // ════════════════════════════════════════════════════════════════════════
  
  static const Widget verticalXs = SizedBox(height: xs);
  static const Widget verticalSm = SizedBox(height: sm);
  static const Widget verticalMd = SizedBox(height: md);
  static const Widget verticalLg = SizedBox(height: lg);
  static const Widget verticalXl = SizedBox(height: xl);
  static const Widget verticalXxl = SizedBox(height: xxl);

  // ════════════════════════════════════════════════════════════════════════
  // RESPONSIVE VERTICAL SPACING WIDGETS
  // ════════════════════════════════════════════════════════════════════════
  
  static Widget verticalXsResponsive(BuildContext context) => 
    SizedBox(height: xsResponsive(context));
  static Widget verticalSmResponsive(BuildContext context) => 
    SizedBox(height: smResponsive(context));
  static Widget verticalMdResponsive(BuildContext context) => 
    SizedBox(height: mdResponsive(context));
  static Widget verticalLgResponsive(BuildContext context) => 
    SizedBox(height: lgResponsive(context));
  static Widget verticalXlResponsive(BuildContext context) => 
    SizedBox(height: xlResponsive(context));
  static Widget verticalXxlResponsive(BuildContext context) => 
    SizedBox(height: xxlResponsive(context));

  // ════════════════════════════════════════════════════════════════════════
  // FIXED HORIZONTAL SPACING WIDGETS
  // ════════════════════════════════════════════════════════════════════════

  static const Widget horizontalXs = SizedBox(width: xs);
  static const Widget horizontalSm = SizedBox(width: sm);
  static const Widget horizontalMd = SizedBox(width: md);
  static const Widget horizontalLg = SizedBox(width: lg);
  static const Widget horizontalXl = SizedBox(width: xl);
  static const Widget horizontalXxl = SizedBox(width: xxl);

  // ════════════════════════════════════════════════════════════════════════
  // RESPONSIVE HORIZONTAL SPACING WIDGETS
  // ════════════════════════════════════════════════════════════════════════
  
  static Widget horizontalXsResponsive(BuildContext context) => 
    SizedBox(width: xsResponsive(context));
  static Widget horizontalSmResponsive(BuildContext context) => 
    SizedBox(width: smResponsive(context));
  static Widget horizontalMdResponsive(BuildContext context) => 
    SizedBox(width: mdResponsive(context));
  static Widget horizontalLgResponsive(BuildContext context) => 
    SizedBox(width: lgResponsive(context));
  static Widget horizontalXlResponsive(BuildContext context) => 
    SizedBox(width: xlResponsive(context));
  static Widget horizontalXxlResponsive(BuildContext context) => 
    SizedBox(width: xxlResponsive(context));

  // ════════════════════════════════════════════════════════════════════════
  // FIXED EDGEINSETS PADDING - All sides
  // ════════════════════════════════════════════════════════════════════════
  
  static const EdgeInsets paddingAll4 = EdgeInsets.all(xs);
  static const EdgeInsets paddingAll8 = EdgeInsets.all(sm);
  static const EdgeInsets paddingAll12 = EdgeInsets.all(md);
  static const EdgeInsets paddingAll16 = EdgeInsets.all(lg);
  static const EdgeInsets paddingAll24 = EdgeInsets.all(xl);
  static const EdgeInsets paddingAll32 = EdgeInsets.all(xxl);

  // ════════════════════════════════════════════════════════════════════════
  // RESPONSIVE EDGEINSETS PADDING - All sides
  // ════════════════════════════════════════════════════════════════════════
  
  static EdgeInsets paddingAll4Responsive(BuildContext context) => 
    EdgeInsets.all(xsResponsive(context));
  static EdgeInsets paddingAll8Responsive(BuildContext context) => 
    EdgeInsets.all(smResponsive(context));
  static EdgeInsets paddingAll12Responsive(BuildContext context) => 
    EdgeInsets.all(mdResponsive(context));
  static EdgeInsets paddingAll16Responsive(BuildContext context) => 
    EdgeInsets.all(lgResponsive(context));
  static EdgeInsets paddingAll24Responsive(BuildContext context) => 
    EdgeInsets.all(xlResponsive(context));
  static EdgeInsets paddingAll32Responsive(BuildContext context) => 
    EdgeInsets.all(xxlResponsive(context));

  // ════════════════════════════════════════════════════════════════════════
  // FIXED EDGEINSETS PADDING - Horizontal
  // ════════════════════════════════════════════════════════════════════════
  
  static const EdgeInsets paddingH4 = EdgeInsets.symmetric(horizontal: xs);
  static const EdgeInsets paddingH8 = EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets paddingH12 = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets paddingH16 = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets paddingH24 = EdgeInsets.symmetric(horizontal: xl);
  static const EdgeInsets paddingH32 = EdgeInsets.symmetric(horizontal: xxl);

  // ════════════════════════════════════════════════════════════════════════
  // RESPONSIVE EDGEINSETS PADDING - Horizontal
  // ════════════════════════════════════════════════════════════════════════
  
  static EdgeInsets paddingH4Responsive(BuildContext context) => 
    EdgeInsets.symmetric(horizontal: xsResponsive(context));
  static EdgeInsets paddingH8Responsive(BuildContext context) => 
    EdgeInsets.symmetric(horizontal: smResponsive(context));
  static EdgeInsets paddingH12Responsive(BuildContext context) => 
    EdgeInsets.symmetric(horizontal: mdResponsive(context));
  static EdgeInsets paddingH16Responsive(BuildContext context) => 
    EdgeInsets.symmetric(horizontal: lgResponsive(context));
  static EdgeInsets paddingH24Responsive(BuildContext context) => 
    EdgeInsets.symmetric(horizontal: xlResponsive(context));
  static EdgeInsets paddingH32Responsive(BuildContext context) => 
    EdgeInsets.symmetric(horizontal: xxlResponsive(context));

  // ════════════════════════════════════════════════════════════════════════
  // FIXED EDGEINSETS PADDING - Vertical
  // ════════════════════════════════════════════════════════════════════════
  
  static const EdgeInsets paddingV4 = EdgeInsets.symmetric(vertical: xs);
  static const EdgeInsets paddingV8 = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets paddingV12 = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets paddingV16 = EdgeInsets.symmetric(vertical: lg);
  static const EdgeInsets paddingV24 = EdgeInsets.symmetric(vertical: xl);
  static const EdgeInsets paddingV32 = EdgeInsets.symmetric(vertical: xxl);

  // ════════════════════════════════════════════════════════════════════════
  // RESPONSIVE EDGEINSETS PADDING - Vertical
  // ════════════════════════════════════════════════════════════════════════
  
  static EdgeInsets paddingV4Responsive(BuildContext context) => 
    EdgeInsets.symmetric(vertical: xsResponsive(context));
  static EdgeInsets paddingV8Responsive(BuildContext context) => 
    EdgeInsets.symmetric(vertical: smResponsive(context));
  static EdgeInsets paddingV12Responsive(BuildContext context) => 
    EdgeInsets.symmetric(vertical: mdResponsive(context));
  static EdgeInsets paddingV16Responsive(BuildContext context) => 
    EdgeInsets.symmetric(vertical: lgResponsive(context));
  static EdgeInsets paddingV24Responsive(BuildContext context) => 
    EdgeInsets.symmetric(vertical: xlResponsive(context));
  static EdgeInsets paddingV32Responsive(BuildContext context) => 
    EdgeInsets.symmetric(vertical: xxlResponsive(context));

  // ════════════════════════════════════════════════════════════════════════
  // FIXED COMBINED PADDING (horizontal + vertical)
  // ════════════════════════════════════════════════════════════════════════
  
  static const EdgeInsets paddingH16V8 = EdgeInsets.symmetric(horizontal: lg, vertical: sm);
  static const EdgeInsets paddingH16V12 = EdgeInsets.symmetric(horizontal: lg, vertical: md);

  // ════════════════════════════════════════════════════════════════════════
  // RESPONSIVE COMBINED PADDING (horizontal + vertical)
  // ════════════════════════════════════════════════════════════════════════
  
  static EdgeInsets paddingH16V8Responsive(BuildContext context) => 
    EdgeInsets.symmetric(
      horizontal: lgResponsive(context), 
      vertical: smResponsive(context),
    );
  static EdgeInsets paddingH16V12Responsive(BuildContext context) => 
    EdgeInsets.symmetric(
      horizontal: lgResponsive(context), 
      vertical: mdResponsive(context),
    );

  // ════════════════════════════════════════════════════════════════════════
  // CUSTOM SPACING HELPERS (for non-standard values)
  // ════════════════════════════════════════════════════════════════════════
  
  static Widget vertical(double height) => SizedBox(height: height);
  static Widget horizontal(double width) => SizedBox(width: width);
  static EdgeInsets padding(double value) => EdgeInsets.all(value);
  static EdgeInsets paddingSymmetric({double? horizontal, double? vertical}) {
    return EdgeInsets.symmetric(
      horizontal: horizontal ?? 0,
      vertical: vertical ?? 0,
    );
  }

  // Responsive custom helpers
  static Widget verticalResponsive(BuildContext context, double height) => 
    SizedBox(height: height * _getScaleFactor(context));
  static Widget horizontalResponsive(BuildContext context, double width) => 
    SizedBox(width: width * _getScaleFactor(context));
  static EdgeInsets paddingResponsive(BuildContext context, double value) => 
    EdgeInsets.all(value * _getScaleFactor(context));
  static EdgeInsets paddingSymmetricResponsive(
    BuildContext context, {
    double? horizontal,
    double? vertical,
  }) {
    final factor = _getScaleFactor(context);
    return EdgeInsets.symmetric(
      horizontal: (horizontal ?? 0) * factor,
      vertical: (vertical ?? 0) * factor,
    );
  }

  // ════════════════════════════════════════════════════════════════════════
  // COMMON SPACING PATTERNS
  // ════════════════════════════════════════════════════════════════════════
  
  // Fixed patterns
  static const Widget listItemSpacing = verticalSm; // Between list items
  static const Widget sectionSpacing = verticalLg; // Between sections
  static const Widget cardSpacing = verticalMd; // Between cards
  static const EdgeInsets screenPadding = paddingAll16; // Standard screen padding
  static const EdgeInsets cardPadding = paddingAll12; // Standard card padding
  static const EdgeInsets buttonPadding = paddingH16V8; // Standard button padding

  // Responsive patterns
  static Widget listItemSpacingResponsive(BuildContext context) => 
    verticalSmResponsive(context);
  static Widget sectionSpacingResponsive(BuildContext context) => 
    verticalLgResponsive(context);
  static Widget cardSpacingResponsive(BuildContext context) => 
    verticalMdResponsive(context);
  static EdgeInsets screenPaddingResponsive(BuildContext context) => 
    paddingAll16Responsive(context);
  static EdgeInsets cardPaddingResponsive(BuildContext context) => 
    paddingAll12Responsive(context);
  static EdgeInsets buttonPaddingResponsive(BuildContext context) => 
    paddingH16V8Responsive(context);
}
