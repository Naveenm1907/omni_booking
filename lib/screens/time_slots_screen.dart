import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/time_slot.dart';
import '../providers/booking_draft_provider.dart';
import '../providers/firestore_providers.dart';
import '../providers/selected_services_provider.dart';
import '../utils/slot_finder.dart';
import '../widgets/responsive_container.dart';
import '../widgets/slot_tile.dart';
import 'booking_confirmation_screen.dart';

final availableSlotsProvider = Provider<AsyncValue<List<TimeSlot>>>((ref) {
  final durationMinutes = ref.watch(selectedServicesProvider).totalDurationMinutes;
  final bookingsAsync = ref.watch(bookingsForSelectedDayProvider);
  final day = ref.watch(selectedDayProvider);

  return bookingsAsync.whenData((bookings) {
    if (durationMinutes <= 0) return const <TimeSlot>[];
    return const SlotFinder().findSlotsForDay(
      day: day,
      durationMinutes: durationMinutes,
      existingBookings: bookings,
    );
  });
});

class TimeSlotsScreen extends ConsumerWidget {
  const TimeSlotsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedServices = ref.watch(selectedServicesProvider);
    final slotsAsync = ref.watch(availableSlotsProvider);
    final draft = ref.watch(bookingDraftProvider);
    final selectedDay = ref.watch(selectedDayProvider);
    final demoMode = ref.watch(demoModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick a time'),
        actions: [
          Row(
            children: [
              Text(
                'Demo',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              Switch(
                value: demoMode,
                onChanged: (v) {
                  ref.read(demoModeProvider.notifier).state = v;
                  ref.read(bookingDraftProvider.notifier).clearSlot();
                },
              ),
            ],
          ),
          TextButton.icon(
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
                initialDate: selectedDay,
              );
              if (picked == null) return;
              ref.read(selectedDayProvider.notifier).state =
                  DateTime(picked.year, picked.month, picked.day);
              ref.read(bookingDraftProvider.notifier).clearSlot();
            },
            icon: const Icon(Icons.edit_calendar),
            label: const Text('Day'),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            onPressed: (draft.startAt != null && draft.counterId != null)
                ? () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const BookingConfirmationScreen(),
                      ),
                    );
                  }
                : null,
            child: const Text('Review booking'),
          ),
        ),
      ),
      body: ResponsiveContainer(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${selectedServices.totalDurationMinutes} min • ${_formatPrice(selectedServices.totalPriceCents)}',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                _formatDay(selectedDay),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.75),
                    ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: slotsAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text('Failed to load availability.\n\n$e'),
                    ),
                  ),
                  data: (slots) {
                    if (selectedServices.totalDurationMinutes <= 0) {
                      return const Center(child: Text('Select services first.'));
                    }
                    if (slots.isEmpty) {
                      return const Center(child: Text('No slots available.'));
                    }
                    return GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: 3.3,
                      ),
                      itemCount: slots.length,
                      itemBuilder: (context, index) {
                        final slot = slots[index];
                        final selected = draft.startAt == slot.startAt;
                        return SlotTile(
                          slot: slot,
                          selected: selected,
                          onTap: slot.isAvailable && slot.counterId != null
                              ? () => ref
                                  .read(bookingDraftProvider.notifier)
                                  .selectSlot(
                                    startAt: slot.startAt,
                                    counterId: slot.counterId!,
                                  )
                              : null,
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _formatPrice(int cents) {
    final value = cents / 100.0;
    return '\$${value.toStringAsFixed(2)}';
  }

  static String _formatDay(DateTime day) {
    return '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
  }
}

