class Service {
  final String id;
  final String name;
  final int durationMinutes;
  final int priceCents;

  const Service({
    required this.id,
    required this.name,
    required this.durationMinutes,
    required this.priceCents,
  });

  factory Service.fromMap(String id, Map<String, dynamic> map) {
    return Service(
      id: id,
      name: map['name'] as String,
      durationMinutes: (map['durationMinutes'] as num).toInt(),
      priceCents: (map['priceCents'] as num).toInt(),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'durationMinutes': durationMinutes,
      'priceCents': priceCents,
    };
  }
}

