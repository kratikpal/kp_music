import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:kp_music/screen/search_screen.dart';
import 'package:kp_music/widget/mini_player.dart';
import 'package:kp_music/widget/song_list.dart';

import '../providers/video_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final AudioPlayer audioPlayer;
  const HomeScreen({required this.audioPlayer, Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  // Video? video;
  List<String> playListIds = [
    "RDCLAK5uy_n9Fbdw7e6ap-98_A-8JYBmPv64v-Uaq1g",
    "PL_yIBWagYVjwYmv3PlwYk0b4vmaaHX6aL",
    "RDCLAK5uy_mLJf8i5vYsqR7oTk6CNO4Ge49J3OU4sRs",
    "RDCLAK5uy_kjNBBWqyQ_Cy14B0P4xrcKgd39CRjXXKk",
    "RDCLAK5uy_kiDNaS5nAXxdzsqFElFKKKs0GUEFJE26w",
  ];

  // void _updateMiniPlayer(Video vid) {
  //   setState(() {
  //     video = vid;
  //   });
  // }

  @override
  void initState() {
    // video = null;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final video = ref.watch(videoProvider);
    return Scaffold(
      body: NestedScrollView(
        floatHeaderSlivers: true,
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            floating: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) {
                      return SearchScreen(
                        audioPlayer: widget.audioPlayer,
                      );
                    }),
                  );
                },
              ),
              IconButton(
                onPressed: () {
                  FirebaseAuth.instance.signOut();
                },
                icon: const Icon(Icons.logout_rounded),
              ),
            ],
          ),
        ],
        body: ListView(
          children: [
            for (int index = 0; index < playListIds.length; index++)
              SizedBox(
                height: 260,
                child: SongList(
                  playListId: playListIds[index],
                  audioPlayer: widget.audioPlayer,
                  // updateMiniPlayer: _updateMiniPlayer,
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: video != null
          ? MiniPlayer(
              audioPlayer: widget.audioPlayer,
            )
          : null,
    );
  }
}
