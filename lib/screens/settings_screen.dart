import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../providers.dart';
import 'manage_customers_screen.dart';
import 'manage_items_screen.dart';
import 'manage_rates_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _showInfoDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK', style: TextStyle(color: AppColors.primaryGreen)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = Provider.of<LocaleProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.darkNavy,
      appBar: AppBar(
        title: Text(locale.settings),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.darkNavy,
        foregroundColor: Colors.white,
      ),
      body: Container(
        color: Colors.white,
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                locale.language,
                style: const TextStyle(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
            _buildListTile(
              icon: Icons.language,
              title: locale.currentLanguage,
              subtitle: locale.isNepali ? 'नेपाली (सक्रिय)' : 'English (Active)',
              onTap: () {
                locale.toggleLanguage();
              },
            ),
            const Divider(height: 1, color: Colors.black12),
            
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                locale.returnDisplayMode,
                style: const TextStyle(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
            _buildListTile(
              icon: Icons.view_agenda,
              title: locale.extraRow,
              subtitle: locale.isNepali ? 'मानक दृश्य' : 'Standard View',
              onTap: () {
                _showInfoDialog(
                  context,
                  locale.returnDisplayMode,
                  locale.isNepali 
                      ? 'वर्तमान मोड: प्रत्येक कक्षमा लोड र फिर्ता दुवै देखाइन्छ।'
                      : 'Current mode: Displays both Load and Return in each cell.',
                );
              },
            ),
            const Divider(height: 1, color: Colors.black12),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                locale.returnFormatStyle,
                style: const TextStyle(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
            _buildListTile(
              icon: Icons.format_list_numbered,
              title: '5-1',
              subtitle: locale.isNepali ? 'लोड - फिर्ता' : 'Load - Return',
              onTap: () {
                _showInfoDialog(
                  context,
                  locale.returnFormatStyle,
                  locale.isNepali 
                      ? 'वर्तमान ढाँचा: लोड माथि र फिर्ता (- संख्या) तल देखाइन्छ।'
                      : 'Current style: Load is displayed on top, and Return (- count) below.',
                );
              },
            ),
            const Divider(height: 1, color: Colors.black12),
            
            const SizedBox(height: 16),
            
            _buildListTile(
              icon: Icons.people,
              title: locale.manageCustomers,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ManageCustomersScreen()),
                );
              },
            ),
            const Divider(height: 1, color: Colors.black12),
            
            _buildListTile(
              icon: Icons.category,
              title: locale.manageItems,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ManageItemsScreen()),
                );
              },
            ),
            const Divider(height: 1, color: Colors.black12),
            
            _buildListTile(
              icon: Icons.currency_rupee,
              title: locale.manageRates,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ManageRatesScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primaryGreen),
      title: Text(
        title,
        style: const TextStyle(color: Colors.black87, fontSize: 16),
      ),
      subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.black45)) : null,
      trailing: const Icon(Icons.chevron_right, color: Colors.black54),
      onTap: onTap,
    );
  }
}
