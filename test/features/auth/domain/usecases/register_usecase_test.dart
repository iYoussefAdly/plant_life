import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:plant_life/core/errors/api_result.dart';
import 'package:plant_life/core/errors/failure.dart';
import 'package:plant_life/features/auth/domain/repos/auth_repository.dart';
import 'package:plant_life/features/auth/domain/usecases/register_usecase.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late RegisterUseCase sut;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    sut = RegisterUseCase(mockRepository);
  });

  group('RegisterUseCase', () {
    const validName = 'Alice';
    const validEmail = 'alice@example.com';
    const validPassword = 'securepass';
    const validDeviceId = 'device-001';

    // ── Validation: email ────────────────────────────────────────────────────

    test('should return Error with email message when email is empty', () async {
      final result = await sut(
        name: validName,
        email: '',
        password: validPassword,
        deviceId: validDeviceId,
      );

      expect(result, isA<Error<void>>());
      expect(
        (result as Error<void>).failure.message,
        'Please enter a valid email address',
      );
      verifyNever(
        () => mockRepository.register(
          name: any(named: 'name'),
          email: any(named: 'email'),
          password: any(named: 'password'),
          deviceId: any(named: 'deviceId'),
        ),
      );
    });

    test('should return Error with email message when email has no @ symbol', () async {
      final result = await sut(
        name: validName,
        email: 'invalidemail',
        password: validPassword,
        deviceId: validDeviceId,
      );

      expect(result, isA<Error<void>>());
      expect(
        (result as Error<void>).failure.message,
        'Please enter a valid email address',
      );
    });

    test('should return Error with email message when email has no domain extension', () async {
      final result = await sut(
        name: validName,
        email: 'alice@example',
        password: validPassword,
        deviceId: validDeviceId,
      );

      expect(result, isA<Error<void>>());
      expect(
        (result as Error<void>).failure.message,
        'Please enter a valid email address',
      );
    });

    // ── Validation: password ─────────────────────────────────────────────────

    test('should return Error with password message when password is empty', () async {
      final result = await sut(
        name: validName,
        email: validEmail,
        password: '',
        deviceId: validDeviceId,
      );

      expect(result, isA<Error<void>>());
      expect(
        (result as Error<void>).failure.message,
        'Password must be at least 6 characters',
      );
      verifyNever(
        () => mockRepository.register(
          name: any(named: 'name'),
          email: any(named: 'email'),
          password: any(named: 'password'),
          deviceId: any(named: 'deviceId'),
        ),
      );
    });

    test('should return Error with password message when password is 5 characters', () async {
      final result = await sut(
        name: validName,
        email: validEmail,
        password: 'abc12',
        deviceId: validDeviceId,
      );

      expect(result, isA<Error<void>>());
      expect(
        (result as Error<void>).failure.message,
        'Password must be at least 6 characters',
      );
    });

    test('should not call repository when password is too short', () async {
      await sut(
        name: validName,
        email: validEmail,
        password: 'abc12',
        deviceId: validDeviceId,
      );

      verifyNever(
        () => mockRepository.register(
          name: any(named: 'name'),
          email: any(named: 'email'),
          password: any(named: 'password'),
          deviceId: any(named: 'deviceId'),
        ),
      );
    });

    // ── Repository delegation ────────────────────────────────────────────────

    test('should call repository with all correct parameters when inputs are valid', () async {
      when(
        () => mockRepository.register(
          name: validName,
          email: validEmail,
          password: validPassword,
          deviceId: validDeviceId,
        ),
      ).thenAnswer((_) async => const Success(null));

      await sut(
        name: validName,
        email: validEmail,
        password: validPassword,
        deviceId: validDeviceId,
      );

      verify(
        () => mockRepository.register(
          name: validName,
          email: validEmail,
          password: validPassword,
          deviceId: validDeviceId,
        ),
      ).called(1);
    });

    test('should return Success when repository register succeeds', () async {
      when(
        () => mockRepository.register(
          name: validName,
          email: validEmail,
          password: validPassword,
          deviceId: validDeviceId,
        ),
      ).thenAnswer((_) async => const Success(null));

      final result = await sut(
        name: validName,
        email: validEmail,
        password: validPassword,
        deviceId: validDeviceId,
      );

      expect(result, isA<Success<void>>());
    });

    test('should return Error from repository when registration fails', () async {
      when(
        () => mockRepository.register(
          name: validName,
          email: validEmail,
          password: validPassword,
          deviceId: validDeviceId,
        ),
      ).thenAnswer(
        (_) async => const Error(ServerFailure('Email already registered')),
      );

      final result = await sut(
        name: validName,
        email: validEmail,
        password: validPassword,
        deviceId: validDeviceId,
      );

      expect(result, isA<Error<void>>());
      expect(
        (result as Error<void>).failure.message,
        'Email already registered',
      );
    });

    test('should accept a password exactly 6 characters long', () async {
      when(
        () => mockRepository.register(
          name: validName,
          email: validEmail,
          password: '123456',
          deviceId: validDeviceId,
        ),
      ).thenAnswer((_) async => const Success(null));

      final result = await sut(
        name: validName,
        email: validEmail,
        password: '123456',
        deviceId: validDeviceId,
      );

      expect(result, isA<Success<void>>());
    });
  });
}
