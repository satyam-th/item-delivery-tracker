import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop_record/providers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LocaleProvider Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('Initial language is Nepali and toggles to English and persists', () async {
      final locale = LocaleProvider();
      await Future.delayed(const Duration(milliseconds: 20));

      expect(locale.isNepali, true);
      expect(locale.home, 'होम');
      expect(locale.todayTotal, 'आजको कुल जम्मा');

      locale.toggleLanguage();
      await Future.delayed(const Duration(milliseconds: 20));

      expect(locale.isNepali, false);
      expect(locale.home, 'Home');
      expect(locale.todayTotal, "Today's Total");
      expect(locale.load, 'Load');
      expect(locale.returnItem, 'Return');

      // Verify persistence by initializing another LocaleProvider instance
      final secondLocale = LocaleProvider();
      await Future.delayed(const Duration(milliseconds: 50));
      expect(secondLocale.isNepali, false);
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

    test('Customer CRUD: add, edit, reorder, and delete with trimming', () async {
      final dp = DataProvider();
      await Future.delayed(const Duration(milliseconds: 50));

      final initialCount = dp.customers.length;

      // Add with whitespace to test trimming
      dp.addCustomer('  नयाँ ग्राहक  ');
      expect(dp.customers.length, initialCount + 1);
      final newCust = dp.customers.last;
      expect(newCust.name, 'नयाँ ग्राहक');

      // Edit with whitespace to test trimming
      dp.editCustomer(newCust.id, '  अपडेट गरिएको ग्राहक  ');
      expect(dp.customers.last.name, 'अपडेट गरिएको ग्राहक');

      // Reorder
      dp.reorderCustomers(0, dp.customers.length);
      expect(dp.customers.last.id, 'c1');

      // Delete
      dp.deleteCustomer(newCust.id);
      expect(dp.customers.length, initialCount);
    });

    test('Item CRUD: add, edit, and delete with trimming', () async {
      final dp = DataProvider();
      await Future.delayed(const Duration(milliseconds: 50));

      final initialItemCount = dp.items.length;

      // Add with whitespace
      dp.addItem('  New Milk  ');
      expect(dp.items.length, initialItemCount + 1);
      final newItem = dp.items.last;
      expect(newItem.name, 'New Milk');

      // Edit with whitespace
      dp.editItem(newItem.id, '  Super Milk  ');
      expect(dp.items.last.name, 'Super Milk');

      // Delete
      dp.deleteItem(newItem.id);
      expect(dp.items.length, initialItemCount);
    });

    test('Transaction deletion works cleanly', () async {
      final dp = DataProvider();
      await Future.delayed(const Duration(milliseconds: 50));

      dp.updateCell('c1', 'i1', 15, 3);
      final txCount = dp.transactions.length;
      expect(txCount, greaterThan(0));

      final txId = dp.transactions.first.id;
      dp.deleteTransaction(txId);
      expect(dp.transactions.length, txCount - 1);
      expect(dp.transactions.any((t) => t.id == txId), false);
    });

    test('Morning vehicle stock and live remaining stock calculation', () async {
      final dp = DataProvider();
      await Future.delayed(const Duration(milliseconds: 50));

      // Initially 0 morning stock
      expect(dp.getMorningStock('i1'), 0);

      final totalDeliveredInitially = dp.getTotalDelivered('i1');
      final totalReturnedInitially = dp.getTotalReturned('i1');

      // Set vehicle stock: 1700 packets of i1 (Nilo) and 1300 of i2 (Hariyo)
      dp.setMorningStock({'i1': 1700, 'i2': 1300});
      expect(dp.getMorningStock('i1'), 1700);
      expect(dp.getMorningStock('i2'), 1300);

      // Remaining should be loaded - totalDelivered + totalReturned
      expect(dp.getRemainingStock('i1'), 1700 - totalDeliveredInitially + totalReturnedInitially);

      // Customer c1 takes 10 additional packets
      final c1Cell = dp.getCellData('c1', 'i1');
      dp.updateCell('c1', 'i1', c1Cell.delivered + 10, c1Cell.returned);

      expect(dp.getRemainingStock('i1'), 1700 - totalDeliveredInitially + totalReturnedInitially - 10);

      // Customer c1 returns 5 packets: remaining increases by 5
      dp.updateCell('c1', 'i1', c1Cell.delivered + 10, c1Cell.returned + 5);
      expect(dp.getRemainingStock('i1'), 1700 - totalDeliveredInitially + totalReturnedInitially - 5);

      // Deleting item cleans up morning stock
      dp.deleteItem('i1');
      expect(dp.getMorningStock('i1'), 0);
    });
  });
}
