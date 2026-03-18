import '../models/booking.dart';
import '../models/time_slot.dart';
import 'booking_constants.dart';
import 'booking_overlap.dart';
import 'time_range.dart';

class SlotFinder {
  const SlotFinder();

  List<TimeSlot> findSlotsForDay({
    required DateTime day,
    required int durationMinutes,
    required List<Booking> existingBookings,
    int openingHour = BookingConstants.openingHour,
    int closingHour = BookingConstants.closingHour,
    int intervalMinutes = BookingConstants.slotIntervalMinutes,
    int counters = BookingConstants.counters,
  }) {
    final startOfDay = DateTime(day.year, day.month, day.day);
    final openAt = DateTime(
      startOfDay.year,
      startOfDay.month,
      startOfDay.day,
      openingHour,
    );
    final closeAt = DateTime(
      startOfDay.year,
      startOfDay.month,
      startOfDay.day,
      closingHour,
    );

    final duration = Duration(minutes: durationMinutes);
    final slots = <TimeSlot>[];

    for (var start = openAt;
        !start.add(duration).isAfter(closeAt);
        start = start.add(Duration(minutes: intervalMinutes))) {
      final end = start.add(duration);
      final range = TimeRange(start: start, end: end);

      int? assignedCounterId;
      for (var counterId = 0; counterId < counters; counterId++) {
        final hasOverlapOnThisCounter = existingBookings
            .where((b) => b.counterId == counterId)
            .any((b) => bookingOverlapsRange(b, range));
        if (!hasOverlapOnThisCounter) {
          assignedCounterId = counterId;
          break;
        }
      }

      slots.add(
        TimeSlot(
          startAt: start,
          endAt: end,
          isAvailable: assignedCounterId != null,
          counterId: assignedCounterId,
        ),
      );
    }

    return slots;
  }
}

