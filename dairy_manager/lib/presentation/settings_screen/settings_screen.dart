import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.black,
        toolbarHeight: 100,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              l10n.settings,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Icon(Icons.settings, color: Colors.white, size: 32),
          ],
        ),
        centerTitle: true,
        actions: [
          // Removed extra settings icon
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          children: [
            const SizedBox(height: 24),
            _pillButton(
              context,
              label: l10n.profile,
              onTap: () => Navigator.pushNamed(context, '/profile'),
            ),
            const SizedBox(height: 16),
            _pillButton(
              context,
              label: l10n.language,
              onTap: () => _showLanguageDialog(context),
            ),
            const SizedBox(height: 16),
            _pillButton(
              context,
              label: l10n.logout,
              onTap: () => _showLogoutDialog(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pillButton(BuildContext context, {required String label, required VoidCallback onTap}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 3,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18,), 
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    final languageProvider = context.read<LanguageProvider>();
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          AppLocalizations.of(context)!.language,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppTheme.textPrimaryColor,
            fontWeight: FontWeight.w600
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption(
              context,
              l10n.english,
              'en',
              languageProvider.locale.languageCode == 'en',
              () {
                languageProvider.setLocale(const Locale('en'));
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 8),
            _buildLanguageOption(
              context,
              l10n.telugu,
              'te',
              languageProvider.locale.languageCode == 'te',
              () {
                languageProvider.setLocale(const Locale('te'));
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    String languageName,
    String languageCode,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected 
                ? AppTheme.primaryColor.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected 
                  ? AppTheme.primaryColor
                  : AppTheme.textSecondaryColor.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Text(
                languageName,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: isSelected 
                      ? AppTheme.primaryColor
                      : AppTheme.textPrimaryColor,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
              const Spacer(),
              if (isSelected)
                Icon(
                  Icons.check,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          l10n.logout,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppTheme.textPrimaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          l10n.logoutConfirmation,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppTheme.textSecondaryColor,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              l10n.cancel,
              style: TextStyle(
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthProvider>().logout();
              Navigator.pushReplacementNamed(context, '/');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
              foregroundColor: AppTheme.whiteColor,
            ),
            child: Text(l10n.logout),
          ),
        ],
      ),
    );
  }
}
