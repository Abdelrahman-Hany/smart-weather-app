import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import 'core/secrets/app_secrets.dart';
import 'core/theme/app_theme.dart';
import 'dependency_injection.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/auth/presentation/cubit/auth_state.dart';
import 'features/premium/presentation/cubit/premium_cubit.dart';
import 'features/weather/presentation/cubit/weather_cubit.dart';
import 'features/weather/presentation/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Initialize Stripe
  Stripe.publishableKey = AppSecrets.stripePublishableKey;

  await initDependencies();

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

  const MyApp({super.key, required this.authCubit, required this.premiumCubit});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>.value(value: authCubit),
        BlocProvider<PremiumCubit>.value(value: premiumCubit),
        BlocProvider(create: (_) => sl<WeatherCubit>()..initialize()),
      ],
      child: BlocListener<AuthCubit, AuthState>(
        listenWhen: (prev, curr) =>
            prev.user?.uid != curr.user?.uid &&
            curr.status == AuthStatus.authenticated,
        listener: (context, state) {
          // When user authenticates, initialize premium status check
          if (state.user != null) {
            context.read<PremiumCubit>().init(state.user!.uid);
          }
        },
        child: MaterialApp(
          title: 'Weather',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.light,
          home: const HomeScreen(),
        ),
      ),
    );
  }
}
