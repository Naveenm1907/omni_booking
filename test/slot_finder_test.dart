import 'package:flutter_test/flutter_test.dart';
import 'package:omnibooking/models/booking.dart';
import 'package:omnibooking/utils/slot_finder.dart';

Booking _booking({
  required String id,
  required DateTime startAt,
  required int durationMinutes,
  required int counterId,
}) {
  return Booking(
    id: id,
    startAt: startAt,
    durationMinutes: durationMinutes,
    counterId: counterId,
    serviceIds: const <String>[],
    totalPriceCents: 0,
  );
}

void main() {
  test('critical: 60min at 10:00 AM must be blocked', () {
    final day = DateTime(2026, 3, 18);

    // Ensure that for 10:00-11:00 every counter has some overlap.
    final bookings = <Booking>[
      _booking(
        id: 'c0',
        startAt: DateTime(day.year, day.month, day.day, 9, 30),
        durationMinutes: 60, // 09:30-10:30 overlaps
        counterId: 0,
      ),
      _booking(
        id: 'c1',
        startAt: DateTime(day.year, day.month, day.day, 10, 0),
        durationMinutes: 30, // 10:00-10:30 overlaps
        counterId: 1,
      ),
      _booking(
        id: 'c2',
        startAt: DateTime(day.year, day.month, day.day, 10, 30),
        durationMinutes: 30, // 10:30-11:00 overlaps
        counterId: 2,
      ),
    ];

    final slots = const SlotFinder().findSlotsForDay(
      day: day,
      durationMinutes: 60,
      existingBookings: bookings,
    );

    final tenAm = DateTime(day.year, day.month, day.day, 10, 0);
    final slotAtTen = slots.firstWhere((s) => s.startAt == tenAm);
    expect(slotAtTen.isAvailable, isFalse);
    expect(slotAtTen.counterId, isNull);
    expect(slotAtTen.availableCounterCount, 0);
  });

  test('boundary: booking ending at 10:00 does not block 10:00', () {
    final day = DateTime(2026, 3, 18);
    final bookings = <Booking>[
      _booking(
        id: 'c0',
        startAt: DateTime(day.year, day.month, day.day, 9, 0),
        durationMinutes: 60, // 09:00-10:00 ends exactly at 10:00
        counterId: 0,
      ),
    ];

    final slots = const SlotFinder().findSlotsForDay(
      day: day,
      durationMinutes: 60,
      existingBookings: bookings,
    );

    final tenAm = DateTime(day.year, day.month, day.day, 10, 0);
    final slotAtTen = slots.firstWhere((s) => s.startAt == tenAm);
    expect(slotAtTen.isAvailable, isTrue);
    expect(slotAtTen.availableCounterCount, greaterThan(0));
  });

  test('assigns another counter when first is blocked', () {
    final day = DateTime(2026, 3, 18);
    final bookings = <Booking>[
      _booking(
        id: 'c0',
        startAt: DateTime(day.year, day.month, day.day, 10, 0),
        durationMinutes: 60,
        counterId: 0, // blocks counter 0 only
      ),
    ];

    final slots = const SlotFinder().findSlotsForDay(
      day: day,
      durationMinutes: 60,
      existingBookings: bookings,
    );

    final tenAm = DateTime(day.year, day.month, day.day, 10, 0);
    final slotAtTen = slots.firstWhere((s) => s.startAt == tenAm);
    expect(slotAtTen.isAvailable, isTrue);
    expect(slotAtTen.counterId, isNot(0));
    expect(slotAtTen.availableCounterCount, 2);
  });
}

