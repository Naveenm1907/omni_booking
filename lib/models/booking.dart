import 'package:cloud_firestore/cloud_firestore.dart';

class Booking {
  final String id;
  final DateTime startAt;
  final int durationMinutes;
  final int counterId;
  final List<String> serviceIds;
  final int totalPriceCents;

  const Booking({
    required this.id,
    required this.startAt,
    required this.durationMinutes,
    required this.counterId,
    required this.serviceIds,
    required this.totalPriceCents,
  });

  DateTime get endAt => startAt.add(Duration(minutes: durationMinutes));

  factory Booking.fromMap(String id, Map<String, dynamic> map) {
    final startAt = (map['startAt'] as Timestamp).toDate();
    return Booking(
      id: id,
      startAt: startAt,
      durationMinutes: (map['durationMinutes'] as num).toInt(),
      counterId: (map['counterId'] as num).toInt(),
      serviceIds: List<String>.from(map['serviceIds'] as List<dynamic>),
      totalPriceCents: (map['totalPriceCents'] as num).toInt(),
    );
  }



  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'startAt': Timestamp.fromDate(startAt),
      'durationMinutes': durationMinutes,
      'counterId': counterId,
      'serviceIds': serviceIds,
      'totalPriceCents': totalPriceCents,
    };
  }
}

