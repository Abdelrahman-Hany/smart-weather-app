import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/routing/app_router.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../premium/presentation/cubit/premium_cubit.dart';

/// Checks if the user is authenticated (non-anonymous) and has premium.
/// If not, shows appropriate gate screen instead of the child.
class PremiumGate extends StatelessWidget {
  final Widget child;
  final VoidCallback? onGateBlocked;

  const PremiumGate({super.key, required this.child, this.onGateBlocked});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    final premiumState = context.watch<PremiumCubit>().state;

    // Not authenticated at all
    if (authState.status != AuthStatus.authenticated) {
      return _buildAuthGate(context);
    }

    // Anonymous user — needs to sign in
    if (authState.isAnonymous) {
      return _buildAnonymousGate(context);
    }

    // Not premium — needs to upgrade
    if (!premiumState.isPremium) {
      return _buildPremiumGate(context);
    }

    return child;
  }

  Widget _buildAuthGate(BuildContext context) {
    final l10n = context.l10n;
    return _GateCard(
      icon: Icons.lock_outline,
      iconColor: Colors.blue,
      title: l10n.signInRequiredTitle,
      description: l10n.signInRequiredDescription,
      actionLabel: l10n.signIn,
      onAction: () => context.push(AppRoutes.login),
    );
  }

  Widget _buildAnonymousGate(BuildContext context) {
    final l10n = context.l10n;
    return _GateCard(
      icon: Icons.account_circle_outlined,
      iconColor: Colors.orange,
      title: l10n.accountRequiredTitle,
      description: l10n.accountRequiredDescription,
      actionLabel: l10n.createAccount,
      onAction: () => context.push(AppRoutes.login),
    );
  }

  Widget _buildPremiumGate(BuildContext context) {
    final l10n = context.l10n;
    return _GateCard(
      icon: Icons.workspace_premium,
      iconColor: Colors.amber.shade700,
      title: l10n.premiumFeatureTitle,
      description: l10n.premiumFeatureDescription,
      actionLabel: l10n.upgradeToPremium,
      onAction: () => context.push(AppRoutes.premium),
    );
  }
}

class _GateCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
  final String actionLabel;
  final VoidCallback onAction;

  const _GateCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 56, color: iconColor),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              description,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: onAction,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(actionLabel, style: const TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
