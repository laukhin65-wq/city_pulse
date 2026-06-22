import 'package:bloc_test/bloc_test.dart';
import 'package:city_pulse/core/errors/failures.dart';
import 'package:city_pulse/features/map/domain/entities/city_event.dart';
import 'package:city_pulse/features/map/domain/repositories/event_repository.dart';
import 'package:city_pulse/features/map/domain/repositories/favorite_repository.dart';
import 'package:city_pulse/features/map/presentation/cubit/favorite_cubit.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// ignore: unnecessary_import
import 'package:dartz/dartz.dart' show unit;

class MockFavoriteRepository extends Mock implements FavoriteRepository {}

class MockEventRepository extends Mock implements EventRepository {}

void main() {
  late FavoriteCubit cubit;
  late MockFavoriteRepository mockFavoriteRepo;
  late MockEventRepository mockEventRepo;

  setUpAll(() {
    registerFallbackValue('');
  });

  setUp(() {
    mockFavoriteRepo = MockFavoriteRepository();
    mockEventRepo = MockEventRepository();
    cubit = FavoriteCubit(
      favoriteRepository: mockFavoriteRepo,
      eventRepository: mockEventRepo,
    );
  });

  tearDown(() => cubit.close());

  CityEvent tEvent() => CityEvent(
        id: '1',
        title: 'Test Event',
        description: 'A test event',
        latitude: 55.7558,
        longitude: 37.6173,
        date: DateTime(2025, 8, 1),
        type: EventType.concert,
      );

  group('FavoriteCubit', () {
    test('initial state should be empty FavoriteState', () {
      expect(cubit.state.favoriteIds, isEmpty);
      expect(cubit.state.favoriteEvents, isEmpty);
    });

    group('loadFavorites', () {
      blocTest<FavoriteCubit, FavoriteState>(
        'should emit empty state when no favorites exist',
        build: () {
          when(() => mockFavoriteRepo.getFavoriteIds())
              .thenAnswer((_) async => const Right([]));
          return FavoriteCubit(
            favoriteRepository: mockFavoriteRepo,
            eventRepository: mockEventRepo,
          );
        },
        act: (cubit) => cubit.loadFavorites(),
        expect: () => [
          predicate<FavoriteState>((s) =>
              s.favoriteIds.isEmpty && s.favoriteEvents.isEmpty),
        ],
      );

      blocTest<FavoriteCubit, FavoriteState>(
        'should load favorite events when IDs exist',
        build: () {
          when(() => mockFavoriteRepo.getFavoriteIds())
              .thenAnswer((_) async => const Right(['1']));
          when(() => mockEventRepo.getEventsByIds(['1']))
              .thenAnswer((_) async => Right([tEvent()]));
          return FavoriteCubit(
            favoriteRepository: mockFavoriteRepo,
            eventRepository: mockEventRepo,
          );
        },
        act: (cubit) => cubit.loadFavorites(),
        expect: () => [
          predicate<FavoriteState>((s) =>
              s.favoriteIds.contains('1') &&
              s.favoriteEvents.length == 1 &&
              s.favoriteEvents.first.id == '1'),
        ],
      );

      blocTest<FavoriteCubit, FavoriteState>(
        'should handle failed events load',
        build: () {
          when(() => mockFavoriteRepo.getFavoriteIds())
              .thenAnswer((_) async => const Right(['1', '2']));
          when(() => mockEventRepo.getEventsByIds(['1', '2']))
              .thenAnswer((_) async => const Left(CacheFailure()));
          return FavoriteCubit(
            favoriteRepository: mockFavoriteRepo,
            eventRepository: mockEventRepo,
          );
        },
        act: (cubit) => cubit.loadFavorites(),
        expect: () => [
          predicate<FavoriteState>((s) =>
              s.favoriteIds.length == 2 &&
              s.favoriteEvents.isEmpty),
        ],
      );

      blocTest<FavoriteCubit, FavoriteState>(
        'should handle failed favorite IDs load',
        build: () {
          when(() => mockFavoriteRepo.getFavoriteIds())
              .thenAnswer((_) async => const Left(CacheFailure()));
          return FavoriteCubit(
            favoriteRepository: mockFavoriteRepo,
            eventRepository: mockEventRepo,
          );
        },
        act: (cubit) => cubit.loadFavorites(),
        expect: () => [],
      );
    });

    group('toggleFavorite', () {
      blocTest<FavoriteCubit, FavoriteState>(
        'should toggle and reload favorites',
        build: () {
          when(() => mockFavoriteRepo.toggleFavorite('1'))
              .thenAnswer((_) async => Right(unit));
          when(() => mockFavoriteRepo.getFavoriteIds())
              .thenAnswer((_) async => const Right(['1']));
          when(() => mockEventRepo.getEventsByIds(['1']))
              .thenAnswer((_) async => Right([tEvent()]));
          return FavoriteCubit(
            favoriteRepository: mockFavoriteRepo,
            eventRepository: mockEventRepo,
          );
        },
        act: (cubit) => cubit.toggleFavorite('1'),
        verify: (_) {
          verify(() => mockFavoriteRepo.toggleFavorite('1')).called(1);
        },
      );
    });

    group('removeFavorite', () {
      blocTest<FavoriteCubit, FavoriteState>(
        'should remove and reload favorites',
        build: () {
          when(() => mockFavoriteRepo.removeFavorite('1'))
              .thenAnswer((_) async => Right(unit));
          when(() => mockFavoriteRepo.getFavoriteIds())
              .thenAnswer((_) async => const Right([]));
          return FavoriteCubit(
            favoriteRepository: mockFavoriteRepo,
            eventRepository: mockEventRepo,
          );
        },
        act: (cubit) => cubit.removeFavorite('1'),
        expect: () => [
          predicate<FavoriteState>((s) =>
              s.favoriteIds.isEmpty && s.favoriteEvents.isEmpty),
        ],
        verify: (_) {
          verify(() => mockFavoriteRepo.removeFavorite('1')).called(1);
        },
      );
    });
  });

  group('FavoriteState', () {
    test('isFavorite should return true for favorite IDs', () {
      const state = FavoriteState(favoriteIds: {'1', '2'});
      expect(state.isFavorite('1'), isTrue);
      expect(state.isFavorite('2'), isTrue);
    });

    test('isFavorite should return false for non-favorite IDs', () {
      const state = FavoriteState(favoriteIds: {'1'});
      expect(state.isFavorite('999'), isFalse);
    });

    test('copyWith should preserve existing values', () {
      final original = FavoriteState(
        favoriteIds: {'1'},
        favoriteEvents: [tEvent()],
      );

      final copy = original.copyWith(favoriteIds: {'1', '2'});

      expect(copy.favoriteIds, {'1', '2'});
      expect(copy.favoriteEvents.length, 1);
    });
  });
}
