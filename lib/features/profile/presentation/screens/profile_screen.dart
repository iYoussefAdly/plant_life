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
import '../../../auth/domain/entities/user_entity.dart';
import '../../../notifications/presentation/bloc/notifications_cubit.dart';
import '../../../store/domain/usecases/clear_store_session_usecase.dart';
import '../../../store/presentation/bloc/cart_cubit.dart';
import '../bloc/profile_cubit.dart';
import '../bloc/profile_state.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile', style: AppTextStyles.headlineMedium),
      ),
      body: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state is ProfileLoggedOut) {
            sl<SocketService>().disconnect();
            // Clear the previous user's notifications so the next session
            // starts with a clean badge/list.
            sl<NotificationsCubit>().reset();
            // Drop the store session + cart so the next user starts clean.
            sl<ClearStoreSessionUseCase>()();
            sl<CartCubit>().reset();
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
            label: 'Name',
            value: user.name,
          ),
        ),
        const SizedBox(height: 10),
        FadeSlideIn(
          index: 2,
          child: _InfoTile(
            icon: Icons.email_outlined,
            label: 'Email',
            value: user.email,
          ),
        ),
        const SizedBox(height: 24),
        FadeSlideIn(
          index: 3,
          child: _NavTile(
            icon: Icons.storefront_outlined,
            label: 'Plant Store',
            onTap: () => context.push(AppRoutes.store),
          ),
        ),
        const SizedBox(height: 10),
        FadeSlideIn(
          index: 4,
          child: _NavTile(
            icon: Icons.receipt_long_outlined,
            label: 'My Orders',
            onTap: () => context.push(AppRoutes.orders),
          ),
        ),
        const SizedBox(height: 24),
        FadeSlideIn(index: 5, child: _LogoutTile(onTap: () => _confirmLogout(context))),
        const SizedBox(height: 16),
      ],
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Log out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Log out'),
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
                  'PlantLife member',
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

  const _NavTile({
    required this.icon,
    required this.label,
    required this.onTap,
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
            const Icon(Icons.chevron_right,
                color: AppColors.textHint, size: 20),
          ],
        ),
      ),
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
              'Log out',
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
