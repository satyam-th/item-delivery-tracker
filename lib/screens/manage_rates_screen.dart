import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers.dart';

class ManageRatesScreen extends StatelessWidget {
  const ManageRatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = Provider.of<LocaleProvider>(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(locale.manageRates),
          backgroundColor: const Color(0xFF0F2027),
          foregroundColor: const Color(0xFFF1A8A6),
          elevation: 0,
          bottom: const TabBar(
            indicatorColor: Color(0xFF138D5B),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: 'Universal Rates'),
              Tab(text: 'Custom Rates'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _UniversalRatesTab(),
            _CustomRatesTab(),
          ],
        ),
      ),
    );
  }
}

void _showRateEditDialog(BuildContext context, String title, double currentRate, Function(double) onSave) {
  final ctrl = TextEditingController(text: currentRate.toString());
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: ctrl,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: const InputDecoration(labelText: 'Rate (Rs)'),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            final val = double.tryParse(ctrl.text);
            if (val != null) {
              onSave(val);
              Navigator.pop(context);
            }
          },
          child: const Text('Save'),
        )
      ],
    ),
  );
}

class _UniversalRatesTab extends StatelessWidget {
  const _UniversalRatesTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<DataProvider>(
      builder: (context, data, child) {
        final items = data.items;

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            final rate = data.getUniversalRate(item.id);
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 0.5,
              child: ListTile(
                leading: const Icon(Icons.inventory_2_outlined, color: Color(0xFF138D5B)),
                title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                subtitle: Text('Rs. ${rate.toStringAsFixed(2)}', style: const TextStyle(color: Color(0xFF138D5B))),
                trailing: IconButton(
                  icon: const Icon(Icons.edit, color: Color(0xFF138D5B), size: 20),
                  onPressed: () {
                    _showRateEditDialog(context, 'Edit Universal Rate', rate, (newVal) {
                      data.updateUniversalRate(item.id, newVal);
                    });
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _CustomRatesTab extends StatelessWidget {
  const _CustomRatesTab();

  Color _getAvatarColor(int index) {
    List<Color> colors = [
      Colors.deepOrange, Colors.blue, Colors.purple, 
      Colors.orange, Colors.purple, Colors.orange, 
      Colors.blueGrey, Colors.purpleAccent, Colors.orangeAccent
    ];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DataProvider>(
      builder: (context, data, child) {
        final customers = data.customers;
        final items = data.items;

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: customers.length,
          itemBuilder: (context, cIndex) {
            final cust = customers[cIndex];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 0.5,
              child: Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  initiallyExpanded: cIndex == 0,
                  leading: CircleAvatar(
                    backgroundColor: _getAvatarColor(cIndex),
                    radius: 16,
                    child: Text('${cIndex + 1}', style: const TextStyle(color: Colors.white, fontSize: 12)),
                  ),
                  title: Text(
                    cust.name, 
                    style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)
                  ),
                  children: items.map((item) {
                    final rate = data.getRate(cust.id, item.id);
                    return ListTile(
                      contentPadding: const EdgeInsets.only(left: 56, right: 16),
                      leading: const Icon(Icons.inventory_2_outlined, color: Colors.grey, size: 20),
                      title: Text(item.name, style: const TextStyle(fontSize: 14)),
                      subtitle: Text('Rs. ${rate.toStringAsFixed(2)}', style: const TextStyle(color: Color(0xFF138D5B), fontSize: 12)),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit, color: Color(0xFF138D5B), size: 18),
                        onPressed: () {
                          _showRateEditDialog(context, 'Edit Custom Rate for ${cust.name}', rate, (newVal) {
                            data.updateCustomRate(cust.id, item.id, newVal);
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
