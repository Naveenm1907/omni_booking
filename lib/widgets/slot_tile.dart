import 'package:flutter/material.dart';

import '../models/time_slot.dart';

class SlotTile extends StatelessWidget {
  final TimeSlot slot;
  final bool isSelected;
  final VoidCallback onTap;

  const SlotTile({
    super.key,
    required this.slot,
    required this.isSelected,
    required this.onTap,
  });

  Color _getSlotColor(BuildContext context) {
    if (!slot.isAvailable) return Colors.red.shade100;
    if (isSelected) {
      return Theme.of(context).colorScheme.primary.withValues(alpha: 0.12);
    }
    if (slot.isPeakTime) return Colors.purple.shade50;
    if (slot.availableCounterCount == 3) return Colors.green.shade100;
    if (slot.availableCounterCount >= 1) return Colors.orange.shade100;
    return Colors.grey.shade200;
  }

  Color _getBorderColor(BuildContext context) {
    if (!slot.isAvailable) return Colors.red;
    if (isSelected) return Theme.of(context).colorScheme.primary;
    if (slot.isPeakTime && slot.isAvailable) return Colors.purple.shade400;
    if (slot.availableCounterCount == 3) return Colors.green;
    if (slot.availableCounterCount >= 1) return Colors.orange;
    return Colors.grey;
  }

  String get _statusText {
    if (!slot.isAvailable) return 'Full';
    if (slot.isPeakTime) return 'Peak';
    return slot.capacityStatus;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(12),
      elevation: slot.isAvailable ? (isSelected ? 4 : 1) : 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: slot.isAvailable ? onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getSlotColor(context),
            border: Border.all(
              color: _getBorderColor(context),
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      _formatTime(slot.startAt),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight:
                                isSelected ? FontWeight.bold : FontWeight.w600,
                            fontSize: 14,
                            color: slot.isAvailable
                                ? Theme.of(context).colorScheme.onSurface
                                : Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.6),
                          ),
                    ),
                  ),
                  if (slot.isPeakTime && slot.isAvailable)
                    Container(
                      margin: const EdgeInsets.only(left: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade600,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'PEAK',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 7,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      _statusText,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: slot.isAvailable
                                ? _getBorderColor(context)
                                : Theme.of(context).colorScheme.error,
                            fontWeight: FontWeight.w500,
                            fontSize: 11,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (slot.isAvailable)
                    Text(
                      '${slot.availableCounterCount} left',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: slot.isPeakTime
                                ? Colors.orange.shade700
                                : Colors.green.shade700,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _formatTime(DateTime dt) {
    final h = dt.hour;
    final m = dt.minute.toString().padLeft(2, '0');
    final suffix = h >= 12 ? 'PM' : 'AM';
    final hour12 = ((h + 11) % 12) + 1;
    return '$hour12:$m $suffix';
  }
}

