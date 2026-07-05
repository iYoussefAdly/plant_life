import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../store/presentation/store_search_launcher.dart';
import '../../domain/entities/task_detail_entity.dart';
import '../bloc/task_detail_cubit.dart';
import '../bloc/task_detail_state.dart';

/// Opens the task-detail bottom sheet for [taskIndex] within [planId].
///
/// [scheduledDate] is the timeline-corrected date from the calling task tile;
/// it overrides the raw (off-by-one) date the task endpoint returns so the
/// sheet stays consistent with the rest of the treatment timeline.
///
/// [recommendedProducts] are the plan's product names; where one is mentioned
/// in the task, a "Search in Store" shortcut is offered.
Future<void> showTaskDetailSheet(
  BuildContext context, {
  required String planId,
  required int taskIndex,
  DateTime? scheduledDate,
  List<String> recommendedProducts = const [],
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => BlocProvider(
      create: (_) => sl<TaskDetailCubit>()..load(planId, taskIndex),
      child: _TaskDetailSheet(
        scheduledDateOverride: scheduledDate,
        recommendedProducts: recommendedProducts,
      ),
    ),
  );
}

class _TaskDetailSheet extends StatelessWidget {
  final DateTime? scheduledDateOverride;
  final List<String> recommendedProducts;

  const _TaskDetailSheet({
    this.scheduledDateOverride,
    this.recommendedProducts = const [],
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.35,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const _Handle(),
              Expanded(
                child: BlocBuilder<TaskDetailCubit, TaskDetailState>(
                  builder: (context, state) => switch (state) {
                    TaskDetailLoading() => const Center(
                        child: Padding(
                          padding: EdgeInsets.all(40),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    TaskDetailLoaded(:final task) => _Content(
                        task: task,
                        scrollController: scrollController,
                        scheduledDateOverride: scheduledDateOverride,
                        recommendedProducts: recommendedProducts,
                      ),
                    TaskDetailError(:final message) => _ErrorBody(
                        message: message,
                        onRetry: () =>
                            context.read<TaskDetailCubit>().retry(),
                      ),
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Handle extends StatelessWidget {
  const _Handle();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10, bottom: 4),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: AppColors.textHint.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  final TaskDetailEntity task;
  final ScrollController scrollController;
  final DateTime? scheduledDateOverride;
  final List<String> recommendedProducts;

  const _Content({
    required this.task,
    required this.scrollController,
    this.scheduledDateOverride,
    this.recommendedProducts = const [],
  });

  /// Products this task mentions in its text — offered as store shortcuts.
  List<String> get _mentionedProducts {
    if (recommendedProducts.isEmpty) return const [];
    final haystack = [
      task.title,
      task.description,
      task.why,
      ...task.tips,
      ...task.warnings,
    ].join(' ').toLowerCase();
    return recommendedProducts
        .where((p) => p.trim().isNotEmpty && haystack.contains(p.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final products = _mentionedProducts;
    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      children: [
        Row(
          children: [
            _DayBadge(day: task.day),
            const Spacer(),
            if (task.completed) const _CompletedChip(),
          ],
        ),
        const SizedBox(height: 14),
        Text(task.title, style: AppTextStyles.headlineSmall),
        if (task.hasDayTitle) ...[
          const SizedBox(height: 4),
          Text(
            task.dayTitle,
            style: AppTextStyles.bodySmall
                .copyWith(color: AppColors.textSecondary),
          ),
        ],
        const SizedBox(height: 12),
        _MetaRow(
          task: task,
          scheduledDate: scheduledDateOverride ?? task.scheduledDate,
        ),
        if (task.hasDescription) ...[
          const SizedBox(height: 20),
          _Section(
            icon: Icons.description_outlined,
            title: 'Instructions',
            child: _Paragraph(task.description),
          ),
        ],
        if (task.hasWhy) ...[
          const SizedBox(height: 20),
          _Section(
            icon: Icons.info_outline,
            title: 'Why this matters',
            child: _Paragraph(task.why),
          ),
        ],
        if (task.hasTips) ...[
          const SizedBox(height: 20),
          _Section(
            icon: Icons.lightbulb_outline,
            title: 'Tips',
            iconColor: AppColors.primary,
            child: _BulletList(
              items: task.tips,
              bulletColor: AppColors.primary,
            ),
          ),
        ],
        if (task.hasWarnings) ...[
          const SizedBox(height: 20),
          _Section(
            icon: Icons.warning_amber_rounded,
            title: 'Warnings',
            iconColor: AppColors.warning,
            child: _BulletList(
              items: task.warnings,
              bulletColor: AppColors.warning,
            ),
          ),
        ],
        if (products.isNotEmpty) ...[
          const SizedBox(height: 20),
          _Section(
            icon: Icons.storefront_outlined,
            title: 'Products',
            iconColor: AppColors.primary,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: products
                  .map((p) => _ProductSearchChip(product: p))
                  .toList(),
            ),
          ),
        ],
        if (!task.hasExtraDetails && products.isEmpty) ...[
          const SizedBox(height: 24),
          Center(
            child: Text(
              'No further details for this task.',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textSecondary),
            ),
          ),
        ],
      ],
    );
  }
}

/// A tappable product chip that opens the Store, pre-filled with a search for
/// the product — reusing the existing store search flow.
class _ProductSearchChip extends StatelessWidget {
  final String product;
  const _ProductSearchChip({required this.product});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          // Capture the router before dismissing the sheet, then hand off to
          // the shared store search flow.
          final router = GoRouter.of(context);
          Navigator.of(context).pop();
          openStoreSearch(router, product);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  product,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.search, size: 16, color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  final TaskDetailEntity task;
  final DateTime? scheduledDate;
  const _MetaRow({required this.task, this.scheduledDate});

  @override
  Widget build(BuildContext context) {
    final chips = <Widget>[
      if (scheduledDate != null)
        _MetaChip(
          icon: Icons.event_outlined,
          label: formatShortDate(scheduledDate!),
        ),
      if (task.hasEstimatedTime)
        _MetaChip(
          icon: Icons.schedule_outlined,
          label: task.estimatedTime,
        ),
    ];
    if (chips.isEmpty) return const SizedBox.shrink();
    return Wrap(spacing: 8, runSpacing: 8, children: chips);
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.textHint.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.labelMedium
                .copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _DayBadge extends StatelessWidget {
  final int day;
  const _DayBadge({required this.day});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        'Day $day',
        style: AppTextStyles.labelLarge.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _CompletedChip extends StatelessWidget {
  const _CompletedChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, size: 15, color: AppColors.success),
          const SizedBox(width: 6),
          Text(
            'Completed',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.success,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;
  final Color? iconColor;

  const _Section({
    required this.icon,
    required this.title,
    required this.child,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: iconColor ?? AppColors.textSecondary),
            const SizedBox(width: 8),
            Text(title, style: AppTextStyles.labelLarge),
          ],
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _Paragraph extends StatelessWidget {
  final String text;
  const _Paragraph(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.textSecondary,
        height: 1.5,
      ),
    );
  }
}

class _BulletList extends StatelessWidget {
  final List<String> items;
  final Color bulletColor;

  const _BulletList({required this.items, required this.bulletColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 7),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: bulletColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorBody({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 44, color: AppColors.error),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
