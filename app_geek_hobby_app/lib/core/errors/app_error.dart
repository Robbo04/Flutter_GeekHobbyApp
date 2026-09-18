enum AppErrorType {
  network,
  api,
  cache,
  configuration,
  unknown,
}

class AppError implements Exception {
  const AppError({
    required this.message,
    this.type = AppErrorType.unknown,
    this.cause,
  });

  final String message;
  final AppErrorType type;
  final Object? cause;

  @override
  String toString() => 'AppError(type: $type, message: $message, cause: $cause)';
}
