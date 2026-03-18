import '../models/service.dart';

class MockData {
  static const services = <Service>[
    Service(
      id: 'haircut',
      name: 'Haircut',
      durationMinutes: 30,
      priceCents: 1500,
    ),
    Service(
      id: 'shave',
      name: 'Shave',
      durationMinutes: 15,
      priceCents: 800,
    ),
    Service(
      id: 'facial',
      name: 'Facial',
      durationMinutes: 60,
      priceCents: 2500,
    ),
    Service(
      id: 'coloring',
      name: 'Coloring',
      durationMinutes: 90,
      priceCents: 4000,
    ),
  ];
}

