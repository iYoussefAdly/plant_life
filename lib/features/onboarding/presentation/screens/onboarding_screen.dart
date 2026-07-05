import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/localization/l10n.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/storage/app_preferences.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../widgets/language_selector.dart';
import '../widgets/onboarding_page.dart';
import '../widgets/page_dots.dart';

/// First-launch introduction: three pages presenting the app, with a language
/// choice on the last page. Marks itself completed in [AppPreferences] (read
/// directly, mirroring how the splash screen reads [TokenStorage]) so future
/// launches skip straight past it.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const _pageCount = 3;

  final _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  bool get _isLastPage => _currentPage == _pageCount - 1;

  Future<void> _finish() async {
    await sl<AppPreferences>().setOnboardingCompleted();
    if (!mounted) return;
    context.go(AppRoutes.login);
  }

  void _next() {
    if (_isLastPage) {
      _finish();
      return;
    }
    _pageController.nextPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primaryDark,
              AppColors.primary,
              AppColors.primaryLight,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: _isLastPage ? 0 : 1,
                  child: TextButton(
                    onPressed: _isLastPage ? null : _finish,
                    child: Text(
                      l10n.onbSkip,
                      style: AppTextStyles.labelLarge.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) =>
                      setState(() => _currentPage = index),
                  children: [
                    OnboardingPage(
                      icon: Icons.document_scanner_outlined,
                      title: l10n.onb1Title,
                      body: l10n.onb1Body,
                    ),
                    OnboardingPage(
                      icon: Icons.medical_services_outlined,
                      title: l10n.onb2Title,
                      body: l10n.onb2Body,
                    ),
                    OnboardingPage(
                      icon: Icons.sensors_outlined,
                      title: l10n.onb3Title,
                      body: l10n.onb3Body,
                      footer: const LanguageSelector(),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: Column(
                  children: [
                    PageDots(count: _pageCount, current: _currentPage),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton(
                        onPressed: _next,
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.primaryDark,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Text(
                            _isLastPage ? l10n.onbGetStarted : l10n.onbNext,
                            key: ValueKey(_isLastPage),
                            style: AppTextStyles.button.copyWith(
                              color: AppColors.primaryDark,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
