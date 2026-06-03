import 'failure.dart';

sealed class ApiResult<T> {
  const ApiResult();
}

final class Success<T> extends ApiResult<T> {
  final T data;
  const Success(this.data);
}

final class Error<T> extends ApiResult<T> {
  final Failure failure;
  const Error(this.failure);
}
