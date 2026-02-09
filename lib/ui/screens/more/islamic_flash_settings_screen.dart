import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/theme.dart';
import '../../../providers/islamic_flash_provider.dart';

/// Islamic Flash Settings Screen
/// Allows users to configure Islamic Flash notifications and preferences
class IslamicFlashSettingsScreen extends StatefulWidget {
  const IslamicFlashSettingsScreen({super.key});

  @override
  State<IslamicFlashSettingsScreen> createState() => _IslamicFlashSettingsScreenState();
}

class _IslamicFlashSettingsScreenState extends State<IslamicFlashSettingsScreen> {
  
  @override
  void initState() {
    super.initState();
    // Initialize provider if not already
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<IslamicFlashProvider>(context, listen: false);
      if (!provider.isInitialized) {
        provider.initialize();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF0F2027), const Color(0xFF203A43), const Color(0xFF2C5364)]
                : [AppColors.primary, AppColors.primaryDark],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(context),
              
              // Settings content
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Consumer<IslamicFlashProvider>(
                    builder: (context, provider, child) {
                      if (provider.isLoading && !provider.isInitialized) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // General Settings
                            _buildSectionTitle('General'),
                            const SizedBox(height: 12),
                            _buildSettingsCard(
                              context,
                              children: [
                                _buildSwitchTile(
                                  context,
                                  title: 'Enable Islamic Flashes',
                                  subtitle: 'Show Islamic reminders in the app',
                                  icon: Icons.auto_awesome,
                                  value: provider.flashEnabled,
                                  onChanged: (value) => provider.setFlashEnabled(value),
                                ),
                                _buildDivider(),
                                _buildSwitchTile(
                                  context,
                                  title: 'Show on Home Screen',
                                  subtitle: 'Display flash card on home',
                                  icon: Icons.home_rounded,
                                  value: provider.showOnHome,
                                  enabled: provider.flashEnabled,
                                  onChanged: (value) => provider.setShowOnHome(value),
                                ),
                                _buildDivider(),
                                _buildSwitchTile(
                                  context,
                                  title: 'Offline Mode',
                                  subtitle: 'Use local flashes when offline',
                                  icon: Icons.offline_bolt_rounded,
                                  value: provider.offlineEnabled,
                                  enabled: provider.flashEnabled,
                                  onChanged: (value) => provider.setOfflineEnabled(value),
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            // Notification Settings
                            _buildSectionTitle('Notifications'),
                            const SizedBox(height: 12),
                            _buildSettingsCard(
                              context,
                              children: [
                                _buildSwitchTile(
                                  context,
                                  title: 'Daily Notifications',
                                  subtitle: 'Receive daily Islamic reminders',
                                  icon: Icons.notifications_active_rounded,
                                  value: provider.notificationsEnabled,
                                  enabled: provider.flashEnabled,
                                  onChanged: (value) => provider.setNotificationsEnabled(value),
                                ),
                                _buildDivider(),
                                _buildTimePicker(
                                  context,
                                  provider: provider,
                                ),
                                _buildDivider(),
                                _buildSwitchTile(
                                  context,
                                  title: 'Random Time',
                                  subtitle: 'Send at random times during the day',
                                  icon: Icons.shuffle_rounded,
                                  value: provider.randomTime,
                                  enabled: provider.flashEnabled && provider.notificationsEnabled,
                                  onChanged: (value) => provider.setRandomTime(value),
                                ),
                                _buildDivider(),
                                _buildSwitchTile(
                                  context,
                                  title: 'Friday Reminders Only',
                                  subtitle: 'Only receive Jumu\'ah reminders',
                                  icon: Icons.mosque_rounded,
                                  value: provider.fridayOnly,
                                  enabled: provider.flashEnabled && provider.notificationsEnabled,
                                  onChanged: (value) => provider.setFridayOnly(value),
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            // Actions
                            _buildSectionTitle('Actions'),
                            const SizedBox(height: 12),
                            _buildSettingsCard(
                              context,
                              children: [
                                _buildActionTile(
                                  context,
                                  title: 'Test Notification',
                                  subtitle: 'Send a test reminder now',
                                  icon: Icons.send_rounded,
                                  onTap: () async {
                                    await provider.sendTestNotification();
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Test notification sent!'),
                                          backgroundColor: AppColors.primary,
                                        ),
                                      );
                                    }
                                  },
                                ),
                                _buildDivider(),
                                _buildActionTile(
                                  context,
                                  title: 'Reset to Defaults',
                                  subtitle: 'Restore all settings',
                                  icon: Icons.restore_rounded,
                                  isDestructive: true,
                                  onTap: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        title: const Text('Reset Settings'),
                                        content: const Text(
                                          'Are you sure you want to reset all Islamic Flash settings to defaults?',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context, false),
                                            child: const Text('Cancel'),
                                          ),
                                          ElevatedButton(
                                            onPressed: () => Navigator.pop(context, true),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.orange,
                                            ),
                                            child: const Text('Reset', style: TextStyle(color: Colors.white)),
                                          ),
                                        ],
                                      ),
                                    );

                                    if (confirm == true) {
                                      await provider.resetSettings();
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Settings reset to defaults'),
                                          ),
                                        );
                                      }
                                    }
                                  },
                                ),
                              ],
                            ),

                            const SizedBox(height: 30),

                            // Info footer
                            _buildInfoFooter(context),

                            const SizedBox(height: 20),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 10, 20, 30),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Center(
              child: Column(
                children: [
                  Text(
                    'Islamic Flashes',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Reminder Settings',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).textTheme.titleLarge?.color,
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context, {required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSwitchTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool enabled = true,
  }) {
    final theme = Theme.of(context);
    
    return Opacity(
      opacity: enabled ? 1.0 : 0.5,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primary, size: 24),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        trailing: Switch(
          value: value,
          onChanged: enabled ? onChanged : null,
          activeColor: AppColors.primary,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }

  Widget _buildTimePicker(BuildContext context, {required IslamicFlashProvider provider}) {
    final theme = Theme.of(context);
    final enabled = provider.flashEnabled && provider.notificationsEnabled && !provider.randomTime;

    return Opacity(
      opacity: enabled ? 1.0 : 0.5,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.access_time_rounded, color: AppColors.primary, size: 24),
        ),
        title: Text(
          'Notification Time',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
        subtitle: Text(
          provider.notificationTimeFormatted,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: AppColors.accent,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: enabled
            ? () async {
                final TimeOfDay? picked = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay(
                    hour: provider.notificationHour,
                    minute: provider.notificationMinute,
                  ),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: Theme.of(context).colorScheme.copyWith(
                          primary: AppColors.primary,
                        ),
                      ),
                      child: child!,
                    );
                  },
                );

                if (picked != null) {
                  await provider.setNotificationTime(picked.hour, picked.minute);
                }
              }
            : null,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final theme = Theme.of(context);
    final color = isDestructive ? Colors.orange : AppColors.primary;

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w500,
          color: isDestructive ? Colors.orange : theme.textTheme.bodyLarge?.color,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.poppins(
          fontSize: 12,
          color: Colors.grey,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      indent: 72,
      endIndent: 16,
      color: Colors.grey.withOpacity(0.2),
    );
  }

  Widget _buildInfoFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.primary, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Islamic Flashes help you stay connected with your faith through daily reminders. All content is from authentic sources.',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
