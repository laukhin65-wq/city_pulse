import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:city_pulse/core/di/injection.dart';
import 'package:city_pulse/core/utils/event_type_utils.dart';
import 'package:city_pulse/features/map/domain/entities/city_event.dart';
import 'package:city_pulse/features/map/presentation/bloc/map_bloc.dart';
import 'package:city_pulse/features/map/presentation/bloc/map_event.dart';
import 'package:city_pulse/features/map/presentation/bloc/map_state.dart';
import 'package:city_pulse/features/map/presentation/pages/create_event_page.dart';
import 'package:city_pulse/features/map/presentation/pages/event_detail_page.dart';
import 'package:city_pulse/features/map/presentation/widgets/event_filter_bar.dart';
import 'package:city_pulse/features/map/presentation/widgets/event_search_bar.dart';

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<MapBloc>()..add(const LoadEvents()),
      child: const MapView(),
    );
  }
}

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  EventType? _selectedFilter;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: BlocBuilder<MapBloc, MapState>(
        builder: (context, state) {
          return Column(
            children: [
              SizedBox(height: MediaQuery.of(context).padding.top),
              EventSearchBar(
                onChanged: (query) => setState(() => _searchQuery = query),
              ),
              const SizedBox(height: 4),
              EventFilterBar(
                selected: _selectedFilter,
                onSelected: (type) => setState(() => _selectedFilter = type),
              ),
              Expanded(
                child: _buildBody(state, theme),
              ),
            ],
          );
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: FloatingActionButton.extended(
          heroTag: 'create_event',
          onPressed: () => _openCreateEvent(context),
          shape: const StadiumBorder(),
          icon: const Icon(Icons.add),
          label: const Text('Событие', style: TextStyle(fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }

  Widget _buildBody(MapState state, ThemeData theme) {
    if (state is MapLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is MapError) {
      return Center(
        child: Card(
          margin: const EdgeInsets.all(32),
          color: theme.colorScheme.errorContainer,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.cloud_off, size: 48, color: theme.colorScheme.error),
                const SizedBox(height: 16),
                Text('Ошибка загрузки',
                    style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.onError)),
                const SizedBox(height: 8),
                Text(state.message, textAlign: TextAlign.center,
                    style: TextStyle(color: theme.colorScheme.onError)),
                const SizedBox(height: 16),
                FilledButton.tonal(
                  onPressed: () => context.read<MapBloc>().add(const LoadEvents()),
                  child: const Text('Повторить'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (state is MapLoaded) {
      final events = _filteredEvents(state);

      if (events.isEmpty) {
        return Center(
          child: Card(
            margin: const EdgeInsets.all(32),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _searchQuery.isNotEmpty ? Icons.search_off : Icons.event_busy,
                    size: 48,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _searchQuery.isNotEmpty ? 'Ничего не найдено' : 'Нет событий',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _searchQuery.isNotEmpty
                        ? 'По запросу «$_searchQuery» ничего не найдено'
                        : 'События пока не добавлены',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }

      return _EventList(
        events: events,
        onEventTap: _openDetail,
      );
    }

    return const SizedBox.shrink();
  }

  List<CityEvent> _filteredEvents(MapLoaded state) {
    var events = state.events;

    if (_selectedFilter != null) {
      events = events.where((e) => e.type == _selectedFilter).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      events = events.where((e) =>
          e.title.toLowerCase().contains(query) ||
          e.description.toLowerCase().contains(query) ||
          (e.venue?.toLowerCase().contains(query) ?? false)).toList();
    }

    return events;
  }

  void _openDetail(CityEvent event) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => EventDetailPage(event: event)),
    );
  }

  void _openCreateEvent(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const CreateEventPage()),
    );
  }
}

class _EventList extends StatelessWidget {
  final List<CityEvent> events;
  final ValueChanged<CityEvent> onEventTap;

  const _EventList({required this.events, required this.onEventTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Icon(Icons.map, size: 16, color: theme.colorScheme.primary),
              const SizedBox(width: 6),
              Text(
                '${events.length} событий',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
              const Spacer(),
              Text(
                'Карта недоступна (нет API ключа)',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return _EventCard(event: event, onTap: () => onEventTap(event));
            },
          ),
        ),
      ],
    );
  }
}

class _EventCard extends StatelessWidget {
  final CityEvent event;
  final VoidCallback onTap;

  const _EventCard({required this.event, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = EventTypeUtils.colorForType(event.type);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(EventTypeUtils.iconForType(event.type), color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      event.venue ?? 'Место не указано',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: theme.colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
