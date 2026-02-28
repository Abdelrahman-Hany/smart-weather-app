import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/utils/weather_descriptions.dart';
import '../../core/utils/weather_utils.dart';
import '../cubit/weather_cubit.dart';
import '../cubit/weather_state.dart';
import '../widgets/current_weather_card.dart';
import '../widgets/daily_forecast.dart';
import '../widgets/hourly_forecast.dart';
import '../widgets/sunrise_sunset_widget.dart';
import '../widgets/weather_detail_row.dart';
import 'manage_locations_screen.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _bottomBarController;
  late Animation<Offset> _bottomBarSlide;
  bool _showBottomBar = true;

  @override
  void initState() {
    super.initState();
    final initialPage = context.read<WeatherCubit>().state.activeIndex;
    _pageController = PageController(initialPage: initialPage);

    _bottomBarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _bottomBarSlide = Tween<Offset>(begin: Offset.zero, end: const Offset(0, 1))
        .animate(
          CurvedAnimation(
            parent: _bottomBarController,
            curve: Curves.easeInOut,
          ),
        );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _bottomBarController.dispose();
    super.dispose();
  }

  void _onVerticalScroll(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification &&
        notification.metrics.axis == Axis.vertical) {
      final delta = notification.scrollDelta ?? 0;
      if (delta > 2 && _showBottomBar) {
        // Scrolling down → hide bar
        _showBottomBar = false;
        _bottomBarController.forward();
      } else if (delta < -2 && !_showBottomBar) {
        // Scrolling up → show bar
        _showBottomBar = true;
        _bottomBarController.reverse();
      }
    }
    if (notification is ScrollEndNotification &&
        notification.metrics.axis == Axis.vertical) {
      // Show bar when scrolling stops at the top
      if (notification.metrics.pixels <= 0 && !_showBottomBar) {
        _showBottomBar = true;
        _bottomBarController.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WeatherCubit, WeatherState>(
      listenWhen: (prev, curr) =>
          prev.activeIndex != curr.activeIndex ||
          prev.locations.length != curr.locations.length ||
          prev.gpsError != curr.gpsError,
      listener: (context, state) {
        if (_pageController.hasClients &&
            _pageController.page?.round() != state.activeIndex) {
          // Delay animation until after the builder rebuilds the PageView
          // with the correct itemCount, preventing scroll-extent clamping.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_pageController.hasClients && mounted) {
              _pageController.animateToPage(
                state.activeIndex,
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
              );
            }
          });
        }
        if (state.gpsError != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.gpsError!),
              backgroundColor: Colors.red.shade700,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 3),
            ),
          );
          context.read<WeatherCubit>().clearGpsError();
        }
      },
      builder: (context, state) {
        if (state.isInitializing || state.locations.isEmpty) {
          return _buildInitialLoading();
        }

        final activeData = state.activeLocationData;
        final colors = _getBackgroundColors(activeData);

        return Scaffold(
          extendBody: true,
          extendBodyBehindAppBar: true,
          backgroundColor: Colors.transparent,
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: colors,
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: NotificationListener<ScrollNotification>(
                onNotification: (n) {
                  _onVerticalScroll(n);
                  return false;
                },
                child: Stack(
                  children: [
                    // Main PageView content (padded top for city name bar)
                    Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: state.locations.length,
                        onPageChanged: (index) {
                          context.read<WeatherCubit>().setActiveIndex(index);
                        },
                        itemBuilder: (context, index) {
                          final locData = state.locations[index];
                          return _buildLocationPage(context, locData);
                        },
                      ),
                    ),
                    // Fixed city name at the top
                    _buildCityNameBar(activeData, colors.first),
                    // Bottom navigation bar overlay
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: SlideTransition(
                        position: _bottomBarSlide,
                        child: _buildBottomBar(state),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCityNameBar(LocationWeatherData? activeData, Color bgColor) {
    final cityName =
        activeData?.weather?.cityName ??
        activeData?.location.cityName ??
        'Weather';

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 8, bottom: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [bgColor, bgColor, bgColor.withValues(alpha: 0.0)],
            stops: const [0.0, 0.65, 1.0],
          ),
        ),
        child: Text(
          cityName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar(WeatherState state) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.only(bottom: bottomPadding + 4, top: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.0),
            Colors.black.withValues(alpha: 0.15),
            Colors.black.withValues(alpha: 0.3),
          ],
          stops: const [0.0, 0.4, 1.0],
        ),
      ),
      child: Row(
        children: [
          // Location list / manage icon
          IconButton(
            icon: const Icon(
              Icons.format_list_bulleted_rounded,
              color: Colors.white,
              size: 26,
            ),
            onPressed: _openManageLocations,
            tooltip: 'Manage locations',
          ),
          // Page indicator dots (center)
          Expanded(child: Center(child: _buildPageDots(state))),
          // Search icon
          IconButton(
            icon: const Icon(
              Icons.search_rounded,
              color: Colors.white,
              size: 26,
            ),
            onPressed: _navigateToSearch,
            tooltip: 'Search city',
          ),
        ],
      ),
    );
  }

  Widget _buildPageDots(WeatherState state) {
    if (state.locations.length <= 1) return const SizedBox.shrink();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(state.locations.length, (index) {
        final isGps = state.locations[index].location.isCurrentLocation;
        final isActive = index == state.activeIndex;

        if (isGps) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Icon(
              Icons.navigation_rounded,
              size: isActive ? 10 : 8,
              color: isActive
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.4),
            ),
          );
        }

        return Container(
          width: isActive ? 8 : 6,
          height: isActive ? 8 : 6,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive
                ? Colors.white
                : Colors.white.withValues(alpha: 0.4),
          ),
        );
      }),
    );
  }

  Widget _buildInitialLoading() {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF4FC3F7), Color(0xFF29B6F6), Color(0xFF039BE5)],
          ),
        ),
        child: const SafeArea(
          child: Center(
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
          ),
        ),
      ),
    );
  }

  Widget _buildLocationPage(BuildContext context, LocationWeatherData locData) {
    switch (locData.status) {
      case WeatherStatus.initial:
      case WeatherStatus.loading:
        return const Center(
          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
        );
      case WeatherStatus.loaded:
        return _buildLoadedContent(context, locData);
      case WeatherStatus.error:
        return _buildErrorContent(context, locData);
    }
  }

  Widget _buildLoadedContent(
    BuildContext context,
    LocationWeatherData locData,
  ) {
    final weather = locData.weather!;
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
          SliverToBoxAdapter(
            child: Column(
              children: [
                // Current weather
                CurrentWeatherCard(weather: weather),
                const SizedBox(height: 24),
                // Hourly forecast
                HourlyForecastWidget(
                  forecasts: locData.hourlyForecast,
                  summary:
                      '${weather.description[0].toUpperCase()}${weather.description.substring(1)}. Low ${weather.tempMin.round()}\u00B0C.',
                ),
                const SizedBox(height: 12),
                // Daily forecast
                DailyForecastWidget(forecasts: locData.dailyForecast),
                const SizedBox(height: 12),
                // Weather details grid
                WeatherDetailRow(
                  items: [
                    WeatherDetailItem(
                      icon: Icons.water_drop_outlined,
                      label: 'Humidity',
                      value: '${weather.humidity}%',
                      subtitle: WeatherDescriptions.humidityLabel(
                        weather.humidity,
                      ),
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
                      subtitle: WeatherDescriptions.visibilityLabel(
                        weather.visibility,
                      ),
                    ),
                    WeatherDetailItem(
                      icon: Icons.cloud_outlined,
                      label: 'Cloudiness',
                      value: '${weather.clouds}%',
                      subtitle: WeatherDescriptions.cloudLabel(weather.clouds),
                    ),
                    WeatherDetailItem(
                      icon: Icons.thermostat_outlined,
                      label: 'Feels Like',
                      value: '${weather.feelsLike.round()}\u00B0',
                      subtitle: WeatherDescriptions.feelsLikeLabel(
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
                const Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: Text(
                    'Data provided by OpenWeatherMap',
                    style: TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                ),
                // Extra padding so content isn't hidden behind bottom bar
                const SizedBox(height: 56),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorContent(BuildContext context, LocationWeatherData locData) {
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
              locData.errorMessage,
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
                  onPressed: _navigateToSearch,
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
      await context.read<WeatherCubit>().loadWeatherByCity(city);
      // Ensure PageController is on the correct page after the city loads.
      _syncPageController();
    }
  }

  void _openManageLocations() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ManageLocationsScreen()),
    );
    if (!mounted) return;
    // Sync page after returning — the active index may have changed
    // while ManageLocationsScreen was on top.
    _syncPageController();
    // Ensure bottom bar is visible when returning
    if (!_showBottomBar) {
      _showBottomBar = true;
      _bottomBarController.reverse();
    }
  }

  /// Jump the PageController to the cubit's active index if they disagree.
  void _syncPageController() {
    if (!_pageController.hasClients || !mounted) return;
    final target = context.read<WeatherCubit>().state.activeIndex;
    if (_pageController.page?.round() != target) {
      _pageController.jumpToPage(target);
    }
  }

  List<Color> _getBackgroundColors(LocationWeatherData? data) {
    if (data?.weather != null) {
      return WeatherUtils.getWeatherGradient(
        data!.weather!.mainCondition,
        isNight: data.isNight,
      );
    }
    return const [Color(0xFF4FC3F7), Color(0xFF29B6F6), Color(0xFF039BE5)];
  }
}
