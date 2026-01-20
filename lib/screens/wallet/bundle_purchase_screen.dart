import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart' hide Card;
import 'package:provider/provider.dart';
import '../../models/bundle.dart';
import '../../providers/wallet_provider.dart';

class BundlePurchaseScreen extends StatefulWidget {
  const BundlePurchaseScreen({super.key});

  @override
  State<BundlePurchaseScreen> createState() => _BundlePurchaseScreenState();
}

class _BundlePurchaseScreenState extends State<BundlePurchaseScreen> {
  String? selectedBundleId;
  bool isProcessing = false;

  @override
  void initState() {
    super.initState();
    // Load bundles when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WalletProvider>().loadBundles();
    });
  }

  Future<void> _handlePurchase(Bundle bundle) async {
    setState(() {
      selectedBundleId = bundle.id;
      isProcessing = true;
    });

    try {
      final walletProvider = context.read<WalletProvider>();

      // Step 1: Create payment intent on backend
      final paymentIntentResult = await walletProvider.createPaymentIntent(
        bundleId: bundle.id,
      );

      if (paymentIntentResult == null) {
        throw Exception(
          walletProvider.errorMessage ?? 'Failed to create payment intent',
        );
      }

      final clientSecret = paymentIntentResult['clientSecret'] as String?;
      final isMock = paymentIntentResult['mock'] == true;

      if (clientSecret == null) {
        throw Exception('No client secret returned');
      }

      // Handle mock payments (for development/testing)
      if (isMock) {
        // Simulate successful payment for mock mode
        if (!mounted) return;

        setState(() {
          isProcessing = false;
          selectedBundleId = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✅ Mock payment successful! ${bundle.formattedGcAmount} GC + FREE ${bundle.bonusScAmount} SC added!',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );

        // Refresh wallet balance
        await walletProvider.loadBalance();
        Navigator.pop(context);
        return;
      }

      // Step 2: Initialize Stripe payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'FriendlyWager',
          style: ThemeMode.dark,
          appearance: PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(
              primary: const Color(0xFF2196F3),
              background: const Color(0xFF1E1E1E),
              componentBackground: const Color(0xFF2A2A2A),
            ),
          ),
        ),
      );

      // Step 3: Present payment sheet to user
      await Stripe.instance.presentPaymentSheet();

      if (!mounted) return;

      setState(() {
        isProcessing = false;
        selectedBundleId = null;
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${bundle.formattedGcAmount} GC + FREE ${bundle.bonusScAmount} SC will be added shortly!',
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );

      // Refresh wallet balance (coins are added via webhook)
      await walletProvider.loadBalance();
      Navigator.pop(context);
    } on StripeException catch (e) {
      if (!mounted) return;

      setState(() {
        isProcessing = false;
        selectedBundleId = null;
      });

      // Handle user cancellation gracefully
      if (e.error.code == FailureCode.Canceled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment cancelled'),
            backgroundColor: Colors.orange,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment failed: ${e.error.localizedMessage}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isProcessing = false;
        selectedBundleId = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Purchase failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buy Gold Coins'), centerTitle: true),
      body: Consumer<WalletProvider>(
        builder: (context, walletProvider, child) {
          if (walletProvider.isLoading && walletProvider.bundles.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (walletProvider.bundles.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('No bundles available'),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => walletProvider.loadBundles(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info banner
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.blue),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'How it works',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Purchase Gold Coins (GC) for social play and get FREE Sweeps Coins (SC) as a bonus. SC can be redeemed for prizes!',
                              style: TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Bundle cards
                ...walletProvider.bundles.map((bundle) {
                  final isSelected = selectedBundleId == bundle.id;
                  final isFeatured = bundle.isFeatured;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _BundleCard(
                      bundle: bundle,
                      isSelected: isSelected,
                      isFeatured: isFeatured,
                      isProcessing: isProcessing,
                      onPurchase: () => _handlePurchase(bundle),
                    ),
                  );
                }),

                const SizedBox(height: 16),

                // Legal disclaimer
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Sweeps Coins are awarded as a free bonus and have no cash value. '
                    'They can be used to enter sweepstakes contests and redeemed for prizes. '
                    '1x playthrough required before redemption. See Terms & Conditions for details.',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _BundleCard extends StatelessWidget {
  final Bundle bundle;
  final bool isSelected;
  final bool isFeatured;
  final bool isProcessing;
  final VoidCallback onPurchase;

  const _BundleCard({
    required this.bundle,
    required this.isSelected,
    required this.isFeatured,
    required this.isProcessing,
    required this.onPurchase,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isFeatured ? 8 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isFeatured ? Colors.orange : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: isProcessing ? null : onPurchase,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Badge
              if (bundle.badgeText != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isFeatured ? Colors.orange : Colors.blue,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    bundle.badgeText!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              if (bundle.badgeText != null) const SizedBox(height: 12),

              // Bundle name
              Text(
                bundle.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (bundle.description != null) ...[
                const SizedBox(height: 4),
                Text(
                  bundle.description!,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
              const SizedBox(height: 16),

              // GC amount
              Row(
                children: [
                  const Icon(
                    Icons.monetization_on,
                    color: Color(0xFFFFD700),
                    size: 28,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${bundle.formattedGcAmount} GC',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Bonus SC
              Row(
                children: [
                  const Icon(Icons.stars, color: Color(0xFF4CAF50), size: 28),
                  const SizedBox(width: 8),
                  RichText(
                    text: TextSpan(
                      style: DefaultTextStyle.of(context).style,
                      children: [
                        const TextSpan(
                          text: 'FREE ',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4CAF50),
                          ),
                        ),
                        TextSpan(
                          text: '${bundle.bonusScAmount} SC Bonus',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Price and buy button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Price
                  Text(
                    bundle.formattedPrice,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),

                  // Buy button
                  ElevatedButton(
                    onPressed: isProcessing ? null : onPurchase,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      backgroundColor: isFeatured ? Colors.orange : Colors.blue,
                    ),
                    child: isSelected && isProcessing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text(
                            'Buy Now',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
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
}
