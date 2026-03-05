import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../../../premium/presentation/cubit/premium_cubit.dart';
import '../../../premium/presentation/screens/premium_screen.dart';

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
    return _GateCard(
      icon: Icons.lock_outline,
      iconColor: Colors.blue,
      title: 'Sign In Required',
      description: 'Please sign in to access AI outfit recommendations.',
      actionLabel: 'Sign In',
      onAction: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      },
    );
  }

  Widget _buildAnonymousGate(BuildContext context) {
    return _GateCard(
      icon: Icons.account_circle_outlined,
      iconColor: Colors.orange,
      title: 'Account Required',
      description:
          'Guest accounts cannot access premium features.\nCreate an account to unlock AI outfit recommendations.',
      actionLabel: 'Create Account',
      onAction: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      },
    );
  }

  Widget _buildPremiumGate(BuildContext context) {
    return _GateCard(
      icon: Icons.workspace_premium,
      iconColor: Colors.amber.shade700,
      title: 'Premium Feature',
      description:
          'AI outfit recommendations are available exclusively for Premium members.',
      actionLabel: 'Upgrade to Premium',
      onAction: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PremiumScreen()),
        );
      },
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
