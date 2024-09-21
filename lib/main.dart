import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:kp_music/screen/auth_screen.dart';
import 'package:kp_music/screen/home_screen.dart';
import 'package:kp_music/services/secure_storage_service.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  );
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]).then(
    (value) => runApp(const ProviderScope(child: MyApp())),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AudioPlayer audioPlayer = AudioPlayer();

  final SecureStorageService _storageService = SecureStorageService();

  @override
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Kp Music",
      theme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.dark,
          seedColor: const Color.fromARGB(225, 26, 189, 160),
        ),
        scaffoldBackgroundColor: Theme.of(context).colorScheme.shadow,
        appBarTheme: const AppBarTheme().copyWith(
          backgroundColor: Colors.transparent,
        ),
        iconButtonTheme: IconButtonThemeData(
          style: IconButton.styleFrom(
            foregroundColor: const Color.fromARGB(225, 26, 189, 160),
          ),
        ),
      ),
      home: FutureBuilder<String?>(
        future: _storageService.read(key: 'token'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return AuthScreen(audioPlayer: audioPlayer);
          }
          return HomeScreen(audioPlayer: audioPlayer);
        },
      ),
    );
  }
}
