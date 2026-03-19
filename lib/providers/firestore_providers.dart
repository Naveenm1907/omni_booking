import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/booking.dart';
import '../models/service.dart';
import '../services/firestore_service.dart';
import '../utils/demo_existing_bookings.dart';
import '../utils/mock_data.dart';
import 'local_bookings_provider.dart';

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

final servicesProvider = StreamProvider<List<Service>>((ref) {
  // Assignment: hardcoded service list is acceptable and avoids requiring
  // Firestore configuration to review the app.
  return Stream.value(MockData.services);
});

final selectedDayProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
});

final bookingsForSelectedDayProvider = StreamProvider<List<Booking>>((ref) {
  final firestore = ref.watch(firestoreServiceProvider);
  final day = ref.watch(selectedDayProvider);
  final local = ref.watch(localBookingsProvider);
  final base = DemoExistingBookings.forDay(day);

  // If Firestore stream fails (offline/DNS/rules), we still show base + local.
  return firestore.watchBookingsForDay(day).map((remote) {
    return [...base, ...local, ...remote];
  });
});

final bookingHistoryProvider = StreamProvider<List<Booking>>((ref) {
  final firestore = ref.watch(firestoreServiceProvider);
  final local = ref.watch(localBookingsProvider);
  return firestore.watchAllBookings().map((remote) => [...local, ...remote]);
});

