class Shop {
  final String id;
  final String name;
  final String address;
  final String phone;
  final String email;
  final String ownerId;
  final String description;
  final String logo;
  final String status;
  final double creditLimit;

  Shop({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.email,
    required this.ownerId,
    required this.description,
    required this.logo,
    required this.status,
    this.creditLimit = 0.0,
  });

  factory Shop.fromMap(String id, Map<String, dynamic> data) => Shop(
    id: id,
    name: data['name'] ?? '',
    address: data['address'] ?? '',
    phone: data['phone'] ?? '',
    email: data['email'] ?? '',
    ownerId: data['ownerId'] ?? '',
    description: data['description'] ?? '',
    logo: data['logo'] ?? '',
    status: data['status'] ?? '',
    creditLimit: (data['creditLimit'] ?? 0.0).toDouble(),
  );

  Map<String, dynamic> toMap() => {
    'name': name,
    'address': address,
    'phone': phone,
    'email': email,
    'ownerId': ownerId,
    'description': description,
    'logo': logo,
    'status': status,
    'creditLimit': creditLimit,
  };
}
