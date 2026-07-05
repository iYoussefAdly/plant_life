import 'package:flutter/widgets.dart';

import '../../../core/localization/l10n.dart';
import '../domain/entities/product_category.dart';

/// Presentation-side display names for the store's domain enums, so the
/// domain layer stays free of UI text.
extension ProductCategoryLabel on ProductCategory {
  String label(BuildContext context) => switch (this) {
        ProductCategory.plantDiseaseTreatment => context.l10n.catTreatments,
        ProductCategory.plantTools => context.l10n.catTools,
        ProductCategory.seeds => context.l10n.catSeeds,
        ProductCategory.fertilizers => context.l10n.catFertilizers,
      };
}

extension ProductSortLabel on ProductSort {
  String label(BuildContext context) => switch (this) {
        ProductSort.newest => context.l10n.sortNewest,
        ProductSort.priceLowToHigh => context.l10n.sortPriceLowHigh,
        ProductSort.priceHighToLow => context.l10n.sortPriceHighLow,
        ProductSort.bestSelling => context.l10n.sortBestSelling,
      };
}
