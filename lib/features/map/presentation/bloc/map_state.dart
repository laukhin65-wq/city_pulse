import 'package:equatable/equatable.dart';

import '../../domain/entities/city_event.dart';

sealed class MapState extends Equatable {
  const MapState();

  @override
  List<Object?> get props => [];
}

class MapInitial extends MapState {
  const MapInitial();
}

class MapLoading extends MapState {
  const MapLoading();
}

class MapLoaded extends MapState {
  final List<CityEvent> events;
  final CityEvent? selectedEvent;

  const MapLoaded({
    required this.events,
    this.selectedEvent,
  });

  @override
  List<Object?> get props => [events, selectedEvent];

  MapLoaded copyWith({
    List<CityEvent>? events,
    CityEvent? Function()? selectedEvent,
  }) {
    return MapLoaded(
      events: events ?? this.events,
      selectedEvent:
          selectedEvent != null ? selectedEvent() : this.selectedEvent,
    );
  }
}

class MapError extends MapState {
  final String message;

  const MapError(this.message);

  @override
  List<Object?> get props => [message];
}
