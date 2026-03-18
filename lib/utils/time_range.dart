class TimeRange {
  final DateTime start;
  final DateTime end;

  TimeRange({required this.start, required this.end})
      : assert(!end.isBefore(start), 'end must be >= start');

  Duration get duration => end.difference(start);

  bool overlaps(TimeRange other) {
    // Half-open intervals: [start, end)
    return start.isBefore(other.end) && end.isAfter(other.start);
  }
}

