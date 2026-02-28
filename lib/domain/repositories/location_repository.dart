import '../entities/saved_location.dart';

/// Abstract contract for persisting and retrieving saved locations.
abstract class LocationRepository {
  /// Get all saved locations, ordered.
  List<SavedLocation> getSavedLocations();

  /// Persist the full ordered list of locations.
  Future<void> saveLocations(List<SavedLocation> locations);

  /// Add a location (or update if it already exists by id).
  /// Returns the index of the location in the list.
  Future<int> addLocation(SavedLocation location);

  /// Remove a location by its [id].
  Future<void> removeLocation(String id);

  /// Insert or update the GPS "current location" entry.
  Future<void> updateGpsLocation(SavedLocation gpsLocation);

  /// Get the persisted active location index.
  int getActiveIndex();

  /// Persist the active location index.
  Future<void> setActiveIndex(int index);
}
