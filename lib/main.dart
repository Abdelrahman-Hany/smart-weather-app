import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/theme/app_theme.dart';
import 'data/datasources/geo_location_service.dart';
import 'data/datasources/location_storage_service.dart';
import 'data/datasources/weather_remote_datasource.dart';
import 'data/repositories/location_repository_impl.dart';
import 'data/repositories/weather_repository_impl.dart';
import 'domain/usecases/compute_daily_forecast.dart';
import 'domain/usecases/get_current_weather.dart';
import 'domain/usecases/get_forecast.dart';
import 'presentation/cubit/weather_cubit.dart';
import 'presentation/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;

  const MyApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    // ── Data sources ──
    final remoteDataSource = WeatherRemoteDataSource();
    final locationStorage = LocationStorageService(prefs);
    final geoService = GeoLocationService();

    // ── Repositories ──
    final weatherRepository = WeatherRepositoryImpl(
      remoteDataSource: remoteDataSource,
    );
    final locationRepository = LocationRepositoryImpl(storage: locationStorage);

    // ── Use-cases ──
    final getCurrentWeather = GetCurrentWeather(weatherRepository);
    final getForecast = GetForecast(weatherRepository);
    final computeDailyForecast = ComputeDailyForecast();

    return BlocProvider(
      create: (_) => WeatherCubit(
        getCurrentWeather: getCurrentWeather,
        getForecast: getForecast,
        computeDailyForecast: computeDailyForecast,
        locationRepository: locationRepository,
        geoLocationService: geoService,
      )..initialize(),
      child: MaterialApp(
        title: 'Weather',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        home: const HomeScreen(),
      ),
    );
  }
}
