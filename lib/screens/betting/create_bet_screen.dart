import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../providers/bet_provider.dart';
import '../../providers/auth_provider.dart';

class CreateBetScreen extends StatefulWidget {
  const CreateBetScreen({super.key});

  @override
  State<CreateBetScreen> createState() => _CreateBetScreenState();
}

class _CreateBetScreenState extends State<CreateBetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _stakeController = TextEditingController();
  final _maxPlayersController = TextEditingController(text: '4');

  String _betType = 'stroke';
  bool _isPublic = true;
  bool _allowOutsideBackers = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _stakeController.dispose();
    _maxPlayersController.dispose();
    super.dispose();
  }

  Future<void> _createBet() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    if (authProvider.user == null) return;

    final stake = double.parse(_stakeController.text);
    final maxPlayers = int.parse(_maxPlayersController.text);

    // Check if user has enough balance
    if (authProvider.user!.walletBalance < stake) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Insufficient balance to create this bet'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      final betProvider = context.read<BetProvider>();
      final bet = await betProvider.createBet(
        name: _nameController.text.trim(),
        betType: _betType,
        stakeAmount: stake,
        maxPlayers: maxPlayers,
        isPublic: _isPublic,
        allowOutsideBackers: _allowOutsideBackers,
      );

      if (mounted) {
        if (bet != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Bet created successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        } else if (betProvider.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(betProvider.errorMessage!),
              backgroundColor: Colors.red,
            ),
          );
          betProvider.clearError();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating bet: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.deepNavy,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppTheme.neonBlue),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Create Bet',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Bet Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Bet Name',
                  hintText: 'Sunday Round at Pebble Beach',
                  prefixIcon: Icon(Icons.golf_course, color: AppTheme.neonBlue),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a bet name';
                  }
                  if (value.length < 3) {
                    return 'Name must be at least 3 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Bet Type
              const Text(
                'Bet Type',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('Stroke Play'),
                    selected: _betType == 'stroke',
                    onSelected: (selected) {
                      if (selected) setState(() => _betType = 'stroke');
                    },
                    selectedColor: AppTheme.hotPink,
                    backgroundColor: AppTheme.darkSlateGray,
                    labelStyle: TextStyle(
                      color: _betType == 'stroke'
                          ? Colors.white
                          : AppTheme.textSecondary,
                    ),
                  ),
                  ChoiceChip(
                    label: const Text('Skins'),
                    selected: _betType == 'skins',
                    onSelected: (selected) {
                      if (selected) setState(() => _betType = 'skins');
                    },
                    selectedColor: AppTheme.hotPink,
                    backgroundColor: AppTheme.darkSlateGray,
                    labelStyle: TextStyle(
                      color: _betType == 'skins'
                          ? Colors.white
                          : AppTheme.textSecondary,
                    ),
                  ),
                  ChoiceChip(
                    label: const Text('Custom'),
                    selected: _betType == 'custom',
                    onSelected: (selected) {
                      if (selected) setState(() => _betType = 'custom');
                    },
                    selectedColor: AppTheme.hotPink,
                    backgroundColor: AppTheme.darkSlateGray,
                    labelStyle: TextStyle(
                      color: _betType == 'custom'
                          ? Colors.white
                          : AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Stake Amount
              TextFormField(
                controller: _stakeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Stake (points)',
                  hintText: '100',
                  prefixIcon: Icon(Icons.attach_money, color: AppTheme.neonBlue),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter stake amount';
                  }
                  final stake = double.tryParse(value);
                  if (stake == null || stake <= 0) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Max Players
              TextFormField(
                controller: _maxPlayersController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Max Players',
                  hintText: '4',
                  prefixIcon: Icon(Icons.people, color: AppTheme.neonBlue),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter max players';
                  }
                  final players = int.tryParse(value);
                  if (players == null || players < 2 || players > 8) {
                    return 'Players must be between 2 and 8';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Options
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.darkSlateGray,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Bet Options',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      title: const Text(
                        'Public Bet',
                        style: TextStyle(color: AppTheme.textPrimary),
                      ),
                      subtitle: const Text(
                        'Anyone can join this bet',
                        style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                      ),
                      value: _isPublic,
                      onChanged: (value) => setState(() => _isPublic = value),
                      activeThumbColor: AppTheme.neonGreen,
                      contentPadding: EdgeInsets.zero,
                    ),
                    const Divider(color: AppTheme.textMuted, height: 1),
                    SwitchListTile(
                      title: const Text(
                        'Allow Outside Backers',
                        style: TextStyle(color: AppTheme.textPrimary),
                      ),
                      subtitle: const Text(
                        'Non-players can bet on outcomes',
                        style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                      ),
                      value: _allowOutsideBackers,
                      onChanged: (value) =>
                          setState(() => _allowOutsideBackers = value),
                      activeThumbColor: AppTheme.neonGreen,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Create Button
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createBet,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'CREATE BET',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
