import 'package:equatable/equatable.dart';

enum EventType {
  concert,
  festival,
  exhibition,
  sport,
  market,
  meetup,
  other,
}

class CityEvent extends Equatable {
  final String id;
  final String title;
  final String description;
  final double latitude;
  final double longitude;
  final DateTime date;
  final EventType type;
  final String? imageUrl;
  final String? venue;

  const CityEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.date,
    required this.type,
    this.imageUrl,
    this.venue,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        latitude,
        longitude,
        date,
        type,
        imageUrl,
        venue,
      ];
}
