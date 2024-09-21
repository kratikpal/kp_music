import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:kp_music/providers/queue_provider.dart';
import 'package:kp_music/widget/shimmer_widget.dart';
import 'package:kp_music/widget/song_card.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class SongList extends ConsumerStatefulWidget {
  final String playListId;
  final AudioPlayer audioPlayer;

  const SongList({
    required this.playListId,
    required this.audioPlayer,
    super.key,
  });

  @override
  ConsumerState<SongList> createState() => _SongListState();
}

class _SongListState extends ConsumerState<SongList> {
  List<Video> searchResult = [];
  Playlist? playlist;

  bool isPlaylistLoading = false;

  void _playAll() async {
    setState(() => isPlaylistLoading = true);

    List<AudioSource> audioSources = [];
    for (final video in searchResult) {
      var yt = YoutubeExplode();
      var manifest = await yt.videos.streamsClient.getManifest(video.id.value);
      var audio = manifest.audioOnly.withHighestBitrate();
      var audioSource = AudioSource.uri(
        audio.url,
        tag: MediaItem(
          // Specify a unique ID for each media item:
          id: video.id.value,
          // Metadata to display in the notification:
          album: video.author,
          title: video.title,
          artUri: Uri.parse(video.thumbnails.mediumResUrl),
        ),
      );
      audioSources.add(audioSource);
    }
    ref.read(queueProvider.notifier).addAudioSources(audioSources);
    final queue = ref.read(queueProvider);

    widget.audioPlayer.setAudioSource(queue, initialIndex: 0);
    widget.audioPlayer.play();
    setState(() => isPlaylistLoading = false);
    // widget.updateMiniPlayer(searchResult[0]);
  }

  bool isLoading = true;

  Future<void> _getPlayList() async {
    var yt = YoutubeExplode();
    playlist = await yt.playlists.get(widget.playListId);

    await for (var video in yt.playlists.getVideos(playlist!.id)) {
      searchResult.add(video);
    }
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
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
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 5),
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
                  ),
                ),
              ),
            ],
          );
  }
}
