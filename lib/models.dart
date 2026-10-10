class Customer {
  final String id;
  String name;
  String address;
  int sortOrder;

  Customer({
    required this.id,
    required this.name,
    required this.address,
    required this.sortOrder,
  });
}

class Item {
  final String id;
  final String name;

  Item({required this.id, required this.name});
}

class DeliveryRecord {
  final String id;
  final String customerId;
  final DateTime date;
  // Map of item ID to quantity dropped
  final Map<String, int> droppedItems;

  DeliveryRecord({
    required this.id,
    required this.customerId,
    required this.date,
    required this.droppedItems,
  });
}
