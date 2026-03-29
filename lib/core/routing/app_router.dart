import 'package:go_router/go_router.dart';

import '../../features/ai_recommendation/presentation/screens/ai_outfit_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/profile_screen.dart';
import '../../features/premium/presentation/screens/premium_screen.dart';
import '../../features/weather/domain/entities/weather_entity.dart';
import '../../features/weather/presentation/screens/home_screen.dart';
import '../../features/weather/presentation/screens/manage_locations_screen.dart';
import '../../features/weather/presentation/screens/search_screen.dart';

abstract final class AppRoutes {
  static const String home = '/';
  static const String search = '/search';
  static const String manageLocations = '/manage-locations';
  static const String login = '/login';
  static const String profile = '/profile';
  static const String premium = '/premium';
  static const String aiOutfit = '/ai-outfit';
}

GoRouter createAppRouter() {
  return GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.search,
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: AppRoutes.manageLocations,
        builder: (context, state) => const ManageLocationsScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.premium,
        builder: (context, state) => const PremiumScreen(),
      ),
      GoRoute(
        path: AppRoutes.aiOutfit,
        builder: (context, state) {
          final weather = state.extra;
          if (weather is! WeatherEntity) {
            return const HomeScreen();
          }
          return AiOutfitScreen(weather: weather);
        },
      ),
    ],
  );
}
