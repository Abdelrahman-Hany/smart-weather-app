import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import '../../data/datasources/location_storage_service.dart';
import '../../domain/entities/saved_location.dart';
import '../../domain/entities/weather_entity.dart';
import '../../domain/entities/forecast_entity.dart';
import '../../domain/usecases/get_current_weather.dart';
import '../../domain/usecases/get_forecast.dart';
import 'weather_state.dart';

class WeatherCubit extends Cubit<WeatherState> {
  final GetCurrentWeather _getCurrentWeather;
  final GetForecast _getForecast;
  final LocationStorageService _storage;

  WeatherCubit({
    required GetCurrentWeather getCurrentWeather,
    required GetForecast getForecast,
    required LocationStorageService storage,
  }) : _getCurrentWeather = getCurrentWeather,
       _getForecast = getForecast,
       _storage = storage,
       super(WeatherState(activeIndex: storage.getActiveIndex()));

  /// Called on app start. Loads saved locations and fetches weather for all.
  Future<void> initialize() async {
    final saved = _storage.getSavedLocations();
    final activeIdx = _storage.getActiveIndex();

    if (saved.isEmpty) {
      // No saved locations — use GPS.
      await _addGpsLocation();
      return;
    }

    // Build initial location list with loading status.
    final locationDataList = saved
        .map(
          (loc) =>
              LocationWeatherData(location: loc, status: WeatherStatus.loading),
        )
        .toList();

    final clampedIndex = activeIdx.clamp(0, locationDataList.length - 1);
    emit(
      state.copyWith(
        locations: locationDataList,
        activeIndex: clampedIndex,
        isInitializing: false,
      ),
    );

    // If the first location is GPS, update it with fresh coordinates.
    if (saved.first.isCurrentLocation) {
      _refreshGpsCoordinates();
    }

    // Fetch weather for all locations in parallel.
    await _fetchAllWeather();
  }

  /// Add a GPS-based location (first time or manual location button).
  Future<void> loadWeatherByLocation() async {
    if (state.isGpsLoading) return; // Prevent duplicate taps.
    final hasExistingLocations = state.locations.isNotEmpty;
    await _addGpsLocation(showFullLoading: !hasExistingLocations);
  }

  /// Add or switch to a city-based location.
  Future<void> loadWeatherByCity(String city) async {
    if (city.trim().isEmpty) return;
    final trimmed = city.trim();

    try {
      // Fetch weather to get lat/lon/country.
      final weather = await _getCurrentWeather(city: trimmed);
      final forecast = await _getForecast(city: trimmed);
      final dailyForecast = _computeDailyForecast(forecast);

      final location = SavedLocation.fromCity(
        cityName: weather.cityName,
        country: weather.country,
        lat: weather.lat,
        lon: weather.lon,
      );

      // Save to storage and get its index.
      final index = await _storage.addLocation(location);
      await _storage.setActiveIndex(index);

      // Update state.
      final locations = List<LocationWeatherData>.from(state.locations);
      final existingIdx = locations.indexWhere(
        (l) => l.location.id == location.id,
      );

      final newData = LocationWeatherData(
        location: location,
        status: WeatherStatus.loaded,
        weather: weather,
        forecast: forecast,
        dailyForecast: dailyForecast,
      );

      if (existingIdx != -1) {
        locations[existingIdx] = newData;
        emit(state.copyWith(locations: locations, activeIndex: existingIdx));
      } else {
        locations.add(newData);
        emit(
          state.copyWith(
            locations: locations,
            activeIndex: locations.length - 1,
          ),
        );
      }
    } catch (e) {
      // If there are existing locations, just show error on a temporary entry.
      if (state.locations.isEmpty) {
        final tempLocation = SavedLocation.fromCity(
          cityName: trimmed,
          country: '',
          lat: 0,
          lon: 0,
        );
        emit(
          state.copyWith(
            locations: [
              LocationWeatherData(
                location: tempLocation,
                status: WeatherStatus.error,
                errorMessage: _getErrorMessage(e),
              ),
            ],
            activeIndex: 0,
            isInitializing: false,
          ),
        );
      }
    }
  }

