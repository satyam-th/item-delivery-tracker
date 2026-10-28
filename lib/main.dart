import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'constants/app_colors.dart';
import 'providers.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/tools_screen.dart';
import 'screens/history_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DataProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
      ],
      child: const ShopRecordApp(),
    ),
  );
}

class ShopRecordApp extends StatelessWidget {
  const ShopRecordApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Item',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.darkNavy,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryGreen),
        useMaterial3: true,
      ),
      home: const MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  
  final List<Widget> _screens = [
    const HomeScreen(),
    const HistoryScreen(),
    const ToolsScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final locale = Provider.of<LocaleProvider>(context);
    final data = Provider.of<DataProvider>(context);

    // Show a loading screen while data loads from SharedPreferences
    if (!data.isLoaded) {
      return Scaffold(
        backgroundColor: AppColors.darkNavy,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text(
                'Item',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 24),
              CircularProgressIndicator(color: AppColors.primaryGreen),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: AppColors.primaryGreen,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.grid_view), label: locale.home),
          BottomNavigationBarItem(icon: const Icon(Icons.history), label: locale.history),
          BottomNavigationBarItem(icon: const Icon(Icons.calculate), label: locale.tools),
          BottomNavigationBarItem(icon: const Icon(Icons.settings), label: locale.settings),
        ],
      ),
    );
  }
}
