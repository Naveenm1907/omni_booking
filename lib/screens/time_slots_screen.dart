import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/time_slot.dart';
import '../providers/booking_draft_provider.dart';
import '../providers/firestore_providers.dart';
import '../providers/selected_services_provider.dart';
import '../utils/money.dart';
import '../utils/slot_finder.dart';
import '../widgets/responsive_container.dart';
import '../widgets/slot_tile.dart';
import 'booking_confirmation_screen.dart';

final availableSlotsProvider = Provider<List<TimeSlot>>((ref) {
  final durationMinutes = ref.watch(selectedServicesProvider).totalDurationMinutes;
  final bookingsAsync = ref.watch(bookingsForSelectedDayProvider);
  final day = ref.watch(selectedDayProvider);

  return bookingsAsync.maybeWhen(
    data: (bookings) {
      if (durationMinutes <= 0) return const <TimeSlot>[];
      return const SlotFinder().findSlotsForDay(
        day: day,
        durationMinutes: durationMinutes,
        existingBookings: bookings,
      );
    },
    orElse: () => const <TimeSlot>[],
  );
});

class TimeSlotsScreen extends ConsumerWidget {
  const TimeSlotsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedServices = ref.watch(selectedServicesProvider);
    final slots = ref.watch(availableSlotsProvider);
    final draft = ref.watch(bookingDraftProvider);
    final selectedDay = ref.watch(selectedDayProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.schedule,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Flexible(
              child: Text(
                'Select Time',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        actions: [
          // Compact info badges
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.schedule,
                  color: Theme.of(context).colorScheme.primary,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  '${selectedServices.totalDurationMinutes}min',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          // Direct calendar button
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.calendar_month, size: 20, color: Colors.white),
              ),
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDay,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 90)),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: Theme.of(context).colorScheme.copyWith(
                          primary: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (picked == null) return;
                ref.read(selectedDayProvider.notifier).state =
                    DateTime(picked.year, picked.month, picked.day);
                ref.read(bookingDraftProvider.notifier).clearSlot();
              },
              tooltip: 'Change Date',
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  width: 1,
                ),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                _formatDay(selectedDay),
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              const Spacer(),
                              // Quick date navigation
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: selectedDay.isAfter(DateTime.now()) 
                                        ? () {
                                            final newDate = selectedDay.subtract(const Duration(days: 1));
                                            if (!newDate.isBefore(DateTime.now())) {
                                              ref.read(selectedDayProvider.notifier).state = newDate;
                                              ref.read(bookingDraftProvider.notifier).clearSlot();
                                            }
                                          }
                                        : null,
                                    icon: Icon(
                                      Icons.chevron_left,
                                      color: selectedDay.isAfter(DateTime.now()) 
                                          ? Theme.of(context).colorScheme.primary
                                          : Colors.grey.shade400,
                                    ),
                                    tooltip: 'Previous Day',
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      final newDate = selectedDay.add(const Duration(days: 1));
                                      if (!newDate.isAfter(DateTime.now().add(const Duration(days: 90)))) {
                                        ref.read(selectedDayProvider.notifier).state = newDate;
                                        ref.read(bookingDraftProvider.notifier).clearSlot();
                                      }
                                    },
                                    icon: Icon(
                                      Icons.chevron_right,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                    tooltip: 'Next Day',
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${selectedServices.selected.length} service${selectedServices.selected.length == 1 ? '' : 's'} • ${selectedServices.totalDurationMinutes}min',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      Money.formatRupeesFromCents(selectedServices.totalPriceCents),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ResponsiveContainer(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: selectedServices.totalDurationMinutes <= 0
                    ? const Center(child: Text('Please select services first'))
                    : slots.isEmpty
                        ? const Center(child: Text('No available slots'))
                        : GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 2.4,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                            itemCount: slots.length,
                            itemBuilder: (context, index) {
                              final slot = slots[index];
                              final isSelected = draft.startAt == slot.startAt;

                              return SlotTile(
                                slot: slot,
                                isSelected: isSelected,
                                onTap: () {
                                  if (!slot.isAvailable || slot.counterId == null) {
                                    return;
                                  }
                                  ref.read(bookingDraftProvider.notifier).selectSlot(
                                        startAt: slot.startAt,
                                        counterId: slot.counterId!,
                                      );
                                },
                              );
                            },
                          ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: (draft.startAt != null && draft.counterId != null)
          ? Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border(
                  top: BorderSide(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _formatTime(draft.startAt!),
                            style:
                                Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(
                                Icons.check_circle_outline,
                                size: 16,
                                color: Colors.green.shade600,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  'Counter ${draft.counterId! + 1}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: Colors.green.shade600,
                                        fontWeight: FontWeight.w500,
                                      ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    FilledButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (context) => const BookingConfirmationScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('Continue'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }

  static String _formatShortDate(DateTime day) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[day.month - 1]} ${day.day}';
  }

  static String _formatDay(DateTime day) {
    return '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
  }

  static String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final displayMinute =
        minute == 0 ? '00' : minute.toString().padLeft(2, '0');
    return '$displayHour:$displayMinute $period';
  }
}

