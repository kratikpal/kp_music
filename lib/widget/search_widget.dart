import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:kp_music/providers/video_provider.dart';
import 'package:kp_music/screen/music_screen.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class SearchWidget extends ConsumerWidget {
  final List<Video> searchResult;
  final AudioPlayer audioPlayer;

  const SearchWidget({
    Key? key,
    required this.searchResult,
    required this.audioPlayer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return searchResult.isNotEmpty
        ? Expanded(
            child: ListView.builder(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.only(bottom: 10),
              itemCount: searchResult.length,
              itemBuilder: (context, index) {
                final result = searchResult[index];
                return GestureDetector(
                  onTap: () {
                    ref.read(videoProvider.notifier).updateVideo(result);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MusicScreen.play(
                          audioPlayer: audioPlayer,
                          // updateMiniPlayer: updateMiniPlayer,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    margin:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Hero(
                          tag: result.id.value,
                          child: Image.network(
                            result.thumbnails.mediumResUrl,
                            width: 100,
                            height: 60,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                result.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                result.author,
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          )
        : Container();
  }
}
