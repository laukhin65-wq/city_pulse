import 'package:city_pulse/core/utils/typedefs.dart';
import 'package:city_pulse/features/map/domain/entities/city_event.dart';
import 'package:city_pulse/features/map/domain/repositories/event_repository.dart';

class GetEventById {
  final EventRepository _repository;

  const GetEventById(this._repository);

  ResultFuture<CityEvent?> call(String id) => _repository.getEventById(id);
}
