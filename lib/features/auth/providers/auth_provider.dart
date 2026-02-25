import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../domain/app_user.dart';
import 'package:flutter/foundation.dart';
import '../../../core/network/api_client.dart';

class AuthState {
  final AppUser? user;
  final bool isLoading;
  final String? error;

  AuthState({this.user, this.isLoading = false, this.error});

  AuthState copyWith({
    AppUser? user,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    // Attempt to listen to Firebase Auth state if it's initialized
    try {
      FirebaseAuth.instance.authStateChanges().listen((User? firebaseUser) {
        if (firebaseUser != null) {
          state = state.copyWith(
            user: AppUser(
              id: firebaseUser.uid,
              email: firebaseUser.email ?? '',
              name: firebaseUser.displayName ?? 'User',
            ),
            isLoading: false,
          );
        } else {
          state = AuthState(); // reset to empty
        }
      });
    } catch (e) {
      debugPrint('Firebase not initialized yet. Using mock auth state.');
    }

    return AuthState();
  }

  Future<void> signIn(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await ApiClient.login(email, password);

      if (response['token'] != null) {
        ApiClient.authToken = response['token'];
        state = state.copyWith(
          user: AppUser(
            id: response['uid'],
            email: response['email'],
            name: '${response['firstName']} ${response['lastName']}',
          ),
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          error: response['error'] ?? 'Login failed',
          isLoading: false,
        );
      }
    } catch (e) {
      debugPrint('API Login Error: \$e');
      state = state.copyWith(error: 'Connection error', isLoading: false);
    }
  }

  Future<void> signUp({
    required String firstName,
    required String lastName,
    required String phone,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await ApiClient.register(
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        email: email,
        password: password,
      );

      if (response['token'] != null) {
        ApiClient.authToken = response['token'];
        state = state.copyWith(
          user: AppUser(
            id: response['uid'],
            email: response['email'],
            name: '${response['firstName']} ${response['lastName']}',
          ),
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          error: response['error'] ?? 'Registration failed',
          isLoading: false,
        );
      }
    } catch (e) {
      debugPrint('API Signup Error: \$e');
      state = state.copyWith(error: 'Connection error', isLoading: false);
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);
    try {
      // Firebase specific signout if mixed
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      debugPrint('FirebaseAuth signOut error (ignored): $e');
    }

    ApiClient.authToken = null;
    state = AuthState(); // Reset auth
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});
