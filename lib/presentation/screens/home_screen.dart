import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/utils/weather_utils.dart';
import '../cubit/weather_cubit.dart';
import '../cubit/weather_state.dart';
import '../widgets/current_weather_card.dart';
import '../widgets/hourly_forecast.dart';
import '../widgets/daily_forecast.dart';
import '../widgets/weather_detail_row.dart';
import '../widgets/sunrise_sunset_widget.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WeatherCubit>().loadWeatherByLocation();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WeatherCubit, WeatherState>(
      builder: (context, state) {
        final colors = _getBackgroundColors(state);

        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: colors,
              ),
            ),
            child: SafeArea(child: _buildBody(context, state)),
          ),
        );
      },
    );
  }

  List<Color> _getBackgroundColors(WeatherState state) {
    if (state.weather != null) {
      return WeatherUtils.getWeatherGradient(
        state.weather!.mainCondition,
        isNight: state.isNight,
      );
    }
    return [
      const Color(0xFF4FC3F7),
      const Color(0xFF29B6F6),
      const Color(0xFF039BE5),
    ];
  }

  Widget _buildBody(BuildContext context, WeatherState state) {
    switch (state.status) {
      case WeatherStatus.initial:
      case WeatherStatus.loading:
        return _buildLoading();
      case WeatherStatus.loaded:
        return _buildLoaded(context, state);
      case WeatherStatus.error:
        return _buildError(context, state);
    }
  }

  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
          SizedBox(height: 16),
          Text(
            'Loading weather...',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildLoaded(BuildContext context, WeatherState state) {
    final weather = state.weather!;
    final cubit = context.read<WeatherCubit>();

    return RefreshIndicator(
      onRefresh: cubit.refreshWeather,
      color: Colors.white,
      backgroundColor: Colors.white24,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          // App Bar
          SliverAppBar(
            floating: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.location_on_outlined, color: Colors.white),
              onPressed: () =>
                  context.read<WeatherCubit>().loadWeatherByLocation(),
            ),
            title: Text(
              weather.cityName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search_rounded, color: Colors.white),
                onPressed: () => _navigateToSearch(),
              ),
              IconButton(
                icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                onPressed: () => cubit.refreshWeather(),
              ),
            ],
          ),
          // Content
          SliverToBoxAdapter(
            child: Column(
              children: [
                // Current weather
                CurrentWeatherCard(weather: weather),
                const SizedBox(height: 24),
                // Hourly forecast
                HourlyForecastWidget(
                  forecasts: state.hourlyForecast,
                  summary:
                      '${weather.description[0].toUpperCase()}${weather.description.substring(1)}. Low ${weather.tempMin.round()}C.',
                ),
                const SizedBox(height: 12),
                // Daily forecast
                DailyForecastWidget(forecasts: state.dailyForecast),
                const SizedBox(height: 12),
                // Weather details grid
                WeatherDetailRow(
                  items: [
                    WeatherDetailItem(
                      icon: Icons.water_drop_outlined,
                      label: 'Humidity',
                      value: '${weather.humidity}%',
                      subtitle: _getHumidityLabel(weather.humidity),
                    ),
                    WeatherDetailItem(
                      icon: Icons.air_rounded,
                      label: 'Wind',
                      value: '${weather.windSpeed.toStringAsFixed(1)} m/s',
                      subtitle: WeatherUtils.windDirectionFromDegrees(
                        weather.windDeg,
                      ),
                    ),
                    WeatherDetailItem(
                      icon: Icons.compress_rounded,
                      label: 'Pressure',
                      value: '${weather.pressure}',
                      subtitle: 'hPa',
                    ),
                    WeatherDetailItem(
                      icon: Icons.visibility_outlined,
                      label: 'Visibility',
                      value:
                          '${(weather.visibility / 1000).toStringAsFixed(1)} km',
                      subtitle: _getVisibilityLabel(weather.visibility),
                    ),
                    WeatherDetailItem(
                      icon: Icons.cloud_outlined,
                      label: 'Cloudiness',
                      value: '${weather.clouds}%',
                      subtitle: _getCloudLabel(weather.clouds),
                    ),
                    WeatherDetailItem(
                      icon: Icons.thermostat_outlined,
                      label: 'Feels Like',
                      value: '${weather.feelsLike.round()}°',
                      subtitle: _getFeelsLikeLabel(
                        weather.temperature,
                        weather.feelsLike,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Sunrise & Sunset
                SunriseSunsetWidget(weather: weather),
                const SizedBox(height: 32),
                // Attribution
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    'Data provided by OpenWeatherMap',
                    style: TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context, WeatherState state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              color: Colors.white54,
              size: 80,
            ),
            const SizedBox(height: 16),
            Text(
              state.errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: () =>
                      context.read<WeatherCubit>().loadWeatherByLocation(),
                  icon: const Icon(Icons.my_location, color: Colors.white),
                  label: const Text(
                    'Use Location',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white54),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton.icon(
                  onPressed: () => _navigateToSearch(),
                  icon: const Icon(Icons.search),
                  label: const Text('Search City'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white24,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToSearch() async {
    final city = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const SearchScreen()),
    );
    if (city != null && mounted) {
      context.read<WeatherCubit>().loadWeatherByCity(city);
    }
  }

  String _getHumidityLabel(int humidity) {
    if (humidity < 30) return 'Low';
    if (humidity < 60) return 'Comfortable';
    if (humidity < 80) return 'Humid';
    return 'Very humid';
  }

  String _getVisibilityLabel(int visibility) {
    if (visibility >= 10000) return 'Clear';
    if (visibility >= 5000) return 'Moderate';
    if (visibility >= 1000) return 'Low';
    return 'Very low';
  }

  String _getCloudLabel(int clouds) {
    if (clouds < 20) return 'Clear sky';
    if (clouds < 50) return 'Partly cloudy';
    if (clouds < 80) return 'Mostly cloudy';
    return 'Overcast';
  }

  String _getFeelsLikeLabel(double temp, double feelsLike) {
    final diff = feelsLike - temp;
    if (diff.abs() < 2) return 'Similar to actual';
    if (diff > 0) return 'Warmer than actual';
    return 'Cooler than actual';
  }
}
