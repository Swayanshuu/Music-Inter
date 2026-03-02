import 'package:cloud_firestore/cloud_firestore.dart';

class SongModel {
  final String id;
  final String title;
  final String composer;
  final String musicLink;
  final String playlistId;
  final DateTime createdAt;

  SongModel({
    required this.id,
    required this.title,
    required this.composer,
    required this.musicLink,
    required this.playlistId,
    required this.createdAt,
  });

  factory SongModel.fromMap(Map<String, dynamic> map, String id) {
    return SongModel(
      id: id,
      title: map['title'] ?? '',
      composer: map['composer'] ?? '',
      musicLink: map['musicLink'] ?? '',
      playlistId: map['playlistId'] ?? '',
      createdAt: _parseDate(map['createdAt']),
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
      'title': title,
      'composer': composer,
      'musicLink': musicLink,
      'playlistId': playlistId,
      'createdAt': createdAt,
    };
  }

  SongModel copyWith({
    String? id,
    String? title,
    String? composer,
    String? musicLink,
    String? playlistId,
    DateTime? createdAt,
  }) {
    return SongModel(
      id: id ?? this.id,
      title: title ?? this.title,
      composer: composer ?? this.composer,
      musicLink: musicLink ?? this.musicLink,
      playlistId: playlistId ?? this.playlistId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
