import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../data/repositories/profile_repository.dart';
import '../../../../core/services/logger_service.dart';
import '../../../../core/services/secure_storage_service.dart';
import '../../auth/data/models/profile_update_request.dart';
import '../../auth/presentation/cubit/auth_cubit.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final Map<String, dynamic> userProfile;

  const ProfileLoaded(this.userProfile);

  @override
  List<Object?> get props => [userProfile];
}

class ProfileUpdateLoading extends ProfileState {}

class ProfileUpdateSuccess extends ProfileState {
  final Map<String, dynamic> updatedProfile;
  final String message;

  const ProfileUpdateSuccess(this.updatedProfile, this.message);

  @override
  List<Object?> get props => [updatedProfile, message];
}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository _profileRepository;
  final AuthCubit _authCubit;

  ProfileCubit(this._profileRepository, this._authCubit)
    : super(ProfileInitial());

  Future<void> loadUserProfile() async {
    if (isClosed) return;
    emit(ProfileLoading());

    try {
      final response = await _profileRepository.getUserProfile();

      if (isClosed) return;
      if (response.status && response.data != null) {
        Map<String, dynamic> profileData;
        if (response.data is List) {
          final List<dynamic> dataList = response.data as List<dynamic>;
          if (dataList.isNotEmpty && dataList.first is Map<String, dynamic>) {
            profileData = dataList.first as Map<String, dynamic>;
          } else {
            profileData = <String, dynamic>{};
          }
        } else if (response.data is Map<String, dynamic>) {
          profileData = response.data as Map<String, dynamic>;
        } else {
          profileData = <String, dynamic>{};
        }

        emit(ProfileLoaded(profileData));
      } else {
        emit(ProfileError(response.message ?? 'Failed to load profile'));
      }
    } catch (e) {
      if (isClosed) return;
      emit(ProfileError('Failed to load profile: $e'));
    }
  }

  Future<void> updateProfilePartial(Map<String, dynamic> changedFields) async {
    LoggerService.logAuth(
      'ProfileCubit: updateProfilePartial called with changed fields: $changedFields',
    );

    if (isClosed) {
      LoggerService.logAuth('ProfileCubit: Cubit is closed, returning early');
      return;
    }

    LoggerService.logAuth('ProfileCubit: Emitting ProfileUpdateLoading state');
    emit(ProfileUpdateLoading());
    LoggerService.logAuth(
      'ProfileCubit: ProfileUpdateLoading state emitted successfully',
    );

    try {
      LoggerService.logAuth(
        'ProfileCubit: About to call _profileRepository.updateProfilePartial()',
      );
      LoggerService.logAuth(
        'ProfileCubit: Changed fields being sent: $changedFields',
      );

      final response = await _profileRepository.updateProfilePartial(
        changedFields,
      );
      LoggerService.logAuth(
        'ProfileCubit: Partial update repository response: ${response.status} - ${response.message}',
      );

      if (isClosed) {
        LoggerService.logAuth(
          'ProfileCubit: Cubit closed after repository call, returning',
        );
        return;
      }

      if (response.status && response.data != null) {
        Map<String, dynamic> updatedProfile;
        if (response.data is List) {
          final List<dynamic> dataList = response.data as List<dynamic>;
          if (dataList.isNotEmpty && dataList.first is Map<String, dynamic>) {
            updatedProfile = dataList.first as Map<String, dynamic>;
          } else {
            updatedProfile = <String, dynamic>{};
          }
        } else if (response.data is Map<String, dynamic>) {
          updatedProfile = response.data as Map<String, dynamic>;
        } else {
          updatedProfile = <String, dynamic>{};
        }

        LoggerService.logAuth(
          'ProfileCubit: Partial profile update successful, updating secure storage',
        );

        await _updateSecureStoragePartial(changedFields);
        LoggerService.logAuth(
          'ProfileCubit: Secure storage updated successfully with partial data',
        );

        LoggerService.logAuth(
          'ProfileCubit: Emitting ProfileUpdateSuccess state for partial update',
        );
        emit(
          ProfileUpdateSuccess(
            updatedProfile,
            response.message ?? 'Profile updated successfully',
          ),
        );
        LoggerService.logAuth(
          'ProfileCubit: ProfileUpdateSuccess state emitted for partial update',
        );

        LoggerService.logAuth(
          'ProfileCubit: Refreshing AuthCubit user profile after partial update',
        );
        await _authCubit.refreshUserProfile();
        LoggerService.logAuth(
          'ProfileCubit: AuthCubit user profile refreshed successfully after partial update',
        );

        LoggerService.logAuth(
          'ProfileCubit: Reloading profile after partial update',
        );
        await loadUserProfile();
        LoggerService.logAuth(
          'ProfileCubit: Profile reloaded successfully after partial update',
        );
      } else {
        LoggerService.logAuth(
          'ProfileCubit: Partial profile update failed, emitting error state',
        );
        emit(ProfileError(response.message ?? 'Failed to update profile'));
        LoggerService.logAuth(
          'ProfileCubit: ProfileError state emitted for partial update',
        );
      }
    } catch (e) {
      LoggerService.logAuth(
        'ProfileCubit: Partial update exception occurred: $e',
      );
      LoggerService.logAuth(
        'ProfileCubit: Partial update exception stack trace: ${StackTrace.current}',
      );
      if (isClosed) {
        LoggerService.logAuth(
          'ProfileCubit: Cubit closed during partial update exception handling, returning',
        );
        return;
      }
      emit(ProfileError('Failed to update profile: $e'));
      LoggerService.logAuth(
        'ProfileCubit: ProfileError state emitted after partial update exception',
      );
    }
  }

  Future<void> updateProfile(ProfileUpdateRequest request) async {
    LoggerService.logAuth(
      'ProfileCubit: updateProfile called with data: $request',
    );

    if (isClosed) {
      LoggerService.logAuth('ProfileCubit: Cubit is closed, returning early');
      return;
    }

    LoggerService.logAuth('ProfileCubit: Emitting ProfileUpdateLoading state');
    emit(ProfileUpdateLoading());
    LoggerService.logAuth(
      'ProfileCubit: ProfileUpdateLoading state emitted successfully',
    );

    try {
      LoggerService.logAuth(
        'ProfileCubit: About to call _profileRepository.updateProfile()',
      );
      LoggerService.logAuth('ProfileCubit: Data being sent: $request');

      final response = await _profileRepository.updateProfile(request);
      LoggerService.logAuth(
        'ProfileCubit: Repository response received: ${response.status} - ${response.message}',
      );

      if (isClosed) {
        LoggerService.logAuth(
          'ProfileCubit: Cubit closed after repository call, returning',
        );
        return;
      }

      if (response.status && response.data != null) {
        Map<String, dynamic> updatedProfile;
        if (response.data is List) {
          final List<dynamic> dataList = response.data as List<dynamic>;
          if (dataList.isNotEmpty && dataList.first is Map<String, dynamic>) {
            updatedProfile = dataList.first as Map<String, dynamic>;
          } else {
            updatedProfile = <String, dynamic>{};
          }
        } else if (response.data is Map<String, dynamic>) {
          updatedProfile = response.data as Map<String, dynamic>;
        } else {
          updatedProfile = <String, dynamic>{};
        }

        LoggerService.logAuth(
          'ProfileCubit: Profile update successful, updating secure storage',
        );

        await _updateSecureStorage(request);
        LoggerService.logAuth(
          'ProfileCubit: Secure storage updated successfully',
        );

        LoggerService.logAuth(
          'ProfileCubit: Emitting ProfileUpdateSuccess state',
        );
        emit(
          ProfileUpdateSuccess(
            updatedProfile,
            response.message ?? 'Profile updated successfully',
          ),
        );
        LoggerService.logAuth(
          'ProfileCubit: ProfileUpdateSuccess state emitted',
        );

        LoggerService.logAuth(
          'ProfileCubit: Refreshing AuthCubit user profile after update',
        );
        await _authCubit.refreshUserProfile();
        LoggerService.logAuth(
          'ProfileCubit: AuthCubit user profile refreshed successfully after update',
        );

        LoggerService.logAuth('ProfileCubit: Reloading profile after update');
        await loadUserProfile();
        LoggerService.logAuth('ProfileCubit: Profile reloaded successfully');
      } else {
        LoggerService.logAuth(
          'ProfileCubit: Profile update failed, emitting error state',
        );
        emit(ProfileError(response.message ?? 'Failed to update profile'));
        LoggerService.logAuth('ProfileCubit: ProfileError state emitted');
      }
    } catch (e) {
      LoggerService.logAuth('ProfileCubit: Exception occurred: $e');
      LoggerService.logAuth(
        'ProfileCubit: Exception stack trace: ${StackTrace.current}',
      );
      if (isClosed) {
        LoggerService.logAuth(
          'ProfileCubit: Cubit closed during exception handling, returning',
        );
        return;
      }
      emit(ProfileError('Failed to update profile: $e'));
      LoggerService.logAuth(
        'ProfileCubit: ProfileError state emitted after exception',
      );
    }
  }

  Future<void> _updateSecureStorage(ProfileUpdateRequest request) async {
    try {
      await SecureStorageService.storeUserName(request.name);
      await SecureStorageService.storeUserEmail(request.email);
      LoggerService.logAuth('Secure storage updated with new profile data');
    } catch (e) {
      LoggerService.warning('Failed to update secure storage: $e');
    }
  }

  Future<void> _updateSecureStoragePartial(
    Map<String, dynamic> changedFields,
  ) async {
    try {
      if (changedFields.containsKey('name')) {
        await SecureStorageService.storeUserName(changedFields['name']);
        LoggerService.logAuth(
          'Secure storage updated with new name: ${changedFields['name']}',
        );
      }
      if (changedFields.containsKey('email')) {
        await SecureStorageService.storeUserEmail(changedFields['email']);
        LoggerService.logAuth(
          'Secure storage updated with new email: ${changedFields['email']}',
        );
      }
      LoggerService.logAuth('Secure storage updated with partial profile data');
    } catch (e) {
      LoggerService.warning('Failed to update secure storage partially: $e');
    }
  }

  void resetState() {
    if (isClosed) return;
    emit(ProfileInitial());
  }
}
