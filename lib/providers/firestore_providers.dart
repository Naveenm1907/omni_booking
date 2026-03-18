import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/booking.dart';
import '../models/service.dart';
import '../services/firestore_service.dart';

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

final servicesProvider = StreamProvider<List<Service>>((ref) {
  final firestore = ref.watch(firestoreServiceProvider);
  return firestore.watchServices();
});

final selectedDayProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
});

final bookingsForSelectedDayProvider = StreamProvider<List<Booking>>((ref) {
  final firestore = ref.watch(firestoreServiceProvider);
  final day = ref.watch(selectedDayProvider);
  return firestore.watchBookingsForDay(day);
});

