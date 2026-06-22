import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:city_pulse/core/errors/failures.dart';
import 'package:city_pulse/features/map/domain/entities/city_event.dart';
import 'package:city_pulse/features/map/domain/usecases/save_event.dart';

enum CreateEventStatus { initial, submitting, success, error }

class CreateEventState extends Equatable {
  final CreateEventStatus status;
  final Failure? failure;

  const CreateEventState({
    this.status = CreateEventStatus.initial,
    this.failure,
  });

  CreateEventState copyWith({
    CreateEventStatus? status,
    Failure? Function()? failure,
  }) {
    return CreateEventState(
      status: status ?? this.status,
      failure: failure != null ? failure() : this.failure,
    );
  }

  @override
  List<Object?> get props => [status, failure];
}

class CreateEventCubit extends Cubit<CreateEventState> {
  final SaveEvent _saveEvent;

  CreateEventCubit({required SaveEvent saveEvent})
      // ignore: prefer_initializing_formals
      : _saveEvent = saveEvent,
        super(const CreateEventState());

  Future<void> submit(CityEvent event) async {
    emit(state.copyWith(status: CreateEventStatus.submitting));

    final result = await _saveEvent(event);

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: CreateEventStatus.error,
          failure: () => failure,
        ),
      ),
      (_) => emit(state.copyWith(status: CreateEventStatus.success)),
    );
  }
}
