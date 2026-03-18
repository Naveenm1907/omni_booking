import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/booking.dart';
import '../models/service.dart';

class FirestoreService {
  final FirebaseFirestore _db;

  FirestoreService({FirebaseFirestore? db}) : _db = db ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _services =>
      _db.collection('services');

  CollectionReference<Map<String, dynamic>> get _bookings =>
      _db.collection('bookings');

  Stream<List<Service>> watchServices() {
    return _services.snapshots().map(
          (snapshot) => snapshot.docs
              .map((d) => Service.fromMap(d.id, d.data()))
              .toList(growable: false),
        );
  }

  Stream<List<Booking>> watchBookingsForDay(DateTime day) {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));

    return _bookings
        .where('startAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('startAt', isLessThan: Timestamp.fromDate(end))
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((d) => Booking.fromMap(d.id, d.data()))
              .toList(growable: false),
        );
  }

  Future<DocumentReference<Map<String, dynamic>>> createBooking(Booking booking) {
    return _bookings.add(booking.toMap());
  }

  Future<void> seedServicesIfEmpty(List<Service> services) async {
    final existing = await _services.limit(1).get();
    if (existing.docs.isNotEmpty) return;

    final batch = _db.batch();
    for (final s in services) {
      batch.set(_services.doc(s.id), s.toMap());
    }
    await batch.commit();
  }
}

