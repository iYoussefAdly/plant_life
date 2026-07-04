import '../../../../core/errors/api_result.dart';
import '../../domain/entities/product_category.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/entities/products_page_entity.dart';
import '../../domain/repos/products_repository.dart';
import '../datasources/products_data_source.dart';
import '../store_response.dart';

class ProductsRepositoryImpl implements ProductsRepository {
  final ProductsDataSource _dataSource;
  ProductsRepositoryImpl(this._dataSource);

  @override
  Future<ApiResult<ProductsPageEntity>> getProducts(ProductQuery query) async {
    try {
      return Success(await _dataSource.getProducts(query));
    } catch (e) {
      return Error(StoreErrorHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<ProductEntity>> getProduct(String id) async {
    try {
      return Success(await _dataSource.getProduct(id));
    } catch (e) {
      return Error(StoreErrorHandler.handle(e));
    }
  }
}
