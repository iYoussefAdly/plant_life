import 'package:flutter/material.dart';

/// Animated page indicator: the active dot stretches into a pill.
class PageDots extends StatelessWidget {
  final int count;
  final int current;

  const PageDots({super.key, required this.count, required this.current});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isActive = index == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 26 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: isActive ? 1 : 0.45),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
