// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:omnibooking/screens/service_selection_screen.dart';

// Mock Firebase for testing
void setupFirebaseAuthMocks() {
  // This is a simple mock setup for testing
  // In a real app, you'd use firebase_auth_mocks or similar
}

void main() {
  setUpAll(() async {
    setupFirebaseAuthMocks();
  });

  testWidgets('OmniBooking app loads correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: ServiceSelectionScreen()),
      ),
    );

    // Verify that our initial screen loads
    expect(find.text('Select services'), findsOneWidget);
  });
}
