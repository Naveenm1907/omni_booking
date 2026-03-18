import '../models/booking.dart';

/// The exact mock dataset provided in the company assignment:
/// - Counter 1: 10:00–11:00
/// - Counter 2: 10:30–11:30
/// - Counter 3: 09:00–10:30
class DemoExistingBookings {
  static List<Booking> forDay(DateTime day) {
    final d = DateTime(day.year, day.month, day.day);
    return <Booking>[
      Booking(
        id: 'demo_c0',
        startAt: DateTime(d.year, d.month, d.day, 10, 0),
        durationMinutes: 60,
        counterId: 0,
        serviceIds: const <String>[],
        totalPriceCents: 0,
      ),
      Booking(
        id: 'demo_c1',
        startAt: DateTime(d.year, d.month, d.day, 10, 30),
        durationMinutes: 60,
        counterId: 1,
        serviceIds: const <String>[],
        totalPriceCents: 0,
      ),
      Booking(
        id: 'demo_c2',
        startAt: DateTime(d.year, d.month, d.day, 9, 0),
        durationMinutes: 90,
        counterId: 2,
        serviceIds: const <String>[],
        totalPriceCents: 0,
      ),
    ];
  }
}

