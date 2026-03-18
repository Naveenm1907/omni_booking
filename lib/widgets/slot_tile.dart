import 'package:flutter/material.dart';

import '../models/time_slot.dart';

class SlotTile extends StatelessWidget {
  final TimeSlot slot;
  final bool selected;
  final VoidCallback? onTap;

  const SlotTile({
    super.key,
    required this.slot,
    required this.selected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isEnabled = slot.isAvailable;

    final Color bg;
    final Color fg;
    if (!isEnabled) {
      bg = scheme.surfaceContainerHighest.withValues(alpha: 0.6);
      fg = scheme.onSurface.withValues(alpha: 0.45);
    } else if (selected) {
      bg = scheme.primaryContainer;
      fg = scheme.onPrimaryContainer;
    } else {
      bg = scheme.surfaceContainerHighest;
      fg = scheme.onSurface;
    }

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: isEnabled ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _formatTime(slot.startAt),
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(color: fg, fontWeight: FontWeight.w700),
                ),
              ),
              if (!isEnabled)
                Icon(Icons.block, size: 18, color: fg)
              else if (selected)
                Icon(Icons.check, size: 18, color: fg)
              else
                Icon(Icons.chevron_right, size: 18, color: fg.withValues(alpha: 0.7)),
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

