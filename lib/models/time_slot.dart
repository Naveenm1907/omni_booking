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
}

