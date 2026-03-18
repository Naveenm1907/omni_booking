import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/service.dart';

class SelectedServicesState {
  final List<Service> selected;

  const SelectedServicesState({required this.selected});

  int get totalDurationMinutes =>
      selected.fold<int>(0, (sum, s) => sum + s.durationMinutes);

  int get totalPriceCents =>
      selected.fold<int>(0, (sum, s) => sum + s.priceCents);

  List<String> get serviceIds => selected.map((s) => s.id).toList(growable: false);
}

class SelectedServicesNotifier extends Notifier<SelectedServicesState> {
  @override
  SelectedServicesState build() {
    return const SelectedServicesState(selected: <Service>[]);
  }

  void toggle(Service service) {
    final exists = state.selected.any((s) => s.id == service.id);
    if (exists) {
      state = SelectedServicesState(
        selected: state.selected.where((s) => s.id != service.id).toList(),
      );
    } else {
      state = SelectedServicesState(selected: [...state.selected, service]);
    }
  }

  void clear() {
    state = const SelectedServicesState(selected: <Service>[]);
  }
}

final selectedServicesProvider =
    NotifierProvider<SelectedServicesNotifier, SelectedServicesState>(
  SelectedServicesNotifier.new,
);

