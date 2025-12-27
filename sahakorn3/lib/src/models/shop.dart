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
  };
}
