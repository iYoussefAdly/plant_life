import 'package:dio/dio.dart';

import '../../domain/entities/products_page_entity.dart';
import 'product_model.dart';

/// Parses `GET /products`:
/// `{ status, results, total, page, totalPages, data: { products: [...] } }`.
class ProductsResponse {
  static ProductsPageEntity parse(Response response) {
    final body = response.data as Map<String, dynamic>? ?? const {};
    final data = body['data'];
    final rawList = data is Map<String, dynamic>
        ? (data['products'] as List? ?? const [])
        : (body['products'] as List? ?? const []);
    final products = rawList
        .whereType<Map<String, dynamic>>()
        .map(ProductModel.fromJson)
        .where((p) => p.id.isNotEmpty)
        .toList();
    return ProductsPageEntity(
      products: products,
      page: (body['page'] as num?)?.toInt() ?? 1,
      totalPages: (body['totalPages'] as num?)?.toInt() ?? 1,
      total: (body['total'] as num?)?.toInt() ?? products.length,
    );
  }
}
