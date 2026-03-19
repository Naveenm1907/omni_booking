import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/booking_draft_provider.dart';
import '../providers/selected_services_provider.dart';
import '../utils/money.dart';
import '../widgets/responsive_container.dart';
import 'booking_history_screen.dart';

class BookingConfirmationScreen extends ConsumerStatefulWidget {
  const BookingConfirmationScreen({super.key});

  @override
  ConsumerState<BookingConfirmationScreen> createState() =>
      _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState
    extends ConsumerState<BookingConfirmationScreen> {
  bool _submitting = false;

  @override
  Widget build(BuildContext context) {
    final selected = ref.watch(selectedServicesProvider);
    final draft = ref.watch(bookingDraftProvider);

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
                Icons.check_circle_outline,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Flexible(
              child: Text(
                'Confirm Booking',
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
          // Compact booking summary
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
                  Icons.currency_rupee,
                  color: Theme.of(context).colorScheme.primary,
                  size: 14,
                ),
                Text(
                  Money.formatRupeesFromCents(selected.totalPriceCents),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          // Info menu
          if (!_submitting)
            PopupMenuButton<String>(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.info_outline, size: 20, color: Colors.white),
              ),
              tooltip: 'Booking Details',
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'details',
                  child: Row(
                    children: [
                      Icon(Icons.receipt_long, size: 20),
                      SizedBox(width: 12),
                      Text('View Summary'),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                if (value == 'details') {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Booking Summary'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Services: ${selected.selected.map((s) => s.name).join(', ')}'),
                          const SizedBox(height: 8),
                          Text('Duration: ${selected.totalDurationMinutes} minutes'),
                          const SizedBox(height: 8),
                          Text('Total: ${Money.formatRupeesFromCents(selected.totalPriceCents)}'),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
          const SizedBox(width: 4),
        ],
      ),
      body: ResponsiveContainer(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _SummaryTile(
              title: 'Services',
              value: selected.selected.isEmpty
                  ? 'None'
                  : selected.selected.map((s) => s.name).join(', '),
            ),
            const SizedBox(height: 12),
            _SummaryTile(
              title: 'Duration',
              value: '${selected.totalDurationMinutes} minutes',
            ),
            const SizedBox(height: 12),
            _SummaryTile(
              title: 'Total',
              value: Money.formatRupeesFromCents(selected.totalPriceCents),
            ),
            const SizedBox(height: 12),
            _SummaryTile(
              title: 'Time',
              value: draft.startAt == null ? 'Not selected' : _formatDateTime(draft.startAt!),
            ),
            const SizedBox(height: 12),
            _SummaryTile(
              title: 'Counter',
              value: draft.counterId == null ? 'Not assigned' : 'Counter ${draft.counterId! + 1}',
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _submitting
                  ? null
                  : () async {
                      final messenger = ScaffoldMessenger.of(context);
                      setState(() => _submitting = true);
                      try {
                        await ref.read(bookingDraftProvider.notifier).submit();
                        ref.read(selectedServicesProvider.notifier).clear();
                        ref.read(bookingDraftProvider.notifier).clearSlot();
                        if (!context.mounted) return;
                        final navigator = Navigator.of(context);
                        await showDialog<void>(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => AlertDialog(
                            title: const Text('Booking created'),
                            content: const Text(
                              'Your booking was saved successfully.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  navigator.push(
                                    MaterialPageRoute<void>(
                                      builder: (context) =>
                                          const BookingHistoryScreen(),
                                    ),
                                  );
                                },
                                child: const Text('View history'),
                              ),
                              FilledButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  navigator.popUntil((r) => r.isFirst);
                                },
                                child: const Text('Done'),
                              ),
                            ],
                          ),
                        );
                      } catch (e) {
                        if (!context.mounted) return;
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(
                              'Booking saved locally (Firestore unreachable or blocked).\n\n$e',
                            ),
                          ),
                        );
                      } finally {
                        if (mounted) setState(() => _submitting = false);
                      }
                    },
              child: Text(_submitting ? 'Submitting…' : 'Confirm'),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatDateTime(DateTime dt) {
    final h = dt.hour;
    final m = dt.minute.toString().padLeft(2, '0');
    final suffix = h >= 12 ? 'PM' : 'AM';
    final hour12 = ((h + 11) % 12) + 1;
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}  $hour12:$m $suffix';
  }
}

class _SummaryTile extends StatelessWidget {
  final String title;
  final String value;

  const _SummaryTile({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .labelLarge
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }
}

