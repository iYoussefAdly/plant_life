import 'package:flutter/material.dart';

/// Lightweight entrance animation: fades in while sliding up slightly.
///
/// Pass an [index] to stagger items in a list — each index delays the start a
/// little, giving a cascading effect without any controllers or packages.
class FadeSlideIn extends StatelessWidget {
  final Widget child;
  final int index;

  const FadeSlideIn({super.key, required this.child, this.index = 0});

  @override
  Widget build(BuildContext context) {
    final delayMs = 70 * index;
    final totalMs = 380 + delayMs;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: totalMs),
      curve: Interval(delayMs / totalMs, 1, curve: Curves.easeOutCubic),
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(
          offset: Offset(0, 16 * (1 - t)),
          child: child,
        ),
      ),
      child: child,
    );
  }
}
