import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/playlist_provider.dart';
import '../models/playlist_model.dart';
import 'playlist_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AppAuthProvider>();
    final playlistProvider = context.watch<PlaylistProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Playlists'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => auth.signOut(),
          ),
        ],
      ),
      body: playlistProvider.playlists.isEmpty
          ? const Center(
              child: Text(
                'No playlists yet.\nTap + to create one!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: playlistProvider.playlists.length,
              itemBuilder: (context, index) {
                final playlist = playlistProvider.playlists[index];
                return Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: const CircleAvatar(child: Icon(Icons.queue_music)),
                    title: Text(
                      playlist.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text('${playlist.songCount} songs'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _confirmDeletePlaylist(
                        context,
                        playlist,
                        playlistProvider,
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              PlaylistDetailScreen(playlist: playlist),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreatePlaylistDialog(context, playlistProvider),
        icon: const Icon(Icons.add),
        label: const Text('New Playlist'),
      ),
    );
  }

  void _showCreatePlaylistDialog(
    BuildContext context,
    PlaylistProvider provider,
  ) {
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create Playlist'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Playlist Name'),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                if (name.isNotEmpty) {
                  provider.createPlaylist(name);
                  Navigator.pop(context);
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDeletePlaylist(
    BuildContext context,
    PlaylistModel playlist,
    PlaylistProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Playlist'),
          content: Text('Delete "${playlist.name}" completely?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                provider.deletePlaylist(playlist.id);
                Navigator.pop(context);
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}
