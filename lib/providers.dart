import 'package:flutter/widgets.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Customer {
  String id;
  String name;
  Customer({required this.id, required this.name});

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
  factory Customer.fromJson(Map<String, dynamic> json) =>
      Customer(id: json['id'], name: json['name']);
}

class Item {
  String id;
  String name;
  Item({required this.id, required this.name});

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
  factory Item.fromJson(Map<String, dynamic> json) =>
      Item(id: json['id'], name: json['name']);
}

class CellData {
  int delivered;
  int returned;
  CellData({required this.delivered, required this.returned});

  Map<String, dynamic> toJson() => {'delivered': delivered, 'returned': returned};
  factory CellData.fromJson(Map<String, dynamic> json) =>
      CellData(delivered: json['delivered'], returned: json['returned']);
}

class TransactionRecord {
  final String id;
  final String customerId;
  final String customerName;
  final String itemId;
  final String itemName;
  final int delivered;
  final int returned;
  final double rate;
  final double total;
  final DateTime date;

  TransactionRecord({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.itemId,
    required this.itemName,
    required this.delivered,
    required this.returned,
    required this.rate,
    required this.total,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
    'id': id, 'customerId': customerId, 'customerName': customerName,
    'itemId': itemId, 'itemName': itemName,
    'delivered': delivered, 'returned': returned,
    'rate': rate, 'total': total,
    'date': date.toIso8601String(),
  };
  factory TransactionRecord.fromJson(Map<String, dynamic> json) =>
      TransactionRecord(
        id: json['id'], customerId: json['customerId'],
        customerName: json['customerName'],
        itemId: json['itemId'], itemName: json['itemName'],
        delivered: json['delivered'], returned: json['returned'],
        rate: (json['rate'] as num).toDouble(),
        total: (json['total'] as num).toDouble(),
        date: DateTime.parse(json['date']),
      );
}

class DataProvider with ChangeNotifier, WidgetsBindingObserver {
  List<Customer> _customers = [];
  List<Item> _items = [];
  Map<String, double> _universalRates = {};
  Map<String, Map<String, double>> _customRates = {};
  Map<String, Map<String, CellData>> _gridData = {};
  Map<String, int> _morningStock = {};
  List<TransactionRecord> _transactions = [];
  List<String> _history = []; // calculator history

  bool _isLoaded = false;
  bool get isLoaded => _isLoaded;

  bool _isSaving = false;
  bool _hasPendingSave = false;

  DataProvider() {
    WidgetsBinding.instance.addObserver(this);
    _loadFromDisk();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  String? _lastActiveDateStr;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _isLoaded) {
      _ensureCurrentDateSync();
    }
  }

  void _ensureCurrentDateSync() {
    if (!_isLoaded) return;
    final todayStr = DateTime.now().toIso8601String().substring(0, 10); // Format: YYYY-MM-DD
    if (_lastActiveDateStr != null && _lastActiveDateStr != todayStr) {
      // It's a new day! Archive yesterday's grid data if it had active data
      if (_gridData.isNotEmpty) {
        SharedPreferences.getInstance().then((prefs) {
          final yesterdayData = jsonEncode(
            _gridData.map((custId, inner) => MapEntry(
              custId,
              inner.map((itemId, cell) => MapEntry(itemId, cell.toJson())),
            )),
          );
          prefs.setString('archivedGrid_$_lastActiveDateStr', yesterdayData);
        });
      }
      if (_morningStock.isNotEmpty) {
        SharedPreferences.getInstance().then((prefs) {
          prefs.setString('archivedMorningStock_$_lastActiveDateStr', jsonEncode(_morningStock));
        });
      }
      _gridData.clear();
      _morningStock.clear();
      _lastActiveDateStr = todayStr;
      
      SharedPreferences.getInstance().then((prefs) {
        prefs.setString('lastActiveDate', todayStr);
      });
      _requestSave();
      
      Future.microtask(() => notifyListeners());
    }
  }

