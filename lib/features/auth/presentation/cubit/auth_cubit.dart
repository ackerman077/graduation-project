import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/services/secure_storage_service.dart';
import '../../../../core/services/logger_service.dart';
import '../../../../core/services/profile_picture_service.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/models/login_request.dart';
import '../../data/models/register_request.dart';
import '../../data/models/user_profile.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final UserProfile user;
  final String token;

  const AuthSuccess({required this.user, required this.token});

  @override
  List<Object?> get props => [user, token];
}

class AuthFailure extends AuthState {
  final String message;
  final int? code;
  final Map<String, List<String>>? validationErrors;

  const AuthFailure({required this.message, this.code, this.validationErrors});

  @override
  List<Object?> get props => [message, code, validationErrors];
}

class AuthUnauthorized extends AuthState {
  final String message;

  const AuthUnauthorized({required this.message});

  @override
  List<Object?> get props => [message];
}

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
  final ProfilePictureService _profilePictureService;

  AuthCubit(this._authRepository, this._profilePictureService)
    : super(AuthInitial());

  Future<void> login(LoginRequest request) async {
    emit(AuthLoading());
    LoggerService.logAuth('Login: ${request.email}');

    try {
      final response = await _authRepository.login(request);

      if (response.isSuccess && response.data != null) {
        final loginResponse = response.data!;

        final tempUser = UserProfile(
          id: 0,
          name: loginResponse.username ?? '',
          email: '', // filled after profile fetch
          phone: '',
          gender: 'male',
          image: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await SecureStorageService.storeAuthToken(loginResponse.token!);
        await SecureStorageService.storeUserEmail(request.email);
        await SecureStorageService.storeUserName(loginResponse.username ?? '');

        LoggerService.logAuth(
          'Login successful for: ${loginResponse.username}',
        );

        try {
          final profileResponse = await _authRepository.getUserProfile();
          if (profileResponse.isSuccess && profileResponse.data != null) {
            final completeUser = profileResponse.data!;
            LoggerService.logAuth(
              'Complete user profile loaded: ${completeUser.email}',
            );

            await _profilePictureService.initialize(completeUser.id.toString());

            emit(AuthSuccess(user: completeUser, token: loginResponse.token!));
          } else {
            LoggerService.warning(
              'Failed to fetch complete profile, using temporary user',
            );

            await _profilePictureService.initialize('0');

            emit(AuthSuccess(user: tempUser, token: loginResponse.token!));
          }
        } catch (e) {
          LoggerService.warning(
            'Error fetching complete profile: $e, using temporary user',
          );

          await _profilePictureService.initialize('0');

          emit(AuthSuccess(user: tempUser, token: loginResponse.token!));
        }
      } else {
        if (response.code == 422) {
          final validationErrors = _parseValidationErrors(response.message);
          LoggerService.warning('Login validation failed: ${response.message}');
          emit(
            AuthFailure(
              message: response.message ?? 'Validation failed',
              code: response.code,
              validationErrors: validationErrors,
            ),
          );
        } else if (response.code == 401) {
          LoggerService.warning('Login unauthorized: ${response.message}');
          emit(
            AuthUnauthorized(
              message: response.message ?? 'Invalid credentials',
            ),
          );
        } else {
          LoggerService.warning('Login failed: ${response.message}');
          emit(
            AuthFailure(
              message: response.message ?? 'Login failed',
              code: response.code,
            ),
          );
        }
      }
    } catch (e) {
      LoggerService.error('Login unexpected error', e, StackTrace.current);
      emit(AuthFailure(message: 'An unexpected error occurred: $e'));
    }
  }

  Future<void> register(RegisterRequest request) async {
    emit(AuthLoading());
    LoggerService.logAuth('Registration: ${request.email}');

    try {
      final response = await _authRepository.register(request);

      if (response.isSuccess && response.data != null) {
        final loginResponse = response.data!;

        await SecureStorageService.storeAuthToken(loginResponse.token!);
        await SecureStorageService.storeUserEmail(request.email);
        await SecureStorageService.storeUserName(loginResponse.username ?? '');

        LoggerService.logAuth(
          'Registration successful for: ${loginResponse.username}',
        );

        final userProfile = UserProfile(
          id: 0,
          name: loginResponse.username ?? '',
          email: request.email,
          phone: request.phone,
          gender: request.gender == 0 ? 'male' : 'female',
          image: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        try {
          final profileResponse = await _authRepository.getUserProfile();
          if (profileResponse.isSuccess && profileResponse.data != null) {
            final serverUser = profileResponse.data!;
            await SecureStorageService.storeUserName(serverUser.name);
            await SecureStorageService.storeUserEmail(serverUser.email);

            LoggerService.logAuth(
              'Complete user profile fetched after registration: ${serverUser.email}',
            );

            await _profilePictureService.initialize(serverUser.id.toString());

            emit(AuthSuccess(user: serverUser, token: loginResponse.token!));
          } else {
            LoggerService.warning(
              'Profile fetch failed, using registration data: ${profileResponse.message}',
            );

            await _profilePictureService.initialize('0');

            emit(AuthSuccess(user: userProfile, token: loginResponse.token!));
          }
        } catch (e) {
          LoggerService.warning(
            'Failed to fetch user profile after registration: $e',
          );

          await _profilePictureService.initialize('0');

          emit(AuthSuccess(user: userProfile, token: loginResponse.token!));
        }
      } else {
        if (response.code == 422) {
          final validationErrors = _parseValidationErrors(response.message);
          LoggerService.warning(
            'Registration validation failed: ${response.message}',
          );
          emit(
            AuthFailure(
              message: response.message ?? 'Validation failed',
              code: response.code,
              validationErrors: validationErrors,
            ),
          );
        } else {
          LoggerService.warning('Registration failed: ${response.message}');
          emit(
            AuthFailure(
              message: response.message ?? 'Registration failed',
              code: response.code,
            ),
          );
        }
      }
    } catch (e) {
      LoggerService.error(
        'Registration unexpected error',
        e,
        StackTrace.current,
      );
      emit(AuthFailure(message: 'An unexpected error occurred: $e'));
    }
  }

  Future<void> logout() async {
    emit(AuthLoading());
    LoggerService.logAuth('Logout requested');

    try {
      try {
        await _authRepository.logout();
        LoggerService.logAuth('Logout API call successful');
      } catch (e) {
        LoggerService.warning('Logout API call failed: $e');
      }

      // Always clear local auth data and profile picture after logout attempt
      await SecureStorageService.clearAuthData();
      _profilePictureService.clearForLogout();

      LoggerService.logAuth('Logout successful');
      emit(AuthInitial());
    } catch (e) {
      LoggerService.error('Logout failed', e, StackTrace.current);
      try {
        await SecureStorageService.clearAuthData();
        _profilePictureService.clearForLogout();
      } catch (clearError) {
        LoggerService.warning('Failed to clear auth data: $clearError');
      }
      emit(AuthInitial());
    }
  }

  Future<void> checkAuthStatus() async {
    emit(AuthLoading());
    LoggerService.logAuth('Checking auth status');

    try {
      final token = await SecureStorageService.getAuthToken();
      if (token != null && token.isNotEmpty) {
        final response = await _authRepository.getUserProfile();

        if (response.isSuccess && response.data != null) {
          LoggerService.logAuth('User authenticated: ${response.data!.email}');

          await _profilePictureService.initialize(response.data!.id.toString());

          emit(AuthSuccess(user: response.data!, token: token));
        } else {
          await SecureStorageService.clearAuthData();
          LoggerService.warning('Invalid token, clearing auth data');
          emit(AuthInitial());
        }
      } else {
        LoggerService.logAuth('No stored token found');
        emit(AuthInitial());
      }
    } catch (e) {
      LoggerService.error('Auth status check failed', e, StackTrace.current);
      emit(AuthInitial());
    }
  }

  Future<void> refreshUserProfile() async {
    LoggerService.logAuth('Refreshing user profile from server');

    try {
      final token = await SecureStorageService.getAuthToken();
      if (token == null || token.isEmpty) {
        LoggerService.warning('No token found for profile refresh');
        return;
      }

      final response = await _authRepository.getUserProfile();

      if (response.isSuccess && response.data != null) {
        LoggerService.logAuth(
          'User profile refreshed successfully: ${response.data!.email}',
        );

        final currentState = state;
        if (currentState is AuthSuccess) {
          emit(AuthSuccess(user: response.data!, token: currentState.token));
        }
      } else {
        LoggerService.warning(
          'Failed to refresh user profile: ${response.message}',
        );
      }
    } catch (e) {
      LoggerService.error(
        'Error refreshing user profile',
        e,
        StackTrace.current,
      );
    }
  }

  Map<String, List<String>> _parseValidationErrors(String? message) {
    final errors = <String, List<String>>{};

    if (message != null) {

      if (message.contains('field is required')) {
        final parts = message.split('. ');
        for (final part in parts) {
          if (part.contains('field is required')) {
            final words = part.split(' ');
            if (words.length >= 3) {
              final field = words[1];
              errors[field] = ['This field is required'];
            }
          }
        }
      }
      else if (message.contains('must be a valid')) {
        final parts = message.split('. ');
        for (final part in parts) {
          if (part.contains('must be a valid')) {
            final words = part.split(' ');
            if (words.length >= 2) {
              final field = words[1];
              if (part.contains('email')) {
                errors[field] = ['Please enter a valid email address'];
              } else if (part.contains('phone')) {
                errors[field] = ['Please enter a valid phone number'];
              } else {
                errors[field] = ['Please enter a valid value'];
              }
            }
          }
        }
      }
      else if (message.contains('has already been taken')) {
        final parts = message.split('. ');
        for (final part in parts) {
          if (part.contains('has already been taken')) {
            final words = part.split(' ');
            if (words.length >= 2) {
              final field = words[1];
              if (field == 'email') {
                errors[field] = ['This email address is already registered'];
              } else {
                errors[field] = ['This $field is already taken'];
              }
            }
          }
        }
      }
      else if (message.contains('must be at least')) {
        final parts = message.split('. ');
        for (final part in parts) {
          if (part.contains('must be at least')) {
            final words = part.split(' ');
            if (words.length >= 2) {
              final field = words[1];
              final match = RegExp(
                r'at least (\d+) characters',
              ).firstMatch(part);
              if (match != null) {
                final minLength = match.group(1);
                errors[field] = ['Must be at least $minLength characters long'];
              }
            }
          }
        }
      }
      else if (message.contains('does not match')) {
        final parts = message.split('. ');
        for (final part in parts) {
          if (part.contains('does not match')) {
            final words = part.split(' ');
            if (words.length >= 2) {
              final field = words[1];
              errors[field] = ['Passwords do not match'];
            }
          }
        }
      }
      else if (message.contains('validation') || message.contains('invalid')) {
        final commonFields = ['name', 'email', 'phone', 'password', 'gender'];
        for (final field in commonFields) {
          if (message.toLowerCase().contains(field)) {
            errors[field] = ['Please check your $field'];
          }
        }
      }
    }

    return errors;
  }
}