  /// Refresh weather data for the currently active location.
  Future<void> refreshWeather() async {
    final data = state.activeLocationData;
    if (data == null) return;

    // If GPS location, re-determine position first.
    if (data.location.isCurrentLocation) {
      try {
        final position = await _determinePosition();
        await _fetchWeatherForIndex(
          state.activeIndex,
          lat: position.latitude,
          lon: position.longitude,
        );
      } catch (e) {
        await _fetchWeatherForIndex(
          state.activeIndex,
          lat: data.location.lat,
          lon: data.location.lon,
        );
      }
    } else {
      await _fetchWeatherForIndex(
        state.activeIndex,
        lat: data.location.lat,
        lon: data.location.lon,
      );
    }
  }

  /// Change the active page/location.
  void setActiveIndex(int index) {
    if (index < 0 || index >= state.locations.length) return;
    emit(state.copyWith(activeIndex: index));
    _storage.setActiveIndex(index);
  }

  /// Clear the transient GPS error after it's been shown.
  void clearGpsError() {
    emit(state.copyWith(clearGpsError: true));
  }

  /// Remove a saved location by index.
  Future<void> removeLocation(int index) async {
    if (index < 0 || index >= state.locations.length) return;
    final locations = List<LocationWeatherData>.from(state.locations);
    final removed = locations.removeAt(index);
    await _storage.removeLocation(removed.location.id);

    int newActive = state.activeIndex;
    if (newActive >= locations.length) {
      newActive = locations.length - 1;
    }
    if (newActive < 0) newActive = 0;

    await _storage.setActiveIndex(newActive);
    emit(state.copyWith(locations: locations, activeIndex: newActive));

    // If no locations left, re-init with GPS.
    if (locations.isEmpty) {
      await _addGpsLocation();
    }
  }

  /// Remove multiple locations by their indices.
  Future<void> removeMultipleLocations(Set<int> indices) async {
    if (indices.isEmpty) return;
    final locations = List<LocationWeatherData>.from(state.locations);
    // Remove from highest index first to avoid shifting.
    final sorted = indices.toList()..sort((a, b) => b.compareTo(a));
    for (final idx in sorted) {
      if (idx >= 0 && idx < locations.length) {
        final removed = locations.removeAt(idx);
        await _storage.removeLocation(removed.location.id);
      }
    }

    int newActive = state.activeIndex;
    if (locations.isEmpty) {
      newActive = 0;
    } else if (newActive >= locations.length) {
      newActive = locations.length - 1;
    }

    await _storage.saveLocations(locations.map((l) => l.location).toList());
    await _storage.setActiveIndex(newActive);
    emit(state.copyWith(locations: locations, activeIndex: newActive));

    if (locations.isEmpty) {
      await _addGpsLocation();
    }
  }

  /// Update the label for a location at the given index.
  Future<void> updateLabel(int index, String label) async {
    if (index < 0 || index >= state.locations.length) return;
    final locations = List<LocationWeatherData>.from(state.locations);
    final loc = locations[index];
    final updatedLocation = loc.location.copyWith(
      label: () => label.isEmpty ? null : label,
    );
    locations[index] = loc.copyWith(location: updatedLocation);
    await _storage.saveLocations(locations.map((l) => l.location).toList());
    emit(state.copyWith(locations: locations));
  }

  /// Remove labels from multiple locations by their indices.
  Future<void> removeLabels(Set<int> indices) async {
    if (indices.isEmpty) return;
    final locations = List<LocationWeatherData>.from(state.locations);
    for (final idx in indices) {
      if (idx >= 0 && idx < locations.length) {
        final loc = locations[idx];
        final updatedLocation = loc.location.copyWith(label: () => null);
        locations[idx] = loc.copyWith(location: updatedLocation);
      }
    }
    await _storage.saveLocations(locations.map((l) => l.location).toList());
    emit(state.copyWith(locations: locations));
  }

