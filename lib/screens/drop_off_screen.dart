import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models.dart';
import '../providers.dart';

class DropOffScreen extends StatefulWidget {
  final Customer customer;

  const DropOffScreen({Key? key, required this.customer}) : super(key: key);

  @override
  State<DropOffScreen> createState() => _DropOffScreenState();
}

class _DropOffScreenState extends State<DropOffScreen> {
  // Map of Item ID -> Quantity
  final Map<String, int> _quantities = {};

  void _submitDelivery() {
    // Filter out 0 quantities
    final dropped = <String, int>{};
    _quantities.forEach((key, value) {
      if (value > 0) dropped[key] = value;
    });

    if (dropped.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No items to drop off')));
      return;
    }

    Provider.of<DataProvider>(context, listen: false).addDelivery(widget.customer.id, dropped);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Delivery recorded for ${widget.customer.name}')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final items = Provider.of<DataProvider>(context, listen: false).items;

    return Scaffold(
      appBar: AppBar(
        title: Text('Drop-off at ${widget.customer.name}'),
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Record dropped items:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final currentQty = _quantities[item.id] ?? 0;
                
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(item.name, style: const TextStyle(fontSize: 16)),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                              onPressed: () {
                                if (currentQty > 0) {
                                  setState(() => _quantities[item.id] = currentQty - 1);
                                }
                              },
                            ),
                            SizedBox(
                              width: 40,
                              child: Text(
                                currentQty.toString(), 
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline, color: Colors.green),
                              onPressed: () {
                                setState(() => _quantities[item.id] = currentQty + 1);
                              },
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _submitDelivery,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                child: const Text('Confirm Drop-off', style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),
          )
        ],
      ),
    );
  }
}
