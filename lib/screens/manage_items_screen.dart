import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../providers.dart';

class ManageItemsScreen extends StatelessWidget {
  const ManageItemsScreen({super.key});

  void _showItemDialog(BuildContext context, {Item? item}) {
    final nameCtrl = TextEditingController(text: item?.name ?? '');
    final locale = Provider.of<LocaleProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(item == null ? locale.addItem : locale.editItem),
        content: TextField(
          controller: nameCtrl,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Item Name (सामानको नाम)',
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
                if (item == null) {
                  dp.addItem(text);
                } else {
                  dp.editItem(item.id, text);
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

  void _confirmDeleteItem(BuildContext context, Item item) {
    final locale = Provider.of<LocaleProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(locale.deleteConfirmTitle),
        content: Text(
          locale.isNepali
              ? '${item.name} लाई हटाउन निश्चित हुनुहुन्छ? यससँग सम्बन्धित सबै रेकर्ड मेटिनेछ।'
              : 'Are you sure you want to delete ${item.name}? All related records will be removed.',
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
              Provider.of<DataProvider>(context, listen: false).deleteItem(item.id);
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
        title: Text(locale.manageItems),
        backgroundColor: AppColors.darkNavy,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<DataProvider>(
        builder: (context, data, child) {
          final items = data.items;

          if (items.isEmpty) {
            return Center(
              child: Text(
                locale.noItems,
                style: const TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }

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
                  leading: const Icon(Icons.inventory_2_outlined, color: AppColors.primaryGreen),
                  title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: AppColors.primaryGreen),
                        onPressed: () => _showItemDialog(context, item: item),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () => _confirmDeleteItem(context, item),
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
        backgroundColor: AppColors.primaryGreen,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(locale.addItem, style: const TextStyle(color: Colors.white)),
      ),
    );
  }
}
