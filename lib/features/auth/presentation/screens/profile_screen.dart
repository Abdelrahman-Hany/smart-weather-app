import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/locale_cubit.dart';
import '../../../../core/utils/show_snackbar.dart';
import '../../../premium/presentation/cubit/premium_cubit.dart';
import '../../../premium/presentation/cubit/premium_state.dart';
import '../../../premium/presentation/screens/premium_screen.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;

    return BlocConsumer<AuthCubit, AuthState>(
      listenWhen: (prev, curr) =>
          prev.errorMessage != curr.errorMessage ||
          (prev.status == AuthStatus.authenticated &&
              curr.status == AuthStatus.unauthenticated),
      listener: (context, state) {
        if (state.errorMessage != null) {
          showErrorSnackbar(context, state.errorMessage!);
          context.read<AuthCubit>().clearError();
        }
        if (state.status == AuthStatus.unauthenticated) {
          Navigator.of(context).pop();
        }
      },
      builder: (context, authState) {
        return BlocBuilder<PremiumCubit, PremiumState>(
          builder: (context, premiumState) {
            final user = authState.user;
            final isPremium = premiumState.isPremium;

            return Scaffold(
              appBar: AppBar(
                title: Text(l10n.profile),
                backgroundColor: Colors.transparent,
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Avatar
                    CircleAvatar(
                      radius: 48,
                      backgroundColor: colorScheme.primaryContainer,
                      backgroundImage: user?.photoUrl != null
                          ? NetworkImage(user!.photoUrl!)
                          : null,
                      child: user?.photoUrl == null
                          ? Icon(
                              user?.isAnonymous == true
                                  ? Icons.person_outline
                                  : Icons.person,
                              size: 48,
                              color: colorScheme.onPrimaryContainer,
                            )
                          : null,
                    ),
                    const SizedBox(height: 16),

                    // Name
                    Text(
                      user?.displayName ??
                          (user?.isAnonymous == true ? l10n.guest : l10n.user),
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 4),

                    // Email
                    if (user?.email != null)
                      Text(
                        user!.email!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    const SizedBox(height: 8),

                    // Premium badge
                    if (isPremium)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.amber.shade600,
                              Colors.orange.shade700,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star, color: Colors.white, size: 16),
                            SizedBox(width: 4),
                            Text(
                              l10n.premiumBadge,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 32),

                    // Anonymous account notice
                    if (authState.isAnonymous) ...[
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: colorScheme.primary,
                                size: 32,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                l10n.guestAccount,
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                l10n.guestAccountDescription,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 16),
                              FilledButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const LoginScreen(),
                                    ),
                                  );
                                },
                                child: Text(l10n.createAccount),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Upgrade to Premium (if not premium)
                    if (!isPremium) ...[
                      Card(
                        child: ListTile(
                          leading: Icon(
                            Icons.workspace_premium,
                            color: Colors.amber.shade700,
                            size: 32,
                          ),
                          title: Text(l10n.upgradeToPremium),
                          subtitle: Text(l10n.premiumOutfitSubtitle),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const PremiumScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Settings section
                    Card(
                      child: Column(
                        children: [
                          if (!authState.isAnonymous)
                            ListTile(
                              leading: const Icon(Icons.email_outlined),
                              title: Text(l10n.email),
                              subtitle: Text(user?.email ?? l10n.notSet),
                            ),
                          ListTile(
                            leading: const Icon(Icons.language_rounded),
                            title: Text(l10n.language),
                            subtitle: Text(
                              context.watch<LocaleCubit>().state.languageCode ==
                                      'ar'
                                  ? l10n.arabic
                                  : l10n.english,
                            ),
                            onTap: () => _showLanguageSheet(context),
                          ),
                          ListTile(
                            leading: const Icon(Icons.info_outline),
                            title: Text(l10n.appVersion),
                            subtitle: const Text('1.0.0'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Sign out
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => context.read<AuthCubit>().signOut(),
                        icon: const Icon(Icons.logout),
                        label: Text(
                          authState.isAnonymous
                              ? l10n.exitGuestMode
                              : l10n.signOut,
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colorScheme.error,
                          side: BorderSide(color: colorScheme.error),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showLanguageSheet(BuildContext context) async {
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
