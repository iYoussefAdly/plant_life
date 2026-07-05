import 'package:go_router/go_router.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/routing/app_routes.dart';
import 'bloc/products_cubit.dart';

/// Switches to the Store tab and runs a product search for [query], reusing the
/// existing shared [ProductsCubit] search flow (no separate implementation).
///
/// Pass a [GoRouter] captured from a still-valid context (before dismissing any
/// modal) so navigation works even after the caller pops itself.
void openStoreSearch(GoRouter router, String query) {
  final trimmed = query.trim();
  if (trimmed.isEmpty) return;
  sl<ProductsCubit>().search(trimmed);
  router.go(AppRoutes.store);
}
