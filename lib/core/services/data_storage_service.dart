import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DataStorageService {
  static const String _homeDataKey = 'cached_home_data';
  static const String _specializationsKey = 'cached_specializations';
  static const String _citiesKey = 'cached_cities';
  static const String _governoratesKey = 'cached_governorates';

  static Future<void> storeHomeData(Map<String, dynamic> homeData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_homeDataKey, jsonEncode(homeData));
    } catch (e) {
      // Ignore cache write failures
    }
  }

  static Future<Map<String, dynamic>?> getHomeData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_homeDataKey);
      if (jsonString != null) {
        return jsonDecode(jsonString) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<void> storeSpecializations(List<dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_specializationsKey, jsonEncode(data));
    } catch (e) {
      // Ignore cache write failures
    }
  }

  static Future<List<dynamic>?> getSpecializations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_specializationsKey);
      if (jsonString != null) {
        return jsonDecode(jsonString) as List<dynamic>;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<void> storeCities(List<dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_citiesKey, jsonEncode(data));
    } catch (e) {
      // Ignore cache write failures
    }
  }

  static Future<List<dynamic>?> getCities() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_citiesKey);
      if (jsonString != null) {
        return jsonDecode(jsonString) as List<dynamic>;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<void> storeGovernorates(List<dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_governoratesKey, jsonEncode(data));
    } catch (e) {
      // Ignore cache write failures
    }
  }

  static Future<List<dynamic>?> getGovernorates() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_governoratesKey);
      if (jsonString != null) {
        return jsonDecode(jsonString) as List<dynamic>;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<void> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_homeDataKey);
      await prefs.remove(_specializationsKey);
      await prefs.remove(_citiesKey);
      await prefs.remove(_governoratesKey);
    } catch (e) {
      // Ignore cache write failures
    }
  }
}
