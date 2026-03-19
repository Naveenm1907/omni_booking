class TimeSlot {
  final DateTime startAt;
  final DateTime endAt;

  /// Null means “no assignment yet” (useful before we run the counter allocator).
  final int? counterId;

  /// When false, the slot should be rendered as blocked/unavailable.
  final bool isAvailable;

  /// How many counters can accommodate the entire slot duration.
  final int availableCounterCount;

  const TimeSlot({
    required this.startAt,
    required this.endAt,
    required this.isAvailable,
    required this.availableCounterCount,
    this.counterId,
  });

  Duration get duration => endAt.difference(startAt);

  bool get isPeakTime {
    // Simple peak window for UX: 11 AM–2 PM.
    return startAt.hour >= 11 && startAt.hour < 14;
  }

  String get capacityStatus {
    if (!isAvailable) return 'Full';
    if (availableCounterCount >= 3) return 'Plenty';
    if (availableCounterCount == 2) return 'Good';
    return 'Limited';
  }
}

