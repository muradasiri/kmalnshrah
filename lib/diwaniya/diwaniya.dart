import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class Diwaniya {
  String id;
  String name;
  String location;
  String code;
  List<String> members;
  List<String> memberImageUrls;

  Diwaniya({
    required this.id,
    required this.name,
    required this.location,
    required this.members,
    required this.code,
    required this.memberImageUrls,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'code': code,
      'members': members,
      'memberImageUrls': memberImageUrls,
    };
  }

  factory Diwaniya.fromDocument(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Diwaniya(
      id: doc.id,
      name: data['name'] ?? '',
      location: data['location'] ?? '',
      code: data['code'] ?? generateRandomCode(),
      members: List<String>.from(data['members'] ?? []),
      memberImageUrls: List<String>.from(data['memberImageUrls'] ?? []),
    );
  }

  static String generateRandomCode() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    return List.generate(7, (index) => chars[random.nextInt(chars.length)]).join();
  }
}
