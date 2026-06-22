import 'package:dartz/dartz.dart';
import 'package:hive/hive.dart';

import 'package:city_pulse/core/errors/failures.dart';
import 'package:city_pulse/core/utils/typedefs.dart';
import 'package:city_pulse/features/map/data/datasources/favorite_local_datasource.dart';
import 'package:city_pulse/features/map/domain/repositories/favorite_repository.dart';

class FavoriteLocalDatasourceImpl
    implements FavoriteLocalDatasource, FavoriteRepository {
  final Box<String> _box;

  const FavoriteLocalDatasourceImpl(this._box);

  @override
  ResultFuture<List<String>> getFavoriteIds() async {
    try {
      return Right(_box.values.toList());
    } on Exception {
      return const Left(CacheFailure());
    }
  }

  @override
  ResultFuture<bool> isFavorite(String eventId) async {
    try {
      return Right(_box.containsKey(eventId));
    } on Exception {
      return const Left(CacheFailure());
    }
  }

  @override
  ResultFuture<Unit> toggleFavorite(String eventId) async {
    try {
      if (_box.containsKey(eventId)) {
        await _box.delete(eventId);
      } else {
        await _box.put(eventId, eventId);
      }
      return Right(unit);
    } on Exception {
      return const Left(CacheFailure());
    }
  }

  @override
  ResultFuture<Unit> removeFavorite(String eventId) async {
    try {
      await _box.delete(eventId);
      return Right(unit);
    } on Exception {
      return const Left(CacheFailure());
    }
  }
}
