import 'package:flutter/material.dart';

import 'package:city_pulse/core/utils/event_type_utils.dart';
import 'package:city_pulse/features/map/domain/entities/city_event.dart';

class EventFilterBar extends StatelessWidget {
  final EventType? selected;
  final ValueChanged<EventType?> onSelected;

  const EventFilterBar({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: EventType.values.length + 1,
        separatorBuilder: (a, b) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          if (index == 0) {
            return FilterChip(
              label: const Text('Все'),
              selected: selected == null,
              onSelected: (_) => onSelected(null),
              visualDensity: VisualDensity.compact,
            );
          }

          final type = EventType.values[index - 1];
          final color = EventTypeUtils.colorForType(type);

          return FilterChip(
            avatar: Icon(EventTypeUtils.iconForType(type), size: 16, color: color),
            label: Text(EventTypeUtils.labelForType(type)),
            selected: selected == type,
            onSelected: (_) => onSelected(selected == type ? null : type),
            selectedColor: color.withValues(alpha: 0.15),
            checkmarkColor: color,
            visualDensity: VisualDensity.compact,
          );
        },
      ),
    );
  }

}
