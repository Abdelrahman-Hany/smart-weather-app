import 'package:flutter/material.dart';

/// Breakpoints for layout adaptation.
abstract final class AppBreakpoints {
  static const double tablet = 600;
  static const double desktop = 900;
}

/// Current breakpoint based on [width].
enum Breakpoint { mobile, tablet, desktop }

Breakpoint _breakpointFor(double width) {
  if (width >= AppBreakpoints.desktop) return Breakpoint.desktop;
  if (width >= AppBreakpoints.tablet) return Breakpoint.tablet;
  return Breakpoint.mobile;
}

/// Convenience extensions on [BuildContext].
extension ResponsiveContext on BuildContext {
  double get _width => MediaQuery.sizeOf(this).width;
  Breakpoint get breakpoint => _breakpointFor(_width);
  bool get isDesktop => _width >= AppBreakpoints.desktop;
  bool get isTablet =>
      _width >= AppBreakpoints.tablet && _width < AppBreakpoints.desktop;
  bool get isMobile => _width < AppBreakpoints.tablet;
  bool get isTabletOrLarger => _width >= AppBreakpoints.tablet;
}

/// A widget that selects a builder based on the current breakpoint.
class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  final WidgetBuilder mobile;
  final WidgetBuilder? tablet;
  final WidgetBuilder? desktop;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bp = _breakpointFor(constraints.maxWidth);
        switch (bp) {
          case Breakpoint.desktop:
            return (desktop ?? tablet ?? mobile)(context);
          case Breakpoint.tablet:
            return (tablet ?? mobile)(context);
          case Breakpoint.mobile:
            return mobile(context);
        }
      },
    );
  }
}

/// Wraps [child] with a centred, max-width constrained box.
/// Ideal for secondary screens (login, profile, search, etc.).
class MaxWidthBox extends StatelessWidget {
  const MaxWidthBox({
    super.key,
    required this.child,
    this.maxWidth = 640,
    this.alignment = Alignment.topCenter,
    this.padding = EdgeInsets.zero,
  });

  final Widget child;
  final double maxWidth;
  final Alignment alignment;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
