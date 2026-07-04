import '../../../../core/errors/api_result.dart';
import '../entities/product_category.dart';
import '../entities/products_page_entity.dart';
import '../repos/products_repository.dart';

class GetProductsUseCase {
  final ProductsRepository _repository;
  GetProductsUseCase(this._repository);

  Future<ApiResult<ProductsPageEntity>> call(ProductQuery query) =>
      _repository.getProducts(query);
}
