import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
  final String? email;
  final String? name;
  final String? surname;
  final String? phone;
  final String? userLevel;
  final DateTime? createdAt;

  AppUser({
    required this.uid,
    this.email,
    this.name,
    this.surname,
    this.phone,
    this.userLevel,
    this.createdAt,
  });

  factory AppUser.fromMap(String id, Map<String, dynamic>? data) {
    data ??= {};
    final ts = data['created_at'];
    DateTime? created;
    if (ts is DateTime) created = ts;
    else if (ts is Map && ts['_seconds'] != null) {
      created = DateTime.fromMillisecondsSinceEpoch((ts['_seconds'] as int) * 1000);
    }
    return AppUser(
      uid: id,
      email: data['email'] as String?,
      name: data['name'] as String?,
      surname: data['surname'] as String?,
      phone: data['phone'] as String?,
      userLevel: data['user_level'] as String?,
      createdAt: created,
    );
  }

  Map<String, dynamic> toMap() => {
        'email': email,
        'name': name,
        'surname': surname,
        'phone': phone,
        'user_level': userLevel,
        'created_at': createdAt != null ? TimestampFromDate(createdAt!) : FieldValue.serverTimestamp(),
      };
}

// small helper to keep toMap readable (uses Firestore FieldValue if needed)
dynamic TimestampFromDate(DateTime d) => {'_seconds': d.millisecondsSinceEpoch ~/ 1000};