import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:kp_music/screen/music_screen.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import '../providers/video_provider.dart';

class SongCard extends ConsumerWidget {
  final Video video;
  final AudioPlayer audioPlayer;
  const SongCard({required this.video, required this.audioPlayer, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 0, 0),
      child: GestureDetector(
        onTap: () {
          ref.read(videoProvider.notifier).updateVideo(video);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MusicScreen.play(
                audioPlayer: audioPlayer,
              ),
            ),
          );
        },
        child: SizedBox(
          width: 120,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  width: 120,
                  height: 120,
                  child: FadeInImage(
                    placeholder: MemoryImage(kTransparentImage),
                    image: NetworkImage(video.thumbnails.mediumResUrl),
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                video.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14),
              ),
              Text(
                video.author,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