  /// Reorder locations (drag & drop in manage screen).
  Future<void> reorderLocations(int oldIndex, int newIndex) async {
    final locations = List<LocationWeatherData>.from(state.locations);
    if (oldIndex < 0 ||
        oldIndex >= locations.length ||
        newIndex < 0 ||
        newIndex >= locations.length)
      return;

    final item = locations.removeAt(oldIndex);
    locations.insert(newIndex, item);

    // Adjust active index to follow the same location.
    int newActive = state.activeIndex;
    if (state.activeIndex == oldIndex) {
      newActive = newIndex;
    } else if (oldIndex < state.activeIndex && newIndex >= state.activeIndex) {
      newActive--;
    } else if (oldIndex > state.activeIndex && newIndex <= state.activeIndex) {
      newActive++;
    }

    await _storage.saveLocations(locations.map((l) => l.location).toList());
    await _storage.setActiveIndex(newActive);
    emit(state.copyWith(locations: locations, activeIndex: newActive));
  }

  // ─── Private helpers ───

  Future<void> _addGpsLocation({bool showFullLoading = true}) async {
    final previousIndex = state.activeIndex;

    emit(state.copyWith(isGpsLoading: true, isInitializing: showFullLoading));

    try {
      final position = await _determinePosition();
      final weather = await _getCurrentWeather(
        lat: position.latitude,
        lon: position.longitude,
      );
      final forecast = await _getForecast(
        lat: position.latitude,
        lon: position.longitude,
      );
      final dailyForecast = _computeDailyForecast(forecast);

      final gpsLocation = SavedLocation.fromGps(
        cityName: weather.cityName,
        country: weather.country,
        lat: position.latitude,
        lon: position.longitude,
      );

      await _storage.updateGpsLocation(gpsLocation);

      final locations = List<LocationWeatherData>.from(state.locations);
      final gpsIdx = locations.indexWhere((l) => l.location.isCurrentLocation);

      final gpsData = LocationWeatherData(
        location: gpsLocation,
        status: WeatherStatus.loaded,
        weather: weather,
        forecast: forecast,
        dailyForecast: dailyForecast,
      );

      if (gpsIdx != -1) {
        locations[gpsIdx] = gpsData;
      } else {
        locations.insert(0, gpsData);
      }

      final activeIdx = locations.indexWhere(
        (l) => l.location.isCurrentLocation,
      );
      await _storage.setActiveIndex(activeIdx);

      emit(
        state.copyWith(
          locations: locations,
          activeIndex: activeIdx,
          isInitializing: false,
          isGpsLoading: false,
        ),
      );
    } catch (e) {
      if (state.locations.isEmpty) {
        emit(
          state.copyWith(
            locations: [
              LocationWeatherData(
                location: const SavedLocation(
                  id: 'gps_current',
                  cityName: 'Current Location',
                  country: '',
                  lat: 0,
                  lon: 0,
                  isCurrentLocation: true,
                ),
                status: WeatherStatus.error,
                errorMessage: _getErrorMessage(e),
              ),
            ],
            activeIndex: 0,
            isInitializing: false,
            isGpsLoading: false,
          ),
        );
      } else {
        // GPS failed but we have existing locations — stay on current page, show error.
        emit(
          state.copyWith(
            isInitializing: false,
            isGpsLoading: false,
            activeIndex: previousIndex.clamp(0, state.locations.length - 1),
            gpsError: _getErrorMessage(e),
          ),
        );
      }
    }
  }

  Future<void> _refreshGpsCoordinates() async {
    try {
      final position = await _determinePosition();
      final gpsLocation = state.locations.firstWhere(
        (l) => l.location.isCurrentLocation,
      );
      final updatedLoc = SavedLocation.fromGps(
        cityName: gpsLocation.location.cityName,
        country: gpsLocation.location.country,
        lat: position.latitude,
        lon: position.longitude,
      );
      await _storage.updateGpsLocation(updatedLoc);
    } catch (_) {
      // Use cached coordinates; no-op.
    }
  }

