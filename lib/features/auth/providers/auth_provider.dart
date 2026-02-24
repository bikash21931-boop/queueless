import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../domain/app_user.dart';
import 'package:flutter/foundation.dart';

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
      // 1. Try Firebase Auth
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      debugPrint('FirebaseAuth error (falling back to mock): \$e');

      // Unconditional Fallback for Hackathon Demo UI Testing
      await Future.delayed(const Duration(seconds: 1));
      state = state.copyWith(
        user: AppUser(id: 'mock_user_123', email: email, name: 'Mock User'),
        isLoading: false,
      );
    }
  }

  Future<void> signUp(String email, String password, String name) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      await userCredential.user?.updateDisplayName(name);

      // We would normally also write this to our Firestore Users collection here

      state = state.copyWith(isLoading: false);
    } catch (e) {
      debugPrint('FirebaseAuth error (falling back to mock): \$e');

      // Unconditional Fallback for Hackathon Demo UI Testing
      await Future.delayed(const Duration(seconds: 1));
      state = state.copyWith(
        user: AppUser(id: 'mock_user_new', email: email, name: name),
        isLoading: false,
      );
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      // Mock fallback
    } finally {
      state = AuthState();
    }
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});
