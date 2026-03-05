import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/show_snackbar.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../cubit/premium_cubit.dart';
import '../cubit/premium_state.dart';

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocConsumer<PremiumCubit, PremiumState>(
      listenWhen: (prev, curr) =>
          prev.errorMessage != curr.errorMessage ||
          (prev.status != PremiumStatus.premium &&
              curr.status == PremiumStatus.premium),
      listener: (context, state) {
        if (state.errorMessage != null) {
          showErrorSnackbar(context, state.errorMessage!);
          context.read<PremiumCubit>().clearError();
        }
        if (state.status == PremiumStatus.premium) {
          showSnackbar(context, '🎉 Welcome to Premium!');
        }
      },
      builder: (context, premiumState) {
        final authState = context.watch<AuthCubit>().state;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Premium'),
            backgroundColor: Colors.transparent,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Premium header
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.amber.shade600,
                        Colors.orange.shade700,
                        Colors.deepOrange.shade600,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.workspace_premium,
                        color: Colors.white,
                        size: 64,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Weather Premium',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        premiumState.isPremium
                            ? 'You\'re a Premium member!'
                            : 'Unlock AI-powered features',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                if (premiumState.isPremium) ...[
                  // Already premium
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.green.shade600,
                            size: 48,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Premium Active',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (premiumState.subscription?.expiresAt != null)
                            Text(
                              'Expires: ${_formatDate(premiumState.subscription!.expiresAt!)}',
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  // Features list
                  _buildFeatureItem(
                    icon: Icons.auto_awesome,
                    title: 'AI Outfit Recommendations',
                    description:
                        'Get smart clothing suggestions based on current weather conditions',
                    color: Colors.purple,
                  ),
                  const SizedBox(height: 12),
                  _buildFeatureItem(
                    icon: Icons.shopping_bag_outlined,
                    title: 'Shopping Links',
                    description:
                        'Find and buy recommended clothes from top retailers',
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 12),
                  _buildFeatureItem(
                    icon: Icons.tips_and_updates_outlined,
                    title: 'Personalized Tips',
                    description:
                        'Weather-based activity and wardrobe planning tips',
                    color: Colors.teal,
                  ),
                  const SizedBox(height: 32),

                  // Auth check
                  if (authState.isAnonymous) ...[
                    Card(
                      color: colorScheme.primaryContainer.withValues(
                        alpha: 0.3,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Icon(
                              Icons.account_circle_outlined,
                              color: colorScheme.primary,
                              size: 32,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Sign in required',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'You need to create an account before purchasing Premium.',
                              textAlign: TextAlign.center,
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
                              child: const Text('Sign In / Sign Up'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ] else ...[
                    // Pricing options
                    if (premiumState.products.isNotEmpty) ...[
                      ...premiumState.products.map((product) {
                        final isYearly = product.id.contains('yearly');
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildPricingCard(
                            context: context,
                            title: product.title,
                            price: product.price,
                            period: isYearly ? '/year' : '/month',
                            isPopular: isYearly,
                            onTap: premiumState.isPurchasing
                                ? null
                                : () => context.read<PremiumCubit>().purchase(
                                    product.id,
                                  ),
                          ),
                        );
                      }),
                    ] else ...[
                      // Fallback pricing when store products aren't loaded
                      _buildPricingCard(
                        context: context,
                        title: 'Monthly',
                        price: '\$2.99',
                        period: '/month',
                        isPopular: false,
                        onTap: premiumState.isPurchasing
                            ? null
                            : () => context.read<PremiumCubit>().purchase(
                                'weather_premium_monthly',
                              ),
                      ),
                      const SizedBox(height: 12),
                      _buildPricingCard(
                        context: context,
                        title: 'Yearly',
                        price: '\$19.99',
                        period: '/year',
                        isPopular: true,
                        onTap: premiumState.isPurchasing
                            ? null
                            : () => context.read<PremiumCubit>().purchase(
                                'weather_premium_yearly',
                              ),
                      ),
                    ],

                    const SizedBox(height: 16),

                    if (premiumState.isPurchasing)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(),
                        ),
                      ),

                    // Check subscription status
                    TextButton(
                      onPressed: premiumState.isPurchasing
                          ? null
                          : () =>
                                context.read<PremiumCubit>().restorePurchases(),
                      child: const Text('Restore Purchases'),
                    ),
                  ],
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPricingCard({
    required BuildContext context,
    required String title,
    required String price,
    required String period,
    required bool isPopular,
    VoidCallback? onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: isPopular ? 4 : 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isPopular
            ? BorderSide(color: Colors.amber.shade600, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              if (isPopular)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade600,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'BEST VALUE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              if (isPopular) const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    price,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                  Text(
                    period,
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
