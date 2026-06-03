import 'package:flutter_test/flutter_test.dart';

import 'package:plant_life/core/errors/api_result.dart';
import 'package:plant_life/features/auth/data/repos/auth_repository_impl.dart';

void main() {
  late AuthRepositoryImpl sut;

  setUp(() {
    sut = AuthRepositoryImpl();
  });

  group('AuthRepositoryImpl', () {
    // ── login ────────────────────────────────────────────────────────────────

    group('login', () {
      test('should return Success for a valid email and password', () async {
        final result = await sut.login(
          email: 'user@example.com',
          password: 'password123',
        );

        expect(result, isA<Success<void>>());
      });

      test('should return Error with invalid-credentials message for error@test.com', () async {
        final result = await sut.login(
          email: 'error@test.com',
          password: 'anypassword',
        );

        expect(result, isA<Error<void>>());
        expect(
          (result as Error<void>).failure.message,
          'Invalid email or password',
        );
      });

      test('should return Success for any non-trigger email', () async {
        final result = await sut.login(
          email: 'another@domain.org',
          password: 'somepassword',
        );

        expect(result, isA<Success<void>>());
      });
    });

    // ── register ─────────────────────────────────────────────────────────────

    group('register', () {
      test('should return Success for a valid registration', () async {
        final result = await sut.register(
          name: 'Bob',
          email: 'bob@example.com',
          password: 'password123',
          deviceId: 'device-abc',
        );

        expect(result, isA<Success<void>>());
      });

      test('should return Error with already-registered message for taken@test.com', () async {
        final result = await sut.register(
          name: 'Bob',
          email: 'taken@test.com',
          password: 'password123',
          deviceId: 'device-abc',
        );

        expect(result, isA<Error<void>>());
        expect(
          (result as Error<void>).failure.message,
          'Email already registered',
        );
      });

      test('should return Success for any non-trigger email', () async {
        final result = await sut.register(
          name: 'Carol',
          email: 'carol@domain.io',
          password: 'password123',
          deviceId: 'device-xyz',
        );

        expect(result, isA<Success<void>>());
      });
    });
  });
}
