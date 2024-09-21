import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kp_music/services/api_client.dart';

import 'package:flutter/material.dart';
import 'package:kp_music/services/api_url.dart';
import 'package:kp_music/services/secure_storage_service.dart';

class AuthState {
  final bool isLoading;
  final bool isSuccess; // New field for success indication
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController nameController;

  AuthState({
    this.isLoading = false,
    this.isSuccess = false, // Default value
    required this.emailController,
    required this.passwordController,
    required this.nameController,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isSuccess, // New field in copyWith
    TextEditingController? emailController,
    TextEditingController? passwordController,
    TextEditingController? nameController,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      emailController: emailController ?? this.emailController,
      passwordController: passwordController ?? this.passwordController,
      nameController: nameController ?? this.nameController,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier()
      : super(AuthState(
          emailController: TextEditingController(),
          passwordController: TextEditingController(),
          nameController: TextEditingController(),
        ));

  final _apiService = ApiClient();

  Future<void> login(BuildContext context) async {
    state = state.copyWith(isLoading: true);

    try {
      final response = await _apiService.post(ApiUrls.login, data: {
        "email": state.emailController.text,
        "password": state.passwordController.text
      });

      if (response.statusCode == 200) {
        final token = response.data['token'];
        final refreshToken = response.data['refreshToken'];
        final SecureStorageService storageService = SecureStorageService();
        await storageService.write(key: 'token', value: token);
        await storageService.write(key: 'refresh_token', value: refreshToken);

        // Indicate success
        state = state.copyWith(isSuccess: true);
      } else {
        // If status code is not 200, extract error message
        final errorMessage = response.data['message'] ?? 'Login failed';
        throw Exception(errorMessage);
      }
    } on DioException catch (dioError) {
      // Handle Dio-specific errors
      String errorMessage;

      if (dioError.response != null) {
        // Server-side error
        errorMessage =
            dioError.response?.data['message'] ?? 'Unexpected server error';
      } else {
        errorMessage = dioError.message ?? 'Unexpected error';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: $errorMessage')),
      );
    } catch (e) {
      // Handle other types of exceptions
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: ${e.toString()}')),
      );
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> signup(BuildContext context) async {
    state = state.copyWith(isLoading: true);

    try {
      final response = await _apiService.post(ApiUrls.signup, data: {
        "email": state.emailController.text,
        "password": state.passwordController.text,
        "firstName": state.nameController.text
      });

      if (response.statusCode == 201) {
        final token = response.data['token'];
        final refreshToken = response.data['refreshToken'];
        final SecureStorageService storageService = SecureStorageService();

        await storageService.write(key: 'token', value: token);
        await storageService.write(key: 'refreshToken', value: refreshToken);

        // Indicate success
        state = state.copyWith(isSuccess: true);
      } else {
        final errorMessage = response.data['message'] ?? 'Signup failed';
        throw Exception(errorMessage);
      }
    } on DioException catch (dioError) {
      // Handle Dio-specific errors
      String errorMessage;

      if (dioError.response != null) {
        // Server-side error
        errorMessage =
            dioError.response?.data['message'] ?? 'Unexpected server error';
      } else {
        // Client-side error (e.g., network issues)
        errorMessage = dioError.message ?? 'Unexpected error';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Signup failed: $errorMessage')),
      );
    } catch (e) {
      // Handle other types of exceptions
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Signup failed: ${e.toString()}')),
      );
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> logout() async {
    final SecureStorageService storageService = SecureStorageService();
    await storageService.delete(key: 'token');
    await storageService.delete(key: 'refreshToken');
    // Indicate success
    state = state.copyWith(isSuccess: false);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
