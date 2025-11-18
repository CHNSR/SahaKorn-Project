class Shop {
  final String id;
  final String name;
  final String address;
  final String phone;
  final String ownerId;

  Shop({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.ownerId,
  });

  factory Shop.fromMap(String id, Map<String, dynamic> data) => Shop(
        id: id,
        name: data['name'] ?? '',
        address: data['address'] ?? '',
        phone: data['phone'] ?? '',
        ownerId: data['ownerId'] ?? '',
      );

  Map<String, dynamic> toMap() => {
        'name': name,
        'address': address,
        'phone': phone,
        'ownerId': ownerId,
      };
}