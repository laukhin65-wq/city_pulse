import 'package:city_pulse/core/errors/failures.dart';
import 'package:city_pulse/features/map/domain/entities/city_event.dart';
import 'package:city_pulse/features/map/domain/repositories/event_repository.dart';
import 'package:city_pulse/features/map/domain/usecases/get_event_by_id.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockEventRepository extends Mock implements EventRepository {}

void main() {
  late GetEventById usecase;
  late MockEventRepository mockRepository;

  setUp(() {
    mockRepository = MockEventRepository();
    usecase = GetEventById(mockRepository);
  });

  const tId = '1';
  final tEvent = CityEvent(
    id: '1',
    title: 'Concert',
    description: 'Live music',
    latitude: 55.75,
    longitude: 37.61,
    date: DateTime(2025, 7, 15),
    type: EventType.concert,
  );

  test(
    'should get event by id from the repository',
    () async {
      when(() => mockRepository.getEventById(tId))
          .thenAnswer((_) async => Right(tEvent));

      final result = await usecase(tId);

      expect(result, Right(tEvent));
      verify(() => mockRepository.getEventById(tId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    },
  );

  test(
    'should return null when event not found',
    () async {
      when(() => mockRepository.getEventById(tId))
          .thenAnswer((_) async => const Right(null));

      final result = await usecase(tId);

      result.fold(
        (_) => fail('Should not be Left'),
        (event) => expect(event, isNull),
      );
    },
  );

  test(
    'should return CacheFailure when repository throws',
    () async {
      when(() => mockRepository.getEventById(tId))
          .thenAnswer((_) async => const Left(CacheFailure()));

      final result = await usecase(tId);

      expect(result, const Left(CacheFailure()));
    },
  );
}
