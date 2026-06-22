import 'package:bloc_test/bloc_test.dart';
import 'package:city_pulse/core/errors/failures.dart';
import 'package:city_pulse/features/map/domain/entities/city_event.dart';
import 'package:city_pulse/features/map/domain/usecases/get_events.dart';
import 'package:city_pulse/features/map/presentation/bloc/map_bloc.dart';
import 'package:city_pulse/features/map/presentation/bloc/map_event.dart';
import 'package:city_pulse/features/map/presentation/bloc/map_state.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetEvents extends Mock implements GetEvents {}

void main() {
  late MapBloc bloc;
  late MockGetEvents mockGetEvents;

  setUp(() {
    mockGetEvents = MockGetEvents();
    bloc = MapBloc(getEvents: mockGetEvents);
  });

  tearDown(() => bloc.close());

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
  ];

  group('MapBloc', () {
    test('initial state should be MapInitial', () {
      expect(bloc.state, const MapInitial());
    });

    group('LoadEvents', () {
      blocTest<MapBloc, MapState>(
        'should emit [MapLoading, MapLoaded] when events loaded',
        build: () {
          when(() => mockGetEvents())
              .thenAnswer((_) async => Right(tEvents));
          return MapBloc(getEvents: mockGetEvents);
        },
        act: (bloc) => bloc.add(const LoadEvents()),
        expect: () => [
          const MapLoading(),
          MapLoaded(events: tEvents),
        ],
        verify: (_) {
          verify(() => mockGetEvents()).called(1);
        },
      );

      blocTest<MapBloc, MapState>(
        'should emit [MapLoading, MapError] when loading fails',
        build: () {
          when(() => mockGetEvents())
              .thenAnswer((_) async => const Left(CacheFailure()));
          return MapBloc(getEvents: mockGetEvents);
        },
        act: (bloc) => bloc.add(const LoadEvents()),
        expect: () => [
          const MapLoading(),
          isA<MapError>(),
        ],
      );

      blocTest<MapBloc, MapState>(
        'should emit [MapLoading, MapLoaded] with empty list',
        build: () {
          when(() => mockGetEvents())
              .thenAnswer((_) async => const Right([]));
          return MapBloc(getEvents: mockGetEvents);
        },
        act: (bloc) => bloc.add(const LoadEvents()),
        expect: () => [
          const MapLoading(),
          const MapLoaded(events: []),
        ],
      );
    });

    group('EventTapped', () {
      blocTest<MapBloc, MapState>(
        'should update selectedEvent in MapLoaded',
        build: () {
          when(() => mockGetEvents())
              .thenAnswer((_) async => Right(tEvents));
          return MapBloc(getEvents: mockGetEvents);
        },
        act: (bloc) {
          bloc.add(const LoadEvents());
          bloc.add(EventTapped(tEvents[0]));
        },
        expect: () => [
          const MapLoading(),
          MapLoaded(events: tEvents),
          MapLoaded(events: tEvents, selectedEvent: tEvents[0]),
        ],
      );
    });

    group('ClearSelectedEvent', () {
      blocTest<MapBloc, MapState>(
        'should set selectedEvent to null',
        build: () {
          when(() => mockGetEvents())
              .thenAnswer((_) async => Right(tEvents));
          return MapBloc(getEvents: mockGetEvents);
        },
        act: (bloc) {
          bloc.add(const LoadEvents());
          bloc.add(EventTapped(tEvents[0]));
          bloc.add(const ClearSelectedEvent());
        },
        expect: () => [
          const MapLoading(),
          MapLoaded(events: tEvents),
          MapLoaded(events: tEvents, selectedEvent: tEvents[0]),
          MapLoaded(events: tEvents),
        ],
      );
    });
  });
}
