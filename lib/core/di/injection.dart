import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:city_pulse/core/adapters/event_model_adapter.dart';
import 'package:city_pulse/core/data/seed_service.dart';
import 'package:city_pulse/features/map/data/datasources/event_local_datasource.dart';
import 'package:city_pulse/features/map/data/datasources/event_local_datasource_impl.dart';
import 'package:city_pulse/features/map/data/datasources/favorite_local_datasource.dart';
import 'package:city_pulse/features/map/data/datasources/favorite_local_datasource_impl.dart';
import 'package:city_pulse/features/map/data/models/event_model.dart';
import 'package:city_pulse/features/map/data/repositories/event_repository_impl.dart';
import 'package:city_pulse/features/map/domain/repositories/event_repository.dart';
import 'package:city_pulse/features/map/domain/repositories/favorite_repository.dart';
import 'package:city_pulse/features/map/domain/usecases/delete_event.dart';
import 'package:city_pulse/features/map/domain/usecases/get_event_by_id.dart';
import 'package:city_pulse/features/map/domain/usecases/get_events.dart';
import 'package:city_pulse/features/map/domain/usecases/save_event.dart';
import 'package:city_pulse/features/map/presentation/bloc/map_bloc.dart';
import 'package:city_pulse/features/map/presentation/cubit/create_event_cubit.dart';
import 'package:city_pulse/features/map/presentation/cubit/favorite_cubit.dart';

final sl = GetIt.instance;

Future<void> init() async {
  await Hive.initFlutter();
  Hive.registerAdapter(EventModelAdapter());

  final eventBox = await Hive.openBox<EventModel>('events');
  final favoriteBox = await Hive.openBox<String>('favorites');

  final seedService = SeedService(eventBox);
  await seedService.seedIfEmpty();

  sl.registerLazySingleton<Box<EventModel>>(() => eventBox);
  sl.registerLazySingleton<Box<String>>(() => favoriteBox);
  sl.registerLazySingleton<SeedService>(() => seedService);

  sl.registerLazySingleton<EventLocalDatasource>(
    () => EventLocalDatasourceImpl(sl()),
  );

  sl.registerLazySingleton<FavoriteLocalDatasourceImpl>(
    () => FavoriteLocalDatasourceImpl(sl()),
  );

  sl.registerLazySingleton<FavoriteLocalDatasource>(
    () => sl<FavoriteLocalDatasourceImpl>(),
  );

  sl.registerLazySingleton<EventRepository>(
    () => EventRepositoryImpl(sl()),
  );

  sl.registerLazySingleton<FavoriteRepository>(
    () => sl<FavoriteLocalDatasourceImpl>(),
  );

  sl.registerLazySingleton(() => GetEvents(sl()));
  sl.registerLazySingleton(() => GetEventById(sl()));
  sl.registerLazySingleton(() => SaveEvent(sl()));
  sl.registerLazySingleton(() => DeleteEvent(sl()));

  sl.registerFactory(
    () => MapBloc(getEvents: sl()),
  );
  sl.registerFactory(
    () => CreateEventCubit(saveEvent: sl()),
  );
  sl.registerFactory(
    () => FavoriteCubit(
      favoriteRepository: sl(),
      eventRepository: sl(),
    ),
  );
}
