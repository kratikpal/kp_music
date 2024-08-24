import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class VideoNotifier extends StateNotifier<Video?> {
  VideoNotifier() : super(null);

  void updateVideo(Video video) {
    state = video;
  }
}

final videoProvider =
    StateNotifierProvider<VideoNotifier, Video?>((ref) => VideoNotifier());
