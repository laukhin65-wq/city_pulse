import 'dart:io';

import 'package:city_pulse/core/adapters/event_model_adapter.dart';
import 'package:city_pulse/features/map/data/datasources/event_local_datasource_impl.dart';
import 'package:city_pulse/features/map/data/models/event_model.dart';
import 'package:city_pulse/features/map/domain/entities/city_event.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

bool _adapterRegistered = false;

void main() {
  late Box<EventModel> box;
  late EventLocalDatasourceImpl datasource;

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final dir = Directory.systemTemp.createTempSync('event_ds_test');
    Hive.init(dir.path);

    if (!_adapterRegistered) {
      Hive.registerAdapter(EventModelAdapter());
      _adapterRegistered = true;
    }

    box = await Hive.openBox<EventModel>(
        'test_events_ds_${DateTime.now().microsecondsSinceEpoch}');
    datasource = EventLocalDatasourceImpl(box);
  });

  tearDown(() async {
    await box.close();
  });

  final tEvent = EventModel(
    id: '1',
    title: 'Concert',
    description: 'Live music event',
    latitude: 55.7558,
    longitude: 37.6173,
    date: DateTime(2025, 8, 1, 18, 0),
    type: EventType.concert,
    venue: 'Stadium',
  );

  final tEvent2 = EventModel(
    id: '2',
    title: 'Festival',
    description: 'Summer festival',
    latitude: 55.7600,
    longitude: 37.6200,
    date: DateTime(2025, 8, 2, 12, 0),
    type: EventType.festival,
    imageUrl: 'https://example.com/img.jpg',
  );

  group('EventLocalDatasourceImpl', () {
    group('getEvents', () {
      test('should return empty list when box is empty', () async {
        final result = await datasource.getEvents();
        expect(result, isEmpty);
      });

      test('should return all events', () async {
        await box.put('1', tEvent);
        await box.put('2', tEvent2);

        final result = await datasource.getEvents();

        expect(result.length, 2);
        expect(result[0].id, '1');
        expect(result[1].id, '2');
      });
    });

    group('getEventById', () {
      test('should return null when event not found', () async {
        final result = await datasource.getEventById('999');
        expect(result, isNull);
      });

      test('should return event when found', () async {
        await box.put('1', tEvent);

        final result = await datasource.getEventById('1');

        expect(result, isNotNull);
        expect(result!.id, '1');
        expect(result.title, 'Concert');
        expect(result.type, EventType.concert);
      });
    });

    group('saveEvent', () {
      test('should save new event to box', () async {
        await datasource.saveEvent(tEvent);

        expect(box.length, 1);
        expect(box.get('1')!.title, 'Concert');
      });

      test('should overwrite existing event with same id', () async {
        await box.put('1', tEvent);

        final updated = EventModel(
          id: '1',
          title: 'Updated Concert',
          description: 'Updated description',
          latitude: 55.7558,
          longitude: 37.6173,
          date: DateTime(2025, 8, 1),
          type: EventType.concert,
        );

        await datasource.saveEvent(updated);

        expect(box.length, 1);
        expect(box.get('1')!.title, 'Updated Concert');
      });

      test('should save multiple events independently', () async {
        await datasource.saveEvent(tEvent);
        await datasource.saveEvent(tEvent2);

        expect(box.length, 2);
        expect(box.get('1')!.title, 'Concert');
        expect(box.get('2')!.title, 'Festival');
      });
    });

    group('deleteEvent', () {
      test('should delete event from box', () async {
        await box.put('1', tEvent);

        await datasource.deleteEvent('1');

        expect(box.containsKey('1'), isFalse);
      });

      test('should not throw when deleting non-existent event', () async {
        await expectLater(datasource.deleteEvent('999'), completes);
      });

      test('should not affect other events', () async {
        await box.put('1', tEvent);
        await box.put('2', tEvent2);

        await datasource.deleteEvent('1');

        expect(box.length, 1);
        expect(box.containsKey('2'), isTrue);
      });
    });

    group('CRUD integration', () {
      test('full lifecycle: save → get → update → delete', () async {
        await datasource.saveEvent(tEvent);

        var result = await datasource.getEventById('1');
        expect(result!.title, 'Concert');

        final updated = EventModel(
          id: '1',
          title: 'Rock Concert',
          description: 'Updated',
          latitude: 55.7558,
          longitude: 37.6173,
          date: DateTime(2025, 8, 1),
          type: EventType.concert,
        );
        await datasource.saveEvent(updated);

        result = await datasource.getEventById('1');
        expect(result!.title, 'Rock Concert');

        await datasource.deleteEvent('1');
        result = await datasource.getEventById('1');
        expect(result, isNull);
      });
    });
  });
}
