import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'features/weather/data/datasources/geo_location_service.dart';
import 'features/weather/data/datasources/location_storage_service.dart';
import 'features/weather/data/datasources/weather_remote_datasource.dart';
import 'features/weather/data/repositories/location_repository_impl.dart';
import 'features/weather/data/repositories/weather_repository_impl.dart';
import 'features/weather/domain/repositories/location_repository.dart';
import 'features/weather/domain/repositories/weather_repository.dart';
import 'features/weather/domain/usecases/compute_daily_forecast.dart';
import 'features/weather/domain/usecases/get_current_weather.dart';
import 'features/weather/domain/usecases/get_forecast.dart';
import 'features/weather/presentation/cubit/weather_cubit.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // ─── External ──────────────────────────────────────────────────────
  final prefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => prefs);
  sl.registerLazySingleton<http.Client>(() => http.Client());

  // ─── Data Sources ──────────────────────────────────────────────────
  sl.registerLazySingleton<WeatherRemoteDataSource>(
    () => WeatherRemoteDataSource(client: sl<http.Client>()),
  );
  sl.registerLazySingleton<LocationStorageService>(
    () => LocationStorageService(sl<SharedPreferences>()),
  );
  sl.registerLazySingleton<GeoLocationService>(() => GeoLocationService());

  // ─── Repositories ──────────────────────────────────────────────────
  sl.registerLazySingleton<WeatherRepository>(
    () =>
        WeatherRepositoryImpl(remoteDataSource: sl<WeatherRemoteDataSource>()),
  );
  sl.registerLazySingleton<LocationRepository>(
    () => LocationRepositoryImpl(storage: sl<LocationStorageService>()),
  );

  // ─── Use Cases ─────────────────────────────────────────────────────
  sl.registerLazySingleton(() => GetCurrentWeather(sl<WeatherRepository>()));
  sl.registerLazySingleton(() => GetForecast(sl<WeatherRepository>()));
  sl.registerLazySingleton(() => ComputeDailyForecast());

  // ─── Cubit ─────────────────────────────────────────────────────────
  sl.registerFactory(
    () => WeatherCubit(
      getCurrentWeather: sl<GetCurrentWeather>(),
      getForecast: sl<GetForecast>(),
      computeDailyForecast: sl<ComputeDailyForecast>(),
      locationRepository: sl<LocationRepository>(),
      geoLocationService: sl<GeoLocationService>(),
    ),
  );
}
