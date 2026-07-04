import 'package:equatable/equatable.dart';

/// Domain entity representing profile summary statistics.
class ProfileStats extends Equatable {
  final int completedTasks;
  final int totalTasks;
  final int activeLocationsCount;

  const ProfileStats({
    required this.completedTasks,
    required this.totalTasks,
    required this.activeLocationsCount,
  });

  @override
  List<Object?> get props => [
        completedTasks,
        totalTasks,
        activeLocationsCount,
      ];
}
