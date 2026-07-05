import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/fade_slide_in.dart';

/// One onboarding page: an icon in the splash-style translucent circle, a
/// title, a short body, and an optional footer (used for the language choice
/// on the last page).
class OnboardingPage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final Widget? footer;

  const OnboardingPage({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FadeSlideIn(
            child: Container(
              width: 132,
              height: 132,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 64, color: Colors.white),
            ),
          ),
          const SizedBox(height: 36),
          FadeSlideIn(
            index: 1,
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.headlineLarge.copyWith(
                color: Colors.white,
                fontSize: 26,
              ),
            ),
          ),
          const SizedBox(height: 14),
          FadeSlideIn(
            index: 2,
            child: Text(
              body,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyLarge.copyWith(
                color: Colors.white.withValues(alpha: 0.88),
                height: 1.5,
              ),
            ),
          ),
          if (footer != null) ...[
            const SizedBox(height: 32),
            FadeSlideIn(index: 3, child: footer!),
          ],
        ],
      ),
    );
  }
}
