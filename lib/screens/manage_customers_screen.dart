import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../providers.dart';

class ManageCustomersScreen extends StatelessWidget {
  const ManageCustomersScreen({super.key});

  Color _getAvatarColor(int index) {
    List<Color> colors = [
      Colors.deepOrange, Colors.blue, Colors.purple, 
      Colors.orange, Colors.purple, Colors.orange, 
      Colors.blueGrey, Colors.purpleAccent, Colors.orangeAccent
    ];
    return colors[index % colors.length];
  }

  void _showCustomerDialog(BuildContext context, {Customer? customer}) {
    final nameCtrl = TextEditingController(text: customer?.name ?? '');
    final locale = Provider.of<LocaleProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(customer == null ? locale.addPerson : locale.editPerson),
        content: TextField(
          controller: nameCtrl,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Name (नाम)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: Text(locale.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              final text = nameCtrl.text.trim();
              if (text.isNotEmpty) {
                final dp = Provider.of<DataProvider>(context, listen: false);
                if (customer == null) {
                  dp.addCustomer(text);
                } else {
                  dp.editCustomer(customer.id, text);
                }
                Navigator.pop(context);
              }
            },
            child: Text(locale.save),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteCustomer(BuildContext context, Customer customer) {
    final locale = Provider.of<LocaleProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(locale.deleteConfirmTitle),
        content: Text(
          locale.isNepali
              ? '${customer.name} लाई हटाउन निश्चित हुनुहुन्छ? उहाँको सबै रेकर्ड मेटिनेछ।'
              : 'Are you sure you want to delete ${customer.name}? All their records will be removed.',
        ),
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
              Provider.of<DataProvider>(context, listen: false).deleteCustomer(customer.id);
              Navigator.pop(ctx);
            },
            child: Text(locale.delete),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = Provider.of<LocaleProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(locale.manageCustomers),
        backgroundColor: AppColors.darkNavy,
        foregroundColor: Colors.white,
      ),
      body: Consumer<DataProvider>(
        builder: (context, data, child) {
          final customers = data.customers;

          if (customers.isEmpty) {
            return Center(
              child: Text(
                locale.noCustomers,
                style: const TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }

          return ReorderableListView.builder(
            buildDefaultDragHandles: false,
            padding: const EdgeInsets.only(top: 8, bottom: 80),
            itemCount: customers.length,
            onReorder: data.reorderCustomers,
            itemBuilder: (context, index) {
              final c = customers[index];
              return Card(
                key: ValueKey(c.id),
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0.5,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getAvatarColor(index),
                    radius: 16,
                    child: Text('${index + 1}', style: const TextStyle(color: Colors.white, fontSize: 12)),
                  ),
                  title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: AppColors.primaryGreen, size: 20),
                        onPressed: () => _showCustomerDialog(context, customer: c),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                        onPressed: () => _confirmDeleteCustomer(context, c),
                      ),
                      ReorderableDragStartListener(
                        index: index,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Icon(Icons.drag_handle, color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCustomerDialog(context),
        backgroundColor: AppColors.primaryGreen,
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: Text(locale.addPerson, style: const TextStyle(color: Colors.white)),
      ),
    );
  }
}
