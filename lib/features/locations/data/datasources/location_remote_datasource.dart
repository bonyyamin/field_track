import 'package:dio/dio.dart';
import 'package:field_tracker/core/constants/api_endpoints.dart';
import 'package:field_tracker/core/error/exceptions.dart';
import '../models/location_model.dart';

abstract class LocationRemoteDataSource {
  Future<List<LocationModel>> getLocations();
  Future<LocationModel> addLocation(LocationModel location);
  Future<LocationModel> updateLocation(LocationModel location);
  Future<void> deleteLocation(String id);
}

class LocationRemoteDataSourceImpl implements LocationRemoteDataSource {
  final Dio _dio;

  const LocationRemoteDataSourceImpl(this._dio);

  @override
  Future<List<LocationModel>> getLocations() async {
    final response = await _dio.get(ApiEndpoints.locations);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = response.data;
      List<dynamic> list;
      if (data is List) {
        list = data;
      } else if (data is Map<String, dynamic> && data.containsKey('data')) {
        list = data['data'] as List;
      } else if (data is Map<String, dynamic> && data.containsKey('locations')) {
        list = data['locations'] as List;
      } else {
        list = [];
      }
      return list.map((json) => LocationModel.fromJson(json as Map<String, dynamic>)).toList();
    }
    throw const ServerException(message: 'Failed to fetch locations');
  }

  @override
  Future<LocationModel> addLocation(LocationModel location) async {
    final response = await _dio.post(
      ApiEndpoints.locations,
      data: location.toJson(),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = response.data;
      Map<String, dynamic> json;
      if (data is Map<String, dynamic> && data.containsKey('data')) {
        json = data['data'] as Map<String, dynamic>;
      } else if (data is Map<String, dynamic> && data.containsKey('location')) {
        json = data['location'] as Map<String, dynamic>;
      } else {
        json = data as Map<String, dynamic>;
      }
      return LocationModel.fromJson(json);
    }
    throw const ServerException(message: 'Failed to add location');
  }

  @override
  Future<LocationModel> updateLocation(LocationModel location) async {
    final response = await _dio.put(
      ApiEndpoints.locationById(location.id),
      data: location.toJson(),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = response.data;
      Map<String, dynamic> json;
      if (data is Map<String, dynamic> && data.containsKey('data')) {
        json = data['data'] as Map<String, dynamic>;
      } else if (data is Map<String, dynamic> && data.containsKey('location')) {
        json = data['location'] as Map<String, dynamic>;
      } else {
        json = data as Map<String, dynamic>;
      }
      return LocationModel.fromJson(json);
    }
    throw const ServerException(message: 'Failed to update location');
  }

  @override
  Future<void> deleteLocation(String id) async {
    final response = await _dio.delete(ApiEndpoints.locationById(id));

    if (response.statusCode == 200 || response.statusCode == 204) {
      return;
    }
    throw const ServerException(message: 'Failed to delete location');
  }
}