  // ===================== PERSISTENCE =====================

  Future<void> _loadFromDisk() async {
    final prefs = await SharedPreferences.getInstance();

    // Check midnight reset during startup
    _lastActiveDateStr = prefs.getString('lastActiveDate');
    final todayStr = DateTime.now().toIso8601String().substring(0, 10);
    bool shouldResetGrid = false;

    if (_lastActiveDateStr != null && _lastActiveDateStr != todayStr) {
      shouldResetGrid = true;
    }

    // Load customers
    final custJson = prefs.getString('customers');
    if (custJson != null) {
      final List<dynamic> list = jsonDecode(custJson);
      _customers = list.map((e) => Customer.fromJson(e)).toList();
    } else {
      // First launch defaults
      _customers = [
        Customer(id: 'c1', name: 'सिर्जना'),
        Customer(id: 'c2', name: 'यदु मोहन'),
        Customer(id: 'c3', name: 'सुवासको भाइ'),
        Customer(id: 'c4', name: 'मन्दिर'),
        Customer(id: 'c5', name: 'शान्तिनगर'),
        Customer(id: 'c6', name: 'मुनि भैरव'),
        Customer(id: 'c7', name: 'तिनकुनेको बाजे'),
        Customer(id: 'c8', name: 'रिताको दिओर'),
        Customer(id: 'c9', name: 'गोकुल'),
      ];
    }

    // Load items
    final itemJson = prefs.getString('items');
    if (itemJson != null) {
      final List<dynamic> list = jsonDecode(itemJson);
      _items = list.map((e) => Item.fromJson(e)).toList();
    } else {
      _items = [
        Item(id: 'i1', name: 'nilo'),
        Item(id: 'i2', name: 'hariyo'),
        Item(id: 'i3', name: 'Ghae'),
        Item(id: 'i4', name: 'Tea'),
        Item(id: 'i5', name: 'Dhae'),
      ];
    }

    // Load universal rates
    final ratesJson = prefs.getString('universalRates');
    if (ratesJson != null) {
      final Map<String, dynamic> map = jsonDecode(ratesJson);
      _universalRates = map.map((k, v) => MapEntry(k, (v as num).toDouble()));
    } else {
      _universalRates = {
        'i1': 46.75, 'i2': 61.75, 'i3': 54.75, 'i4': 41.75, 'i5': 70.00
      };
    }

    // Load custom rates
    final customRatesJson = prefs.getString('customRates');
    if (customRatesJson != null) {
      final Map<String, dynamic> outer = jsonDecode(customRatesJson);
      _customRates = outer.map((custId, innerDyn) {
        final Map<String, dynamic> inner = innerDyn;
        return MapEntry(custId, inner.map((itemId, v) => MapEntry(itemId, (v as num).toDouble())));
      });
    }

    // Load grid data (or reset if it's a new day)
    final gridJson = prefs.getString('gridData');
    if (shouldResetGrid) {
      if (gridJson != null) {
        // Archive previous grid before clearing
        await prefs.setString('archivedGrid_$_lastActiveDateStr', gridJson);
      }
      _gridData = {};
    } else if (gridJson != null) {
      final Map<String, dynamic> outer = jsonDecode(gridJson);
      _gridData = outer.map((custId, innerDyn) {
        final Map<String, dynamic> inner = innerDyn;
        return MapEntry(custId, inner.map((itemId, v) => MapEntry(itemId, CellData.fromJson(v))));
      });
    } else {
      // First launch sample data
      _gridData = {
        'c1': {'i1': CellData(delivered: 55, returned: 0), 'i2': CellData(delivered: 25, returned: 0)},
        'c2': {'i1': CellData(delivered: 240, returned: 0), 'i2': CellData(delivered: 45, returned: 0), 'i3': CellData(delivered: 51, returned: 0)},
        'c3': {'i1': CellData(delivered: 100, returned: 0), 'i2': CellData(delivered: 27, returned: 0), 'i3': CellData(delivered: 28, returned: 0)},
        'c4': {'i1': CellData(delivered: 20, returned: 0), 'i2': CellData(delivered: 7, returned: 0), 'i3': CellData(delivered: 7, returned: 0)},
        'c5': {'i1': CellData(delivered: 160, returned: 0), 'i2': CellData(delivered: 30, returned: 0), 'i3': CellData(delivered: 20, returned: 0)},
        'c6': {'i1': CellData(delivered: 10, returned: 0), 'i2': CellData(delivered: 5, returned: 0)},
        'c7': {'i1': CellData(delivered: 30, returned: 0), 'i2': CellData(delivered: 5, returned: 0), 'i3': CellData(delivered: 5, returned: 0)},
        'c8': {'i1': CellData(delivered: 120, returned: 0), 'i2': CellData(delivered: 40, returned: 0), 'i3': CellData(delivered: 20, returned: 0)},
        'c9': {'i1': CellData(delivered: 90, returned: 0), 'i2': CellData(delivered: 13, returned: 0), 'i3': CellData(delivered: 20, returned: 0)},
      };
    }

    _lastActiveDateStr = todayStr;
    await prefs.setString('lastActiveDate', todayStr);

    // Load morning stock
    final stockJson = prefs.getString('morningStock');
    if (shouldResetGrid) {
      if (stockJson != null) {
        await prefs.setString('archivedMorningStock_$_lastActiveDateStr', stockJson);
      }
      _morningStock = {};
    } else if (stockJson != null) {
      final Map<String, dynamic> map = jsonDecode(stockJson);
      _morningStock = map.map((k, v) => MapEntry(k, (v as num).toInt()));
    }

    // Load transactions
    final txJson = prefs.getString('transactions');
    if (txJson != null) {
      final List<dynamic> list = jsonDecode(txJson);
      _transactions = list.map((e) => TransactionRecord.fromJson(e)).toList();
    }

    // Load calculator history
    final histJson = prefs.getString('calcHistory');
    if (histJson != null) {
      _history = List<String>.from(jsonDecode(histJson));
    }

    _isLoaded = true;
    notifyListeners();
  }

