import '../../../../core/errors/api_result.dart';
import '../entities/product_entity.dart';
import '../repos/products_repository.dart';

class GetProductUseCase {
  final ProductsRepository _repository;
  GetProductUseCase(this._repository);

  Future<ApiResult<ProductEntity>> call(String id) =>
      _repository.getProduct(id);
}
