import 'dart:io';

import 'package:city_pulse/core/adapters/event_model_adapter.dart';
import 'package:city_pulse/features/map/data/datasources/favorite_local_datasource_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

bool _adapterRegistered = false;

void main() {
  late Box<String> box;
  late FavoriteLocalDatasourceImpl datasource;

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final dir = Directory.systemTemp.createTempSync('fav_test');
    Hive.init(dir.path);

    if (!_adapterRegistered) {
      Hive.registerAdapter(EventModelAdapter());
      _adapterRegistered = true;
    }

    box = await Hive.openBox<String>('test_favorites_${DateTime.now().microsecondsSinceEpoch}');
    datasource = FavoriteLocalDatasourceImpl(box);
  });

  tearDown(() async {
    await box.close();
  });

  group('FavoriteLocalDatasource', () {
    group('getFavoriteIds', () {
      test('should return empty list when no favorites', () async {
        final result = await datasource.getFavoriteIds();
        expect(result.isRight(), isTrue);
        result.fold((l) => fail('Expected Right'), (r) => expect(r, isEmpty));
      });

      test('should return all favorite IDs', () async {
        await box.put('1', '1');
        await box.put('2', '2');

        final result = await datasource.getFavoriteIds();

        expect(result.isRight(), isTrue);
        result.fold((l) => fail('Expected Right'), (r) {
          expect(r, containsAll(['1', '2']));
          expect(r.length, 2);
        });
      });
    });

    group('isFavorite', () {
      test('should return false when event is not favorite', () async {
        final result = await datasource.isFavorite('1');
        expect(result.isRight(), isTrue);
        result.fold((l) => fail('Expected Right'), (r) => expect(r, isFalse));
      });

      test('should return true when event is favorite', () async {
        await box.put('1', '1');

        final result = await datasource.isFavorite('1');
        expect(result.isRight(), isTrue);
        result.fold((l) => fail('Expected Right'), (r) => expect(r, isTrue));
      });
    });

    group('toggleFavorite', () {
      test('should add event to favorites when not already favorite', () async {
        final result = await datasource.toggleFavorite('1');

        expect(result.isRight(), isTrue);
        expect(box.containsKey('1'), isTrue);
        final favResult = await datasource.isFavorite('1');
        favResult.fold((l) => fail('Expected Right'), (r) => expect(r, isTrue));
      });

      test('should remove event from favorites when already favorite', () async {
        await box.put('1', '1');

        final result = await datasource.toggleFavorite('1');

        expect(result.isRight(), isTrue);
        expect(box.containsKey('1'), isFalse);
        final favResult = await datasource.isFavorite('1');
        favResult.fold((l) => fail('Expected Right'), (r) => expect(r, isFalse));
      });

      test('should toggle multiple times correctly', () async {
        await datasource.toggleFavorite('1');
        final r1 = await datasource.isFavorite('1');
        r1.fold((l) => fail('Expected Right'), (r) => expect(r, isTrue));

        await datasource.toggleFavorite('1');
        final r2 = await datasource.isFavorite('1');
        r2.fold((l) => fail('Expected Right'), (r) => expect(r, isFalse));

        await datasource.toggleFavorite('1');
        final r3 = await datasource.isFavorite('1');
        r3.fold((l) => fail('Expected Right'), (r) => expect(r, isTrue));
      });
    });

    group('removeFavorite', () {
      test('should remove event from favorites', () async {
        await box.put('1', '1');

        final result = await datasource.removeFavorite('1');

        expect(result.isRight(), isTrue);
        expect(box.containsKey('1'), isFalse);
      });

      test('should not throw when removing non-existent event', () async {
        final result = await datasource.removeFavorite('999');
        expect(result.isRight(), isTrue);
      });
    });

    group('multiple events', () {
      test('should manage multiple favorites independently', () async {
        await datasource.toggleFavorite('1');
        await datasource.toggleFavorite('2');
        await datasource.toggleFavorite('3');

        final r1 = await datasource.getFavoriteIds();
        r1.fold((l) => fail('Expected Right'), (r) {
          expect(r, containsAll(['1', '2', '3']));
        });

        await datasource.toggleFavorite('2');

        final r2 = await datasource.getFavoriteIds();
        r2.fold((l) => fail('Expected Right'), (r) {
          expect(r, containsAll(['1', '3']));
          expect(r, isNot(contains('2')));
        });
      });
    });
  });
}
