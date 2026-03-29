import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/locale_cubit.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/utils/show_snackbar.dart';
import '../../../../core/utils/weather_descriptions.dart';
import '../../../../core/utils/weather_utils.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../premium/presentation/cubit/premium_cubit.dart';
import '../../../premium/presentation/cubit/premium_state.dart';
import '../../domain/entities/weather_entity.dart';
import '../cubit/weather_cubit.dart';
import '../cubit/weather_state.dart';
import '../widgets/current_weather_card.dart';
import '../widgets/daily_forecast.dart';
import '../widgets/hourly_forecast.dart';
import '../widgets/sunrise_sunset_widget.dart';
import '../widgets/weather_detail_row.dart';

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
        _showBottomBar = false;
        _bottomBarController.forward();
      } else if (delta < -2 && !_showBottomBar) {
        _showBottomBar = true;
        _bottomBarController.reverse();
      }
    }
    if (notification is ScrollEndNotification &&
        notification.metrics.axis == Axis.vertical) {
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
          showErrorSnackbar(context, state.gpsError!);
          context.read<WeatherCubit>().clearGpsError();
        }
      },
      builder: (context, state) {
        if (state.isInitializing || state.locations.isEmpty) {
          return _buildInitialLoading();
        }

        final activeData = state.activeLocationData;
        final colors = _getBackgroundColors(activeData);

        // On desktop/tablet: two-column layout
        if (context.isTabletOrLarger) {
          return _buildDesktopLayout(context, state, activeData, colors);
        }

        // Mobile: original full-screen layout
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
                    _buildCityNameBar(activeData, colors.first),
                    _buildTopRightActions(context),
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

  /// Desktop/tablet: left sidebar with location list + right weather panel.
  Widget _buildDesktopLayout(
    BuildContext context,
    WeatherState state,
    LocationWeatherData? activeData,
    List<Color> colors,
  ) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors,
          ),
        ),
        child: SafeArea(
          child: Row(
            children: [
              // ── Left Sidebar ──────────────────────────────────────────
              Container(
                width: 300,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.18),
                  border: Border(
                    right: BorderSide(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    // Sidebar header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.wb_sunny_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            l10n.weather,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Spacer(),
                          // Language toggle
                          IconButton(
                            icon: const Icon(
                              Icons.language_rounded,
                              color: Colors.white70,
                              size: 20,
                            ),
                            tooltip: l10n.language,
                            onPressed: _showLanguageSheet,
                          ),
                          // Profile / Auth
                          BlocBuilder<AuthCubit, AuthState>(
                            builder: (context, authState) {
                              return IconButton(
                                icon: Icon(
                                  authState.isSignedIn
                                      ? Icons.account_circle
                                      : Icons.account_circle_outlined,
                                  color: Colors.white70,
                                  size: 22,
                                ),
                                tooltip:
                                    authState.isSignedIn
                                        ? l10n.profile
                                        : l10n.signIn,
                                onPressed: () {
                                  if (authState.isSignedIn) {
                                    context.push(AppRoutes.profile);
                                  } else {
                                    context.push(AppRoutes.login);
                                  }
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    // Search bar
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      child: GestureDetector(
                        onTap: _navigateToSearch,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.search_rounded,
                                color: Colors.white60,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                l10n.searchCityHint,
                                style: const TextStyle(
                                  color: Colors.white60,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Location list
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        itemCount: state.locations.length,
                        itemBuilder: (context, index) {
                          final locData = state.locations[index];
                          final isActive = index == state.activeIndex;
                          return _SidebarLocationTile(
                            locData: locData,
                            isActive: isActive,
                            onTap: () {
                              context
                                  .read<WeatherCubit>()
                                  .setActiveIndex(index);
                            },
                          );
                        },
                      ),
                    ),
                    // Manage locations button
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          icon: const Icon(
                            Icons.format_list_bulleted_rounded,
                            color: Colors.white70,
                            size: 18,
                          ),
                          label: Text(
                            l10n.manageLocations,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                          onPressed: _openManageLocations,
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: Colors.white.withValues(alpha: 0.2),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Right Main Panel ──────────────────────────────────────
              Expanded(
                child: NotificationListener<ScrollNotification>(
                  onNotification: (n) {
                    _onVerticalScroll(n);
                    return false;
                  },
                  child: activeData != null
                      ? _buildLocationPage(context, activeData)
                      : const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCityNameBar(LocationWeatherData? activeData, Color bgColor) {
    final l10n = context.l10n;
    final cityName =
        activeData?.weather?.cityName ??
        activeData?.location.cityName ??
        l10n.weather;

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
    final l10n = context.l10n;
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
          IconButton(
            icon: const Icon(
              Icons.format_list_bulleted_rounded,
              color: Colors.white,
              size: 26,
            ),
            onPressed: _openManageLocations,
            tooltip: l10n.manageLocations,
          ),
          Expanded(child: Center(child: _buildPageDots(state))),
          IconButton(
            icon: const Icon(
              Icons.search_rounded,
              color: Colors.white,
              size: 26,
            ),
            onPressed: _navigateToSearch,
            tooltip: l10n.searchCity,
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
    final l10n = context.l10n;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF4FC3F7), Color(0xFF29B6F6), Color(0xFF039BE5)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.loadingWeather,
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
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
    final l10n = context.l10n;
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
                CurrentWeatherCard(weather: weather),
                const SizedBox(height: 24),
                HourlyForecastWidget(
                  forecasts: locData.hourlyForecast,
                  summary:
                      '${weather.description[0].toUpperCase()}${weather.description.substring(1)}. ${l10n.lowTemperature(weather.tempMin.round())}',
                ),
                const SizedBox(height: 12),
                DailyForecastWidget(forecasts: locData.dailyForecast),
                const SizedBox(height: 12),
                WeatherDetailRow(
                  items: [
                    WeatherDetailItem(
                      icon: Icons.water_drop_outlined,
                      label: l10n.humidity,
                      value: '${weather.humidity}%',
                      subtitle: WeatherDescriptions.humidityLabel(
                        context,
                        weather.humidity,
                      ),
                    ),
                    WeatherDetailItem(
                      icon: Icons.air_rounded,
                      label: l10n.wind,
                      value: '${weather.windSpeed.toStringAsFixed(1)} m/s',
                      subtitle: WeatherUtils.windDirectionFromDegrees(
                        weather.windDeg,
                      ),
                    ),
                    WeatherDetailItem(
                      icon: Icons.compress_rounded,
                      label: l10n.pressure,
                      value: '${weather.pressure}',
                      subtitle: 'hPa',
                    ),
                    WeatherDetailItem(
                      icon: Icons.visibility_outlined,
                      label: l10n.visibility,
                      value:
                          '${(weather.visibility / 1000).toStringAsFixed(1)} km',
                      subtitle: WeatherDescriptions.visibilityLabel(
                        context,
                        weather.visibility,
                      ),
                    ),
                    WeatherDetailItem(
                      icon: Icons.cloud_outlined,
                      label: l10n.cloudiness,
                      value: '${weather.clouds}%',
                      subtitle: WeatherDescriptions.cloudLabel(
                        context,
                        weather.clouds,
                      ),
                    ),
                    WeatherDetailItem(
                      icon: Icons.thermostat_outlined,
                      label: l10n.feelsLike,
                      value: '${weather.feelsLike.round()}\u00B0',
                      subtitle: WeatherDescriptions.feelsLikeLabel(
                        context,
                        weather.temperature,
                        weather.feelsLike,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SunriseSunsetWidget(weather: weather),
                const SizedBox(height: 32),
                // AI Outfit Recommendation Button
                _buildAiRecommendationButton(context, weather),
                const SizedBox(height: 12),
                const Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: _DataProviderText(),
                ),
                const SizedBox(height: 56),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorContent(BuildContext context, LocationWeatherData locData) {
    final l10n = context.l10n;
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
                  label: Text(
                    l10n.useLocation,
                    style: const TextStyle(color: Colors.white),
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
                  label: Text(l10n.searchCity),
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
    final city = await context.push<String>(AppRoutes.search);
    if (city != null && mounted) {
      await context.read<WeatherCubit>().loadWeatherByCity(city);
      _syncPageController();
    }
  }

  void _openManageLocations() async {
    await context.push<void>(AppRoutes.manageLocations);
    if (!mounted) return;
    _syncPageController();
    if (!_showBottomBar) {
      _showBottomBar = true;
      _bottomBarController.reverse();
    }
  }

  void _syncPageController() {
    if (!_pageController.hasClients || !mounted) return;
    final target = context.read<WeatherCubit>().state.activeIndex;
    if (_pageController.page?.round() != target) {
      _pageController.jumpToPage(target);
    }
  }

  Widget _buildTopRightActions(BuildContext context) {
    final l10n = context.l10n;
    return PositionedDirectional(
      top: 4,
      end: 4,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(
              Icons.language_rounded,
              color: Colors.white,
              size: 24,
            ),
            tooltip: l10n.language,
            onPressed: _showLanguageSheet,
          ),
          BlocBuilder<AuthCubit, AuthState>(
            builder: (context, authState) {
              return IconButton(
                icon: Icon(
                  authState.isSignedIn
                      ? Icons.account_circle
                      : Icons.account_circle_outlined,
                  color: Colors.white,
                  size: 26,
                ),
                onPressed: () {
                  if (authState.isSignedIn) {
                    context.push(AppRoutes.profile);
                  } else {
                    context.push(AppRoutes.login);
                  }
                },
                tooltip: authState.isSignedIn ? l10n.profile : l10n.signIn,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAiRecommendationButton(
    BuildContext context,
    WeatherEntity weather,
  ) {
    final l10n = context.l10n;
    return BlocBuilder<PremiumCubit, PremiumState>(
      builder: (context, premiumState) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: premiumState.isPremium
                  ? [Colors.purple.shade400, Colors.deepPurple.shade600]
                  : [Colors.white24, Colors.white12],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                context.push(AppRoutes.aiOutfit, extra: weather);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.auto_awesome,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                l10n.aiOutfitAdvisor,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              if (!premiumState.isPremium) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.shade600,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'PRO',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            l10n.aiOutfitSubtitle,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.white54),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
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

  Future<void> _showLanguageSheet() async {
    final cubit = context.read<LocaleCubit>();

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return BlocBuilder<LocaleCubit, Locale>(
          builder: (context, locale) {
            final l10n = sheetContext.l10n;
            final current = locale.languageCode;

            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(title: Text(l10n.language)),
                  ListTile(
                    title: Text(l10n.english),
                    trailing: current == 'en'
                        ? const Icon(Icons.check_rounded)
                        : null,
                    onTap: () {
                      cubit.setLanguageCode('en');
                      Navigator.pop(sheetContext);
                    },
                  ),
                  ListTile(
                    title: Text(l10n.arabic),
                    trailing: current == 'ar'
                        ? const Icon(Icons.check_rounded)
                        : null,
                    onTap: () {
                      cubit.setLanguageCode('ar');
                      Navigator.pop(sheetContext);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _DataProviderText extends StatelessWidget {
  const _DataProviderText();

  @override
  Widget build(BuildContext context) {
    return Text(
      context.l10n.dataProvidedBy,
      style: const TextStyle(color: Colors.white38, fontSize: 12),
    );
  }
}

/// A compact location tile used in the desktop sidebar.
class _SidebarLocationTile extends StatelessWidget {
  const _SidebarLocationTile({
    required this.locData,
    required this.isActive,
    required this.onTap,
  });

  final LocationWeatherData locData;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final location = locData.location;
    final weather = locData.weather;
    final cityName = weather?.cityName ?? location.cityName;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: isActive
            ? Colors.white.withValues(alpha: 0.2)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                if (location.isCurrentLocation)
                  const Padding(
                    padding: EdgeInsets.only(right: 6),
                    child: Icon(
                      Icons.navigation_rounded,
                      color: Colors.white70,
                      size: 14,
                    ),
                  ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cityName,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: isActive
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (location.country.isNotEmpty)
                        Text(
                          location.country,
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
                if (weather != null)
                  Text(
                    '${weather.temperature.round()}°',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w300,
                    ),
                  )
                else if (locData.status == WeatherStatus.loading)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                      color: Colors.white54,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
