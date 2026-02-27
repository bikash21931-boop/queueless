import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Note: Before running, ensure to configure Firebase via flutterfire configure
  // try {
  //   await Firebase.initializeApp();
  // } catch (e) {
  //   debugPrint('Firebase not initialized: $e');
  // }

  runApp(const ProviderScope(child: QueueLessApp()));
}