import 'package:dartz/dartz.dart';

import 'package:city_pulse/core/utils/typedefs.dart';

abstract interface class FavoriteRepository {
  ResultFuture<List<String>> getFavoriteIds();
  ResultFuture<bool> isFavorite(String eventId);
  ResultFuture<Unit> toggleFavorite(String eventId);
  ResultFuture<Unit> removeFavorite(String eventId);
}
