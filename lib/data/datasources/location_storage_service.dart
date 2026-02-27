import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/saved_location.dart';

class LocationStorageService {
  static const _locationsKey = 'saved_locations';
  static const _activeIndexKey = 'active_location_index';

  final SharedPreferences _prefs;

  LocationStorageService(this._prefs);

  /// Get all saved locations, ordered.
  List<SavedLocation> getSavedLocations() {
    final jsonList = _prefs.getStringList(_locationsKey);
    if (jsonList == null || jsonList.isEmpty) return [];
    return jsonList
        .map(
          (s) => SavedLocation.fromJson(jsonDecode(s) as Map<String, dynamic>),
        )
        .toList();
  }

  /// Save the full list of locations.
  Future<void> saveLocations(List<SavedLocation> locations) async {
    final jsonList = locations.map((loc) => jsonEncode(loc.toJson())).toList();
    await _prefs.setStringList(_locationsKey, jsonList);
  }

  /// Add a location. If it already exists (by id), it won't be duplicated.
  /// Returns the index of the location.
  Future<int> addLocation(SavedLocation location) async {
    final locations = getSavedLocations();
    final existingIndex = locations.indexWhere((l) => l.id == location.id);
    if (existingIndex != -1) {
      // Update the existing entry.
      locations[existingIndex] = location;
      await saveLocations(locations);
      return existingIndex;
    }
    locations.add(location);
    await saveLocations(locations);
    return locations.length - 1;
  }

  /// Remove a location by id.
  Future<void> removeLocation(String id) async {
    final locations = getSavedLocations();
    locations.removeWhere((l) => l.id == id);
    await saveLocations(locations);
  }

  /// Update the "current GPS" location entry (keeps it at index 0 or inserts).
  Future<void> updateGpsLocation(SavedLocation gpsLocation) async {
    final locations = getSavedLocations();
    final gpsIndex = locations.indexWhere((l) => l.isCurrentLocation);
    if (gpsIndex != -1) {
      locations[gpsIndex] = gpsLocation;
    } else {
      locations.insert(0, gpsLocation);
    }
    await saveLocations(locations);
  }

  /// Get active location index.
  int getActiveIndex() => _prefs.getInt(_activeIndexKey) ?? 0;

  /// Save active location index.
  Future<void> setActiveIndex(int index) async {
    await _prefs.setInt(_activeIndexKey, index);
  }
}
