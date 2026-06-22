import 'package:equatable/equatable.dart';

import '../../domain/entities/city_event.dart';

sealed class MapEvent extends Equatable {
  const MapEvent();

  @override
  List<Object?> get props => [];
}

class LoadEvents extends MapEvent {
  const LoadEvents();
}

class EventTapped extends MapEvent {
  final CityEvent event;

  const EventTapped(this.event);

  @override
  List<Object?> get props => [event];
}

class ClearSelectedEvent extends MapEvent {
  const ClearSelectedEvent();
}
