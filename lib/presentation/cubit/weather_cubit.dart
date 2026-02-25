import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import '../../domain/entities/weather_entity.dart';
import '../../domain/entities/forecast_entity.dart';
import '../../domain/usecases/get_current_weather.dart';
import '../../domain/usecases/get_forecast.dart';
import 'weather_state.dart';

class WeatherCubit extends Cubit<WeatherState> {
  final GetCurrentWeather _getCurrentWeather;
  final GetForecast _getForecast;

  WeatherCubit({
    required GetCurrentWeather getCurrentWeather,
    required GetForecast getForecast,
  }) : _getCurrentWeather = getCurrentWeather,
       _getForecast = getForecast,
       super(const WeatherState());

  Future<void> loadWeatherByLocation() async {
    emit(state.copyWith(status: WeatherStatus.loading));

    try {
      final position = await _determinePosition();
      await _fetchWeatherData(lat: position.latitude, lon: position.longitude);
    } catch (e) {
      emit(
        state.copyWith(
          status: WeatherStatus.error,
          errorMessage: _getErrorMessage(e),
        ),
      );
    }
  }

  Future<void> loadWeatherByCity(String city) async {
    if (city.trim().isEmpty) return;

    final trimmedCity = city.trim();
    emit(
      state.copyWith(status: WeatherStatus.loading, searchCity: trimmedCity),
    );

    try {
      await _fetchWeatherData(city: trimmedCity);
    } catch (e) {
      emit(
        state.copyWith(
          status: WeatherStatus.error,
          errorMessage: _getErrorMessage(e),
        ),
      );
    }
  }

  Future<void> refreshWeather() async {
    try {
      if (state.searchCity.isNotEmpty) {
        await _fetchWeatherData(city: state.searchCity);
      } else if (state.weather != null) {
        await _fetchWeatherData(
          lat: state.weather!.lat,
          lon: state.weather!.lon,
        );
      } else {
        await loadWeatherByLocation();
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: WeatherStatus.error,
          errorMessage: _getErrorMessage(e),
        ),
      );
    }
  }

  Future<void> _fetchWeatherData({
    double? lat,
    double? lon,
    String? city,
  }) async {
    final results = await Future.wait([
      _getCurrentWeather(lat: lat, lon: lon, city: city),
      _getForecast(lat: lat, lon: lon, city: city),
    ]);

    final weather = results[0] as WeatherEntity;
    final forecast = results[1] as List<ForecastEntity>;
    final dailyForecast = _computeDailyForecast(forecast);

    emit(
      state.copyWith(
        status: WeatherStatus.loaded,
        weather: weather,
        forecast: forecast,
        dailyForecast: dailyForecast,
      ),
    );
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
