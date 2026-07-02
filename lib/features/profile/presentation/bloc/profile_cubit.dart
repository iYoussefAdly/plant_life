import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/api_result.dart';
import '../../../auth/domain/usecases/get_me_usecase.dart';
import '../../../auth/domain/usecases/logout_usecase.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final GetMeUseCase _getMeUseCase;
  final LogoutUseCase _logoutUseCase;

  ProfileCubit(this._getMeUseCase, this._logoutUseCase)
      : super(const ProfileInitial());

  /// Loads the current user. When a profile is already shown, refreshes
  /// silently (keeps the visible data on background failure) so the Home
  /// greeting never flashes back to a loading state.
  Future<void> loadProfile() async {
    final hadData = state is ProfileLoaded;
    if (!hadData) emit(const ProfileLoading());
    final result = await _getMeUseCase();
    if (isClosed) return;
    switch (result) {
      case Success(:final data):
        emit(ProfileLoaded(data));
      case Error(:final failure):
        if (!hadData) emit(ProfileError(failure.message));
    }
  }

  /// Clears the session and signals the UI to return to login.
  Future<void> logout() async {
    await _logoutUseCase();
    if (!isClosed) emit(const ProfileLoggedOut());
  }
}
