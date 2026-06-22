import 'package:dartz/dartz.dart';

import 'package:city_pulse/core/utils/typedefs.dart';
import 'package:city_pulse/features/map/domain/entities/city_event.dart';
import 'package:city_pulse/features/map/domain/repositories/event_repository.dart';

class SaveEvent {
  final EventRepository _repository;

  const SaveEvent(this._repository);

  ResultFuture<Unit> call(CityEvent event) => _repository.saveEvent(event);
}
