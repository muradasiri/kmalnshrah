import 'package:cloud_firestore/cloud_firestore.dart';

class Diwaniya {
  String id;
  String name;
  String? imageUrl;
  String code;
  String createdBy;
  List<String> members;

  Diwaniya({
    required this.id,
    required this.name,
    this.imageUrl,
    required this.code,
    required this.createdBy,
    required this.members,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'imageUrl': imageUrl,
      'code': code,
      'createdBy': createdBy,
      'members': members,
    };
  }

  static Diwaniya fromMap(Map<String, dynamic> map, String documentId) {
    return Diwaniya(
      id: documentId,
      name: map['name'],
      imageUrl: map['imageUrl'],
      code: map['code'],
      createdBy: map['createdBy'],
      members: List<String>.from(map['members'] ?? []),
    );
  }
}

class Player {
  String id;
  String name;
  String? imageUrl;
  int wins;
  int losses;

  Player({
    required this.id,
    required this.name,
    this.imageUrl,
    this.wins = 0,
    this.losses = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'imageUrl': imageUrl,
      'wins': wins,
      'losses': losses,
    };
  }

  static Player fromMap(Map<String, dynamic> map, String documentId) {
    return Player(
      id: documentId,
      name: map['name'],
      imageUrl: map['imageUrl'],
      wins: map['wins'] ?? 0,
      losses: map['losses'] ?? 0,
    );
  }

  Player copyWith({
    String? id,
    String? name,
    String? imageUrl,
    int? wins,
    int? losses,
  }) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      wins: wins ?? this.wins,
      losses: losses ?? this.losses,
    );
  }
}

class ScoreArchive {
  String id;
  String winner;
  int usScore;
  int themScore;
  String duration;
  DateTime dateTime;
  String teamUs1;
  String teamUs2;
  String teamThem1;
  String teamThem2;

  ScoreArchive({
    required this.id,
    required this.winner,
    required this.usScore,
    required this.themScore,
    required this.duration,
    required this.dateTime,
    required this.teamUs1,
    required this.teamUs2,
    required this.teamThem1,
    required this.teamThem2,
  });

  Map<String, dynamic> toMap() {
    return {
      'winner': winner,
      'usScore': usScore,
      'themScore': themScore,
      'duration': duration,
      'dateTime': dateTime.toIso8601String(),
      'teamUs1': teamUs1,
      'teamUs2': teamUs2,
      'teamThem1': teamThem1,
      'teamThem2': teamThem2,
    };
  }

  static ScoreArchive fromMap(Map<String, dynamic> map, String documentId) {
    return ScoreArchive(
      id: documentId,
      winner: map['winner'],
      usScore: map['usScore'],
      themScore: map['themScore'],
      duration: map['duration'],
      dateTime: DateTime.parse(map['dateTime']),
      teamUs1: map['teamUs1'],
      teamUs2: map['teamUs2'],
      teamThem1: map['teamThem1'],
      teamThem2: map['teamThem2'],
    );
  }
}
