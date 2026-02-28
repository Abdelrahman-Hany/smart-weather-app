/// Converts raw errors/exceptions into user-friendly messages.
class ErrorHandler {
  const ErrorHandler._();

  /// Returns a human-readable string for the given [error].
  static String getMessage(Object error) {
    final message = error.toString();

    if (message.contains('City not found')) {
      return 'City not found. Please check the name and try again.';
    }
    if (message.contains('Location')) {
      return message.replaceAll('Exception: ', '');
    }
    if (message.contains('SocketException') ||
        message.contains('ClientException')) {
      return 'No internet connection. Please check your network.';
    }
    return 'Something went wrong. Please try again.';
  }
}
