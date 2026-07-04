import 'package:equatable/equatable.dart';
import '../error/failures.dart';

/// Sealed functional Either class representing either a Left (Failure) or Right (Success).
sealed class Either<L, R> {
  const Either();

  bool get isLeft => this is Left<L, R>;
  bool get isRight => this is Right<L, R>;

  L? get leftOrNull => isLeft ? (this as Left<L, R>).value : null;
  R? get rightOrNull => isRight ? (this as Right<L, R>).value : null;

  T fold<T>(T Function(L left) onLeft, T Function(R right) onRight);
}

/// Represents the failure case (Left).
final class Left<L, R> extends Either<L, R> {
  final L value;
  const Left(this.value);

  @override
  T fold<T>(T Function(L left) onLeft, T Function(R right) onRight) {
    return onLeft(value);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Left<L, R> && other.value == value);

  @override
  int get hashCode => value.hashCode;
}

/// Represents the success case (Right).
final class Right<L, R> extends Either<L, R> {
  final R value;
  const Right(this.value);

  @override
  T fold<T>(T Function(L left) onLeft, T Function(R right) onRight) {
    return onRight(value);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Right<L, R> && other.value == value);

  @override
  int get hashCode => value.hashCode;
}

/// Abstract UseCase contract that all domain feature use cases implement.
abstract class UseCase<T, Params> {
  Future<Either<Failure, T>> call(Params params);
}

/// Helper class for UseCases that accept no input parameters.
class NoParams extends Equatable {
  const NoParams();

  @override
  List<Object?> get props => [];
}