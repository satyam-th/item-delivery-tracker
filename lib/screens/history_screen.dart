import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../constants/app_colors.dart';
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
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

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
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryGreen,
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

  void _confirmDeleteTx(BuildContext context, String txId) {
    final locale = Provider.of<LocaleProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(locale.deleteConfirmTitle),
        content: Text(locale.deleteConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(locale.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.returnRed,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Provider.of<DataProvider>(context, listen: false).deleteTransaction(txId);
              Navigator.pop(ctx);
            },
            child: Text(locale.delete),
          ),
        ],
      ),
    );
  }

  void _shareFilteredBill(BuildContext context, List<TransactionRecord> records, double totalAmount) {
    if (records.isEmpty) return;

    final dateStr = _selectedDate != null ? _formatDate(_selectedDate!) : 'All Dates';
    final customerTitle = _selectedCustomer != 'All'
        ? records.first.customerName
        : (_searchQuery.isNotEmpty ? _searchQuery : 'All Persons');

    final buffer = StringBuffer();
    buffer.writeln('📦 Shop Delivery Record (डेलिभरी हिसाब)');
    buffer.writeln('📅 Date: $dateStr');
    if (_selectedCustomer != 'All' || _searchQuery.isNotEmpty) {
      buffer.writeln('👤 Filter: $customerTitle');
    }
    buffer.writeln('----------------------------------------');

    for (var i = 0; i < records.length; i++) {
      final tx = records[i];
      final net = tx.delivered - tx.returned;
      if (_selectedCustomer == 'All') {
        buffer.writeln('${i + 1}. ${tx.customerName} - ${tx.itemName}');
      } else {
        buffer.writeln('${i + 1}. ${tx.itemName}');
      }
      buffer.writeln('   Del: ${tx.delivered} | Ret: ${tx.returned} | Net: $net @ Rs. ${tx.rate.toStringAsFixed(2)}');
      buffer.writeln('   Subtotal: Rs. ${tx.total.toStringAsFixed(2)}');
    }

    buffer.writeln('----------------------------------------');
    buffer.writeln('💰 Grand Total: Rs. ${totalAmount.toStringAsFixed(2)}');
    buffer.writeln('🙏 Thank you!');

    Share.share(
      buffer.toString(),
      subject: 'Delivery Bill - $customerTitle ($dateStr)',
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = Provider.of<LocaleProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F0),
      appBar: AppBar(
        title: Text(locale.history),
        centerTitle: true,
        backgroundColor: AppColors.darkNavy,
        foregroundColor: Colors.white,
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
            bool matchesSearch = _searchQuery.isEmpty ||
                tx.customerName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                tx.itemName.toLowerCase().contains(_searchQuery.toLowerCase());
            return matchesCust && matchesItem && matchesDate && matchesSearch;
          }).toList();

          final filteredTotal = txs.fold(0.0, (sum, tx) => sum + tx.total);
          final filteredCount = txs.length;

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
                          color: AppColors.greyCard,
                          border: Border.all(color: Colors.black12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 18, color: AppColors.primaryGreen),
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
                              color: AppColors.greyCard,
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
                              color: AppColors.greyCard,
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
                    const SizedBox(height: 8),
                    // Search Bar
                    TextField(
                      controller: _searchCtrl,
                      decoration: InputDecoration(
                        hintText: 'Search customer or item (खोज्नुहोस्)...',
                        hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                        prefixIcon: const Icon(Icons.search, size: 20, color: Colors.grey),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18, color: Colors.grey),
                                onPressed: () {
                                  _searchCtrl.clear();
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: AppColors.greyCard,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.black12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.black12),
                        ),
                      ),
                      onChanged: (val) => setState(() => _searchQuery = val.trim()),
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
                                            Text('Return: ${tx.returned}', style: const TextStyle(color: AppColors.returnRed, fontWeight: FontWeight.w500, fontSize: 13)),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text('Net: ${tx.delivered - tx.returned}', style: const TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold, fontSize: 13)),
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
                                          color: AppColors.lightGreenBadge,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          'Rs. ${tx.total.toStringAsFixed(2)}',
                                          style: const TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold, fontSize: 12),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                        onPressed: () => _confirmDeleteTx(context, tx.id),
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
              // Bottom Action Bar for Share
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      offset: const Offset(0, -2),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: Row(
                    children: [
                      // Filtered summary details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '$filteredCount ${filteredCount == 1 ? "record" : "records"}',
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                            Text(
                              'Rs. ${filteredTotal.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Share Button
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 1,
                        ),
                        onPressed: txs.isEmpty ? null : () => _shareFilteredBill(context, txs, filteredTotal),
                        icon: const Icon(Icons.share, size: 18),
                        label: Text(
                          locale.shareBill,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
