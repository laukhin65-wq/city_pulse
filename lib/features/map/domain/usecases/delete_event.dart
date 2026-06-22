import 'package:dartz/dartz.dart';

import 'package:city_pulse/core/utils/typedefs.dart';
import 'package:city_pulse/features/map/domain/repositories/event_repository.dart';

class DeleteEvent {
  final EventRepository _repository;

  const DeleteEvent(this._repository);

  ResultFuture<Unit> call(String id) => _repository.deleteEvent(id);
}
