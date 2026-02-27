import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'data/datasources/location_storage_service.dart';
import 'data/datasources/weather_remote_datasource.dart';
import 'data/repositories/weather_repository_impl.dart';
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
    // Dependency injection
    final remoteDataSource = WeatherRemoteDataSource();
    final repository = WeatherRepositoryImpl(
      remoteDataSource: remoteDataSource,
    );
    final getCurrentWeather = GetCurrentWeather(repository);
    final getForecast = GetForecast(repository);
    final locationStorage = LocationStorageService(prefs);

    return BlocProvider(
      create: (_) => WeatherCubit(
        getCurrentWeather: getCurrentWeather,
        getForecast: getForecast,
        storage: locationStorage,
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
