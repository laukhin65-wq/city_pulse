import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

import 'package:city_pulse/core/di/injection.dart';
import 'package:city_pulse/core/utils/event_type_utils.dart';
import 'package:city_pulse/features/map/domain/entities/city_event.dart';
import 'package:city_pulse/features/map/presentation/bloc/map_bloc.dart';
import 'package:city_pulse/features/map/presentation/bloc/map_event.dart';
import 'package:city_pulse/features/map/presentation/cubit/create_event_cubit.dart';
import 'package:city_pulse/features/map/presentation/widgets/map_picker.dart';

class EditEventPage extends StatelessWidget {
  final CityEvent event;

  const EditEventPage({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CreateEventCubit(saveEvent: sl()),
      child: EditEventView(event: event),
    );
  }
}

class EditEventView extends StatefulWidget {
  final CityEvent event;

  const EditEventView({super.key, required this.event});

  @override
  State<EditEventView> createState() => _EditEventViewState();
}

class _EditEventViewState extends State<EditEventView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _venueController;

  late EventType _selectedType;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  LatLng? _selectedLocation;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.event.title);
    _descriptionController = TextEditingController(text: widget.event.description);
    _venueController = TextEditingController(text: widget.event.venue ?? '');
    _selectedType = widget.event.type;
    _selectedDate = widget.event.date;
    _selectedTime = TimeOfDay.fromDateTime(widget.event.date);
    _selectedLocation = LatLng(widget.event.latitude, widget.event.longitude);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _venueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<CreateEventCubit, CreateEventState>(
      listener: (context, state) {
        if (state.status == CreateEventStatus.success) {
          context.read<MapBloc>().add(const LoadEvents());
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Событие обновлено'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (state.status == CreateEventStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Ошибка: ${state.failure}'),
              backgroundColor: theme.colorScheme.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Редактировать'),
          actions: [
            BlocBuilder<CreateEventCubit, CreateEventState>(
              builder: (context, state) {
                return IconButton(
                  icon: state.status == CreateEventStatus.submitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.check),
                  onPressed: state.status == CreateEventStatus.submitting
                      ? null
                      : _submit,
                );
              },
            ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Название',
                  prefixIcon: Icon(Icons.title),
                ),
                textCapitalization: TextCapitalization.sentences,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Введите название';
                  if (value.trim().length < 3) return 'Минимум 3 символа';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Описание',
                  prefixIcon: Icon(Icons.description),
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Введите описание';
                  if (value.trim().length < 10) return 'Минимум 10 символов';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _venueController,
                decoration: const InputDecoration(
                  labelText: 'Место проведения',
                  prefixIcon: Icon(Icons.place),
                ),
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 24),
              Text(
                'Тип события',
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: EventType.values.map((type) {
                  final isSelected = _selectedType == type;
                  final color = EventTypeUtils.colorForType(type);
                  return ChoiceChip(
                    avatar: Icon(EventTypeUtils.iconForType(type), size: 18,
                        color: isSelected ? color : theme.colorScheme.onSurface),
                    label: Text(EventTypeUtils.labelForType(type)),
                    selected: isSelected,
                    selectedColor: color.withValues(alpha: 0.15),
                    onSelected: (_) => setState(() => _selectedType = type),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              Text(
                'Дата и время',
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickDate,
                      icon: const Icon(Icons.calendar_today),
                      label: Text(DateFormat.yMMMd('ru').format(_selectedDate)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickTime,
                      icon: const Icon(Icons.access_time),
                      label: Text(_selectedTime.format(context)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Местоположение на карте',
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              MapPicker(
                selectedLocation: _selectedLocation,
                onLocationSelected: (latLng) => setState(() => _selectedLocation = latLng),
              ),
              const SizedBox(height: 32),
              BlocBuilder<CreateEventCubit, CreateEventState>(
                builder: (context, state) {
                  return FilledButton.icon(
                    onPressed: state.status == CreateEventStatus.submitting ? null : _submit,
                    icon: state.status == CreateEventStatus.submitting
                        ? const SizedBox(width: 18, height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.save),
                    label: Text(state.status == CreateEventStatus.submitting
                        ? 'Сохранение...'
                        : 'Сохранить'),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final updated = CityEvent(
      id: widget.event.id,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      latitude: _selectedLocation?.latitude ?? widget.event.latitude,
      longitude: _selectedLocation?.longitude ?? widget.event.longitude,
      date: DateTime(
        _selectedDate.year, _selectedDate.month, _selectedDate.day,
        _selectedTime.hour, _selectedTime.minute,
      ),
      type: _selectedType,
      venue: _venueController.text.trim().isEmpty ? null : _venueController.text.trim(),
    );

    context.read<CreateEventCubit>().submit(updated);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _selectedTime);
    if (picked != null) setState(() => _selectedTime = picked);
  }
}
