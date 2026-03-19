import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/booking.dart';

class LocalBookingsNotifier extends Notifier<List<Booking>> {
  @override
  List<Booking> build() => const <Booking>[];

  void add(Booking booking) {
    // Put newest first for history UX.
    state = [booking, ...state];
  }

  void clear() {
    state = const <Booking>[];
  }
}

final localBookingsProvider =
    NotifierProvider<LocalBookingsNotifier, List<Booking>>(
  LocalBookingsNotifier.new,
);

