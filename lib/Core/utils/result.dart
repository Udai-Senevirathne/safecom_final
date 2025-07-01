import '../error/failures.dart';

sealed class Result<T> {
  const Result();

  factory Result.success(T data) = Success<T>;
  factory Result.error(Failure failure) = Error<T>;
}

class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

class Error<T> extends Result<T> {
  final Failure failure;
  const Error(this.failure);
}

extension ResultExtension<T> on Result<T> {
  R fold<R>(R Function(Failure failure) onError, R Function(T data) onSuccess) {
    return switch (this) {
      Success<T>() => onSuccess((this as Success<T>).data),
      Error<T>() => onError((this as Error<T>).failure),
    };
  }

  bool get isSuccess => this is Success<T>;
  bool get isError => this is Error<T>;

  T? get data => switch (this) {
    Success<T>() => (this as Success<T>).data,
    Error<T>() => null,
  };

  Failure? get failure => switch (this) {
    Success<T>() => null,
    Error<T>() => (this as Error<T>).failure,
  };
}
