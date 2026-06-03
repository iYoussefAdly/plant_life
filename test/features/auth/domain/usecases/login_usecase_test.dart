import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:plant_life/core/errors/api_result.dart';
import 'package:plant_life/core/errors/failure.dart';
import 'package:plant_life/features/auth/domain/repos/auth_repository.dart';
import 'package:plant_life/features/auth/domain/usecases/login_usecase.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late LoginUseCase sut;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    sut = LoginUseCase(mockRepository);
  });

  group('LoginUseCase', () {
    const validEmail = 'user@example.com';
    const validPassword = 'password123';

    // ── Validation: email ────────────────────────────────────────────────────

    test('should return Error with email message when email is empty', () async {
      final result = await sut(email: '', password: validPassword);

      expect(result, isA<Error<void>>());
      expect(
        (result as Error<void>).failure.message,
        'Please enter a valid email address',
      );
      verifyNever(
        () => mockRepository.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      );
    });

    test('should return Error with email message when email has no @ symbol', () async {
      final result = await sut(email: 'notanemail', password: validPassword);

      expect(result, isA<Error<void>>());
      expect(
        (result as Error<void>).failure.message,
        'Please enter a valid email address',
      );
      verifyNever(
        () => mockRepository.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      );
    });

    test('should return Error with email message when email has no domain extension', () async {
      final result = await sut(email: 'user@example', password: validPassword);

      expect(result, isA<Error<void>>());
      expect(
        (result as Error<void>).failure.message,
        'Please enter a valid email address',
      );
    });

    // ── Validation: password ─────────────────────────────────────────────────

    test('should return Error with password message when password is empty', () async {
      final result = await sut(email: validEmail, password: '');

      expect(result, isA<Error<void>>());
      expect(
        (result as Error<void>).failure.message,
        'Password must be at least 6 characters',
      );
      verifyNever(
        () => mockRepository.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      );
    });

    test('should return Error with password message when password is 5 characters', () async {
      final result = await sut(email: validEmail, password: '12345');

      expect(result, isA<Error<void>>());
      expect(
        (result as Error<void>).failure.message,
        'Password must be at least 6 characters',
      );
    });

    test('should not call repository when password is too short', () async {
      await sut(email: validEmail, password: '12345');

      verifyNever(
        () => mockRepository.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      );
    });

    // ── Repository delegation ────────────────────────────────────────────────

    test('should call repository with correct credentials when inputs are valid', () async {
      when(
        () => mockRepository.login(email: validEmail, password: validPassword),
      ).thenAnswer((_) async => const Success(null));

      await sut(email: validEmail, password: validPassword);

      verify(
        () => mockRepository.login(email: validEmail, password: validPassword),
      ).called(1);
    });

    test('should return Success when repository login succeeds', () async {
      when(
        () => mockRepository.login(email: validEmail, password: validPassword),
      ).thenAnswer((_) async => const Success(null));

      final result = await sut(email: validEmail, password: validPassword);

      expect(result, isA<Success<void>>());
    });

    test('should return Error from repository when login fails', () async {
      when(
        () => mockRepository.login(email: validEmail, password: validPassword),
      ).thenAnswer(
        (_) async => const Error(ServerFailure('Invalid email or password')),
      );

      final result = await sut(email: validEmail, password: validPassword);

      expect(result, isA<Error<void>>());
      expect(
        (result as Error<void>).failure.message,
        'Invalid email or password',
      );
    });

    test('should accept a password exactly 6 characters long', () async {
      when(
        () => mockRepository.login(email: validEmail, password: '123456'),
      ).thenAnswer((_) async => const Success(null));

      final result = await sut(email: validEmail, password: '123456');

      expect(result, isA<Success<void>>());
    });
  });
}
