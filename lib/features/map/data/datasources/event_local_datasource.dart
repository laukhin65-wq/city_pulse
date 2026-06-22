import 'package:city_pulse/features/map/data/models/event_model.dart';

abstract interface class EventLocalDatasource {
  Future<List<EventModel>> getEvents();
  Future<EventModel?> getEventById(String id);
  Future<void> saveEvent(EventModel event);
  Future<void> deleteEvent(String id);
}
