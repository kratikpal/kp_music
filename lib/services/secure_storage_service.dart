import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  // Create a private constructor
  SecureStorageService._privateConstructor();

  // The single instance of the class
  static final SecureStorageService _instance =
      SecureStorageService._privateConstructor();

  // The single instance of FlutterSecureStorage
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Factory constructor to return the same instance
  factory SecureStorageService() {
    return _instance;
  }

  // Method to write data to secure storage
  Future<void> write({required String key, required String value}) async {
    await _storage.write(key: key, value: value);
  }

  // Method to read data from secure storage
  Future<String?> read({required String key}) async {
    return await _storage.read(key: key);
  }

  // Method to delete data from secure storage
  Future<void> delete({required String key}) async {
    await _storage.delete(key: key);
  }

  // Method to clear all data from secure storage
  Future<void> clear() async {
    await _storage.deleteAll();
  }
}
