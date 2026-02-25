import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'data/datasources/weather_remote_datasource.dart';
import 'data/repositories/weather_repository_impl.dart';
import 'domain/usecases/get_current_weather.dart';
import 'domain/usecases/get_forecast.dart';
import 'presentation/cubit/weather_cubit.dart';
import 'presentation/screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Dependency injection
    final remoteDataSource = WeatherRemoteDataSource();
    final repository = WeatherRepositoryImpl(
      remoteDataSource: remoteDataSource,
    );
    final getCurrentWeather = GetCurrentWeather(repository);
    final getForecast = GetForecast(repository);

    return BlocProvider(
      create: (_) => WeatherCubit(
        getCurrentWeather: getCurrentWeather,
        getForecast: getForecast,
      ),
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
