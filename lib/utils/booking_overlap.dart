import '../models/booking.dart';
import 'time_range.dart';

TimeRange bookingTimeRange(Booking booking) {
  return TimeRange(start: booking.startAt, end: booking.endAt);
}

bool bookingOverlapsRange(Booking booking, TimeRange range) {
  return bookingTimeRange(booking).overlaps(range);
}

