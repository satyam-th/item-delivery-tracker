import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _selectedCustomer = 'All';
  String _selectedItem = 'All';
  DateTime? _selectedDate = DateTime.now();

  Color _getAvatarColor(int index) {
    List<Color> colors = [
      Colors.deepOrange, Colors.blueGrey, Colors.purple, 
      Colors.orange, Colors.purple, Colors.orange, 
      Colors.blueGrey, Colors.purpleAccent, Colors.orangeAccent
    ];
    return colors[index % colors.length];
  }

  String _formatDate(DateTime date) {
    const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  void _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF138D5B),
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = Provider.of<LocaleProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F0),
      appBar: AppBar(
        title: Text(locale.history),
        centerTitle: true,
        backgroundColor: const Color(0xFF0F2027),
      ),
      body: Consumer<DataProvider>(
        builder: (context, data, child) {
          // Apply Filters
          var txs = data.transactions.where((tx) {
            bool matchesCust = _selectedCustomer == 'All' || tx.customerId == _selectedCustomer;
            bool matchesItem = _selectedItem == 'All' || tx.itemId == _selectedItem;
            bool matchesDate = _selectedDate == null || 
                (tx.date.year == _selectedDate!.year && 
                 tx.date.month == _selectedDate!.month && 
                 tx.date.day == _selectedDate!.day);
            return matchesCust && matchesItem && matchesDate;
          }).toList();

          return Column(
            children: [
              // Filters Area
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    // Date Picker Interactive
                    InkWell(
                      onTap: () => _pickDate(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9F9F9),
                          border: Border.all(color: Colors.black12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 18, color: Color(0xFF138D5B)),
                                const SizedBox(width: 8),
                                Text(
                                  _selectedDate == null ? 'All Dates (सबै मिति)' : _formatDate(_selectedDate!),
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                            if (_selectedDate != null)
                              GestureDetector(
                                onTap: () => setState(() => _selectedDate = null),
                                child: const Icon(Icons.clear, size: 18, color: Colors.grey),
                              )
                            else
                              const Icon(Icons.arrow_drop_down, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Dropdowns Row
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9F9F9),
                              border: Border.all(color: Colors.black12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                isExpanded: true,
                                value: _selectedCustomer,
                                items: [
                                  const DropdownMenuItem(value: 'All', child: Text('All Persons')),
                                  ...data.customers.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name, overflow: TextOverflow.ellipsis))),
                                ],
                                onChanged: (val) {
                                  if (val != null) setState(() => _selectedCustomer = val);
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9F9F9),
                              border: Border.all(color: Colors.black12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                isExpanded: true,
                                value: _selectedItem,
                                items: [
                                  const DropdownMenuItem(value: 'All', child: Text('All Items')),
                                  ...data.items.map((i) => DropdownMenuItem(value: i.id, child: Text(i.name, overflow: TextOverflow.ellipsis))),
                                ],
                                onChanged: (val) {
                                  if (val != null) setState(() => _selectedItem = val);
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // List of Transactions
              Expanded(
                child: txs.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.receipt_long_outlined, size: 60, color: Colors.grey),
                            const SizedBox(height: 12),
                            Text(locale.noHistory, style: const TextStyle(fontSize: 16, color: Colors.grey)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: txs.length,
                        itemBuilder: (context, index) {
                          final tx = txs[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            elevation: 0.5,
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Avatar
                                  CircleAvatar(
                                    backgroundColor: _getAvatarColor(index),
                                    radius: 20,
                                    child: Text(
                                      tx.customerName.isNotEmpty ? tx.customerName[0] : '?', 
                                      style: const TextStyle(color: Colors.white, fontSize: 16)
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // Details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${tx.customerName} · ${tx.itemName}',
                                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Text('Load: ${tx.delivered}', style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.w500, fontSize: 13)),
                                            const SizedBox(width: 12),
                                            Text('Return: ${tx.returned}', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w500, fontSize: 13)),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text('Net: ${tx.delivered - tx.returned}', style: const TextStyle(color: Color(0xFF138D5B), fontWeight: FontWeight.bold, fontSize: 13)),
                                            Text('${tx.date.hour}:${tx.date.minute.toString().padLeft(2, '0')}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Actions & Total
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE5F4EC),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          'Rs. ${tx.total.toStringAsFixed(2)}',
                                          style: const TextStyle(color: Color(0xFF138D5B), fontWeight: FontWeight.bold, fontSize: 12),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                        onPressed: () => data.deleteTransaction(tx.id),
                                      )
                                    ],
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
