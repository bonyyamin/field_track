import 'package:equatable/equatable.dart';
import '../../domain/entities/location_entity.dart';

sealed class LocationEvent extends Equatable {
  const LocationEvent();

  @override
  List<Object?> get props => [];
}

class LoadLocations extends LocationEvent {
  const LoadLocations();
}

class AddLocation extends LocationEvent {
  final LocationEntity location;

  const AddLocation(this.location);

  @override
  List<Object?> get props => [location];
}

class UpdateLocation extends LocationEvent {
  final LocationEntity location;

  const UpdateLocation(this.location);

  @override
  List<Object?> get props => [location];
}

class DeleteLocation extends LocationEvent {
  final String id;

  const DeleteLocation(this.id);

  @override
  List<Object?> get props => [id];
}

class SearchLocations extends LocationEvent {
  final String query;

  const SearchLocations(this.query);

  @override
  List<Object?> get props => [query];
}