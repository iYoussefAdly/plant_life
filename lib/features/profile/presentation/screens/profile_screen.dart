import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/networking/socket_service.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/fade_slide_in.dart';
import '../../../../core/localization/l10n.dart';
import '../../../../core/localization/locale_cubit.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../notifications/presentation/bloc/notifications_cubit.dart';
import '../../../store/domain/usecases/clear_store_session_usecase.dart';
import '../../../store/presentation/bloc/cart_cubit.dart';
import '../../../store/presentation/bloc/products_cubit.dart';
import '../bloc/profile_cubit.dart';
import '../bloc/profile_state.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.profile, style: AppTextStyles.headlineMedium),
      ),
      body: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state is ProfileLoggedOut) {
            sl<SocketService>().disconnect();
            // Clear the previous user's notifications so the next session
            // starts with a clean badge/list.
            sl<NotificationsCubit>().reset();
            // Drop the store session + cart + catalogue so the next user
            // starts clean.
            sl<ClearStoreSessionUseCase>()();
            sl<CartCubit>().reset();
            sl<ProductsCubit>().reset();
            context.go(AppRoutes.login);
          }
        },
        builder: (context, state) => switch (state) {
          ProfileInitial() ||
          ProfileLoggedOut() =>
            const SizedBox.shrink(),
          ProfileLoading() =>
            const Center(child: CircularProgressIndicator()),
          ProfileLoaded(:final user) => _ProfileContent(user: user),
          ProfileError(:final message) => ErrorView(
              message: message,
              onRetry: () => context.read<ProfileCubit>().loadProfile(),
            ),
        },
      ),
    );
  }
}

class _ProfileContent extends StatelessWidget {
  final UserEntity user;

  const _ProfileContent({required this.user});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        FadeSlideIn(child: _ProfileHeader(user: user)),
        const SizedBox(height: 20),
        FadeSlideIn(
          index: 1,
          child: _InfoTile(
            icon: Icons.person_outline,
            label: context.l10n.name,
            value: user.name,
          ),
        ),
        const SizedBox(height: 10),
        FadeSlideIn(
          index: 2,
          child: _InfoTile(
            icon: Icons.email_outlined,
            label: context.l10n.email,
            value: user.email,
          ),
        ),
        const SizedBox(height: 24),
        FadeSlideIn(
          index: 3,
          child: _NavTile(
            icon: Icons.storefront_outlined,
            label: context.l10n.plantStore,
            // Store is a bottom-nav tab, so switch to it rather than pushing a
            // duplicate over the shell.
            onTap: () => context.go(AppRoutes.store),
          ),
        ),
        const SizedBox(height: 10),
        FadeSlideIn(
          index: 4,
          child: _NavTile(
            icon: Icons.receipt_long_outlined,
            label: context.l10n.myOrders,
            onTap: () => context.push(AppRoutes.orders),
          ),
        ),
        const SizedBox(height: 10),
        FadeSlideIn(
          index: 5,
          child: _NavTile(
            icon: Icons.language_outlined,
            label: context.l10n.language,
            trailing: Text(
              _currentLanguageName(context),
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            onTap: () => _pickLanguage(context),
          ),
        ),
        const SizedBox(height: 24),
        FadeSlideIn(index: 6, child: _LogoutTile(onTap: () => _confirmLogout(context))),
        const SizedBox(height: 16),
      ],
    );
  }

  /// Native-form name of the active language, shown on the Language tile.
  String _currentLanguageName(BuildContext context) {
    final locale = context.watch<LocaleCubit>().state ??
        Localizations.localeOf(context);
    return locale.languageCode == 'ar'
        ? context.l10n.languageArabic
        : context.l10n.languageEnglish;
  }

  Future<void> _pickLanguage(BuildContext context) async {
    final cubit = context.read<LocaleCubit>();
    final current = cubit.state ?? Localizations.localeOf(context);
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Text(sheetContext.l10n.language,
                style: AppTextStyles.headlineSmall),
            const SizedBox(height: 8),
            _LanguageOption(
              label: sheetContext.l10n.languageEnglish,
              selected: current.languageCode == 'en',
              onTap: () {
                cubit.setLocale(const Locale('en'));
                Navigator.of(sheetContext).pop();
              },
            ),
            _LanguageOption(
              label: sheetContext.l10n.languageArabic,
              selected: current.languageCode == 'ar',
              onTap: () {
                cubit.setLocale(const Locale('ar'));
                Navigator.of(sheetContext).pop();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(dialogContext.l10n.logOut),
        content: Text(dialogContext.l10n.logOutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(dialogContext.l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(dialogContext.l10n.logOut),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<ProfileCubit>().logout();
    }
  }
}

class _ProfileHeader extends StatelessWidget {
  final UserEntity user;

  const _ProfileHeader({required this.user});

  @override
  Widget build(BuildContext context) {
    final hasAvatar = user.avatarUrl?.isNotEmpty == true;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryDark, AppColors.primary],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            backgroundImage: hasAvatar ? NetworkImage(user.avatarUrl!) : null,
            child: hasAvatar
                ? null
                : Text(
                    user.initials,
                    style: AppTextStyles.headlineLarge.copyWith(
                      color: Colors.white,
                      fontSize: 26,
                    ),
                  ),
          ),
          const SizedBox(height: 14),
          Text(
            user.name,
            style: AppTextStyles.headlineMedium.copyWith(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            user.email,
            style: AppTextStyles.bodySmall.copyWith(
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.eco, size: 14, color: Colors.white),
                const SizedBox(width: 6),
                Text(
                  context.l10n.plantLifeMember,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, size: 20, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  /// Optional value shown before the chevron (e.g. the active language).
  final Widget? trailing;

  const _NavTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, size: 20, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            if (trailing != null) ...[
              trailing!,
              const SizedBox(width: 6),
            ],
            const Icon(Icons.chevron_right,
                color: AppColors.textHint, size: 20),
          ],
        ),
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      trailing: selected
          ? const Icon(Icons.check, color: AppColors.primary)
          : null,
      onTap: onTap,
    );
  }
}

class _LogoutTile extends StatelessWidget {
  final VoidCallback onTap;

  const _LogoutTile({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.error.withValues(alpha: 0.25)),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(11),
              ),
              child: const Icon(Icons.logout_outlined,
                  size: 20, color: AppColors.error),
            ),
            const SizedBox(width: 12),
            Text(
              context.l10n.logOut,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            const Icon(Icons.chevron_right, color: AppColors.error, size: 20),
          ],
        ),
      ),
    );
  }
}
