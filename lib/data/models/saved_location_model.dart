import 'dart:convert';

import '../../domain/entities/saved_location.dart';

/// Data-layer model that adds JSON serialization to [SavedLocation].
class SavedLocationModel extends SavedLocation {
  const SavedLocationModel({
    required super.id,
    required super.cityName,
    required super.country,
    required super.lat,
    required super.lon,
    super.isCurrentLocation,
    super.label,
  });

  /// Convert a domain [SavedLocation] to a serialisable [SavedLocationModel].
  factory SavedLocationModel.fromEntity(SavedLocation entity) {
    return SavedLocationModel(
      id: entity.id,
      cityName: entity.cityName,
      country: entity.country,
      lat: entity.lat,
      lon: entity.lon,
      isCurrentLocation: entity.isCurrentLocation,
      label: entity.label,
    );
  }

  factory SavedLocationModel.fromJson(Map<String, dynamic> json) {
    return SavedLocationModel(
      id: json['id'] as String,
      cityName: json['cityName'] as String,
      country: json['country'] as String,
      lat: (json['lat'] as num).toDouble(),
      lon: (json['lon'] as num).toDouble(),
      isCurrentLocation: json['isCurrentLocation'] as bool? ?? false,
      label: json['label'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'cityName': cityName,
    'country': country,
    'lat': lat,
    'lon': lon,
    'isCurrentLocation': isCurrentLocation,
    if (label != null) 'label': label,
  };

  String encode() => jsonEncode(toJson());

  static SavedLocationModel decode(String source) =>
      SavedLocationModel.fromJson(jsonDecode(source) as Map<String, dynamic>);
}
