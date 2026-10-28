import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop_record/providers.dart';
import 'package:shop_record/screens/home_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget createTestWidget() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DataProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
      ],
      child: const MaterialApp(
        home: HomeScreen(),
      ),
    );
  }

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('HomeScreen renders table, customer list, and grand total', (tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Verify header and first customer name exists
    expect(find.text('Item'), findsOneWidget);
    expect(find.text('सिर्जना'), findsOneWidget);
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('Tapping customer name opens CustomerLoadReturnSheet with tabs', (tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Tap the customer 'सिर्जना'
    final customerFinder = find.text('सिर्जना');
    expect(customerFinder, findsOneWidget);
    await tester.tap(customerFinder);
    await tester.pumpAndSettle();

    // Bottom sheet should be visible with customer name and Load/Return tabs
    expect(find.byType(CustomerLoadReturnSheet), findsOneWidget);
    expect(find.text('दिएको (Load)'), findsOneWidget);
    expect(find.text('फिर्ता (Return)'), findsOneWidget);
    expect(find.text('बचत गर्नुहोस्'), findsOneWidget);

    // Switch to Return tab
    await tester.tap(find.text('फिर्ता (Return)'));
    await tester.pumpAndSettle();

    // Tap Save button to close sheet
    await tester.tap(find.text('बचत गर्नुहोस्'));
    await tester.pumpAndSettle();

    // Bottom sheet is dismissed
    expect(find.byType(CustomerLoadReturnSheet), findsNothing);
  });

  testWidgets('Top vehicle stock bar renders and opens edit stock dialog', (tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Verify Morning Stock header exists
    expect(find.text('गाडी लोड'), findsOneWidget);
    expect(find.text('गाडी लोड मिलाउनुहोस्'), findsOneWidget);

    // Tap 'गाडी लोड मिलाउनुहोस्' to open dialog
    await tester.tap(find.text('गाडी लोड मिलाउनुहोस्'));
    await tester.pumpAndSettle();

    // Verify dialog opened
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('बचत गर्नुहोस्'), findsOneWidget);

    // Tap Cancel
    await tester.tap(find.text('रद्द गर्नुहोस्'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
  });
}
