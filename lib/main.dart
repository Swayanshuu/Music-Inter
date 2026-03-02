import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'providers/auth_provider.dart';
import 'providers/playlist_provider.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MusicListerApp());
}

class MusicListerApp extends StatelessWidget {
  const MusicListerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppAuthProvider()),
        ChangeNotifierProxyProvider<AppAuthProvider, PlaylistProvider>(
          create: (_) => PlaylistProvider(),
          update: (_, auth, playlist) {
            playlist!.updateUserId(auth.userId);
            return playlist;
          },
        ),
      ],
      child: MaterialApp(
        title: 'Music Lister',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(centerTitle: false, elevation: 1),
          inputDecorationTheme: const InputDecorationTheme(
            border: OutlineInputBorder(),
          ),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
