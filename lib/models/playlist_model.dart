import 'package:cloud_firestore/cloud_firestore.dart';

class PlaylistModel {
  final String id;
  final String name;
  final String userId;
  final String? description;
  final DateTime createdAt;
  final int songCount;

  PlaylistModel({
    required this.id,
    required this.name,
    required this.userId,
    this.description,
    required this.createdAt,
    this.songCount = 0,
  });

  factory PlaylistModel.fromMap(Map<String, dynamic> map, String id) {
    return PlaylistModel(
      id: id,
      name: map['name'] ?? '',
      userId: map['userId'] ?? '',
      description: map['description'],
      createdAt: _parseDate(map['createdAt']),
      songCount: map['songCount'] ?? 0,
    );
  }

  static DateTime _parseDate(dynamic date) {
    if (date == null) return DateTime.now();
    if (date is DateTime) return date;
    if (date is Timestamp) return date.toDate();
    return DateTime.now();
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'userId': userId,
      'description': description,
      'createdAt': createdAt,
      'songCount': songCount,
    };
  }

  PlaylistModel copyWith({
    String? id,
    String? name,
    String? userId,
    String? description,
    DateTime? createdAt,
    int? songCount,
  }) {
    return PlaylistModel(
      id: id ?? this.id,
      name: name ?? this.name,
      userId: userId ?? this.userId,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      songCount: songCount ?? this.songCount,
    );
  }
}
