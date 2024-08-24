import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import '../providers/video_provider.dart';
import '../screen/music_screen.dart';

class MiniPlayer extends ConsumerStatefulWidget {
  final AudioPlayer audioPlayer;

  const MiniPlayer({
    required this.audioPlayer,
    super.key,
  });

  @override
  ConsumerState<MiniPlayer> createState() => _MiniPlayerState();
}

class _MiniPlayerState extends ConsumerState<MiniPlayer> {
  bool isPlaying = false;

  @override
  void initState() {
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

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final video = ref.watch(videoProvider);
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MusicScreen(
              audioPlayer: widget.audioPlayer,
            ),
          ),
        );
      },
      child: Container(
        color: Colors.grey[900],
        height: 80,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            Row(
              children: [
                Hero(
                  tag: video!.id.value,
                  child: Image.network(
                    video.thumbnails.maxResUrl,
                    width: 60,
                    height: 48,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        video.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        video.author,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    isPlaying
                        ? widget.audioPlayer.pause()
                        : widget.audioPlayer.play();
                  },
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (child, animation) => RotationTransition(
                      turns:
                          Tween<double>(begin: 0.7, end: 1).animate(animation),
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
          ],
        ),
      ),
    );
  }
}
