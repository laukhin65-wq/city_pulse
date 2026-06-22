import 'package:city_pulse/features/map/data/models/event_model.dart';
import 'package:city_pulse/features/map/domain/entities/city_event.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final testDate = DateTime(2025, 7, 15, 18, 30);

  final testModel = EventModel(
    id: '1',
    title: 'Rock Festival',
    description: 'Annual rock festival in the park',
    latitude: 55.7558,
    longitude: 37.6173,
    date: testDate,
    type: EventType.festival,
    imageUrl: 'https://example.com/image.jpg',
    venue: 'Gorky Park',
  );

  final testJson = {
    'id': '1',
    'title': 'Rock Festival',
    'description': 'Annual rock festival in the park',
    'latitude': 55.7558,
    'longitude': 37.6173,
    'date': '2025-07-15T18:30:00.000',
    'type': 'festival',
    'imageUrl': 'https://example.com/image.jpg',
    'venue': 'Gorky Park',
  };

  group('EventModel', () {
    group('fromJson', () {
      test('should return a valid EventModel from JSON', () {
        final result = EventModel.fromJson(testJson);

        expect(result, equals(testModel));
      });

      test('should handle null optional fields', () {
        final jsonWithoutOptionals = Map<String, dynamic>.from(testJson)
          ..remove('imageUrl')
          ..remove('venue');

        final result = EventModel.fromJson(jsonWithoutOptionals);

        expect(result.imageUrl, isNull);
        expect(result.venue, isNull);
      });

      test('should default to EventType.other for unknown type', () {
        final jsonWithUnknownType = Map<String, dynamic>.from(testJson)
          ..['type'] = 'unknown_type';

        final result = EventModel.fromJson(jsonWithUnknownType);

        expect(result.type, EventType.other);
      });

      test('should parse latitude as double from int', () {
        final jsonWithIntLat = Map<String, dynamic>.from(testJson)
          ..['latitude'] = 55;

        final result = EventModel.fromJson(jsonWithIntLat);

        expect(result.latitude, 55.0);
      });
    });

    group('toJson', () {
      test('should return a valid JSON map', () {
        final result = testModel.toJson();

        expect(result, equals(testJson));
      });

      test('should include null optional fields', () {
        final modelWithoutOptionals = EventModel(
          id: '1',
          title: 'Test',
          description: 'Desc',
          latitude: 55.0,
          longitude: 37.0,
          date: testDate,
          type: EventType.other,
        );

        final result = modelWithoutOptionals.toJson();

        expect(result.containsKey('imageUrl'), isTrue);
        expect(result['imageUrl'], isNull);
        expect(result.containsKey('venue'), isTrue);
        expect(result['venue'], isNull);
      });
    });

    group('fromJson → toJson roundtrip', () {
      test('should preserve data through serialization cycle', () {
        final fromJson = EventModel.fromJson(testJson);
        final toJson = fromJson.toJson();

        expect(toJson, equals(testJson));
      });
    });

    group('fromEntity / toEntity', () {
      test('toEntity should return the same instance', () {
        final entity = testModel.toEntity();

        expect(identical(entity, testModel), isTrue);
      });

      test('fromEntity should create EventModel from CityEvent', () {
        final entity = CityEvent(
          id: '2',
          title: 'Jazz Night',
          description: 'Smooth jazz evening',
          latitude: 55.7600,
          longitude: 37.6200,
          date: testDate,
          type: EventType.concert,
        );

        final model = EventModel.fromEntity(entity);

        expect(model.id, entity.id);
        expect(model.title, entity.title);
        expect(model.type, EventType.concert);
      });
    });
  });
}
