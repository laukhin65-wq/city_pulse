import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

import 'package:city_pulse/core/di/injection.dart';
import 'package:city_pulse/core/theme/theme_notifier.dart';
import 'package:city_pulse/features/map/data/models/event_model.dart';
import 'package:city_pulse/features/map/presentation/bloc/map_bloc.dart';
import 'package:city_pulse/features/map/presentation/bloc/map_event.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Настройки')),
      body: ListView(
        children: [
          const _SectionHeader(title: 'Внешний вид'),
          ValueListenableBuilder<ThemeMode>(
            valueListenable: themeNotifier,
            builder: (context, currentMode, _) {
              return ListTile(
                leading: Icon(_iconForMode(currentMode)),
                title: const Text('Тема'),
                subtitle: Text(_labelForMode(currentMode)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showThemeDialog(context, currentMode),
              );
            },
          ),
          const Divider(),
          const _SectionHeader(title: 'Данные'),
          ListTile(
            leading: Icon(Icons.delete_outline, color: theme.colorScheme.error),
            title: Text(
              'Очистить все данные',
              style: TextStyle(color: theme.colorScheme.error),
            ),
            subtitle: const Text('Удалить все события и избранное'),
            onTap: () => _confirmClearData(context),
          ),
          const Divider(),
          const _SectionHeader(title: 'О приложении'),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('CityPulse'),
            subtitle: Text('v1.0.0 • MVP'),
          ),
          const ListTile(
            leading: Icon(Icons.code),
            title: Text('Архитектура'),
            subtitle: Text('Clean Architecture + BLoC + Hive'),
          ),
        ],
      ),
    );
  }

  String _labelForMode(ThemeMode mode) => switch (mode) {
        ThemeMode.system => 'Системная',
        ThemeMode.light => 'Светлая',
        ThemeMode.dark => 'Тёмная',
      };

  IconData _iconForMode(ThemeMode mode) => switch (mode) {
        ThemeMode.system => Icons.brightness_auto,
        ThemeMode.light => Icons.light_mode,
        ThemeMode.dark => Icons.dark_mode,
      };

  void _showThemeDialog(BuildContext context, ThemeMode currentMode) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Тема'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ThemeMode.values.map((mode) {
            return ListTile(
              leading: Icon(_iconForMode(mode)),
              title: Text(_labelForMode(mode)),
              trailing: currentMode == mode
                  ? Icon(Icons.check, color: Theme.of(ctx).colorScheme.primary)
                  : null,
              onTap: () {
                themeNotifier.value = mode;
                Navigator.of(ctx).pop();
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _confirmClearData(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Очистить данные?'),
        content: const Text('Все события и избранное будут удалены. Это действие необратимо.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await _clearAllData(context);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Очистить'),
          ),
        ],
      ),
    );
  }

  Future<void> _clearAllData(BuildContext context) async {
    final eventBox = sl<Box<EventModel>>();
    final favoriteBox = sl<Box<String>>();

    await eventBox.clear();
    await favoriteBox.clear();

    if (context.mounted) {
      context.read<MapBloc>().add(const LoadEvents());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Все данные удалены'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
