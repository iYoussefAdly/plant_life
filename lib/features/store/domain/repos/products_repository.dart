import '../../../../core/errors/api_result.dart';
import '../entities/product_category.dart';
import '../entities/product_entity.dart';
import '../entities/products_page_entity.dart';

abstract class ProductsRepository {
  Future<ApiResult<ProductsPageEntity>> getProducts(ProductQuery query);
  Future<ApiResult<ProductEntity>> getProduct(String id);
}
