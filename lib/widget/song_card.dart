import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:kp_music/screen/music_screen.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class SongCard extends StatelessWidget {
  final Video video;
  final AudioPlayer audioPlayer;
  final Function updateMiniPlayer;
  const SongCard(
      {required this.video,
      required this.audioPlayer,
      required this.updateMiniPlayer,
      super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 0, 0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MusicScreen.play(
                  video: video,
                  audioPlayer: audioPlayer,
                  updateMiniPlayer: updateMiniPlayer),
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
