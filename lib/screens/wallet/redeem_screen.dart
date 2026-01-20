import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/wallet_provider.dart';
import '../../providers/kyc_provider.dart';

class RedeemScreen extends StatefulWidget {
  const RedeemScreen({super.key});

  @override
  State<RedeemScreen> createState() => _RedeemScreenState();
}

class _RedeemScreenState extends State<RedeemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  String? selectedCardType = 'Amazon';
  bool isProcessing = false;

  final List<Map<String, dynamic>> giftCardOptions = [
    {'type': 'Amazon', 'icon': Icons.shopping_bag, 'color': Colors.orange},
    {'type': 'Visa', 'icon': Icons.credit_card, 'color': Colors.blue},
    {'type': 'Mastercard', 'icon': Icons.credit_card, 'color': Colors.red},
    {'type': 'Walmart', 'icon': Icons.store, 'color': Colors.blueGrey},
    {'type': 'Target', 'icon': Icons.track_changes, 'color': Colors.red},
    {'type': 'Best Buy', 'icon': Icons.computer, 'color': Colors.yellow},
  ];

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _handleRedeem() async {
    if (!_formKey.currentState!.validate()) return;

    // Parse amount
    final scAmount = int.tryParse(_amountController.text);
    if (scAmount == null || scAmount < 50) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Minimum redemption is 50 SC'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final walletProvider = context.read<WalletProvider>();
    final kycProvider = context.read<KYCProvider>();

    // Check KYC status
    if (!kycProvider.isApproved) {
      _showKYCRequiredDialog();
      return;
    }

    // Check redeemable SC
    if (walletProvider.redeemableSc < scAmount) {
      _showPlaythroughRequiredDialog(walletProvider);
      return;
    }

    setState(() => isProcessing = true);

    final result = await walletProvider.redeemSC(
      scAmount: scAmount,
      cardType: selectedCardType!,
    );

    setState(() => isProcessing = false);

    if (!mounted) return;

    if (result != null) {
      // Success
      _showSuccessDialog(scAmount);
    } else {
      // Error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(walletProvider.errorMessage ?? 'Redemption failed'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showKYCRequiredDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('KYC Verification Required'),
        content: const Text(
          'You must complete identity verification before redeeming Sweeps Coins. '
          'This is required by law to prevent fraud and ensure you receive your prizes.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/kyc/submit');
            },
            child: const Text('Verify Now'),
          ),
        ],
      ),
    );
  }

  void _showPlaythroughRequiredDialog(WalletProvider walletProvider) {
    final playthroughRemaining = walletProvider.scPlaythroughRemaining;
    final progress = walletProvider.playthroughProgress;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Playthrough Required'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'You need to complete the playthrough requirement before redeeming these SC.',
            ),
            const SizedBox(height: 16),
            Text(
              'Playthrough remaining: $playthroughRemaining SC',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress / 100,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
            const SizedBox(height: 4),
            Text(
              '${progress.toStringAsFixed(0)}% Complete',
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 16),
            const Text(
              'Play bets with SC to complete the playthrough requirement.',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(int scAmount) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.check_circle, color: Colors.green, size: 32),
            SizedBox(width: 8),
            Text('Redemption Successful!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You have successfully redeemed $scAmount SC for a \$${scAmount * 0.1} $selectedCardType gift card.',
            ),
            const SizedBox(height: 16),
            const Text(
              'Your gift card code will be sent to your email within 24-48 hours.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to wallet
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Redeem Sweeps Coins'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Balance card
              Consumer<WalletProvider>(
                builder: (context, walletProvider, child) {
                  return Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Available SC',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${walletProvider.scBalance} SC',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF4CAF50),
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text(
                                    'Redeemable SC',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${walletProvider.redeemableSc} SC',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Playthrough progress
                          if (walletProvider.scPlaythroughRemaining > 0) ...[
                            const Divider(),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Playthrough Progress:'),
                                Text(
                                  '${walletProvider.playthroughProgress.toStringAsFixed(0)}%',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: walletProvider.playthroughProgress / 100,
                              backgroundColor: Colors.grey[300],
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.blue,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${walletProvider.scPlaythroughRemaining} SC needs to be played once',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

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
                            '1 SC = \$0.10 USD',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Minimum redemption: 50 SC (\$5.00 gift card)',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Amount input
              const Text(
                'Amount to Redeem',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: 'SC Amount',
                  hintText: 'Enter amount (minimum 50 SC)',
                  prefixIcon: const Icon(Icons.stars, color: Color(0xFF4CAF50)),
                  suffixText: 'SC',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  final amount = int.tryParse(value);
                  if (amount == null) {
                    return 'Please enter a valid number';
                  }
                  if (amount < 50) {
                    return 'Minimum redemption is 50 SC';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {}); // Update USD preview
                },
              ),
              if (_amountController.text.isNotEmpty) ...[
                const SizedBox(height: 8),
                Consumer<WalletProvider>(
                  builder: (context, walletProvider, child) {
                    final scAmount = int.tryParse(_amountController.text) ?? 0;
                    final usdValue = scAmount * 0.1;
                    return Text(
                      '≈ \$${usdValue.toStringAsFixed(2)} USD gift card value',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    );
                  },
                ),
              ],
              const SizedBox(height: 24),

              // Gift card type selection
              const Text(
                'Select Gift Card Type',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.2,
                ),
                itemCount: giftCardOptions.length,
                itemBuilder: (context, index) {
                  final option = giftCardOptions[index];
                  final isSelected = selectedCardType == option['type'];

                  return InkWell(
                    onTap: () {
                      setState(() {
                        selectedCardType = option['type'];
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isSelected ? Colors.blue : Colors.grey[300]!,
                          width: isSelected ? 3 : 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        color: isSelected
                            ? Colors.blue.withOpacity(0.1)
                            : Colors.white,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            option['icon'],
                            color: option['color'],
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            option['type'],
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),

              // Redeem button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: isProcessing ? null : _handleRedeem,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isProcessing
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Redeem SC',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),

              // Terms
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Gift card codes will be sent to your registered email within 24-48 hours. '
                  'You must complete KYC verification and playthrough requirements before redeeming. '
                  'See Terms & Conditions for full details.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
