import 'package:city_pulse/core/errors/exceptions.dart';
import 'package:city_pulse/core/errors/failures.dart';
import 'package:city_pulse/features/map/data/datasources/event_local_datasource.dart';
import 'package:city_pulse/features/map/data/models/event_model.dart';
import 'package:city_pulse/features/map/data/repositories/event_repository_impl.dart';
import 'package:city_pulse/features/map/domain/entities/city_event.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockEventLocalDatasource extends Mock
    implements EventLocalDatasource {}

class FakeEventModel extends Fake implements EventModel {}

void main() {
  late EventRepositoryImpl repository;
  late MockEventLocalDatasource mockDatasource;

  setUpAll(() {
    registerFallbackValue(FakeEventModel());
  });

  setUp(() {
    mockDatasource = MockEventLocalDatasource();
    repository = EventRepositoryImpl(mockDatasource);
  });

  final tEventModel = EventModel(
    id: '1',
    title: 'Concert',
    description: 'Live music',
    latitude: 55.75,
    longitude: 37.61,
    date: DateTime(2025, 7, 15),
    type: EventType.concert,
  );

  group('getEvents', () {
    test(
      'should return list of CityEvent when datasource succeeds',
      () async {
        when(() => mockDatasource.getEvents())
            .thenAnswer((_) async => [tEventModel]);

        final result = await repository.getEvents();

        result.fold(
          (_) => fail('Should not be Left'),
          (events) {
            expect(events, hasLength(1));
            expect(events.first.id, '1');
            expect(events.first.title, 'Concert');
            expect(events.first.type, EventType.concert);
          },
        );
        verify(() => mockDatasource.getEvents()).called(1);
      },
    );

    test(
      'should return CacheFailure when datasource throws CacheException',
      () async {
        when(() => mockDatasource.getEvents())
            .thenThrow(const CacheException());

        final result = await repository.getEvents();

        expect(result, const Left(CacheFailure()));
      },
    );
  });

  group('getEventById', () {
    test(
      'should return CityEvent when datasource succeeds',
      () async {
        when(() => mockDatasource.getEventById('1'))
            .thenAnswer((_) async => tEventModel);

        final result = await repository.getEventById('1');

        result.fold(
          (_) => fail('Should not be Left'),
          (event) {
            expect(event, isNotNull);
            expect(event!.id, '1');
            expect(event.title, 'Concert');
          },
        );
      },
    );

    test(
      'should return null when event not found',
      () async {
        when(() => mockDatasource.getEventById('999'))
            .thenAnswer((_) async => null);

        final result = await repository.getEventById('999');

        result.fold(
          (_) => fail('Should not be Left'),
          (event) => expect(event, isNull),
        );
      },
    );

    test(
      'should return CacheFailure when datasource throws',
      () async {
        when(() => mockDatasource.getEventById('1'))
            .thenThrow(const CacheException());

        final result = await repository.getEventById('1');

        expect(result, const Left(CacheFailure()));
      },
    );
  });

  group('saveEvent', () {
    test(
      'should call datasource.saveEvent and return unit on success',
      () async {
        when(() => mockDatasource.saveEvent(any()))
            .thenAnswer((_) async {});

        final tEvent = CityEvent(
          id: '1',
          title: 'Concert',
          description: 'Live music',
          latitude: 55.75,
          longitude: 37.61,
          date: DateTime(2025, 7, 15),
          type: EventType.concert,
        );

        final result = await repository.saveEvent(tEvent);

        expect(result, const Right(unit));
        verify(() => mockDatasource.saveEvent(any())).called(1);
      },
    );

    test(
      'should return CacheFailure when save fails',
      () async {
        when(() => mockDatasource.saveEvent(any()))
            .thenThrow(const CacheException());

        final tEvent = CityEvent(
          id: '1',
          title: 'Concert',
          description: 'Live music',
          latitude: 55.75,
          longitude: 37.61,
          date: DateTime(2025, 7, 15),
          type: EventType.concert,
        );

        final result = await repository.saveEvent(tEvent);

        expect(result, const Left(CacheFailure()));
      },
    );
  });

  group('deleteEvent', () {
    test(
      'should call datasource.deleteEvent and return unit on success',
      () async {
        when(() => mockDatasource.deleteEvent('1'))
            .thenAnswer((_) async {});

        final result = await repository.deleteEvent('1');

        expect(result, const Right(unit));
        verify(() => mockDatasource.deleteEvent('1')).called(1);
      },
    );

    test(
      'should return CacheFailure when delete fails',
      () async {
        when(() => mockDatasource.deleteEvent('1'))
            .thenThrow(const CacheException());

        final result = await repository.deleteEvent('1');

        expect(result, const Left(CacheFailure()));
      },
    );
  });
}
