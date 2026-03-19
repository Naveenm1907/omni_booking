import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/booking.dart';
import '../providers/firestore_providers.dart';
import '../utils/money.dart';
import '../utils/mock_data.dart';

// Filter state provider
final bookingFilterProvider = StateProvider<String>((ref) => 'all');

class BookingHistoryScreen extends ConsumerWidget {
  const BookingHistoryScreen({super.key});

  List<Booking> _filterBookings(List<Booking> bookings, String filter) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Week: Monday to Sunday of current week
    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
    
    // Month: First day to last day of current month
    final monthStart = DateTime(now.year, now.month, 1);
    final monthEnd = DateTime(now.year, now.month + 1, 1).subtract(const Duration(milliseconds: 1));

    print('Filter: $filter, Today: $today, Total bookings: ${bookings.length}');
    print('Week range: $weekStart to $weekEnd');
    print('Month range: $monthStart to $monthEnd');

    switch (filter) {
      case 'today':
        final todayBookings = bookings.where((booking) {
          final bookingDate = DateTime(
            booking.startAt.year,
            booking.startAt.month,
            booking.startAt.day,
          );
          final isToday = bookingDate.isAtSameMomentAs(today);
          print('Booking date: $bookingDate, Is today: $isToday');
          return isToday;
        }).toList();
        print('Today bookings found: ${todayBookings.length}');
        return todayBookings;
        
      case 'week':
        final weekBookings = bookings.where((booking) {
          final isInWeek = booking.startAt.isAfter(weekStart.subtract(const Duration(milliseconds: 1))) &&
                          booking.startAt.isBefore(weekEnd.add(const Duration(milliseconds: 1)));
          print('Booking: ${booking.startAt}, In this week: $isInWeek');
          return isInWeek;
        }).toList();
        print('Week bookings found: ${weekBookings.length}');
        return weekBookings;
        
      case 'month':
        final monthBookings = bookings.where((booking) {
          final isInMonth = booking.startAt.isAfter(monthStart.subtract(const Duration(milliseconds: 1))) &&
                           booking.startAt.isBefore(monthEnd.add(const Duration(milliseconds: 1)));
          print('Booking: ${booking.startAt}, In this month: $isInMonth');
          return isInMonth;
        }).toList();
        print('Month bookings found: ${monthBookings.length}');
        return monthBookings;
        
      default:
        print('All bookings returned: ${bookings.length}');
        return bookings;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(bookingHistoryProvider);
    final currentFilter = ref.watch(bookingFilterProvider);

    String _getFilterDisplayName(String filter) {
      switch (filter) {
        case 'today':
          return 'Today';
        case 'week':
          return 'This Week';
        case 'month':
          return 'This Month';
        default:
          return 'All';
      }
    }

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
                Icons.history,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Flexible(
              child: Text(
                'Booking History',
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
          // Current filter display
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: Text(
              _getFilterDisplayName(currentFilter),
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
          // Filter and options menu
          PopupMenuButton<String>(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.filter_list, size: 20, color: Colors.white),
            ),
            tooltip: 'Filter & Options',
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'refresh',
                child: Row(
                  children: [
                    Icon(Icons.refresh, size: 20),
                    SizedBox(width: 12),
                    Text('Refresh'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'all',
                child: Row(
                  children: [
                    Icon(
                      currentFilter == 'all' ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    const Text('All Bookings'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'today',
                child: Row(
                  children: [
                    Icon(
                      currentFilter == 'today' ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    const Text('Today'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'week',
                child: Row(
                  children: [
                    Icon(
                      currentFilter == 'week' ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    const Text('This Week'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'month',
                child: Row(
                  children: [
                    Icon(
                      currentFilter == 'month' ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    const Text('This Month'),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              switch (value) {
                case 'refresh':
                  ref.invalidate(bookingHistoryProvider);
                  break;
                case 'all':
                case 'today':
                case 'week':
                case 'month':
                  ref.read(bookingFilterProvider.notifier).state = value;
                  break;
              }
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: bookingsAsync.when(
        data: (allBookings) {
          final filteredBookings = _filterBookings(allBookings, currentFilter);
          
          if (filteredBookings.isEmpty) {
            return _empty(context, currentFilter);
          }
          
          final grouped = _groupByDay(filteredBookings);
          final keys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: keys.length,
            itemBuilder: (context, index) {
              final key = keys[index];
              final dayBookings = grouped[key]!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _dateHeader(context, key),
                  const SizedBox(height: 8),
                  ...dayBookings.map((b) => _bookingCard(context, b)),
                  const SizedBox(height: 16),
                ],
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _error(context, e.toString()),
      ),
    );
  }

  static Widget _empty(BuildContext context, String filter) {
    String title = 'No Bookings';
    String subtitle = 'Your booking history will appear here';
    
    switch (filter) {
      case 'today':
        title = 'No Bookings Today';
        subtitle = 'You have no bookings scheduled for today';
        break;
      case 'week':
        title = 'No Bookings This Week';
        subtitle = 'You have no bookings scheduled for this week';
        break;
      case 'month':
        title = 'No Bookings This Month';
        subtitle = 'You have no bookings scheduled for this month';
        break;
      default:
        title = 'No Bookings Yet';
        subtitle = 'Your booking history will appear here';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  static Widget _error(BuildContext context, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: Colors.red[400]),
            const SizedBox(height: 16),
            Text(
              'Error Loading Bookings',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(color: Colors.red[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  static Widget _dateHeader(BuildContext context, String dateKey) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(Icons.calendar_today,
              size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            dateKey,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
        ],
      ),
    );
  }

  static Widget _bookingCard(BuildContext context, Booking booking) {
    final startTime = _formatTime(booking.startAt);
    final endTime = _formatTime(booking.endAt);
    final services = MockData.services
        .where((s) => booking.serviceIds.contains(s.id))
        .toList(growable: false);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$startTime - $endTime',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Counter ${booking.counterId + 1}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.shade300),
                  ),
                  child: Text(
                    'Confirmed',
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Text(
              'Services:',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            ...services.map(
              (service) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(service.name,
                          style: Theme.of(context).textTheme.bodyMedium),
                    ),
                    Text(
                      '${service.durationMinutes}m • ${Money.formatRupeesFromCents(service.priceCents)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Divider(height: 1),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total:',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  Money.formatRupeesFromCents(booking.totalPriceCents),
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
    );
  }

  static Map<String, List<Booking>> _groupByDay(List<Booking> bookings) {
    final map = <String, List<Booking>>{};
    for (final b in bookings) {
      final k =
          '${b.startAt.day.toString().padLeft(2, '0')}/${b.startAt.month.toString().padLeft(2, '0')}/${b.startAt.year}';
      map.putIfAbsent(k, () => <Booking>[]).add(b);
    }
    return map;
  }

  static String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final displayMinute = minute == 0 ? '00' : minute.toString().padLeft(2, '0');
    return '$displayHour:$displayMinute $period';
  }
}

