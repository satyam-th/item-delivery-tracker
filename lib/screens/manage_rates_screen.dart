import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
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
          backgroundColor: AppColors.darkNavy,
          foregroundColor: Colors.white,
          elevation: 0,
          bottom: TabBar(
            indicatorColor: AppColors.primaryGreen,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: locale.universalRates),
              Tab(text: locale.customRates),
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
  final locale = Provider.of<LocaleProvider>(context, listen: false);

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: ctrl,
        autofocus: true,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: const InputDecoration(
          labelText: 'Rate (Rs)',
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
            final val = double.tryParse(ctrl.text.trim());
            if (val != null && val >= 0) {
              onSave(val);
              Navigator.pop(context);
            }
          },
          child: Text(locale.save),
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
                leading: const Icon(Icons.inventory_2_outlined, color: AppColors.primaryGreen),
                title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                subtitle: Text('Rs. ${rate.toStringAsFixed(2)}', style: const TextStyle(color: AppColors.primaryGreen)),
                trailing: IconButton(
                  icon: const Icon(Icons.edit, color: AppColors.primaryGreen, size: 20),
                  onPressed: () {
                    _showRateEditDialog(context, 'Edit Universal Rate: ${item.name}', rate, (newVal) {
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
                      subtitle: Text('Rs. ${rate.toStringAsFixed(2)}', style: const TextStyle(color: AppColors.primaryGreen, fontSize: 12)),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit, color: AppColors.primaryGreen, size: 18),
                        onPressed: () {
                          _showRateEditDialog(context, 'Edit Custom Rate for ${cust.name}: ${item.name}', rate, (newVal) {
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
