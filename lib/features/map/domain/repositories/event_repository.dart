import 'package:dartz/dartz.dart';

import 'package:city_pulse/core/utils/typedefs.dart';
import 'package:city_pulse/features/map/domain/entities/city_event.dart';

abstract interface class EventRepository {
  ResultFuture<List<CityEvent>> getEvents();
  ResultFuture<List<CityEvent>> getEventsByIds(List<String> ids);
  ResultFuture<CityEvent?> getEventById(String id);
  ResultFuture<Unit> saveEvent(CityEvent event);
  ResultFuture<Unit> deleteEvent(String id);
}
