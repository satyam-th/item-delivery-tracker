import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers.dart';

class ManageItemsScreen extends StatelessWidget {
  const ManageItemsScreen({super.key});

  void _showItemDialog(BuildContext context, {Item? item}) {
    final nameCtrl = TextEditingController(text: item?.name ?? '');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(item == null ? 'Add Item' : 'Edit Item'),
        content: TextField(
          controller: nameCtrl,
          decoration: const InputDecoration(labelText: 'Item Name'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.isNotEmpty) {
                final dp = Provider.of<DataProvider>(context, listen: false);
                if (item == null) {
                  dp.addItem(nameCtrl.text);
                } else {
                  dp.editItem(item.id, nameCtrl.text);
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
        title: Text(locale.manageItems),
        backgroundColor: const Color(0xFF0F2027),
        foregroundColor: const Color(0xFFF1A8A6),
        elevation: 0,
      ),
      body: Consumer<DataProvider>(
        builder: (context, data, child) {
          final items = data.items;

          return ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 80),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0.5,
                child: ListTile(
                  leading: const Icon(Icons.inventory_2_outlined, color: Color(0xFF138D5B)),
                  title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Color(0xFF138D5B)),
                        onPressed: () => _showItemDialog(context, item: item),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () => data.deleteItem(item.id),
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
        onPressed: () => _showItemDialog(context),
        backgroundColor: const Color(0xFF138D5B),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Item', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
