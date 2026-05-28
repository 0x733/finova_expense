sealed class Result<T> {
  const Result();

  R when<R>({required R Function(T data) success, required R Function(String message) failure}) {
    final self = this;
    if (self is Success<T>) {
      return success(self.data);
    }
    return failure((self as Failure<T>).message);
  }
}

final class Success<T> extends Result<T> {
  const Success(this.data);

  final T data;
}

final class Failure<T> extends Result<T> {
  const Failure(this.message);

  final String message;
}
