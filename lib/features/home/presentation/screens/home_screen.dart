import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/fade_slide_in.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/skeleton.dart';
import '../../../notifications/presentation/bloc/notifications_cubit.dart';
import '../../../notifications/presentation/bloc/notifications_state.dart';
import '../../../profile/presentation/bloc/profile_cubit.dart';
import '../../../profile/presentation/bloc/profile_state.dart';
import '../../../store/presentation/widgets/store_entry_card.dart';
import '../../domain/entities/home_data_entity.dart';
import '../bloc/home_cubit.dart';
import '../bloc/home_state.dart';
import '../widgets/alerts_section.dart';
import '../widgets/sensor_summary_card.dart';
import '../widgets/treatment_tasks_section.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        titleSpacing: 16,
        title: const _GreetingHeader(),
        actions: [
          BlocBuilder<NotificationsCubit, NotificationsState>(
            builder: (context, state) {
              final unread = switch (state) {
                NotificationsLoaded(:final unreadCount) => unreadCount,
                _ => 0,
              };
              return IconButton(
                icon: Badge(
                  isLabelVisible: unread > 0,
                  backgroundColor: AppColors.error,
                  textColor: Colors.white,
                  label: Text('$unread'),
                  child: const Icon(Icons.notifications_outlined),
                ),
                onPressed: () => context.push(AppRoutes.notifications),
              );
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) => switch (state) {
          HomeInitial() => const SizedBox.shrink(),
          HomeLoading() => const _HomeSkeleton(),
          HomeSuccess(:final data) => _HomeContent(data: data),
          HomeError(:final message) => ErrorView(
              message: message,
              onRetry: () => context.read<HomeCubit>().loadHomeData(),
            ),
        },
      ),
    );
  }
}

/// Time-based greeting + user name, with a tappable avatar that opens Profile.
class _GreetingHeader extends StatelessWidget {
  const _GreetingHeader();

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        final user = state is ProfileLoaded ? state.user : null;
        final hasAvatar = user?.avatarUrl?.isNotEmpty == true;
        return Row(
          children: [
            GestureDetector(
              onTap: () => context.push(AppRoutes.profile),
              child: CircleAvatar(
                radius: 19,
                backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                backgroundImage:
                    hasAvatar ? NetworkImage(user!.avatarUrl!) : null,
                child: hasAvatar
                    ? null
                    : (user != null
                        ? Text(
                            user.initials,
                            style: AppTextStyles.labelLarge.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          )
                        : const Icon(Icons.person_outline,
                            size: 20, color: AppColors.primary)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$_greeting 👋',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                  Text(
                    user?.name.isNotEmpty == true ? user!.name : 'PlantLife',
                    style: AppTextStyles.headlineSmall.copyWith(fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _HomeContent extends StatelessWidget {
  final HomeDataEntity data;

  const _HomeContent({required this.data});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => context.read<HomeCubit>().loadHomeData(silent: true),
      color: AppColors.primary,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        children: [
          const FadeSlideIn(child: StoreEntryCard()),
          const SizedBox(height: 24),
          FadeSlideIn(
            index: 1,
            child: SectionHeader(
              icon: Icons.monitor_heart_outlined,
              title: 'Sensor Overview',
              trailing: Text(
                '${data.sensorReadings.length} sensors',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.textHint,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.3,
            ),
            itemCount: data.sensorReadings.length,
            itemBuilder: (context, index) => FadeSlideIn(
              index: index + 1,
              child: SensorSummaryCard(reading: data.sensorReadings[index]),
            ),
          ),
          const SizedBox(height: 28),
          FadeSlideIn(index: 2, child: AlertsSection(alerts: data.alerts)),
          const SizedBox(height: 28),
          FadeSlideIn(
            index: 3,
            child: TreatmentTasksSection(tasks: data.todayTasks),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

/// Dashboard-shaped loading placeholder instead of a bare spinner.
class _HomeSkeleton extends StatelessWidget {
  const _HomeSkeleton();

  @override
  Widget build(BuildContext context) {
    return SkeletonPulse(
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        children: [
          const SkeletonBox(width: 160, height: 22, radius: 8),
          const SizedBox(height: 14),
          Row(
            children: const [
              Expanded(child: SkeletonBox(height: 120, radius: 16)),
              SizedBox(width: 12),
              Expanded(child: SkeletonBox(height: 120, radius: 16)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: const [
              Expanded(child: SkeletonBox(height: 120, radius: 16)),
              SizedBox(width: 12),
              Expanded(child: SkeletonBox(height: 120, radius: 16)),
            ],
          ),
          const SizedBox(height: 28),
          const SkeletonBox(width: 120, height: 22, radius: 8),
          const SizedBox(height: 14),
          const SkeletonBox(height: 64, radius: 12),
          const SizedBox(height: 8),
          const SkeletonBox(height: 64, radius: 12),
          const SizedBox(height: 8),
          const SkeletonBox(height: 64, radius: 12),
        ],
      ),
    );
  }
}
