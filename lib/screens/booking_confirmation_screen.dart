import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/booking_draft_provider.dart';
import '../providers/selected_services_provider.dart';
import '../widgets/responsive_container.dart';

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
      appBar: AppBar(title: const Text('Confirm booking')),
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
              value: _formatPrice(selected.totalPriceCents),
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
                      final navigator = Navigator.of(context);
                      setState(() => _submitting = true);
                      try {
                        await ref.read(bookingDraftProvider.notifier).submit();
                        ref.read(selectedServicesProvider.notifier).clear();
                        ref.read(bookingDraftProvider.notifier).clearSlot();
                        messenger.showSnackBar(
                          const SnackBar(content: Text('Booking created')),
                        );
                        navigator.popUntil((r) => r.isFirst);
                      } catch (e) {
                        messenger.showSnackBar(
                          SnackBar(content: Text(e.toString())),
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

  static String _formatPrice(int cents) {
    final value = cents / 100.0;
    return '\$${value.toStringAsFixed(2)}';
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

