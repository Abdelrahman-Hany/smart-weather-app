import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_app_sarmad/features/notifications/data/datasources/fcm_messaging_service.dart';
import 'package:weather_app_sarmad/features/notifications/data/repositories/notification_repository_impl.dart';
import 'package:weather_app_sarmad/features/notifications/domain/repositories/notification_repository.dart';
import 'package:weather_app_sarmad/features/notifications/domain/usecases/initialize_message_handlers.dart';
import 'package:weather_app_sarmad/features/notifications/domain/usecases/request_notification_permissions.dart';
import 'package:weather_app_sarmad/features/notifications/domain/usecases/start_token_sync_for_user.dart';
import 'package:weather_app_sarmad/features/notifications/domain/usecases/stop_token_sync.dart';
import 'core/localization/locale_cubit.dart';

// Weather feature
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

// Auth feature
import 'features/auth/data/datasources/firebase_auth_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/sign_in_anonymously.dart';
import 'features/auth/domain/usecases/sign_in_with_email.dart';
import 'features/auth/domain/usecases/sign_in_with_google.dart';
import 'features/auth/domain/usecases/sign_out.dart';
import 'features/auth/domain/usecases/sign_up_with_email.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';

// Premium feature
import 'features/premium/data/datasources/premium_datasource.dart';
import 'features/premium/data/repositories/premium_repository_impl.dart';
import 'features/premium/domain/repositories/premium_repository.dart';
import 'features/premium/domain/usecases/check_premium_status.dart';
import 'features/premium/domain/usecases/purchase_premium.dart';
import 'features/premium/presentation/cubit/premium_cubit.dart';

// AI Recommendation feature
import 'features/ai_recommendation/data/datasources/ai_remote_datasource.dart';
import 'features/ai_recommendation/data/repositories/ai_recommendation_repository_impl.dart';
import 'features/ai_recommendation/domain/repositories/ai_recommendation_repository.dart';
import 'features/ai_recommendation/domain/usecases/get_clothing_recommendations.dart';
import 'features/ai_recommendation/presentation/cubit/ai_recommendation_cubit.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // ─── External ──────────────────────────────────────────────────────
  final prefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => prefs);
  sl.registerLazySingleton<http.Client>(() => http.Client());
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
  sl.registerLazySingleton<FirebaseMessaging>(() => FirebaseMessaging.instance);
  // ─── Data Sources ──────────────────────────────────────────────────
  // Weather
  sl.registerLazySingleton<WeatherRemoteDataSource>(
    () => WeatherRemoteDataSource(client: sl<http.Client>()),
  );
  sl.registerLazySingleton<LocationStorageService>(
    () => LocationStorageService(sl<SharedPreferences>()),
  );
  sl.registerLazySingleton<GeoLocationService>(() => GeoLocationService());

  // Auth
  sl.registerLazySingleton<FirebaseAuthDataSource>(
    () => FirebaseAuthDataSource(),
  );

  // Premium
  sl.registerLazySingleton<PremiumDataSource>(
    () => PremiumDataSource(httpClient: sl<http.Client>()),
  );

  // AI
  sl.registerLazySingleton<AiRemoteDataSource>(() => AiRemoteDataSource());

  // Notifications
  sl.registerLazySingleton<FcmMessagingService>(() => FcmMessagingService(
    messaging: sl<FirebaseMessaging>(),
    firestore: sl<FirebaseFirestore>(),
  ));

  // ─── Repositories ──────────────────────────────────────────────────
  sl.registerLazySingleton<WeatherRepository>(
    () =>
        WeatherRepositoryImpl(remoteDataSource: sl<WeatherRemoteDataSource>()),
  );
  sl.registerLazySingleton<LocationRepository>(
    () => LocationRepositoryImpl(storage: sl<LocationStorageService>()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(dataSource: sl<FirebaseAuthDataSource>()),
  );
  sl.registerLazySingleton<PremiumRepository>(
    () => PremiumRepositoryImpl(dataSource: sl<PremiumDataSource>()),
  );
  sl.registerLazySingleton<AiRecommendationRepository>(
    () => AiRecommendationRepositoryImpl(dataSource: sl<AiRemoteDataSource>()),
  );
  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(fcmMessagingService: sl<FcmMessagingService>()),
  );

  // ─── Use Cases ─────────────────────────────────────────────────────
  // Weather
  sl.registerLazySingleton(() => GetCurrentWeather(sl<WeatherRepository>()));
  sl.registerLazySingleton(() => GetForecast(sl<WeatherRepository>()));
  sl.registerLazySingleton(() => ComputeDailyForecast());

  // Auth
  sl.registerLazySingleton(() => SignInAnonymously(sl<AuthRepository>()));
  sl.registerLazySingleton(() => SignInWithEmail(sl<AuthRepository>()));
  sl.registerLazySingleton(() => SignUpWithEmail(sl<AuthRepository>()));
  sl.registerLazySingleton(() => SignInWithGoogle(sl<AuthRepository>()));
  sl.registerLazySingleton(() => SignOut(sl<AuthRepository>()));

  // Premium
  sl.registerLazySingleton(() => CheckPremiumStatus(sl<PremiumRepository>()));
  sl.registerLazySingleton(() => PurchasePremium(sl<PremiumRepository>()));

  // AI
  sl.registerLazySingleton(
    () => GetClothingRecommendations(sl<AiRecommendationRepository>()),
  );

  // Notifications
  sl.registerLazySingleton(() => InitializeMessageHandlers(sl<NotificationRepository>()));
  sl.registerLazySingleton(() => RequestNotificationPermissions(sl<NotificationRepository>()));
  sl.registerLazySingleton(() => StartTokenSyncForUser(sl<NotificationRepository>()));
  sl.registerLazySingleton(() => StopTokenSync(sl<NotificationRepository>()));


  // ─── Cubits ────────────────────────────────────────────────────────
  // Weather (factory — new instance each time)
  sl.registerFactory(
    () => WeatherCubit(
      getCurrentWeather: sl<GetCurrentWeather>(),
      getForecast: sl<GetForecast>(),
      computeDailyForecast: sl<ComputeDailyForecast>(),
      locationRepository: sl<LocationRepository>(),
      geoLocationService: sl<GeoLocationService>(),
    ),
  );

  // Auth (singleton — lives for app lifetime, listens to auth stream)
  sl.registerLazySingleton(
    () => AuthCubit(
      authRepository: sl<AuthRepository>(),
      signInAnonymously: sl<SignInAnonymously>(),
      signInWithEmail: sl<SignInWithEmail>(),
      signUpWithEmail: sl<SignUpWithEmail>(),
      signInWithGoogle: sl<SignInWithGoogle>(),
      signOut: sl<SignOut>(),
    ),
  );

  // Premium (singleton — tracks subscription state across the app)
  sl.registerLazySingleton(
    () => PremiumCubit(
      checkPremiumStatus: sl<CheckPremiumStatus>(),
      purchasePremium: sl<PurchasePremium>(),
      premiumRepository: sl<PremiumRepository>(),
      premiumDataSource: sl<PremiumDataSource>(),
    ),
  );

  // AI Recommendation (factory — fresh instance per screen)
  sl.registerFactory(
    () => AiRecommendationCubit(
      getClothingRecommendations: sl<GetClothingRecommendations>(),
    ),
  );

  // Locale (singleton — app-wide language preference)
  sl.registerLazySingleton(() => LocaleCubit(sl<SharedPreferences>()));
}
