import 'package:dartz/dartz.dart';

import 'package:city_pulse/core/errors/exceptions.dart';
import 'package:city_pulse/core/errors/failures.dart';
import 'package:city_pulse/core/utils/typedefs.dart';
import 'package:city_pulse/features/map/domain/entities/city_event.dart';
import 'package:city_pulse/features/map/domain/repositories/event_repository.dart';
import 'package:city_pulse/features/map/data/datasources/event_local_datasource.dart';
import 'package:city_pulse/features/map/data/models/event_model.dart';

class EventRepositoryImpl implements EventRepository {
  final EventLocalDatasource _localDatasource;

  const EventRepositoryImpl(this._localDatasource);

  @override
  ResultFuture<List<CityEvent>> getEvents() async {
    try {
      final models = await _localDatasource.getEvents();
      return Right(models.map((m) => m.toEntity()).toList());
    } on CacheException {
      return const Left(CacheFailure());
    }
  }

  @override
  ResultFuture<List<CityEvent>> getEventsByIds(List<String> ids) async {
    try {
      final models = <EventModel>[];
      for (final id in ids) {
        final model = await _localDatasource.getEventById(id);
        if (model != null) models.add(model);
      }
      return Right(models.map((m) => m.toEntity()).toList());
    } on CacheException {
      return const Left(CacheFailure());
    }
  }

  @override
  ResultFuture<CityEvent?> getEventById(String id) async {
    try {
      final model = await _localDatasource.getEventById(id);
      return Right(model?.toEntity());
    } on CacheException {
      return const Left(CacheFailure());
    }
  }

  @override
  ResultFuture<Unit> saveEvent(CityEvent event) async {
    try {
      await _localDatasource.saveEvent(EventModel.fromEntity(event));
      return const Right(unit);
    } on CacheException {
      return const Left(CacheFailure());
    }
  }

  @override
  ResultFuture<Unit> deleteEvent(String id) async {
    try {
      await _localDatasource.deleteEvent(id);
      return const Right(unit);
    } on CacheException {
      return const Left(CacheFailure());
    }
  }
}