  Future<void> _fetchAllWeather() async {
    final futures = <Future>[];
    for (int i = 0; i < state.locations.length; i++) {
      futures.add(
        _fetchWeatherForIndex(
          i,
          lat: state.locations[i].location.lat,
          lon: state.locations[i].location.lon,
        ),
      );
    }
    await Future.wait(futures);
  }

  Future<void> _fetchWeatherForIndex(
    int index, {
    double? lat,
    double? lon,
    String? city,
  }) async {
    if (index < 0 || index >= state.locations.length) return;

    // Mark loading.
    _updateLocationAtIndex(
      index,
      state.locations[index].copyWith(status: WeatherStatus.loading),
    );

    try {
      final results = await Future.wait([
        _getCurrentWeather(lat: lat, lon: lon, city: city),
        _getForecast(lat: lat, lon: lon, city: city),
      ]);

      final weather = results[0] as WeatherEntity;
      final forecast = results[1] as List<ForecastEntity>;
      final dailyForecast = _computeDailyForecast(forecast);

      if (index >= state.locations.length) return;

      _updateLocationAtIndex(
        index,
        state.locations[index].copyWith(
          status: WeatherStatus.loaded,
          weather: weather,
          forecast: forecast,
          dailyForecast: dailyForecast,
        ),
      );
    } catch (e) {
      if (index >= state.locations.length) return;

      _updateLocationAtIndex(
        index,
        state.locations[index].copyWith(
          status: WeatherStatus.error,
          errorMessage: _getErrorMessage(e),
        ),
      );
    }
  }

  void _updateLocationAtIndex(int index, LocationWeatherData data) {
    final locations = List<LocationWeatherData>.from(state.locations);
    if (index >= 0 && index < locations.length) {
      locations[index] = data;
      emit(state.copyWith(locations: locations));
    }
  }

  List<DailyForecast> _computeDailyForecast(List<ForecastEntity> forecasts) {
    final Map<String, List<ForecastEntity>> grouped = {};

    for (final forecast in forecasts) {
      final key =
          '${forecast.dateTime.year}-${forecast.dateTime.month}-${forecast.dateTime.day}';
      grouped.putIfAbsent(key, () => []).add(forecast);
    }

    return grouped.entries
        .map((entry) {
          final dayForecasts = entry.value;
          final tempMin = dayForecasts
              .map((f) => f.tempMin)
              .reduce((a, b) => a < b ? a : b);
          final tempMax = dayForecasts
              .map((f) => f.tempMax)
              .reduce((a, b) => a > b ? a : b);
          final maxPop = dayForecasts
              .map((f) => f.pop)
              .reduce((a, b) => a > b ? a : b);

          final conditionCounts = <String, int>{};
          for (final f in dayForecasts) {
            conditionCounts[f.mainCondition] =
                (conditionCounts[f.mainCondition] ?? 0) + 1;
          }
          final mainCondition = conditionCounts.entries
              .reduce((a, b) => a.value > b.value ? a : b)
              .key;

          final representativeForecast = dayForecasts.firstWhere(
            (f) => f.mainCondition == mainCondition,
          );

          final dayForecast = dayForecasts.where((f) => f.icon.endsWith('d'));
          final nightForecast = dayForecasts.where((f) => f.icon.endsWith('n'));
          final dayIcon = dayForecast.isNotEmpty
              ? dayForecast.first.icon
              : representativeForecast.icon;
          final nightIcon = nightForecast.isNotEmpty
              ? nightForecast.first.icon
              : representativeForecast.icon.replaceAll('d', 'n');

          return DailyForecast(
            date: dayForecasts.first.dateTime,
            tempMin: tempMin,
            tempMax: tempMax,
            mainCondition: mainCondition,
            dayIcon: dayIcon,
            nightIcon: nightIcon,
            description: representativeForecast.description,
            pop: maxPop,
          );
        })
        .take(7)
        .toList();
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Location permissions are permanently denied. Please enable them in settings.',
      );
    }

    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.low,
        timeLimit: Duration(seconds: 10),
      ),
    );
  }

  String _getErrorMessage(Object error) {
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
