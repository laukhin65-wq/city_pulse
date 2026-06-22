import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:city_pulse/features/map/domain/entities/city_event.dart';
import 'package:city_pulse/features/map/domain/repositories/event_repository.dart';
import 'package:city_pulse/features/map/domain/repositories/favorite_repository.dart';

class FavoriteState extends Equatable {
  final Set<String> favoriteIds;
  final List<CityEvent> favoriteEvents;

  const FavoriteState({
    this.favoriteIds = const {},
    this.favoriteEvents = const [],
  });

  bool isFavorite(String eventId) => favoriteIds.contains(eventId);

  FavoriteState copyWith({
    Set<String>? favoriteIds,
    List<CityEvent>? favoriteEvents,
  }) {
    return FavoriteState(
      favoriteIds: favoriteIds ?? this.favoriteIds,
      favoriteEvents: favoriteEvents ?? this.favoriteEvents,
    );
  }

  @override
  List<Object?> get props => [favoriteIds, favoriteEvents];
}

class FavoriteCubit extends Cubit<FavoriteState> {
  final FavoriteRepository _favoriteRepository;
  final EventRepository _eventRepository;

  FavoriteCubit({
    required FavoriteRepository favoriteRepository,
    required EventRepository eventRepository,
  })  : _favoriteRepository = favoriteRepository,
        _eventRepository = eventRepository,
        super(const FavoriteState());

  Future<void> loadFavorites() async {
    final idsResult = await _favoriteRepository.getFavoriteIds();

    await idsResult.fold(
      (_) => null,
      (ids) async {
        if (ids.isEmpty) {
          emit(const FavoriteState());
          return;
        }

        final eventsResult = await _eventRepository.getEventsByIds(ids);

        eventsResult.fold(
          (_) => emit(FavoriteState(favoriteIds: ids.toSet())),
          (events) => emit(FavoriteState(
            favoriteIds: ids.toSet(),
            favoriteEvents: events,
          )),
        );
      },
    );
  }

  Future<void> toggleFavorite(String eventId) async {
    final result = await _favoriteRepository.toggleFavorite(eventId);
    result.fold(
      (_) => null,
      (_) => loadFavorites(),
    );
  }

  Future<void> removeFavorite(String eventId) async {
    final result = await _favoriteRepository.removeFavorite(eventId);
    result.fold(
      (_) => null,
      (_) => loadFavorites(),
    );
  }
}
