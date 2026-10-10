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
          'milk',
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
      onTap: isTotalRow ? null : () {
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
