import 'package:city_pulse/core/utils/typedefs.dart';
import 'package:city_pulse/features/map/domain/entities/city_event.dart';
import 'package:city_pulse/features/map/domain/repositories/event_repository.dart';

class GetEvents {
  final EventRepository _repository;

  const GetEvents(this._repository);

  ResultFuture<List<CityEvent>> call() => _repository.getEvents();
}
