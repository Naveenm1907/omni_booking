import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/firestore_providers.dart';
import '../providers/selected_services_provider.dart';
import '../widgets/responsive_container.dart';
import '../widgets/service_card.dart';
import 'time_slots_screen.dart';

class ServiceSelectionScreen extends ConsumerWidget {
  const ServiceSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servicesAsync = ref.watch(servicesProvider);
    final selected = ref.watch(selectedServicesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select services'),
        actions: [
          if (selected.selected.isNotEmpty)
            TextButton(
              onPressed: () => ref.read(selectedServicesProvider.notifier).clear(),
              child: const Text('Clear'),
            ),
        ],
      ),
      bottomNavigationBar: _BasketBar(
        totalDurationMinutes: selected.totalDurationMinutes,
        totalPriceCents: selected.totalPriceCents,
        enabled: selected.selected.isNotEmpty,
        onContinue: selected.selected.isEmpty
            ? null
            : () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => const TimeSlotsScreen(),
                  ),
                );
              },
      ),
      body: ResponsiveContainer(
        child: servicesAsync.when(
          data: (services) {
            if (services.isEmpty) {
              return const _EmptyState(
                title: 'No services yet',
                message: 'Seed data hasn’t loaded. Try restarting the app.',
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              itemCount: services.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final s = services[index];
                final isSelected = selected.selected.any((x) => x.id == s.id);
                return ServiceCard(
                  service: s,
                  selected: isSelected,
                  onTap: () => ref.read(selectedServicesProvider.notifier).toggle(s),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => _EmptyState(
            title: 'Failed to load services',
            message: e.toString(),
          ),
        ),
      ),
    );
  }
}

class _BasketBar extends StatelessWidget {
  final int totalDurationMinutes;
  final int totalPriceCents;
  final bool enabled;
  final VoidCallback? onContinue;

  const _BasketBar({
    required this.totalDurationMinutes,
    required this.totalPriceCents,
    required this.enabled,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: BoxDecoration(
          color: scheme.surface,
          border: Border(top: BorderSide(color: scheme.outlineVariant)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    enabled ? 'Basket' : 'Select at least one service',
                    style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    enabled
                        ? '$totalDurationMinutes min • ${_formatPrice(totalPriceCents)}'
                        : 'Duration and price update live',
                    style: textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurface.withValues(alpha: 0.75),
                    ),
                  ),
                ],
              ),
            ),
            FilledButton(
              onPressed: onContinue,
              child: const Text('Pick time'),
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
}

class _EmptyState extends StatelessWidget {
  final String title;
  final String message;

  const _EmptyState({required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

