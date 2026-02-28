/// Pure domain entity representing a saved weather location.
///
/// No serialization logic here — that belongs in the data layer
/// ([SavedLocationModel]).
class SavedLocation {
  final String id;
  final String cityName;
  final String country;
  final double lat;
  final double lon;
  final bool isCurrentLocation;
  final String? label;

  const SavedLocation({
    required this.id,
    required this.cityName,
    required this.country,
    required this.lat,
    required this.lon,
    this.isCurrentLocation = false,
    this.label,
  });

  SavedLocation copyWith({
    String? id,
    String? cityName,
    String? country,
    double? lat,
    double? lon,
    bool? isCurrentLocation,
    String? Function()? label,
  }) {
    return SavedLocation(
      id: id ?? this.id,
      cityName: cityName ?? this.cityName,
      country: country ?? this.country,
      lat: lat ?? this.lat,
      lon: lon ?? this.lon,
      isCurrentLocation: isCurrentLocation ?? this.isCurrentLocation,
      label: label != null ? label() : this.label,
    );
  }

  /// Create from GPS-determined location.
  factory SavedLocation.fromGps({
    required String cityName,
    required String country,
    required double lat,
    required double lon,
  }) {
    return SavedLocation(
      id: 'gps_current',
      cityName: cityName,
      country: country,
      lat: lat,
      lon: lon,
      isCurrentLocation: true,
    );
  }

  /// Create from a city search.
  factory SavedLocation.fromCity({
    required String cityName,
    required String country,
    required double lat,
    required double lon,
  }) {
    return SavedLocation(
      id: '${cityName.toLowerCase()}_${lat.toStringAsFixed(2)}_${lon.toStringAsFixed(2)}',
      cityName: cityName,
      country: country,
      lat: lat,
      lon: lon,
      isCurrentLocation: false,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SavedLocation &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'SavedLocation($cityName, $country)';
}
