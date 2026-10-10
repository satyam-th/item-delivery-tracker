import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(customer == null ? 'Add Person' : 'Edit Person'),
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
            child: const Text('Cancel')
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF138D5B),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              if (nameCtrl.text.trim().isNotEmpty) {
                final dp = Provider.of<DataProvider>(context, listen: false);
                if (customer == null) {
                  dp.addCustomer(nameCtrl.text.trim());
                } else {
                  dp.editCustomer(customer.id, nameCtrl.text.trim());
                }
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
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
        backgroundColor: const Color(0xFF0F2027),
        foregroundColor: const Color(0xFFF1A8A6),
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
                        icon: const Icon(Icons.edit, color: Color(0xFF138D5B), size: 20),
                        onPressed: () => _showCustomerDialog(context, customer: c),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                        onPressed: () => data.deleteCustomer(c.id),
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
        backgroundColor: const Color(0xFF138D5B),
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: const Text('Add Person', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
