import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:kp_music/screen/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  );
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]).then(
    (value) => runApp(MyApp()),
  );
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final AudioPlayer audioPlayer = AudioPlayer();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Kp Music",
      theme: ThemeData.dark().copyWith(
        useMaterial3: true,
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
      home: HomeScreen(audioPlayer: audioPlayer),
    );
  }
}