  void _requestSave() {
    if (_isSaving) {
      _hasPendingSave = true;
      return;
    }
    _isSaving = true;
    _saveToDisk().then((_) {
      _isSaving = false;
      if (_hasPendingSave) {
        _hasPendingSave = false;
        _requestSave();
      }
    }).catchError((_) {
      _isSaving = false;
    });
  }

  Future<void> _saveToDisk() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('customers', jsonEncode(_customers.map((c) => c.toJson()).toList()));
    await prefs.setString('items', jsonEncode(_items.map((i) => i.toJson()).toList()));
    await prefs.setString('universalRates', jsonEncode(_universalRates));
    await prefs.setString('customRates', jsonEncode(
      _customRates.map((k, v) => MapEntry(k, v))
    ));
    await prefs.setString('gridData', jsonEncode(
      _gridData.map((custId, inner) => MapEntry(custId, inner.map((itemId, cell) => MapEntry(itemId, cell.toJson()))))
    ));
    await prefs.setString('morningStock', jsonEncode(_morningStock));
    await prefs.setString('transactions', jsonEncode(_transactions.map((t) => t.toJson()).toList()));
    await prefs.setString('calcHistory', jsonEncode(_history));
  }

  // ===================== GETTERS =====================

  List<Customer> get customers => _customers;
  List<Item> get items => _items;
  List<String> get history => _history;
  List<TransactionRecord> get transactions => _transactions;
  Map<String, int> get morningStock => _morningStock;

  int getMorningStock(String itemId) => _morningStock[itemId] ?? 0;

  void updateMorningStock(String itemId, int qty) {
    _morningStock[itemId] = qty;
    notifyListeners();
    _requestSave();
  }

  void setMorningStock(Map<String, int> stock) {
    _morningStock = Map.from(stock);
    notifyListeners();
    _requestSave();
  }

  int getTotalDelivered(String itemId) {
    _ensureCurrentDateSync();
    int sum = 0;
    for (var c in _customers) {
      final cell = _gridData[c.id]?[itemId];
      if (cell != null) {
        sum += cell.delivered;
      }
    }
    return sum;
  }

  int getTotalReturned(String itemId) {
    _ensureCurrentDateSync();
    int sum = 0;
    for (var c in _customers) {
      final cell = _gridData[c.id]?[itemId];
      if (cell != null) {
        sum += cell.returned;
      }
    }
    return sum;
  }

  int getRemainingStock(String itemId) {
    final loaded = getMorningStock(itemId);
    final delivered = getTotalDelivered(itemId);
    final returned = getTotalReturned(itemId);
    return loaded - delivered + returned;
  }

  // ===================== GRID & RATES =====================

  CellData getCellData(String customerId, String itemId) {
    _ensureCurrentDateSync();
    return _gridData[customerId]?[itemId] ?? CellData(delivered: 0, returned: 0);
  }

  double getRate(String customerId, String itemId) {
    if (_customRates.containsKey(customerId) && _customRates[customerId]!.containsKey(itemId)) {
      return _customRates[customerId]![itemId]!;
    }
    return _universalRates[itemId] ?? 0.0;
  }
  
  double getUniversalRate(String itemId) => _universalRates[itemId] ?? 0.0;

  void updateUniversalRate(String itemId, double newRate) {
    _universalRates[itemId] = newRate;
    notifyListeners();
    _requestSave();
  }

  void updateCustomRate(String customerId, String itemId, double newRate) {
    if (!_customRates.containsKey(customerId)) {
      _customRates[customerId] = {};
    }
    _customRates[customerId]![itemId] = newRate;
    notifyListeners();
    _requestSave();
  }

  double getRowTotal(String customerId) {
    _ensureCurrentDateSync();
    double total = 0;
    if (_gridData.containsKey(customerId)) {
      _gridData[customerId]!.forEach((itemId, cell) {
        double rate = getRate(customerId, itemId);
        total += (cell.delivered - cell.returned) * rate;
      });
    }
    return double.parse(total.toStringAsFixed(2));
  }

  double get grandTotal {
    double sum = 0;
    for (var c in _customers) {
      sum += getRowTotal(c.id);
    }
    return double.parse(sum.toStringAsFixed(2));
  }

  void updateCell(String customerId, String itemId, int load, int returnQty) {
    _ensureCurrentDateSync();
    if (!_gridData.containsKey(customerId)) {
      _gridData[customerId] = {};
    }
    _gridData[customerId]![itemId] = CellData(delivered: load, returned: returnQty);
    
    final cust = _customers.firstWhere((c) => c.id == customerId, orElse: () => Customer(id: customerId, name: 'Unknown'));
    final item = _items.firstWhere((i) => i.id == itemId, orElse: () => Item(id: itemId, name: 'Unknown'));
    final rate = getRate(customerId, itemId);
    final calculatedTotal = double.parse(((load - returnQty) * rate).toStringAsFixed(2));
    
    _transactions.insert(0, TransactionRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      customerId: customerId, customerName: cust.name,
      itemId: itemId, itemName: item.name,
      delivered: load, returned: returnQty,
      rate: rate, total: calculatedTotal,
      date: DateTime.now(),
    ));

    notifyListeners();
    _requestSave();
  }

  void updateCustomerGrid({
    required String customerId,
    required Map<String, int> loads,
    required Map<String, int> returns,
  }) {
    _ensureCurrentDateSync();
    if (!_gridData.containsKey(customerId)) {
      _gridData[customerId] = {};
    }

    final cust = _customers.firstWhere(
      (c) => c.id == customerId,
      orElse: () => Customer(id: customerId, name: 'Unknown'),
    );
    final now = DateTime.now();

    for (var item in _items) {
      final oldCell = _gridData[customerId]?[item.id];
      final oldLoad = oldCell?.delivered ?? 0;
      final oldRet = oldCell?.returned ?? 0;

      final newLoad = loads[item.id] ?? oldLoad;
      final newRet = returns[item.id] ?? oldRet;

      _gridData[customerId]![item.id] = CellData(delivered: newLoad, returned: newRet);

      if (newLoad != oldLoad || newRet != oldRet) {
        final rate = getRate(customerId, item.id);
        final calculatedTotal = double.parse(((newLoad - newRet) * rate).toStringAsFixed(2));
        _transactions.insert(0, TransactionRecord(
          id: '${now.millisecondsSinceEpoch}_${item.id}',
          customerId: customerId,
          customerName: cust.name,
          itemId: item.id,
          itemName: item.name,
          delivered: newLoad,
          returned: newRet,
          rate: rate,
          total: calculatedTotal,
          date: now,
        ));
      }
    }

    notifyListeners();
    _requestSave();
  }

  // ===================== CRUD =====================

  void addCustomer(String name) {
    _customers.add(Customer(id: 'c_${DateTime.now().millisecondsSinceEpoch}', name: name.trim()));
    notifyListeners();
    _requestSave();
  }

  void editCustomer(String id, String newName) {
    final idx = _customers.indexWhere((c) => c.id == id);
    if (idx != -1) { 
      _customers[idx].name = newName.trim(); 
      notifyListeners();
      _requestSave();
    }
  }

  void deleteCustomer(String id) {
    _customers.removeWhere((c) => c.id == id);
    _gridData.remove(id);
    _customRates.remove(id);
    _transactions.removeWhere((t) => t.customerId == id);
    notifyListeners();
    _requestSave();
  }

  void reorderCustomers(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) newIndex -= 1;
    final item = _customers.removeAt(oldIndex);
    _customers.insert(newIndex, item);
    notifyListeners();
    _requestSave();
  }

  void addItem(String name) {
    final trimmedName = name.trim();
    final newId = 'i_${DateTime.now().millisecondsSinceEpoch}';
    _items.add(Item(id: newId, name: trimmedName));
    _universalRates[newId] = 0.0;
    notifyListeners();
    _requestSave();
  }

  void editItem(String id, String newName) {
    final idx = _items.indexWhere((i) => i.id == id);
    if (idx != -1) { 
      _items[idx].name = newName.trim(); 
      notifyListeners();
      _requestSave();
    }
  }

  void deleteItem(String id) {
    _items.removeWhere((i) => i.id == id);
    _universalRates.remove(id);
    _morningStock.remove(id);
    _gridData.forEach((_, cellMap) => cellMap.remove(id));
    _customRates.forEach((_, rateMap) => rateMap.remove(id));
    _transactions.removeWhere((t) => t.itemId == id);
    notifyListeners();
    _requestSave();
  }

  void deleteTransaction(String txId) {
    _transactions.removeWhere((t) => t.id == txId);
    notifyListeners();
    _requestSave();
  }

  void addHistory(String record) {
    _history.insert(0, record);
    notifyListeners();
    _requestSave();
  }
}

