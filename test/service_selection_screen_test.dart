import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:omnibooking/models/service.dart';
import 'package:omnibooking/providers/firestore_providers.dart';
import 'package:omnibooking/screens/service_selection_screen.dart';

void main() {
  testWidgets('service selection updates basket totals', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          servicesProvider.overrideWith((ref) => Stream.value(const <Service>[
                Service(
                    id: 's1', name: 'Cut', durationMinutes: 30, priceCents: 1500),
                Service(
                    id: 's2',
                    name: 'Shave',
                    durationMinutes: 15,
                    priceCents: 800),
              ])),
        ],
        child: const MaterialApp(home: ServiceSelectionScreen()),
      ),
    );

    await tester.pump();

    expect(find.text('Continue'), findsOneWidget);

    await tester.tap(find.text('Cut'));
    await tester.pump();

    expect(find.textContaining('30 min'), findsOneWidget);
    expect(find.textContaining('₹15'), findsOneWidget);
  });
}

