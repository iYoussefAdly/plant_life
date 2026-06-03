import '../../domain/entities/home_data_entity.dart';

sealed class HomeState {
  const HomeState();
}

final class HomeInitial extends HomeState {
  const HomeInitial();
}

final class HomeLoading extends HomeState {
  const HomeLoading();
}

final class HomeSuccess extends HomeState {
  final HomeDataEntity data;
  const HomeSuccess(this.data);
}

final class HomeError extends HomeState {
  final String message;
  const HomeError(this.message);
}
