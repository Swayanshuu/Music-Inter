import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/playlist_model.dart';
import '../models/song_model.dart';

class PlaylistProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const _uuid = Uuid();

  String? _userId;
  List<PlaylistModel> _playlists = [];
  List<SongModel> _songs = [];
  bool _isLoading = false;
  String? _error;

  List<PlaylistModel> get playlists => _playlists;
  List<SongModel> get songs => _songs;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void updateUserId(String? uid) {
    if (_userId != uid) {
      _userId = uid;
      if (uid != null) {
        listenToPlaylists();
      } else {
        _playlists = [];
        _songs = [];
        notifyListeners();
      }
    }
  }

  void listenToPlaylists() {
    _db
        .collection('playlists')
        .where('userId', isEqualTo: _userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snap) {
          _playlists = snap.docs
              .map((d) => PlaylistModel.fromMap(d.data(), d.id))
              .toList();
          notifyListeners();
        });
  }

  Future<void> createPlaylist(String name, {String? description}) async {
    _setLoading(true);
    try {
      final playlist = PlaylistModel(
        id: '',
        name: name,
        userId: _userId!,
        description: description,
        createdAt: DateTime.now(),
      );
      await _db.collection('playlists').add(playlist.toMap());
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deletePlaylist(String playlistId) async {
    _setLoading(true);
    try {
      final songSnap = await _db
          .collection('songs')
          .where('playlistId', isEqualTo: playlistId)
          .get();
      final batch = _db.batch();
      for (final doc in songSnap.docs) {
        batch.delete(doc.reference);
      }
      batch.delete(_db.collection('playlists').doc(playlistId));
      await batch.commit();
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  void listenToSongs(String playlistId) {
    _db
        .collection('songs')
        .where('playlistId', isEqualTo: playlistId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .listen((snap) {
          _songs = snap.docs
              .map((d) => SongModel.fromMap(d.data(), d.id))
              .toList();
          notifyListeners();
        });
  }

  Future<void> addSong({
    required String playlistId,
    required String title,
    required String composer,
    required String musicLink,
  }) async {
    _setLoading(true);
    try {
      final song = SongModel(
        id: _uuid.v4(),
        title: title,
        composer: composer,
        musicLink: musicLink,
        playlistId: playlistId,
        createdAt: DateTime.now(),
      );
      await _db.collection('songs').add(song.toMap());
      await _db.collection('playlists').doc(playlistId).update({
        'songCount': FieldValue.increment(1),
      });
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateSong({
    required String songId,
    required String playlistId,
    required String composer,
    required String musicLink,
  }) async {
    _setLoading(true);
    try {
      await _db.collection('songs').doc(songId).update({
        'composer': composer,
        'musicLink': musicLink,
      });
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteSong(String songId, String playlistId) async {
    _setLoading(true);
    try {
      await _db.collection('songs').doc(songId).delete();
      await _db.collection('playlists').doc(playlistId).update({
        'songCount': FieldValue.increment(-1),
      });
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  List<SongModel> getSongsForPlaylist(String playlistId) {
    return _songs.where((s) => s.playlistId == playlistId).toList();
  }

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }
}
