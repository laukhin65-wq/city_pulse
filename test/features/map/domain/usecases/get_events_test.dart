import 'package:city_pulse/core/errors/failures.dart';
import 'package:city_pulse/features/map/domain/entities/city_event.dart';
import 'package:city_pulse/features/map/domain/repositories/event_repository.dart';
import 'package:city_pulse/features/map/domain/usecases/get_events.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockEventRepository extends Mock implements EventRepository {}

void main() {
  late GetEvents usecase;
  late MockEventRepository mockRepository;

  setUp(() {
    mockRepository = MockEventRepository();
    usecase = GetEvents(mockRepository);
  });

  final tEvents = [
    CityEvent(
      id: '1',
      title: 'Concert',
      description: 'Live music',
      latitude: 55.75,
      longitude: 37.61,
      date: DateTime(2025, 7, 15),
      type: EventType.concert,
    ),
    CityEvent(
      id: '2',
      title: 'Market',
      description: 'Farmer market',
      latitude: 55.76,
      longitude: 37.62,
      date: DateTime(2025, 7, 16),
      type: EventType.market,
    ),
  ];

  test(
    'should get list of events from the repository',
    () async {
      when(() => mockRepository.getEvents())
          .thenAnswer((_) async => Right(tEvents));

      final result = await usecase();

      expect(result, Right(tEvents));
      verify(() => mockRepository.getEvents()).called(1);
      verifyNoMoreInteractions(mockRepository);
    },
  );

  test(
    'should return CacheFailure when repository throws',
    () async {
      when(() => mockRepository.getEvents())
          .thenAnswer((_) async => const Left(CacheFailure()));

      final result = await usecase();

      expect(result, const Left(CacheFailure()));
      verify(() => mockRepository.getEvents()).called(1);
    },
  );

  test(
    'should return empty list when no events exist',
    () async {
      when(() => mockRepository.getEvents())
          .thenAnswer((_) async => const Right([]));

      final result = await usecase();

      result.fold(
        (_) => fail('Should not be Left'),
        (events) => expect(events, isEmpty),
      );
    },
  );
}
