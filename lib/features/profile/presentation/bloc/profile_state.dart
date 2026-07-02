import '../../../auth/domain/entities/user_entity.dart';

sealed class ProfileState {
  const ProfileState();
}

final class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

final class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

final class ProfileLoaded extends ProfileState {
  final UserEntity user;
  const ProfileLoaded(this.user);
}

final class ProfileError extends ProfileState {
  final String message;
  const ProfileError(this.message);
}

final class ProfileLoggedOut extends ProfileState {
  const ProfileLoggedOut();
}
