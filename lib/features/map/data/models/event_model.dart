import 'package:city_pulse/features/map/domain/entities/city_event.dart';

class EventModel extends CityEvent {
  const EventModel({
    required super.id,
    required super.title,
    required super.description,
    required super.latitude,
    required super.longitude,
    required super.date,
    required super.type,
    super.imageUrl,
    super.venue,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      type: EventType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => EventType.other,
      ),
      imageUrl: json['imageUrl'] as String?,
      venue: json['venue'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'date': date.toIso8601String(),
      'type': type.name,
      'imageUrl': imageUrl,
      'venue': venue,
    };
  }

  factory EventModel.fromEntity(CityEvent entity) {
    return EventModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      latitude: entity.latitude,
      longitude: entity.longitude,
      date: entity.date,
      type: entity.type,
      imageUrl: entity.imageUrl,
      venue: entity.venue,
    );
  }

  CityEvent toEntity() => this;
}
