import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import '../providers/video_provider.dart';

class MusicScreen extends ConsumerStatefulWidget {
  final AudioPlayer audioPlayer;
  final bool isPlay;

  const MusicScreen({
    required this.audioPlayer,
    super.key,
  }) : isPlay = false;

  const MusicScreen.play({
    required this.audioPlayer,
    super.key,
  }) : isPlay = true;

  @override
  ConsumerState<MusicScreen> createState() => _MusicScreenState();
}

class _MusicScreenState extends ConsumerState<MusicScreen> {
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  Future<void> _play() async {
    final video = ref.read(videoProvider);
    if (video == null) {
      return;
    }
    if (widget.audioPlayer.playing) {
      widget.audioPlayer.stop();
    }
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
    widget.audioPlayer.setAudioSource(audioSource);
    widget.audioPlayer.play();
    ref.read(videoProvider.notifier).updateSongHistory();
    // updateMiniPlayer(video!);
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  void initState() {
    super.initState();

    if (widget.isPlay) {
      _play();
    }

    widget.audioPlayer.positionStream.listen((event) {
      setState(() {
        position = event;
      });
    });

    widget.audioPlayer.durationStream.listen((event) {
      if (event == null) {
        return;
      }
      setState(() {
        duration = event;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final video = ref.watch(videoProvider);
    return Stack(
      fit: StackFit.expand,
      children: [
        ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 3, sigmaY: 5),
          child: Image.network(
            video!.thumbnails.maxResUrl,
            fit: BoxFit.fill,
            errorBuilder: (context, error, stackTrace) => Image.asset(
              'assets/images/music.jpg',
              fit: BoxFit.fill,
            ),
          ),
        ),
        Scaffold(
          backgroundColor: Colors.black54,
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Hero(
                    tag: video.id.value,
                    child: FadeInImage(
                      placeholder: MemoryImage(kTransparentImage),
                      image: NetworkImage(video.thumbnails.maxResUrl),
                      fit: BoxFit.cover,
                      imageErrorBuilder: (context, error, stackTrace) =>
                          Image.asset(
                        'assets/images/music.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Text(video.title),
                  Slider(
                    min: 0,
                    max: duration.inSeconds.toDouble(),
                    value: position.inSeconds.toDouble(),
                    onChanged: (value) async {
                      await widget.audioPlayer
                          .seek(Duration(seconds: value.toInt()));
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDuration(position),
                      ),
                      Text(
                        _formatDuration(duration),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 50,
                    child: StreamBuilder<PlayerState>(
                      stream: widget.audioPlayer.playerStateStream,
                      builder: (context, snapshot) {
                        if (snapshot.data!.processingState ==
                                ProcessingState.loading ||
                            snapshot.data!.processingState ==
                                ProcessingState.buffering) {
                          return IconButton(
                            onPressed: () {},
                            iconSize: 50,
                            icon: const CircularProgressIndicator(),
                          );
                        }
                        return IconButton(
                          iconSize: 50,
                          onPressed: () {
                            if (snapshot.data!.playing) {
                              widget.audioPlayer.pause();
                            } else {
                              widget.audioPlayer.play();
                            }
                          },
                          icon: Icon(
                            snapshot.data!.playing
                                ? Icons.pause
                                : Icons.play_arrow,
                            key: ValueKey(snapshot.data!.playing),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {},
            child: const Icon(Icons.download),
          ),
        ),
      ],
    );
  }
}
