import 'dart:io';

import 'package:city_pulse/core/data/seed_events.dart';
import 'package:city_pulse/core/data/seed_service.dart';
import 'package:city_pulse/core/adapters/event_model_adapter.dart';
import 'package:city_pulse/features/map/data/models/event_model.dart';
import 'package:city_pulse/features/map/domain/entities/city_event.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

bool _adapterRegistered = false;

void main() {
  late Box<EventModel> box;
  late SeedService seedService;

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final dir = Directory.systemTemp.createTempSync('seed_test');
    Hive.init(dir.path);

    if (!_adapterRegistered) {
      Hive.registerAdapter(EventModelAdapter());
      _adapterRegistered = true;
    }

    box = await Hive.openBox<EventModel>('test_events_${DateTime.now().microsecondsSinceEpoch}');
    seedService = SeedService(box);
  });

  tearDown(() async {
    await box.close();
  });

  group('SeedService', () {
    test('isEmpty should return true when box is empty', () {
      expect(seedService.isEmpty, isTrue);
    });

    test('isEmpty should return false when box has data', () async {
      await seedService.seedIfEmpty();
      expect(seedService.isEmpty, isFalse);
    });

    test('seedIfEmpty should add all seed events', () async {
      await seedService.seedIfEmpty();
      expect(box.length, seedEvents.length);
    });

    test('seedIfEmpty should not add duplicates', () async {
      await seedService.seedIfEmpty();
      await seedService.seedIfEmpty();
      expect(box.length, seedEvents.length);
    });

    test('seedIfEmpty should preserve event data', () async {
      await seedService.seedIfEmpty();

      final firstSeed = seedEvents.first;
      final firstBox = box.get(firstSeed.id);

      expect(firstBox, isNotNull);
      expect(firstBox!.id, firstSeed.id);
      expect(firstBox.title, firstSeed.title);
      expect(firstBox.type, firstSeed.type);
    });

    test('seedIfEmpty should not overwrite existing data', () async {
      final customEvent = EventModel(
        id: 'custom_1',
        title: 'My Custom Event',
        description: 'Not a seed event',
        latitude: 55.0,
        longitude: 37.0,
        date: DateTime(2025),
        type: EventType.meetup,
      );
      await box.put('custom_1', customEvent);

      await seedService.seedIfEmpty();

      expect(box.length, 1);
      expect(box.get('custom_1')!.title, 'My Custom Event');
    });

    test('should contain all 10 seed event types', () async {
      await seedService.seedIfEmpty();
      final types = box.values.map((e) => e.type).toSet();
      expect(types.length, greaterThanOrEqualTo(7));
    });
  });
}
