import 'package:hive/hive.dart';

import 'package:city_pulse/core/data/seed_events.dart';
import 'package:city_pulse/features/map/data/models/event_model.dart';

class SeedService {
  final Box<EventModel> _box;

  const SeedService(this._box);

  bool get isEmpty => _box.isEmpty;

  Future<void> seedIfEmpty() async {
    if (_box.isNotEmpty) return;

    for (final event in seedEvents) {
      await _box.put(event.id, event);
    }
  }
}
