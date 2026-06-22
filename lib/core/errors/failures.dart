import 'package:equatable/equatable.dart';

sealed class Failure extends Equatable {
  const Failure();

  @override
  List<Object?> get props => [];
}

class CacheFailure extends Failure {
  const CacheFailure();
}

class ServerFailure extends Failure {
  final String? message;

  const ServerFailure({this.message});

  @override
  List<Object?> get props => [message];
}

class LocationFailure extends Failure {
  const LocationFailure();
}
