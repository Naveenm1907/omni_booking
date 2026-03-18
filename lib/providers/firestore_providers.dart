import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/booking.dart';
import '../models/service.dart';
import '../services/firestore_service.dart';
import '../utils/demo_existing_bookings.dart';

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

/// Company-assignment demo mode:
/// when enabled, the app uses the provided "Existing Bookings" dataset so
/// availability is deterministic during review.
final demoModeProvider = StateProvider<bool>((ref) => true);

final servicesProvider = StreamProvider<List<Service>>((ref) {
  final firestore = ref.watch(firestoreServiceProvider);
  return firestore.watchServices();
});

final selectedDayProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
});

final bookingsForSelectedDayProvider = StreamProvider<List<Booking>>((ref) {
  final day = ref.watch(selectedDayProvider);
  final demoMode = ref.watch(demoModeProvider);
  if (demoMode) {
    return Stream.value(DemoExistingBookings.forDay(day));
  }

  final firestore = ref.watch(firestoreServiceProvider);
  return firestore.watchBookingsForDay(day);
});

