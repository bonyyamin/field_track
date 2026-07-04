import 'package:field_tracker/core/error/error_mapper.dart';
import 'package:field_tracker/core/error/failures.dart';
import 'package:field_tracker/core/network/network_info.dart';
import 'package:field_tracker/core/usecase/usecase.dart';
import '../../domain/entities/location_entity.dart';
import '../../domain/repositories/location_repository.dart';
import '../datasources/location_local_datasource.dart';
import '../datasources/location_remote_datasource.dart';
import '../models/location_model.dart';

class LocationRepositoryImpl implements LocationRepository {
  final LocationRemoteDataSource _remoteDataSource;
  final LocationLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;

  const LocationRepositoryImpl({
    required this._remoteDataSource,
    required this._localDataSource,
    required this._networkInfo,
  });

  @override
  Future<Either<Failure, List<LocationEntity>>> getLocations() async {
    final isOnline = await _networkInfo.isConnected;
    if (isOnline) {
      try {
        final remoteLocations = await _remoteDataSource.getLocations();
        await _localDataSource.cacheLocations(remoteLocations);
        return Right(remoteLocations);
      } catch (e) {
        try {
          final localLocations = await _localDataSource.getCachedLocations();
          if (localLocations.isNotEmpty) {
            return Right(localLocations);
          }
        } catch (_) {}
        return Left(mapExceptionToFailure(e));
      }
    } else {
      try {
        final localLocations = await _localDataSource.getCachedLocations();
        return Right(localLocations);
      } catch (e) {
        return Left(mapExceptionToFailure(e));
      }
    }
  }

  @override
  Future<Either<Failure, LocationEntity>> addLocation(LocationEntity location) async {
    final model = LocationModel.fromEntity(location);
    try {
      final createdModel = await _remoteDataSource.addLocation(model);
      await _localDataSource.saveLocation(createdModel);
      return Right(createdModel);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, LocationEntity>> updateLocation(LocationEntity location) async {
    final model = LocationModel.fromEntity(location);
    try {
      final updatedModel = await _remoteDataSource.updateLocation(model);
      await _localDataSource.saveLocation(updatedModel);
      return Right(updatedModel);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteLocation(String id) async {
    try {
      await _remoteDataSource.deleteLocation(id);
      await _localDataSource.deleteLocation(id);
      return const Right(null);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }
}