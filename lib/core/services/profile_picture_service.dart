import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import 'logger_service.dart';

class ProfilePictureService {
  static final _instance = ProfilePictureService._internal();
  factory ProfilePictureService() => _instance;
  ProfilePictureService._internal();

  File? _profilePicture;
  final List<Function(File?)> _listeners = [];
  static const String _profileImageFileName = 'profile_picture.jpg';
  String? _currentUserId;

  File? get profilePicture => _profilePicture;

  Future<void> initialize(String? userId) async {
    _currentUserId = userId;
    await _loadSavedProfilePicture();
  }

  Future<void> setProfilePicture(File? imageFile) async {
    _profilePicture = imageFile;

    if (imageFile != null) {
      await _saveProfilePictureToStorage(imageFile);
    } else {
      await _removeProfilePictureFromStorage();
    }

    _notifyListeners();
  }

  Future<void> _loadSavedProfilePicture() async {
    try {
      if (_currentUserId == null) {
        _profilePicture = null;
        _notifyListeners();
        return;
      }

      final appDir = await getApplicationDocumentsDirectory();
      final profileImagePath = path.join(
        appDir.path,
        '${_currentUserId}_$_profileImageFileName',
      );
      final profileImageFile = File(profileImagePath);

      if (await profileImageFile.exists()) {
        _profilePicture = profileImageFile;
      } else {
        _profilePicture = null;
      }
      _notifyListeners();
    } catch (e) {
      _profilePicture = null;
      _notifyListeners();
    }
  }

  Future<void> _saveProfilePictureToStorage(File imageFile) async {
    try {
      if (_currentUserId == null) return;

      final appDir = await getApplicationDocumentsDirectory();
      final profileImagePath = path.join(
        appDir.path,
        '${_currentUserId}_$_profileImageFileName',
      );

      await imageFile.copy(profileImagePath);
      _profilePicture = File(profileImagePath);
    } catch (e) {
      LoggerService.error('Failed to save profile picture', e);
    }
  }

  Future<void> _removeProfilePictureFromStorage() async {
    try {
      if (_currentUserId == null) return;

      final appDir = await getApplicationDocumentsDirectory();
      final profileImagePath = path.join(
        appDir.path,
        '${_currentUserId}_$_profileImageFileName',
      );
      final profileImageFile = File(profileImagePath);

      if (await profileImageFile.exists()) {
        await profileImageFile.delete();
      }
    } catch (e) {
      LoggerService.error('Failed to remove profile picture from storage', e);
    }
  }

  void addListener(Function(File?) listener) {
    _listeners.add(listener);
  }

  void removeListener(Function(File?) listener) {
    _listeners.remove(listener);
  }

  void _notifyListeners() {
    for (final listener in _listeners) {
      listener(_profilePicture);
    }
  }

  void clear() {
    _profilePicture = null;
    _currentUserId = null;
    _removeProfilePictureFromStorage();
    _notifyListeners();
  }

  void clearForLogout() {
    _profilePicture = null;
    _currentUserId = null;
    _notifyListeners();
  }
}
