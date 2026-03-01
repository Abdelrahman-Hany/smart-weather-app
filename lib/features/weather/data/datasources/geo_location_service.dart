import 'package:geolocator/geolocator.dart';

/// Service responsible for determining the device's GPS position.
///
/// Encapsulates permission checks and error translation so that consumers
/// don't depend on the Geolocator API directly.
class GeoLocationService {
  /// Returns the current device position.
  ///
  /// Throws an [Exception] with a user-friendly message when location
  /// services are disabled or permissions are denied.
  Future<Position> determinePosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Location permissions are permanently denied. '
        'Please enable them in settings.',
      );
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.low,
        timeLimit: Duration(seconds: 10),
      ),
    );
  }
}
