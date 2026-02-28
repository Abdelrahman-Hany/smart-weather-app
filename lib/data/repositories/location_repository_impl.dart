import '../../domain/entities/saved_location.dart';
import '../../domain/repositories/location_repository.dart';
import '../datasources/location_storage_service.dart';

/// Concrete implementation of [LocationRepository] backed by [LocationStorageService].
class LocationRepositoryImpl implements LocationRepository {
  final LocationStorageService _storage;

  LocationRepositoryImpl({required LocationStorageService storage})
    : _storage = storage;

  @override
  List<SavedLocation> getSavedLocations() => _storage.getSavedLocations();

  @override
  Future<void> saveLocations(List<SavedLocation> locations) =>
      _storage.saveLocations(locations);

  @override
  Future<int> addLocation(SavedLocation location) =>
      _storage.addLocation(location);

  @override
  Future<void> removeLocation(String id) => _storage.removeLocation(id);

  @override
  Future<void> updateGpsLocation(SavedLocation gpsLocation) =>
      _storage.updateGpsLocation(gpsLocation);

  @override
  int getActiveIndex() => _storage.getActiveIndex();

  @override
  Future<void> setActiveIndex(int index) => _storage.setActiveIndex(index);
}
