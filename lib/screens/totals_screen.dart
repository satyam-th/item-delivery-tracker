import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers.dart';

class TotalsScreen extends StatelessWidget {
  const TotalsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aggregated Drop-offs'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Consumer<DataProvider>(
        builder: (context, data, child) {
          final totals = data.getAggregatedTotals();
          final items = data.items;

          if (totals.isEmpty) {
            return const Center(child: Text('No items dropped off today.'));
          }

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final totalQty = totals[item.id] ?? 0;

              if (totalQty == 0) return const SizedBox.shrink(); // Don't show if 0

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                elevation: 3,
                child: ListTile(
                  leading: const Icon(Icons.inventory, color: Colors.teal),
                  title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Total: $totalQty',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal, fontSize: 16),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
