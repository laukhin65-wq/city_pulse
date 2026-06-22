import 'package:bloc_test/bloc_test.dart';
import 'package:city_pulse/core/errors/failures.dart';
import 'package:city_pulse/features/map/domain/entities/city_event.dart';
import 'package:city_pulse/features/map/domain/usecases/save_event.dart';
import 'package:city_pulse/features/map/presentation/cubit/create_event_cubit.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSaveEvent extends Mock implements SaveEvent {}

void main() {
  late CreateEventCubit cubit;
  late MockSaveEvent mockSaveEvent;

  setUpAll(() {
    registerFallbackValue(
      CityEvent(
        id: '',
        title: '',
        description: '',
        latitude: 0,
        longitude: 0,
        date: DateTime(2025),
        type: EventType.other,
      ),
    );
  });

  setUp(() {
    mockSaveEvent = MockSaveEvent();
    cubit = CreateEventCubit(saveEvent: mockSaveEvent);
  });

  tearDown(() => cubit.close());

  final tEvent = CityEvent(
    id: 'test_1',
    title: 'Test Event',
    description: 'A test event for cubit testing',
    latitude: 55.7558,
    longitude: 37.6173,
    date: DateTime(2025, 8, 1, 18, 0),
    type: EventType.concert,
    venue: 'Test Venue',
  );

  group('CreateEventCubit', () {
    test('initial state should be CreateEventState.initial', () {
      expect(cubit.state.status, CreateEventStatus.initial);
      expect(cubit.state.failure, isNull);
    });

    group('submit', () {
      blocTest<CreateEventCubit, CreateEventState>(
        'should emit [submitting, success] when save succeeds',
        build: () {
          when(() => mockSaveEvent(any()))
              .thenAnswer((_) async => const Right(unit));
          return CreateEventCubit(saveEvent: mockSaveEvent);
        },
        act: (cubit) => cubit.submit(tEvent),
        expect: () => [
          isA<CreateEventState>()
              .having((s) => s.status, 'status', CreateEventStatus.submitting),
          isA<CreateEventState>()
              .having((s) => s.status, 'status', CreateEventStatus.success),
        ],
        verify: (_) {
          verify(() => mockSaveEvent(tEvent)).called(1);
        },
      );

      blocTest<CreateEventCubit, CreateEventState>(
        'should emit [submitting, error] when save fails with CacheFailure',
        build: () {
          when(() => mockSaveEvent(any()))
              .thenAnswer((_) async => const Left(CacheFailure()));
          return CreateEventCubit(saveEvent: mockSaveEvent);
        },
        act: (cubit) => cubit.submit(tEvent),
        expect: () => [
          isA<CreateEventState>()
              .having((s) => s.status, 'status', CreateEventStatus.submitting),
          isA<CreateEventState>()
              .having((s) => s.status, 'status', CreateEventStatus.error)
              .having((s) => s.failure, 'failure', isA<CacheFailure>()),
        ],
      );

      blocTest<CreateEventCubit, CreateEventState>(
        'should emit [submitting, error] when save fails with ServerFailure',
        build: () {
          when(() => mockSaveEvent(any()))
              .thenAnswer((_) async => const Left(ServerFailure(message: 'timeout')));
          return CreateEventCubit(saveEvent: mockSaveEvent);
        },
        act: (cubit) => cubit.submit(tEvent),
        expect: () => [
          isA<CreateEventState>()
              .having((s) => s.status, 'status', CreateEventStatus.submitting),
          isA<CreateEventState>()
              .having((s) => s.status, 'status', CreateEventStatus.error)
              .having((s) => s.failure, 'failure', isA<ServerFailure>()),
        ],
      );

      blocTest<CreateEventCubit, CreateEventState>(
        'should preserve failure after error state',
        build: () {
          when(() => mockSaveEvent(any()))
              .thenAnswer((_) async => const Left(CacheFailure()));
          return CreateEventCubit(saveEvent: mockSaveEvent);
        },
        act: (cubit) => cubit.submit(tEvent),
        verify: (cubit) {
          expect(cubit.state.status, CreateEventStatus.error);
          expect(cubit.state.failure, isA<CacheFailure>());
        },
      );
    });
  });
}
