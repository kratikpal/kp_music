import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kp_music/services/api_client.dart';
import 'package:kp_music/services/api_url.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class VideoNotifier extends StateNotifier<Video?> {
  VideoNotifier() : super(null);

  void updateVideo(Video video) {
    state = video;
  }

  Future<void> updateSongHistory() async {
    try {
      ApiClient apiClient = ApiClient();

      apiClient.post(ApiUrls.songHistory, data: {
        "songId": state!.id.value,
        "playedAt": DateTime.now().toIso8601String()
      });
    } catch (e) {
      print(e);
    }
  }
}

final videoProvider =
    StateNotifierProvider<VideoNotifier, Video?>((ref) => VideoNotifier());
