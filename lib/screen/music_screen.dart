import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class MusicScreen extends StatefulWidget {
  final Video video;
  final AudioPlayer audioPlayer;
  final Function updateMiniPlayer;

  const MusicScreen({
    required this.video,
    required this.audioPlayer,
    required this.updateMiniPlayer,
    super.key,
  });

  MusicScreen.play(
      {required this.video,
      required this.audioPlayer,
      required this.updateMiniPlayer,
      super.key}) {
    _play();
  }

  Future<void> _play() async {
    if (audioPlayer.playing) {
      audioPlayer.stop();
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
    audioPlayer.setAudioSource(audioSource);
    audioPlayer.play();
    updateMiniPlayer(video);
  }

  @override
  State<MusicScreen> createState() => _MusicScreenState();
}

class _MusicScreenState extends State<MusicScreen> {
  late bool isPlaying;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  // Future<void> _play() async {
  //   if (widget.audioPlayer.playing) {
  //     widget.audioPlayer.stop();
  //   }
  //   var yt = YoutubeExplode();
  //   var manifest =
  //       await yt.videos.streamsClient.getManifest(widget.video.id.value);
  //   var audio = manifest.audioOnly.withHighestBitrate();
  //   var audioSource = AudioSource.uri(
  //     audio.url,
  //     tag: MediaItem(
  //       // Specify a unique ID for each media item:
  //       id: widget.video.id.value,
  //       // Metadata to display in the notification:
  //       album: widget.video.author,
  //       title: widget.video.title,
  //       artUri: Uri.parse(widget.video.thumbnails.mediumResUrl),
  //     ),
  //   );
  //   widget.audioPlayer.setAudioSource(audioSource);
  //   widget.audioPlayer.play();
  //   setState(() {
  //     isPlaying = true;
  //   });
  //   widget.updateMiniPlayer(widget.video);
  // }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  void initState() {
    super.initState();
    // _play();

    widget.audioPlayer.playerStateStream.listen((event) {
      if (event.playing) {
        setState(() {
          isPlaying = true;
        });
      } else {
        setState(() {
          isPlaying = false;
        });
      }
    });

    widget.audioPlayer.positionStream.listen((event) {
      setState(() {
        position = event;
      });
    });

    widget.audioPlayer.durationStream.listen((event) {
      setState(() {
        duration = event!;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 3, sigmaY: 5),
          child: Image.network(
            widget.video.thumbnails.maxResUrl,
            fit: BoxFit.fill,
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
                    tag: widget.video.id.value,
                    child: FadeInImage(
                      placeholder: MemoryImage(kTransparentImage),
                      image: NetworkImage(widget.video.thumbnails.maxResUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                  Text(widget.video.title),
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
                  IconButton(
                    iconSize: 50,
                    onPressed: () {
                      if (isPlaying) {
                        widget.audioPlayer.pause();
                      } else {
                        widget.audioPlayer.play();
                      }
                    },
                    icon: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      transitionBuilder: (child, animation) =>
                          RotationTransition(
                        turns: Tween<double>(begin: 0.7, end: 1)
                            .animate(animation),
                        child: child,
                      ),
                      child: Icon(
                        isPlaying ? Icons.pause : Icons.play_arrow,
                        key: ValueKey(isPlaying),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
