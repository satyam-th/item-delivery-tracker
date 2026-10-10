import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers.dart';
import 'manage_customers_screen.dart';
import 'manage_items_screen.dart';
import 'manage_rates_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = Provider.of<LocaleProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0F2027),
      appBar: AppBar(
        title: Text(locale.settings), // Settings
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color(0xFF0F2027),
        foregroundColor: const Color(0xFFF1A8A6), // Pinkish text from image
      ),
      body: Container(
        color: Colors.white, // default background
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                locale.language, // Language
                style: const TextStyle(color: Colors.black54, fontSize: 12),
              ),
            ),
            _buildListTile(
              icon: Icons.language,
              title: locale.currentLanguage,
              onTap: () {
                locale.toggleLanguage();
              },
            ),
            const Divider(height: 1, color: Colors.black12),
            
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                locale.returnDisplayMode, // Return display mode
                style: const TextStyle(color: Colors.black54, fontSize: 12),
              ),
            ),
            _buildListTile(
              icon: Icons.view_agenda,
              title: locale.extraRow, // Extra row
              onTap: () {},
            ),
            const Divider(height: 1, color: Colors.black12),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                locale.returnFormatStyle, // Return format style
                style: const TextStyle(color: Colors.black54, fontSize: 12),
              ),
            ),
            _buildListTile(
              icon: Icons.format_list_numbered,
              title: '5-1',
              onTap: () {},
            ),
            const Divider(height: 1, color: Colors.black12),
            
            const SizedBox(height: 16),
            
            _buildListTile(
              icon: Icons.people,
              title: locale.manageCustomers, // Manage people
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
              title: locale.manageItems, // Manage items
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
              title: locale.manageRates, // Manage rates
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

  Widget _buildListTile({required IconData icon, required String title, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF138D5B)), // Green icons
      title: Text(
        title,
        style: const TextStyle(color: Colors.black87, fontSize: 16),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.black54),
      onTap: onTap,
    );
  }
}


