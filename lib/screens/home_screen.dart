import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers.dart';
import 'manage_customers_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _formatCurrentDate() {
    final now = DateTime.now();
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${weekdays[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';
  }

  @override
  Widget build(BuildContext context) {
    final locale = Provider.of<LocaleProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0F2027),
      appBar: AppBar(
        title: const Text(
          'Item',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text(
                _formatCurrentDate(),
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          _buildSummaryHeader(locale),
          Expanded(
            child: Container(
              color: Colors.white,
              child: _buildDataTable(locale),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryHeader(LocaleProvider locale) {
    return Consumer<DataProvider>(
      builder: (context, data, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                locale.todayTotal,
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF138D5B),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Rs. ${data.grandTotal.toStringAsFixed(2)}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildDataTable(LocaleProvider locale) {
    return Consumer<DataProvider>(
      builder: (context, data, child) {
        final customers = data.customers;
        final items = data.items;
        
        return SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Fixed Left Column (Customer Names)
              SizedBox(
                width: 130,
                child: Column(
                  children: [
                    // Name header - must match 130px width
                    Container(
                      width: 130,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: Color(0xFF1B3B36),
                        border: Border(
                          right: BorderSide(color: Colors.white24, width: 0.5),
                          bottom: BorderSide(color: Colors.white24, width: 0.5),
                        ),
                      ),
                      child: Text(
                        locale.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ...customers.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final cust = entry.value;
                      return _buildCustomerCell(context, cust, idx);
                    }).toList(),
                    // Bottom Total Row Label
                    _buildCustomerCell(context, Customer(id: 'total', name: locale.grandTotal), customers.length, isTotalRow: true),
                  ],
                ),
              ),
              // Scrollable Right Columns
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row
                      Row(
                        children: [
                          ...items.map((item) => _buildHeaderCell(item.name)).toList(),
                          _buildHeaderCell(locale.total),
                        ],
                      ),
                      // Data Rows
                      ...customers.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final cust = entry.value;
                        return Row(
                          children: [
                            ...items.map((item) {
                              final cellData = data.getCellData(cust.id, item.id);
                              return _buildDataCell(context, cust, item, cellData, idx);
                            }).toList(),
                            _buildTotalCell(data.getRowTotal(cust.id), idx),
                          ],
                        );
                      }).toList(),
                      // Bottom Total Row Values
                      Row(
                        children: [
                          ...items.map((item) {
                             int totalDelivered = 0;
                             int totalReturned = 0;
                             for (var c in customers) {
                               var cell = data.getCellData(c.id, item.id);
                               totalDelivered += cell.delivered;
                               totalReturned += cell.returned;
                             }
                             final dummyCust = Customer(id: 'total', name: '');
                             return _buildDataCell(
                               context, dummyCust, item,
                               CellData(delivered: totalDelivered, returned: totalReturned), 
                               customers.length, 
                               isTotalRow: true
                             );
                          }).toList(),
                          // Grand Total Sum
                          _buildTotalCell(
                            data.grandTotal, 
                            customers.length, 
                            isTotalRow: true
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeaderCell(String title) {
    return Container(
      width: title == 'Total' || title == 'जम्मा' ? 80 : 75,
      height: 40,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: Color(0xFF1B3B36),
        border: Border(
          right: BorderSide(color: Colors.white24, width: 0.5),
          bottom: BorderSide(color: Colors.white24, width: 0.5),
        ),
      ),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildCustomerCell(BuildContext context, Customer cust, int index, {bool isTotalRow = false}) {
    Color bgColor = index % 2 == 0 ? Colors.white : const Color(0xFFE3F2FD);
    if (isTotalRow) bgColor = const Color(0xFFB3E5FC);

    final displayName = cust.name;

    return InkWell(
      onTap: isTotalRow ? null : () => _showCustomerUpdateSheet(context, cust),
      onLongPress: isTotalRow ? null : () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ManageCustomersScreen()),
        );
      },
      child: Container(
        width: 130,
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          color: bgColor,
          border: const Border(
            right: BorderSide(color: Colors.black12, width: 1),
            bottom: BorderSide(color: Colors.black12, width: 1),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                displayName,
                style: TextStyle(
                  color: Colors.black87, 
                  fontSize: 13,
                  fontWeight: isTotalRow ? FontWeight.bold : FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (!isTotalRow)
              const Icon(Icons.edit_note, size: 16, color: Colors.black38),
          ],
        ),
      ),
    );
  }

  void _showCustomerUpdateSheet(BuildContext context, Customer cust) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CustomerLoadReturnSheet(customer: cust),
    );
  }

  void _showCellEditDialog(BuildContext context, Customer cust, Item item, CellData currentData) {
    final loadCtrl = TextEditingController(text: currentData.delivered == 0 ? '' : currentData.delivered.toString());
    final returnCtrl = TextEditingController(text: currentData.returned == 0 ? '' : currentData.returned.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${cust.name} - ${item.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: loadCtrl,
              autofocus: true,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Load (Dropped / दिएको)',
                hintText: '0',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: returnCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Return (फिर्ता)',
                hintText: '0',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text('Cancel')
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF138D5B),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              final dp = Provider.of<DataProvider>(context, listen: false);
              final load = int.tryParse(loadCtrl.text) ?? 0;
              final ret = int.tryParse(returnCtrl.text) ?? 0;
              dp.updateCell(cust.id, item.id, load, ret);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildDataCell(BuildContext context, Customer cust, Item item, CellData data, int index, {bool isTotalRow = false}) {
    Color bgColor = index % 2 == 0 ? Colors.white : const Color(0xFFE3F2FD);
    if (isTotalRow) bgColor = const Color(0xFFB3E5FC);

    return InkWell(
      onTap: isTotalRow ? null : () => _showCellEditDialog(context, cust, item, data),
      child: Container(
        width: 75,
        height: 60,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bgColor,
          border: const Border(
            right: BorderSide(color: Colors.black12, width: 1),
            bottom: BorderSide(color: Colors.black12, width: 1),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${data.delivered}',
              style: TextStyle(
                color: Colors.black87, 
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '-${data.returned}',
              style: TextStyle(
                color: Colors.red, 
                fontSize: 12,
                fontWeight: isTotalRow ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalCell(double total, int index, {bool isTotalRow = false}) {
    Color bgColor = index % 2 == 0 ? Colors.white : const Color(0xFFE3F2FD);
    if (isTotalRow) bgColor = const Color(0xFFB3E5FC);

    return Container(
      width: 80,
      height: 60,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bgColor,
        border: const Border(
          right: BorderSide(color: Colors.black12, width: 1),
          bottom: BorderSide(color: Colors.black12, width: 1),
        ),
      ),
      child: Text(
        total.toStringAsFixed(0),
        style: TextStyle(
          color: Colors.black87, 
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class CustomerLoadReturnSheet extends StatefulWidget {
  final Customer customer;

  const CustomerLoadReturnSheet({super.key, required this.customer});

  @override
  State<CustomerLoadReturnSheet> createState() => _CustomerLoadReturnSheetState();
}

class _CustomerLoadReturnSheetState extends State<CustomerLoadReturnSheet> {
  int _activeTab = 0; // 0 = Load, 1 = Return
  final Map<String, TextEditingController> _loadControllers = {};
  final Map<String, TextEditingController> _returnControllers = {};

  @override
  void initState() {
    super.initState();
    final dp = Provider.of<DataProvider>(context, listen: false);
    for (var item in dp.items) {
      final cell = dp.getCellData(widget.customer.id, item.id);
      _loadControllers[item.id] = TextEditingController(
        text: cell.delivered == 0 ? '' : cell.delivered.toString(),
      );
      _returnControllers[item.id] = TextEditingController(
        text: cell.returned == 0 ? '' : cell.returned.toString(),
      );
    }
  }

  @override
  void dispose() {
    for (var ctrl in _loadControllers.values) {
      ctrl.dispose();
    }
    for (var ctrl in _returnControllers.values) {
      ctrl.dispose();
    }
    super.dispose();
  }

  void _stepQuantity(String itemId, bool isLoad, int delta) {
    final ctrl = isLoad ? _loadControllers[itemId] : _returnControllers[itemId];
    if (ctrl == null) return;
    int current = int.tryParse(ctrl.text) ?? 0;
    int updated = current + delta;
    if (updated < 0) updated = 0;
    final newText = updated == 0 ? '' : updated.toString();
    ctrl.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
    setState(() {});
  }

  void _save(BuildContext context) {
    final dp = Provider.of<DataProvider>(context, listen: false);
    final locale = Provider.of<LocaleProvider>(context, listen: false);

    final loads = <String, int>{};
    final returns = <String, int>{};

    for (var item in dp.items) {
      loads[item.id] = int.tryParse(_loadControllers[item.id]?.text ?? '') ?? 0;
      returns[item.id] = int.tryParse(_returnControllers[item.id]?.text ?? '') ?? 0;
    }

    dp.updateCustomerGrid(
      customerId: widget.customer.id,
      loads: loads,
      returns: returns,
    );

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          locale.isNepali
              ? '${widget.customer.name} को रेकर्ड सुरक्षित भयो'
              : 'Records saved for ${widget.customer.name}',
        ),
        backgroundColor: const Color(0xFF138D5B),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dp = Provider.of<DataProvider>(context);
    final locale = Provider.of<LocaleProvider>(context);
    final items = dp.items;

    int totalLoadCount = 0;
    int totalReturnCount = 0;
    for (var item in items) {
      totalLoadCount += int.tryParse(_loadControllers[item.id]?.text ?? '') ?? 0;
      totalReturnCount += int.tryParse(_returnControllers[item.id]?.text ?? '') ?? 0;
    }

    final isLoad = _activeTab == 0;
    final themeColor = isLoad ? const Color(0xFF138D5B) : const Color(0xFFD32F2F);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top pull bar
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 6),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Customer Name Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: const Color(0xFF138D5B).withOpacity(0.15),
                    child: const Icon(Icons.person, color: Color(0xFF138D5B), size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.customer.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          locale.isNepali
                              ? 'सामान लोड वा फिर्ता अपडेट गर्नुहोस्'
                              : 'Update Load & Return quantities',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.black54),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Tab Switcher: Load (दिएको) vs Return (फिर्ता)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    // Load Tab
                    Expanded(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () => setState(() => _activeTab = 0),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _activeTab == 0
                                ? const Color(0xFF138D5B)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: _activeTab == 0
                                ? [
                                    BoxShadow(
                                      color: const Color(0xFF138D5B).withOpacity(0.3),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    )
                                  ]
                                : null,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.local_shipping_outlined,
                                size: 18,
                                color: _activeTab == 0 ? Colors.white : Colors.black87,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                locale.load,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: _activeTab == 0 ? Colors.white : Colors.black87,
                                ),
                              ),
                              if (totalLoadCount > 0) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: _activeTab == 0 ? Colors.white24 : Colors.grey.shade300,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '$totalLoadCount',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: _activeTab == 0 ? Colors.white : Colors.black87,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    // Return Tab
                    Expanded(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () => setState(() => _activeTab = 1),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _activeTab == 1
                                ? const Color(0xFFD32F2F)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: _activeTab == 1
                                ? [
                                    BoxShadow(
                                      color: const Color(0xFFD32F2F).withOpacity(0.3),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    )
                                  ]
                                : null,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.assignment_return_outlined,
                                size: 18,
                                color: _activeTab == 1 ? Colors.white : Colors.black87,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                locale.returnItem,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: _activeTab == 1 ? Colors.white : Colors.black87,
                                ),
                              ),
                              if (totalReturnCount > 0) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: _activeTab == 1 ? Colors.white24 : Colors.grey.shade300,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '$totalReturnCount',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: _activeTab == 1 ? Colors.white : Colors.black87,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Item List
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                itemCount: items.length,
                separatorBuilder: (context, i) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final item = items[index];
                  final ctrl = isLoad ? _loadControllers[item.id]! : _returnControllers[item.id]!;
                  final otherVal = isLoad
                      ? (_returnControllers[item.id]?.text.isEmpty ?? true ? '0' : _returnControllers[item.id]!.text)
                      : (_loadControllers[item.id]?.text.isEmpty ?? true ? '0' : _loadControllers[item.id]!.text);
                  final rate = dp.getRate(widget.customer.id, item.id);

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        // Item name & details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Text(
                                    'Rs. ${rate.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      isLoad ? 'फिर्ता: $otherVal' : 'दिएको: $otherVal',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Stepper / Input Field
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.remove_circle_outline,
                                color: themeColor,
                              ),
                              iconSize: 28,
                              onPressed: () => _stepQuantity(item.id, isLoad, -1),
                            ),
                            SizedBox(
                              width: 65,
                              height: 42,
                              child: TextField(
                                controller: ctrl,
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                                  hintText: '0',
                                  filled: true,
                                  fillColor: themeColor.withOpacity(0.06),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: themeColor,
                                      width: 1,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: Colors.grey.shade300,
                                      width: 1,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: themeColor,
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                                onChanged: (_) => setState(() {}),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.add_circle,
                                color: themeColor,
                              ),
                              iconSize: 28,
                              onPressed: () => _stepQuantity(item.id, isLoad, 1),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const Divider(height: 1),

            // Save Button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () => _save(context),
                  icon: const Icon(Icons.check, color: Colors.white),
                  label: Text(
                    locale.save,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF138D5B),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
