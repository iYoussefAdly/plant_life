import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/api_result.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;

  AuthCubit(this._loginUseCase, this._registerUseCase)
      : super(const AuthInitial());

  Future<void> login({
    required String email,
    required String password,
  }) async {
    emit(const AuthLoading());
    final result = await _loginUseCase(email: email, password: password);
    switch (result) {
      case Success():
        emit(const AuthSuccess());
      case Error(:final failure):
        emit(AuthError(failure.message));
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String deviceId,
  }) async {
    emit(const AuthLoading());
    final result = await _registerUseCase(
      name: name,
      email: email,
      password: password,
      deviceId: deviceId,
    );
    switch (result) {
      case Success():
        emit(const AuthSuccess());
      case Error(:final failure):
        emit(AuthError(failure.message));
    }
  }

  void reset() => emit(const AuthInitial());
}
