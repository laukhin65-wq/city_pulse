import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:city_pulse/features/map/domain/usecases/get_events.dart';
import 'map_event.dart';
import 'map_state.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  final GetEvents _getEvents;

  MapBloc({required GetEvents getEvents})
      // ignore: prefer_initializing_formals
      : _getEvents = getEvents,
        super(const MapInitial()) {
    on<LoadEvents>(_onLoadEvents);
    on<EventTapped>(_onEventTapped);
    on<ClearSelectedEvent>(_onClearSelectedEvent);
  }

  Future<void> _onLoadEvents(
    LoadEvents event,
    Emitter<MapState> emit,
  ) async {
    emit(const MapLoading());

    final result = await _getEvents();

    result.fold(
      (failure) => emit(MapError(failure.toString())),
      (events) => emit(MapLoaded(events: events)),
    );
  }

  void _onEventTapped(
    EventTapped event,
    Emitter<MapState> emit,
  ) {
    final currentState = state;
    if (currentState is MapLoaded) {
      emit(currentState.copyWith(selectedEvent: () => event.event));
    }
  }

  void _onClearSelectedEvent(
    ClearSelectedEvent event,
    Emitter<MapState> emit,
  ) {
    final currentState = state;
    if (currentState is MapLoaded) {
      emit(currentState.copyWith(selectedEvent: () => null));
    }
  }
}
