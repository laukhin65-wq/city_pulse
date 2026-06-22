import 'package:city_pulse/core/errors/failures.dart';
import 'package:city_pulse/features/map/domain/entities/city_event.dart';
import 'package:city_pulse/features/map/domain/repositories/event_repository.dart';
import 'package:city_pulse/features/map/domain/usecases/save_event.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockEventRepository extends Mock implements EventRepository {}

class FakeCityEvent extends Fake implements CityEvent {}

void main() {
  late SaveEvent usecase;
  late MockEventRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(FakeCityEvent());
  });

  setUp(() {
    mockRepository = MockEventRepository();
    usecase = SaveEvent(mockRepository);
  });

  final tEvent = CityEvent(
    id: 'test_1',
    title: 'Test Event',
    description: 'A test event for unit testing',
    latitude: 55.7558,
    longitude: 37.6173,
    date: DateTime(2025, 8, 1, 18, 0),
    type: EventType.concert,
    venue: 'Test Venue',
  );

  test(
    'should call repository.saveEvent and return unit on success',
    () async {
      when(() => mockRepository.saveEvent(any()))
          .thenAnswer((_) async => const Right(unit));

      final result = await usecase(tEvent);

      expect(result, const Right(unit));
      verify(() => mockRepository.saveEvent(tEvent)).called(1);
      verifyNoMoreInteractions(mockRepository);
    },
  );

  test(
    'should return CacheFailure when repository save fails',
    () async {
      when(() => mockRepository.saveEvent(any()))
          .thenAnswer((_) async => const Left(CacheFailure()));

      final result = await usecase(tEvent);

      expect(result, const Left(CacheFailure()));
      verify(() => mockRepository.saveEvent(tEvent)).called(1);
    },
  );

  test(
    'should return ServerFailure when repository throws server error',
    () async {
      when(() => mockRepository.saveEvent(any()))
          .thenAnswer((_) async => const Left(ServerFailure(message: 'timeout')));

      final result = await usecase(tEvent);

      expect(result, const Left(ServerFailure(message: 'timeout')));
    },
  );
}
