import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:kp_music/widget/shimmer_widget.dart';
import 'package:kp_music/widget/song_card.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class SongList extends StatefulWidget {
  final String playListId;
  final AudioPlayer audioPlayer;
  final Function updateMiniPlayer;

  const SongList({
    required this.playListId,
    required this.audioPlayer,
    required this.updateMiniPlayer,
    Key? key,
  }) : super(key: key);

  @override
  State<SongList> createState() => _SongListState();
}

class _SongListState extends State<SongList> {
  List<Video> searchResult = [];
  Playlist? playlist;
  bool isLoading = true;

  Future<void> _getPlayList() async {
    var yt = YoutubeExplode();
    playlist = await yt.playlists.get(widget.playListId);

    await for (var video in yt.playlists.getVideos(playlist!.id)) {
      searchResult.add(video);
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    _getPlayList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const ShimmerWidget()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 0, 10),
                child: Text(
                  playlist!.title,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: searchResult.length,
                  itemBuilder: (context, index) => SongCard(
                    video: searchResult[index],
                    audioPlayer: widget.audioPlayer,
                    updateMiniPlayer: widget.updateMiniPlayer,
                  ),
                ),
              ),
            ],
          );
  }
}