class LocaleProvider with ChangeNotifier {
  bool _isNepali = true;
  bool get isNepali => _isNepali;

  LocaleProvider() {
    _loadFromDisk();
  }

  Future<void> _loadFromDisk() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('isNepali')) {
      _isNepali = prefs.getBool('isNepali') ?? true;
      notifyListeners();
    }
  }

  void toggleLanguage() async {
    _isNepali = !_isNepali;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isNepali', _isNepali);
  }

  String get home => _isNepali ? 'होम' : 'Home';
  String get history => _isNepali ? 'इतिहास' : 'History';
  String get tools => _isNepali ? 'उपकरण' : 'Tools';
  String get settings => _isNepali ? 'सेटिङहरू' : 'Settings';
  
  String get todayTotal => _isNepali ? 'आजको कुल जम्मा' : 'Today\'s Total';
  String get name => _isNepali ? 'नाम' : 'Name';
  String get grandTotal => _isNepali ? 'कुल जम्मा' : 'Grand Total';
  String get total => _isNepali ? 'जम्मा' : 'Total';
  
  String get language => _isNepali ? 'भाषा' : 'Language';
  String get currentLanguage => _isNepali ? 'नेपाली' : 'English';
  String get returnDisplayMode => _isNepali ? 'फिर्ता प्रदर्शन मोड' : 'Return display mode';
  String get extraRow => _isNepali ? 'अतिरिक्त पङ्क्ति' : 'Extra row';
  String get returnFormatStyle => _isNepali ? 'फिर्ता ढाँचा शैली' : 'Return format style';
  
  String get manageCustomers => _isNepali ? 'व्यक्तिहरू व्यवस्थापन गर्नुहोस्' : 'Manage Persons';
  String get manageItems => _isNepali ? 'वस्तुहरू व्यवस्थापन गर्नुहोस्' : 'Manage Items';
  String get manageRates => _isNepali ? 'दरहरू व्यवस्थापन गर्नुहोस्' : 'Manage Rates';
  
  String get noHistory => _isNepali ? 'कुनै इतिहास छैन' : 'No history found';
  String get noCustomers => _isNepali ? 'कुनै ग्राहक छैन' : 'No customers found';
  String get noItems => _isNepali ? 'कुनै वस्तु छैन' : 'No items found';

  String get load => _isNepali ? 'दिएको (Load)' : 'Load';
  String get returnItem => _isNepali ? 'फिर्ता (Return)' : 'Return';
  String get save => _isNepali ? 'बचत गर्नुहोस्' : 'Save';
  String get cancel => _isNepali ? 'रद्द गर्नुहोस्' : 'Cancel';
  String get updateFor => _isNepali ? 'अपडेट गर्नुहोस्' : 'Update for';

  String get addPerson => _isNepali ? 'व्यक्ति थप्नुहोस्' : 'Add Person';
  String get editPerson => _isNepali ? 'व्यक्ति सम्पादन गर्नुहोस्' : 'Edit Person';
  String get addItem => _isNepali ? 'सामान थप्नुहोस्' : 'Add Item';
  String get editItem => _isNepali ? 'सामान सम्पादन गर्नुहोस्' : 'Edit Item';
  String get universalRates => _isNepali ? 'सबैका लागि दर' : 'Universal Rates';
  String get customRates => _isNepali ? 'विशेष दर' : 'Custom Rates';

  String get delete => _isNepali ? 'हटाउनुहोस्' : 'Delete';
  String get deleteConfirmTitle => _isNepali ? 'हटाउने पुष्टि' : 'Confirm Delete';
  String get deleteConfirmMessage => _isNepali ? 'के तपाईं पक्का हटाउन चाहनुहुन्छ?' : 'Are you sure you want to delete this?';

  String get morningStock => _isNepali ? 'गाडी लोड' : 'Vehicle Stock';
  String get setMorningStock => _isNepali ? 'गाडी लोड प्रविष्टि' : 'Set Vehicle Stock';
  String get editVehicleStock => _isNepali ? 'गाडी लोड मिलाउनुहोस्' : 'Edit Vehicle Stock';
  String get loaded => _isNepali ? 'लोड' : 'Loaded';
  String get remaining => _isNepali ? 'बाँकी' : 'Remaining';
  String get dropped => _isNepali ? 'कुल दिएको' : 'Total Dropped';
  String get share => _isNepali ? 'सेयर' : 'Share';
  String get shareBill => _isNepali ? 'बिल सेयर गर्नुहोस्' : 'Share Bill';
  String get noRecordsToShare => _isNepali ? 'सेयर गर्न कुनै रेकर्ड छैन' : 'No records to share';
  String get delivered => _isNepali ? 'दिएको' : 'Delivered';
  String get totalAmount => _isNepali ? 'कुल रकम' : 'Total Amount';
}
