import '../../domain/entities/product_category.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/entities/products_page_entity.dart';
import '../models/product_model.dart';
import '../models/products_response.dart';
import '../store_api_client.dart';
import '../store_api_endpoints.dart';
import '../store_response.dart';

class ProductsDataSource {
  final StoreApiClient _client;
  const ProductsDataSource(this._client);

  Future<ProductsPageEntity> getProducts(ProductQuery query) async {
    final params = <String, dynamic>{
      'page': query.page,
      'limit': query.limit,
      'sort': query.sort.apiValue,
    };
    if (query.keyword.trim().isNotEmpty) params['keyword'] = query.keyword.trim();
    if (query.category != null) params['category'] = query.category!.apiValue;
    if (query.minPrice != null) params['price[gte]'] = query.minPrice;
    if (query.maxPrice != null) params['price[lte]'] = query.maxPrice;

    final response =
        await _client.dio.get<dynamic>(StoreApiEndpoints.products, queryParameters: params);
    return ProductsResponse.parse(response);
  }

  Future<ProductEntity> getProduct(String id) async {
    final response =
        await _client.dio.get<dynamic>(StoreApiEndpoints.product(id));
    final data = StoreResponse.dataMap(response);
    final product = data['product'];
    return ProductModel.fromJson(
      product is Map<String, dynamic> ? product : data,
    );
  }
}
