import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/playlist_model.dart';
import '../models/song_model.dart';
import '../providers/playlist_provider.dart';

class PlaylistDetailScreen extends StatefulWidget {
  final PlaylistModel playlist;

  const PlaylistDetailScreen({super.key, required this.playlist});

  @override
  State<PlaylistDetailScreen> createState() => _PlaylistDetailScreenState();
}

class _PlaylistDetailScreenState extends State<PlaylistDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final provider = context.read<PlaylistProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(widget.playlist.name)),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('songs')
            .where('playlistId', isEqualTo: widget.playlist.id)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final songs = snapshot.hasData
              ? snapshot.data!.docs
                    .map(
                      (d) => SongModel.fromMap(
                        d.data() as Map<String, dynamic>,
                        d.id,
                      ),
                    )
                    .toList()
              : <SongModel>[];

          return RefreshIndicator(
            onRefresh: () async {
              await Future.delayed(const Duration(milliseconds: 500));
            },
            child: songs.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.7,
                        child: const Center(
                          child: Text(
                            'No songs in this playlist.\nAdd some songs!',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                    ],
                  )
                : ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: songs.length,
                    itemBuilder: (context, index) {
                      final song = songs[index];
                      return Card(
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: const CircleAvatar(
                            child: Icon(Icons.music_note),
                          ),
                          title: Text(
                            song.title,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Composer: ${song.composer}'),
                              const SizedBox(height: 4),
                              InkWell(
                                onTap: () => _openLink(song.musicLink),
                                child: Text(
                                  'Play Link',
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                ),
                                onPressed: () => _showEditSongDialog(
                                  context,
                                  song,
                                  provider,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => provider.deleteSong(
                                  song.id,
                                  widget.playlist.id,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSongDialog(context, provider),
        icon: const Icon(Icons.add),
        label: const Text('Add Song'),
      ),
    );
  }

  void _showAddSongDialog(BuildContext context, PlaylistProvider provider) {
    final titleController = TextEditingController();
    final composerController = TextEditingController();
    final linkController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Song'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Song Title'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: composerController,
                  decoration: const InputDecoration(labelText: 'Composer'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: linkController,
                  decoration: const InputDecoration(labelText: 'Music Link'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final title = titleController.text.trim();
                final composer = composerController.text.trim();
                final link = linkController.text.trim();
                if (title.isNotEmpty &&
                    composer.isNotEmpty &&
                    link.isNotEmpty) {
                  provider.addSong(
                    playlistId: widget.playlist.id,
                    title: title,
                    composer: composer,
                    musicLink: link,
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showEditSongDialog(
    BuildContext context,
    SongModel song,
    PlaylistProvider provider,
  ) {
    final titleController = TextEditingController(text: song.title);
    final composerController = TextEditingController(text: song.composer);
    final linkController = TextEditingController(text: song.musicLink);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Song'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Song Title'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: composerController,
                  decoration: const InputDecoration(labelText: 'Composer'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: linkController,
                  decoration: const InputDecoration(labelText: 'Music Link'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final title = titleController.text.trim();
                final composer = composerController.text.trim();
                final link = linkController.text.trim();
                if (title.isNotEmpty &&
                    composer.isNotEmpty &&
                    link.isNotEmpty) {
                  provider.updateSong(
                    songId: song.id,
                    playlistId: widget.playlist.id,
                    title: title,
                    composer: composer,
                    musicLink: link,
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openLink(String urlStr) async {
    final url = Uri.parse(urlStr);
    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Could not open link')));
      }
    }
  }
}
