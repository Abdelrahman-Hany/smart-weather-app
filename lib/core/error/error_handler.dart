import '../error/exceptions.dart';
import '../error/failures.dart';

/// Converts raw errors/exceptions into user-friendly [Failures].
class ErrorHandler {
  const ErrorHandler._();

  /// Returns a [Failures] for the given [error].
  static Failures handle(Object error) {
    if (error is ServerException) {
      return Failures(message: error.message);
    }

    final message = error.toString();

    if (message.contains('City not found')) {
      return Failures(
        message: 'City not found. Please check the name and try again.',
      );
    }
    if (message.contains('Location')) {
      return Failures(message: message.replaceAll('Exception: ', ''));
    }
    if (message.contains('SocketException') ||
        message.contains('ClientException')) {
      return Failures(
        message: 'No internet connection. Please check your network.',
      );
    }
    return Failures(message: 'Something went wrong. Please try again.');
  }

  /// Returns a human-readable string for the given [error].
  static String getMessage(Object error) => handle(error).message;
}
