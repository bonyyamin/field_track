import 'package:field_tracker/core/error/failures.dart';
import 'package:field_tracker/core/usecase/usecase.dart';
import 'package:field_tracker/features/locations/domain/repositories/location_repository.dart';
import 'package:field_tracker/features/todos/domain/repositories/todo_repository.dart';
import '../entities/profile_stats.dart';

/// Usecase to gather quick profile stats (tasks completed/total and active locations).
class GetProfileStatsUseCase implements UseCase<ProfileStats, NoParams> {
  final TodoRepository todoRepository;
  final LocationRepository locationRepository;

  GetProfileStatsUseCase({
    required this.todoRepository,
    required this.locationRepository,
  });

  @override
  Future<Either<Failure, ProfileStats>> call(NoParams params) async {
    final todosResult = await todoRepository.getTodos();
    final locationsResult = await locationRepository.getLocations();

    int completedTasks = 0;
    int totalTasks = 0;
    int activeLocations = 0;

    todosResult.fold(
      (failure) {},
      (todos) {
        totalTasks = todos.length;
        completedTasks = todos.where((t) => t.isCompleted).length;
      },
    );

    locationsResult.fold(
      (failure) {},
      (locations) {
        activeLocations = locations.where((l) => l.isActive).length;
      },
    );

    return Right(ProfileStats(
      completedTasks: completedTasks,
      totalTasks: totalTasks,
      activeLocationsCount: activeLocations,
    ));
  }
}