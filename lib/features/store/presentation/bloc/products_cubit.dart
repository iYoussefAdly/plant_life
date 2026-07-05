import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/api_result.dart';
import '../../domain/entities/product_category.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/usecases/get_products_usecase.dart';
import 'products_state.dart';

class ProductsCubit extends Cubit<ProductsState> {
  final GetProductsUseCase _getProducts;

  ProductQuery _query = const ProductQuery();
  final List<ProductEntity> _items = [];

  /// Bumped whenever the active query is reset (search/filter/sort/refresh) so
  /// that an in-flight `loadMore` from a superseded query can discard its
  /// stale response instead of appending it or corrupting the page counter.
  int _generation = 0;

  ProductsCubit(this._getProducts) : super(const ProductsInitial());

  ProductQuery get query => _query;

  /// Loads the catalogue only if it hasn't been loaded yet. Used when entering
  /// the Store tab so that existing search/filter state (this cubit is a shared
  /// singleton) is preserved across tab switches instead of being reset.
  Future<void> ensureLoaded() =>
      state is ProductsInitial ? load() : Future.value();

  /// Clears all state back to a fresh catalogue — called on logout so the next
  /// user never sees the previous session's products or search.
  void reset() {
    _query = const ProductQuery();
    _items.clear();
    _generation++;
    emit(const ProductsInitial());
  }

  Future<void> load() async {
    final gen = ++_generation;
    emit(const ProductsLoading());
    _query = _query.copyWith(page: 1);
    final result = await _getProducts(_query);
    if (isClosed || gen != _generation) return;
    switch (result) {
      case Success(:final data):
        _items
          ..clear()
          ..addAll(data.products);
        emit(ProductsLoaded(
          products: List.unmodifiable(_items),
          query: _query,
          hasMore: data.hasMore,
          isLoadingMore: false,
          total: data.total,
        ));
      case Error(:final failure):
        emit(ProductsError(failure.message));
    }
  }

  Future<void> _applyQuery(ProductQuery next) {
    _query = next.copyWith(page: 1);
    return load();
  }

  Future<void> search(String keyword) =>
      _applyQuery(_query.copyWith(keyword: keyword));

  Future<void> setCategory(ProductCategory? category) => _applyQuery(
        category == null
            ? _query.copyWith(clearCategory: true)
            : _query.copyWith(category: category),
      );

  Future<void> setSort(ProductSort sort) =>
      _applyQuery(_query.copyWith(sort: sort));

  Future<void> setPriceRange(double? min, double? max) => _applyQuery(
        _query.copyWith(
          minPrice: min,
          clearMinPrice: min == null,
          maxPrice: max,
          clearMaxPrice: max == null,
        ),
      );

  Future<void> clearFilters() => _applyQuery(const ProductQuery());

  /// Appends the next page for infinite scroll.
  Future<void> loadMore() async {
    final s = state;
    if (s is! ProductsLoaded || !s.hasMore || s.isLoadingMore) return;
    final gen = _generation;
    emit(s.copyWith(isLoadingMore: true));

    _query = _query.copyWith(page: _query.page + 1);
    final result = await _getProducts(_query);
    // Discard if the cubit closed or the query was superseded while awaiting —
    // a stale rollback here would corrupt the new query's page counter.
    if (isClosed || gen != _generation) return;
    switch (result) {
      case Success(:final data):
        _items.addAll(data.products);
        emit(ProductsLoaded(
          products: List.unmodifiable(_items),
          query: _query,
          hasMore: data.hasMore,
          isLoadingMore: false,
          total: data.total,
        ));
      case Error():
        // Roll back the page increment; keep what we already have.
        _query = _query.copyWith(page: _query.page - 1);
        emit(s.copyWith(isLoadingMore: false));
    }
  }
}
