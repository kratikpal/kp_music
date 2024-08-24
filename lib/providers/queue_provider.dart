import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

class QueueNotifier extends StateNotifier<ConcatenatingAudioSource> {
  QueueNotifier() : super(ConcatenatingAudioSource(children: []));

  void addAudioSources(List<AudioSource> audioSources) {
    state = ConcatenatingAudioSource(children: [
      ...state.children,
      for (final audioSource in audioSources) audioSource
    ]);
  }
}

final queueProvider =
    StateNotifierProvider<QueueNotifier, ConcatenatingAudioSource>(
        (ref) => QueueNotifier());
