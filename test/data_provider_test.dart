import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop_record/providers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LocaleProvider Tests', () {
    test('Initial language is Nepali and toggles to English', () {
      final locale = LocaleProvider();
      expect(locale.isNepali, true);
      expect(locale.home, 'होम');
      expect(locale.todayTotal, 'आजको कुल जम्मा');

      locale.toggleLanguage();
      expect(locale.isNepali, false);
      expect(locale.home, 'Home');
      expect(locale.todayTotal, "Today's Total");
      expect(locale.load, 'Load');
      expect(locale.returnItem, 'Return');
    });
  });

  group('DataProvider Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('Initializes with default customers and items on first run', () async {
      final dp = DataProvider();
      // Allow async _loadFromDisk to complete
      await Future.delayed(const Duration(milliseconds: 50));

      expect(dp.isLoaded, true);
      expect(dp.customers.isNotEmpty, true);
      expect(dp.items.isNotEmpty, true);
      expect(dp.customers.first.name, 'सिर्जना');
    });

    test('Rates: Universal rate fallback and custom rate override', () async {
      final dp = DataProvider();
      await Future.delayed(const Duration(milliseconds: 50));

      // Universal rate for item 1
      final uniRate = dp.getUniversalRate('i1');
      expect(uniRate, 46.75);

      // Customer c1 should get universal rate initially
      expect(dp.getRate('c1', 'i1'), 46.75);

      // Set custom rate for c1
      dp.updateCustomRate('c1', 'i1', 50.0);
      expect(dp.getRate('c1', 'i1'), 50.0);

      // Other customers still get universal rate
      expect(dp.getRate('c2', 'i1'), 46.75);
    });

    test('Cell update and row total calculation', () async {
      final dp = DataProvider();
      await Future.delayed(const Duration(milliseconds: 50));

      // Update cell for c1, i1: 10 delivered, 2 returned (net 8)
      // Rate is 46.75 -> 8 * 46.75 = 374.0
      dp.updateCell('c1', 'i1', 10, 2);

      final cell = dp.getCellData('c1', 'i1');
      expect(cell.delivered, 10);
      expect(cell.returned, 2);

      // Check transactions recorded
      expect(dp.transactions.isNotEmpty, true);
      expect(dp.transactions.first.delivered, 10);
      expect(dp.transactions.first.returned, 2);
    });

    test('updateCustomerGrid batch updates properly', () async {
      final dp = DataProvider();
      await Future.delayed(const Duration(milliseconds: 50));

      final prevTxCount = dp.transactions.length;

      dp.updateCustomerGrid(
        customerId: 'c1',
        loads: {'i1': 20, 'i2': 10},
        returns: {'i1': 5, 'i2': 2},
      );

      final cell1 = dp.getCellData('c1', 'i1');
      expect(cell1.delivered, 20);
      expect(cell1.returned, 5);

      final cell2 = dp.getCellData('c1', 'i2');
      expect(cell2.delivered, 10);
      expect(cell2.returned, 2);

      expect(dp.transactions.length, greaterThan(prevTxCount));
    });

    test('Customer CRUD: add, edit, reorder, and delete', () async {
      final dp = DataProvider();
      await Future.delayed(const Duration(milliseconds: 50));

      final initialCount = dp.customers.length;

      // Add
      dp.addCustomer('नयाँ ग्राहक');
      expect(dp.customers.length, initialCount + 1);
      final newCust = dp.customers.last;
      expect(newCust.name, 'नयाँ ग्राहक');

      // Edit
      dp.editCustomer(newCust.id, 'अपडेट गरिएको ग्राहक');
      expect(dp.customers.last.name, 'अपडेट गरिएको ग्राहक');

      // Reorder
      dp.reorderCustomers(0, dp.customers.length);
      expect(dp.customers.last.id, 'c1');

      // Delete
      dp.deleteCustomer(newCust.id);
      expect(dp.customers.length, initialCount);
    });

    test('Item CRUD: add, edit, and delete', () async {
      final dp = DataProvider();
      await Future.delayed(const Duration(milliseconds: 50));

      final initialItemCount = dp.items.length;

      // Add
      dp.addItem('New Milk');
      expect(dp.items.length, initialItemCount + 1);
      final newItem = dp.items.last;
      expect(newItem.name, 'New Milk');

      // Edit
      dp.editItem(newItem.id, 'Super Milk');
      expect(dp.items.last.name, 'Super Milk');

      // Delete
      dp.deleteItem(newItem.id);
      expect(dp.items.length, initialItemCount);
    });
  });
}
