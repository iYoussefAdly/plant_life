import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/api_result.dart';
import '../../../../core/notifications/push_notifications_service.dart';
import '../../../sensors/domain/usecases/register_fcm_token_usecase.dart';
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
  final RegisterFcmTokenUseCase _registerFcmTokenUseCase;
  final PushNotificationsService _push;

  AuthCubit(
    this._loginUseCase,
    this._registerUseCase,
    this._logoutUseCase,
    this._provisionStoreSessionUseCase,
    this._registerFcmTokenUseCase,
    this._push,
  ) : super(const AuthInitial());

  /// Registers the FCM device token with the backend so this account receives
  /// Sensor danger push alerts. Fire-and-forget — never blocks entering the app.
  void _registerPushToken() {
    unawaited(() async {
      final token = await _push.getToken();
      if (token != null && token.isNotEmpty) {
        await _registerFcmTokenUseCase(token);
      }
    }());
  }

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
        _registerPushToken();
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
        _registerPushToken();
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
