import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:weather_app_sarmad/core/usecase/usecase.dart';
import 'package:weather_app_sarmad/features/notifications/domain/usecases/initialize_message_handlers.dart';
import 'package:weather_app_sarmad/features/notifications/domain/usecases/request_notification_permissions.dart';
import 'package:weather_app_sarmad/features/notifications/domain/usecases/start_token_sync_for_user.dart';
import 'package:weather_app_sarmad/features/notifications/domain/usecases/stop_token_sync.dart';

import 'core/localization/app_localizations.dart';
import 'core/localization/locale_cubit.dart';
import 'core/routing/app_router.dart';
import 'core/secrets/app_secrets.dart';
import 'core/theme/app_theme.dart';
import 'dependency_injection.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/auth/presentation/cubit/auth_state.dart';
import 'features/premium/presentation/cubit/premium_cubit.dart';
import 'features/weather/presentation/cubit/weather_cubit.dart';
import 'firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Stripe (not supported on web)
  if (!kIsWeb) {
    Stripe.publishableKey = AppSecrets.stripePublishableKey;
  }

  await initDependencies();

  await sl<RequestNotificationPermissions>()(NoParams());
  await sl<InitializeMessageHandlers>()(NoParams());

  // Initialize auth cubit and start listening to auth changes
  final authCubit = sl<AuthCubit>()..init();
  final premiumCubit = sl<PremiumCubit>();

  // If user is already authenticated at startup, init premium immediately
  // (the BlocListener below only catches *future* transitions)
  if (authCubit.state.status == AuthStatus.authenticated &&
      authCubit.state.user != null) {
    premiumCubit.init(authCubit.state.user!.uid);
  }

  runApp(MyApp(authCubit: authCubit, premiumCubit: premiumCubit));
}

class MyApp extends StatelessWidget {
  final AuthCubit authCubit;
  final PremiumCubit premiumCubit;
  final _router = createAppRouter();

  MyApp({super.key, required this.authCubit, required this.premiumCubit});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<LocaleCubit>.value(value: sl<LocaleCubit>()),
        BlocProvider<AuthCubit>.value(value: authCubit),
        BlocProvider<PremiumCubit>.value(value: premiumCubit),
        BlocProvider(create: (_) => sl<WeatherCubit>()..initialize()),
      ],
      child: BlocListener<AuthCubit, AuthState>(
        listenWhen: (prev, curr) =>
            prev.user?.uid != curr.user?.uid || prev.status != curr.status,
        listener: (context, state) async {
          if (state.status == AuthStatus.authenticated && state.user != null) {
            context.read<PremiumCubit>().init(state.user!.uid);

            await sl<StartTokenSyncForUser>()(
              StartTokenSyncParams(userId: state.user!.uid),
            );
          } else {
            await sl<StopTokenSync>()(NoParams());
          }
        },
        child: BlocBuilder<LocaleCubit, Locale>(
          builder: (context, locale) {
            return MaterialApp.router(
              onGenerateTitle: (context) => context.l10n.appTitle,
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: ThemeMode.light,
              locale: locale,
              routerConfig: _router,
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
            );
          },
        ),
      ),
    );
  }
}
