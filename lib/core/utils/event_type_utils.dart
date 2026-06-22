import 'package:flutter/material.dart';

import 'package:city_pulse/features/map/domain/entities/city_event.dart';

class EventTypeUtils {
  EventTypeUtils._();

  static Color colorForType(EventType type) => switch (type) {
        EventType.concert => Colors.deepPurple,
        EventType.festival => Colors.orange,
        EventType.exhibition => Colors.blue,
        EventType.sport => Colors.green,
        EventType.market => Colors.amber,
        EventType.meetup => Colors.pink,
        EventType.other => Colors.grey,
      };

  static IconData iconForType(EventType type) => switch (type) {
        EventType.concert => Icons.music_note,
        EventType.festival => Icons.celebration,
        EventType.exhibition => Icons.palette,
        EventType.sport => Icons.sports,
        EventType.market => Icons.store,
        EventType.meetup => Icons.people,
        EventType.other => Icons.location_on,
      };

  static String labelForType(EventType type) => switch (type) {
        EventType.concert => 'Концерт',
        EventType.festival => 'Фестиваль',
        EventType.exhibition => 'Выставка',
        EventType.sport => 'Спорт',
        EventType.market => 'Маркет',
        EventType.meetup => 'Встреча',
        EventType.other => 'Другое',
      };
}
