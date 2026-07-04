import 'package:equatable/equatable.dart';
import '../../domain/entities/location_entity.dart';

sealed class LocationState extends Equatable {
  const LocationState();

  @override
  List<Object?> get props => [];
}

class LocationInitial extends LocationState {
  const LocationInitial();
}

class LocationLoading extends LocationState {
  const LocationLoading();
}

class LocationLoaded extends LocationState {
  final List<LocationEntity> allLocations;
  final List<LocationEntity> filteredLocations;
  final String searchQuery;

  const LocationLoaded({
    required this.allLocations,
    required this.filteredLocations,
    this.searchQuery = '',
  });

  @override
  List<Object?> get props => [allLocations, filteredLocations, searchQuery];
}

class LocationSubmitting extends LocationState {
  const LocationSubmitting();
}

class LocationSuccess extends LocationState {
  final String message;

  const LocationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class LocationError extends LocationState {
  final String message;

  const LocationError(this.message);

  @override
  List<Object?> get props => [message];
}