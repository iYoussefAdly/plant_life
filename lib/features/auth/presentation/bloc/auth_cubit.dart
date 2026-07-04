import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/api_result.dart';
import '../../../store/domain/usecases/provision_store_session_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final LogoutUseCase _logoutUseCase;
  final ProvisionStoreSessionUseCase _provisionStoreSessionUseCase;

  AuthCubit(
    this._loginUseCase,
    this._registerUseCase,
    this._logoutUseCase,
    this._provisionStoreSessionUseCase,
  ) : super(const AuthInitial());

  Future<void> login({
    required String email,
    required String password,
  }) async {
    emit(const AuthLoading());
    final result = await _loginUseCase(email: email, password: password);
    switch (result) {
      case Success():
        // Bridge the same credentials to the store backend (fire-and-forget so
        // it never blocks entering the app).
        unawaited(
          _provisionStoreSessionUseCase(email: email, password: password),
        );
        emit(const AuthSuccess());
      case Error(:final failure):
        emit(AuthError(failure.message));
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    emit(const AuthLoading());
    final result = await _registerUseCase(
      name: name,
      email: email,
      password: password,
    );
    switch (result) {
      case Success():
        unawaited(
          _provisionStoreSessionUseCase(
            email: email,
            password: password,
            name: name,
          ),
        );
        emit(const AuthSuccess());
      case Error(:final failure):
        emit(AuthError(failure.message));
    }
  }

  Future<void> logout() async {
    await _logoutUseCase();
    emit(const AuthLoggedOut());
  }

  void reset() => emit(const AuthInitial());
}
