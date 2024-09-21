import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:kp_music/providers/user_provider.dart';
import 'package:kp_music/widget/shimmer_widget.dart';
import 'package:kp_music/widget/song_card.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class RecentlyPlayedWidget extends ConsumerStatefulWidget {
  final AudioPlayer audioPlayer;

  const RecentlyPlayedWidget({super.key, required this.audioPlayer});

  @override
  ConsumerState<RecentlyPlayedWidget> createState() =>
      _RecentlyPlayedWidgetState();
}

class _RecentlyPlayedWidgetState extends ConsumerState<RecentlyPlayedWidget> {
  var yt = YoutubeExplode();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(10, 0, 10, 5),
              child: Text(
                "Recently Played",
                style: TextStyle(fontSize: 20),
              ),
            ),
            IconButton(
                onPressed: () {
                  ref.read(userProvider.notifier).getSongHistory();
                },
                icon: const Icon(Icons.refresh)),
          ],
        ),
        SizedBox(
          height: 240,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: userState.songHistory!.length,
            itemBuilder: (context, index) {
              final song = userState.songHistory![index];
              return FutureBuilder<Video>(
                future: yt.videos.get(song.songId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(
                      width: 140,
                      height: 20,
                      child: ShimmerWidget(),
                    );
                  } else if (snapshot.hasError) {
                    // Handle the error accordingly
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (snapshot.hasData) {
                    // Once the data is fetched, return the SongCard widget
                    var video = snapshot.data!;
                    return SongCard(
                      video: video,
                      audioPlayer: widget.audioPlayer,
                    );
                  } else {
                    return Container(); // Return an empty container if no data
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
