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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PlaylistProvider>().listenToSongs(widget.playlist.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PlaylistProvider>();
    final songs = provider.getSongsForPlaylist(widget.playlist.id);

    return Scaffold(
      appBar: AppBar(title: Text(widget.playlist.name)),
      body: songs.isEmpty
          ? const Center(
              child: Text(
                'No songs in this playlist.\nAdd some songs!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: songs.length,
              itemBuilder: (context, index) {
                final song = songs[index];
                return Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: const CircleAvatar(child: Icon(Icons.music_note)),
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
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () =>
                              _showEditSongDialog(context, song, provider),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () =>
                              provider.deleteSong(song.id, widget.playlist.id),
                        ),
                      ],
                    ),
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
                Text(
                  'Title: ${song.title}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
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
                final composer = composerController.text.trim();
                final link = linkController.text.trim();
                if (composer.isNotEmpty && link.isNotEmpty) {
                  provider.updateSong(
                    songId: song.id,
                    playlistId: widget.playlist.id,
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
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.inAppWebView);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Could not open link')));
      }
    }
  }
}
