import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/app_theme.dart';
import '../../providers/auth_provider.dart';
import 'change_password_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Notification settings
  bool _pushNotifications = true;
  bool _emailNotifications = true;
  bool _betInvites = true;
  bool _followNotifications = true;
  bool _reminders = true;

  // Privacy settings
  bool _profileVisibility = true;
  bool _showEmail = false;
  bool _showPhone = false;
  bool _allowBetInvites = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _pushNotifications = prefs.getBool('push_notifications') ?? true;
      _emailNotifications = prefs.getBool('email_notifications') ?? true;
      _betInvites = prefs.getBool('bet_invites') ?? true;
      _followNotifications = prefs.getBool('follow_notifications') ?? true;
      _reminders = prefs.getBool('reminders') ?? true;
      _profileVisibility = prefs.getBool('profile_visibility') ?? true;
      _showEmail = prefs.getBool('show_email') ?? false;
      _showPhone = prefs.getBool('show_phone') ?? false;
      _allowBetInvites = prefs.getBool('allow_bet_invites') ?? true;
    });
  }

  Future<void> _saveSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => _DeleteAccountDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      backgroundColor: AppTheme.deepNavy,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.neonBlue),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Account Information Section
          _buildSectionHeader('Account Information'),
          _buildInfoCard(
            icon: Icons.email_outlined,
            title: 'Email',
            value: user?.email ?? 'Not available',
          ),
          _buildInfoCard(
            icon: Icons.person_outline,
            title: 'Username',
            value: '@${user?.username ?? 'unknown'}',
          ),
          _buildInfoCard(
            icon: Icons.calendar_today_outlined,
            title: 'Member Since',
            value: user?.createdAt != null
                ? '${user!.createdAt!.year}'
                : 'Unknown',
          ),

          const SizedBox(height: 24),

          // Notifications Section
          _buildSectionHeader('Notifications'),
          _buildSettingsCard(
            child: Column(
              children: [
                _buildSwitchTile(
                  title: 'Push Notifications',
                  subtitle: 'Receive push notifications',
                  value: _pushNotifications,
                  onChanged: (value) {
                    setState(() => _pushNotifications = value);
                    _saveSetting('push_notifications', value);
                  },
                ),
                const Divider(color: AppTheme.textMuted, height: 1),
                _buildSwitchTile(
                  title: 'Email Notifications',
                  subtitle: 'Receive email updates',
                  value: _emailNotifications,
                  onChanged: (value) {
                    setState(() => _emailNotifications = value);
                    _saveSetting('email_notifications', value);
                  },
                ),
                const Divider(color: AppTheme.textMuted, height: 1),
                _buildSwitchTile(
                  title: 'Bet Invites',
                  subtitle: 'Get notified of bet invitations',
                  value: _betInvites,
                  onChanged: (value) {
                    setState(() => _betInvites = value);
                    _saveSetting('bet_invites', value);
                  },
                ),
                const Divider(color: AppTheme.textMuted, height: 1),
                _buildSwitchTile(
                  title: 'Follow Notifications',
                  subtitle: 'When someone follows you',
                  value: _followNotifications,
                  onChanged: (value) {
                    setState(() => _followNotifications = value);
                    _saveSetting('follow_notifications', value);
                  },
                ),
                const Divider(color: AppTheme.textMuted, height: 1),
                _buildSwitchTile(
                  title: 'Reminders',
                  subtitle: 'Bet reminders and updates',
                  value: _reminders,
                  onChanged: (value) {
                    setState(() => _reminders = value);
                    _saveSetting('reminders', value);
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Privacy Section
          _buildSectionHeader('Privacy'),
          _buildSettingsCard(
            child: Column(
              children: [
                _buildSwitchTile(
                  title: 'Public Profile',
                  subtitle: 'Make your profile visible to everyone',
                  value: _profileVisibility,
                  onChanged: (value) {
                    setState(() => _profileVisibility = value);
                    _saveSetting('profile_visibility', value);
                  },
                ),
                const Divider(color: AppTheme.textMuted, height: 1),
                _buildSwitchTile(
                  title: 'Show Email',
                  subtitle: 'Display email on your profile',
                  value: _showEmail,
                  onChanged: (value) {
                    setState(() => _showEmail = value);
                    _saveSetting('show_email', value);
                  },
                ),
                const Divider(color: AppTheme.textMuted, height: 1),
                _buildSwitchTile(
                  title: 'Show Phone Number',
                  subtitle: 'Display phone on your profile',
                  value: _showPhone,
                  onChanged: (value) {
                    setState(() => _showPhone = value);
                    _saveSetting('show_phone', value);
                  },
                ),
                const Divider(color: AppTheme.textMuted, height: 1),
                _buildSwitchTile(
                  title: 'Allow Bet Invites',
                  subtitle: 'Anyone can invite you to bets',
                  value: _allowBetInvites,
                  onChanged: (value) {
                    setState(() => _allowBetInvites = value);
                    _saveSetting('allow_bet_invites', value);
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Security Section
          _buildSectionHeader('Security'),
          _buildSettingsCard(
            child: Column(
              children: [
                _buildActionTile(
                  icon: Icons.lock_outline,
                  title: 'Change Password',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ChangePasswordScreen(),
                      ),
                    );
                  },
                ),
                const Divider(color: AppTheme.textMuted, height: 1),
                _buildActionTile(
                  icon: Icons.email_outlined,
                  title: 'Change Email',
                  onTap: () {
                    // TODO: Implement change email
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Coming soon')),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Support Section
          _buildSectionHeader('Support & Legal'),
          _buildSettingsCard(
            child: Column(
              children: [
                _buildActionTile(
                  icon: Icons.description_outlined,
                  title: 'Terms of Service',
                  onTap: () {
                    // TODO: Navigate to ToS
                  },
                ),
                const Divider(color: AppTheme.textMuted, height: 1),
                _buildActionTile(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacy Policy',
                  onTap: () {
                    // TODO: Navigate to Privacy Policy
                  },
                ),
                const Divider(color: AppTheme.textMuted, height: 1),
                _buildActionTile(
                  icon: Icons.help_outline,
                  title: 'Help & Support',
                  onTap: () {
                    // TODO: Navigate to Help Center
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Danger Zone
          _buildSectionHeader('Danger Zone'),
          _buildSettingsCard(
            child: _buildActionTile(
              icon: Icons.delete_forever,
              title: 'Delete Account',
              isDestructive: true,
              onTap: _showDeleteAccountDialog,
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title,
        style: const TextStyle(
          color: AppTheme.neonBlue,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSettingsCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.darkSlateGray,
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.darkSlateGray,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.neonBlue, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(
        title,
        style: const TextStyle(
          color: AppTheme.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          color: AppTheme.textSecondary,
          fontSize: 12,
        ),
      ),
      value: value,
      onChanged: onChanged,
      activeThumbColor: AppTheme.neonGreen,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? AppTheme.hotPink : AppTheme.neonBlue,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? AppTheme.hotPink : AppTheme.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: isDestructive ? AppTheme.hotPink : AppTheme.textSecondary,
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}

class _DeleteAccountDialog extends StatefulWidget {
  @override
  State<_DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<_DeleteAccountDialog> {
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _deleteAccount() async {
    if (_passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your password'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // TODO: Implement delete account API call
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        Navigator.pop(context);
        context.read<AuthProvider>().logout();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
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
    return AlertDialog(
      backgroundColor: AppTheme.darkSlateGray,
      title: const Text(
        'Delete Account',
        style: TextStyle(color: AppTheme.hotPink),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'This action cannot be undone. All your data will be permanently deleted.',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Enter your password',
              border: OutlineInputBorder(),
            ),
            style: const TextStyle(color: AppTheme.textPrimary),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: AppTheme.neonBlue)),
        ),
        TextButton(
          onPressed: _isLoading ? null : _deleteAccount,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppTheme.hotPink,
                  ),
                )
              : const Text('Delete', style: TextStyle(color: AppTheme.hotPink)),
        ),
      ],
    );
  }
}
