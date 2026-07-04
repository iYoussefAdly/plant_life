import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Network image with consistent loading + error placeholders for the store.
class StoreNetworkImage extends StatelessWidget {
  final String? url;
  final BoxFit fit;

  const StoreNetworkImage({super.key, required this.url, this.fit = BoxFit.cover});

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) return const _Placeholder();
    return Image.network(
      url!,
      fit: fit,
      errorBuilder: (_, _, _) => const _Placeholder(),
      loadingBuilder: (context, child, progress) => progress == null
          ? child
          : Container(
              color: AppColors.primary.withValues(alpha: 0.05),
              child: const Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primary.withValues(alpha: 0.06),
      child: Icon(
        Icons.local_florist_outlined,
        color: AppColors.primary.withValues(alpha: 0.4),
        size: 32,
      ),
    );
  }
}
