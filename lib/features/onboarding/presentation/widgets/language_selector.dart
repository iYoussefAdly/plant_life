import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/l10n.dart';
import '../../../../core/localization/locale_cubit.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// English / Arabic choice shown on the last onboarding page. Selecting a
/// language applies it immediately (live preview — the whole app flips,
/// including RTL) and persists it via [LocaleCubit].
class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    // Fall back to the ambient locale so the correct chip is highlighted even
    // before the user makes an explicit choice.
    final current = context.watch<LocaleCubit>().state ??
        Localizations.localeOf(context);
    return Column(
      children: [
        Text(
          l10n.onbChooseLanguage,
          style: AppTextStyles.labelLarge.copyWith(
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _LanguageChip(
              label: l10n.languageEnglish,
              selected: current.languageCode == 'en',
              onTap: () =>
                  context.read<LocaleCubit>().setLocale(const Locale('en')),
            ),
            const SizedBox(width: 12),
            _LanguageChip(
              label: l10n.languageArabic,
              selected: current.languageCode == 'ar',
              onTap: () =>
                  context.read<LocaleCubit>().setLocale(const Locale('ar')),
            ),
          ],
        ),
      ],
    );
  }
}

class _LanguageChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? Colors.white
              : Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.white.withValues(alpha: selected ? 1 : 0.4),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected) ...[
              const Icon(Icons.check_rounded,
                  size: 18, color: AppColors.primaryDark),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: AppTextStyles.labelLarge.copyWith(
                color: selected ? AppColors.primaryDark : Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
