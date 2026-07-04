import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:field_tracker/core/usecase/usecase.dart';
import '../../domain/usecases/location_usecases.dart';
import 'location_event.dart';
import 'location_state.dart';

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  final GetLocationsUseCase getLocationsUseCase;
  final AddLocationUseCase addLocationUseCase;
  final UpdateLocationUseCase updateLocationUseCase;
  final DeleteLocationUseCase deleteLocationUseCase;

  LocationBloc({
    required this.getLocationsUseCase,
    required this.addLocationUseCase,
    required this.updateLocationUseCase,
    required this.deleteLocationUseCase,
  }) : super(const LocationInitial()) {
    on<LoadLocations>(_onLoadLocations);
    on<AddLocation>(_onAddLocation);
    on<UpdateLocation>(_onUpdateLocation);
    on<DeleteLocation>(_onDeleteLocation);
    on<SearchLocations>(_onSearchLocations);
  }

  Future<void> _onLoadLocations(
    LoadLocations event,
    Emitter<LocationState> emit,
  ) async {
    emit(const LocationLoading());
    final result = await getLocationsUseCase(const NoParams());
    result.fold(
      (failure) => emit(LocationError(failure.message)),
      (locations) => emit(
        LocationLoaded(
          allLocations: locations,
          filteredLocations: locations,
        ),
      ),
    );
  }

  Future<void> _onAddLocation(
    AddLocation event,
    Emitter<LocationState> emit,
  ) async {
    emit(const LocationSubmitting());
    final result = await addLocationUseCase(event.location);
    result.fold(
      (failure) => emit(LocationError(failure.message)),
      (created) {
        emit(const LocationSuccess('Location added successfully'));
        add(const LoadLocations());
      },
    );
  }

  Future<void> _onUpdateLocation(
    UpdateLocation event,
    Emitter<LocationState> emit,
  ) async {
    emit(const LocationSubmitting());
    final result = await updateLocationUseCase(event.location);
    result.fold(
      (failure) => emit(LocationError(failure.message)),
      (updated) {
        emit(const LocationSuccess('Location updated successfully'));
        add(const LoadLocations());
      },
    );
  }

  Future<void> _onDeleteLocation(
    DeleteLocation event,
    Emitter<LocationState> emit,
  ) async {
    emit(const LocationSubmitting());
    final result = await deleteLocationUseCase(event.id);
    result.fold(
      (failure) => emit(LocationError(failure.message)),
      (_) {
        emit(const LocationSuccess('Location deleted successfully'));
        add(const LoadLocations());
      },
    );
  }

  void _onSearchLocations(
    SearchLocations event,
    Emitter<LocationState> emit,
  ) {
    if (state is LocationLoaded) {
      final currentState = state as LocationLoaded;
      final query = event.query.trim().toLowerCase();

      if (query.isEmpty) {
        emit(
          LocationLoaded(
            allLocations: currentState.allLocations,
            filteredLocations: currentState.allLocations,
            searchQuery: '',
          ),
        );
      } else {
        final filtered = currentState.allLocations.where((loc) {
          final name = loc.locationName.toLowerCase();
          final coords = '${loc.latitude}, ${loc.longitude}'.toLowerCase();
          return name.contains(query) || coords.contains(query);
        }).toList();

        emit(
          LocationLoaded(
            allLocations: currentState.allLocations,
            filteredLocations: filtered,
            searchQuery: event.query,
          ),
        );
      }
    }
  }
}