import 'package:field_tracker/core/error/failures.dart';
import 'package:field_tracker/core/usecase/usecase.dart';
import '../entities/location_entity.dart';
import '../repositories/location_repository.dart';

class GetLocationsUseCase implements UseCase<List<LocationEntity>, NoParams> {
  final LocationRepository repository;

  const GetLocationsUseCase(this.repository);

  @override
  Future<Either<Failure, List<LocationEntity>>> call(NoParams params) {
    return repository.getLocations();
  }
}

class AddLocationUseCase implements UseCase<LocationEntity, LocationEntity> {
  final LocationRepository repository;

  const AddLocationUseCase(this.repository);

  @override
  Future<Either<Failure, LocationEntity>> call(LocationEntity location) {
    return repository.addLocation(location);
  }
}

class UpdateLocationUseCase implements UseCase<LocationEntity, LocationEntity> {
  final LocationRepository repository;

  const UpdateLocationUseCase(this.repository);

  @override
  Future<Either<Failure, LocationEntity>> call(LocationEntity location) {
    return repository.updateLocation(location);
  }
}

class DeleteLocationUseCase implements UseCase<void, String> {
  final LocationRepository repository;

  const DeleteLocationUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String id) {
    return repository.deleteLocation(id);
  }
}
