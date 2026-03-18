import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/booking.dart';
import 'firestore_providers.dart';
import 'selected_services_provider.dart';

class BookingDraftState {
  final DateTime? startAt;
  final int? counterId;

  const BookingDraftState({
    required this.startAt,
    required this.counterId,
  });
}

class BookingDraftNotifier extends Notifier<BookingDraftState> {
  @override
  BookingDraftState build() {
    return const BookingDraftState(startAt: null, counterId: null);
  }

  void selectSlot({required DateTime startAt, required int counterId}) {
    state = BookingDraftState(startAt: startAt, counterId: counterId);
  }

  void clearSlot() {
    state = const BookingDraftState(startAt: null, counterId: null);
  }

  Future<void> submit() async {
    final startAt = state.startAt;
    final counterId = state.counterId;
    if (startAt == null || counterId == null) {
      throw StateError('Select a time slot before submitting.');
    }

    final selected = ref.read(selectedServicesProvider);
    if (selected.selected.isEmpty) {
      throw StateError('Select at least one service before submitting.');
    }

    final demoMode = ref.read(demoModeProvider);
    if (demoMode) {
      // Company assignment: keep the review deterministic and avoid requiring
      // Firebase auth/rules setup just to demonstrate the algorithm + UX.
      await Future<void>.delayed(const Duration(milliseconds: 250));
      return;
    }

    final firestore = ref.read(firestoreServiceProvider);
    final booking = Booking(
      id: '',
      startAt: startAt,
      durationMinutes: selected.totalDurationMinutes,
      counterId: counterId,
      serviceIds: selected.serviceIds,
      totalPriceCents: selected.totalPriceCents,
    );

    await firestore.createBooking(booking);
  }
}

final bookingDraftProvider =
    NotifierProvider<BookingDraftNotifier, BookingDraftState>(
  BookingDraftNotifier.new,
);

