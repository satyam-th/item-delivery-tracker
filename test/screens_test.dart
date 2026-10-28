import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop_record/providers.dart';
import 'package:shop_record/screens/manage_customers_screen.dart';
import 'package:shop_record/screens/manage_items_screen.dart';
import 'package:shop_record/screens/history_screen.dart';
import 'package:shop_record/screens/settings_screen.dart';
import 'package:shop_record/screens/tools_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget wrapWithProviders(Widget child, {DataProvider? dp, LocaleProvider? lp}) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => dp ?? DataProvider()),
        ChangeNotifierProvider(create: (_) => lp ?? LocaleProvider()),
      ],
      child: MaterialApp(home: child),
    );
  }

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('ManageCustomersScreen displays customers and opens delete confirmation', (tester) async {
    final dp = DataProvider();
    await tester.pumpWidget(wrapWithProviders(const ManageCustomersScreen(), dp: dp));
    await tester.pumpAndSettle();

    expect(find.text('सिर्जना'), findsOneWidget);

    // Find and tap delete button for the first customer
    final deleteButtons = find.byIcon(Icons.delete_outline);
    expect(deleteButtons, findsWidgets);
    await tester.tap(deleteButtons.first);
    await tester.pumpAndSettle();

    // Confirmation dialog is shown
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('रद्द गर्नुहोस्'), findsOneWidget);

    // Cancel deletion
    await tester.tap(find.text('रद्द गर्नुहोस्'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('ManageItemsScreen displays items and opens add dialog', (tester) async {
    final dp = DataProvider();
    await tester.pumpWidget(wrapWithProviders(const ManageItemsScreen(), dp: dp));
    await tester.pumpAndSettle();

    expect(find.text('nilo'), findsOneWidget);

    // Tap Add Item FAB
    final addFab = find.byType(FloatingActionButton);
    expect(addFab, findsOneWidget);
    await tester.tap(addFab);
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(
      find.descendant(of: find.byType(AlertDialog), matching: find.text('सामान थप्नुहोस्')),
      findsOneWidget,
    );
  });

  testWidgets('ToolsScreen calculates expression correctly', (tester) async {
    await tester.pumpWidget(wrapWithProviders(const ToolsScreen()));
    await tester.pumpAndSettle();

    // Tap 7, x, 8, =
    await tester.tap(find.widgetWithText(ElevatedButton, '7'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ElevatedButton, 'x'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ElevatedButton, '8'));
    await tester.pumpAndSettle();

    // Verify live result shows = 56
    expect(find.text('= 56'), findsOneWidget);

    // Tap =
    await tester.tap(find.widgetWithText(ElevatedButton, '='));
    await tester.pumpAndSettle();

    expect(find.text('56'), findsOneWidget);
  });

  testWidgets('SettingsScreen toggles language', (tester) async {
    final lp = LocaleProvider();
    await tester.pumpWidget(wrapWithProviders(const SettingsScreen(), lp: lp));
    await tester.pumpAndSettle();

    expect(find.text('नेपाली (सक्रिय)'), findsOneWidget);

    // Tap language row
    await tester.tap(find.text('नेपाली'));
    await tester.pumpAndSettle();

    expect(find.text('English (Active)'), findsOneWidget);
  });

  testWidgets('HistoryScreen renders filters, search bar, and bottom share action bar', (tester) async {
    final dp = DataProvider();
    await tester.pumpWidget(wrapWithProviders(const HistoryScreen(), dp: dp));
    await tester.pumpAndSettle();

    expect(find.text('All Persons'), findsOneWidget);
    expect(find.text('All Items'), findsOneWidget);
    // Search bar
    expect(find.byType(TextField), findsOneWidget);
    // Bottom share button
    expect(find.text('बिल सेयर गर्नुहोस्'), findsOneWidget);
  });
}
