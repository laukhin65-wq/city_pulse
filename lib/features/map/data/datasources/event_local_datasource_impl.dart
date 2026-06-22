import 'package:hive/hive.dart';

import 'package:city_pulse/core/errors/exceptions.dart';
import 'package:city_pulse/features/map/data/models/event_model.dart';
import 'package:city_pulse/features/map/data/datasources/event_local_datasource.dart';

class EventLocalDatasourceImpl implements EventLocalDatasource {
  final Box<EventModel> _box;

  const EventLocalDatasourceImpl(this._box);

  @override
  Future<List<EventModel>> getEvents() async {
    try {
      return _box.values.toList();
    } on Exception {
      throw const CacheException();
    }
  }

  @override
  Future<EventModel?> getEventById(String id) async {
    try {
      return _box.get(id);
    } on Exception {
      throw const CacheException();
    }
  }

  @override
  Future<void> saveEvent(EventModel event) async {
    try {
      await _box.put(event.id, event);
    } on Exception {
      throw const CacheException();
    }
  }

  @override
  Future<void> deleteEvent(String id) async {
    try {
      await _box.delete(id);
    } on Exception {
      throw const CacheException();
    }
  }
}
