import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/app.dart';

void main() {
  testWidgets('QueueLessApp widget test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: QueueLessApp()));

    // Verify it builds out the QueueLessApp properly
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
