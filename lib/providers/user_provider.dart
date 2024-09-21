import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kp_music/models/song_history_model.dart';
import 'package:kp_music/models/user_model.dart';
import 'package:kp_music/services/api_client.dart';
import 'package:kp_music/services/api_url.dart';

class UserState {
  final UserModel? user;
  final bool isLoading;
  List<SongHistoryList>? songHistory;

  UserState({this.user, this.isLoading = false, this.songHistory});

  UserState copyWith(
      {UserModel? user, bool? isLoading, List<SongHistoryList>? songHistory}) {
    return UserState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      songHistory: songHistory ?? this.songHistory,
    );
  }
}

class UserNotifier extends StateNotifier<UserState> {
  UserNotifier() : super(UserState(isLoading: false));

  // Example API call method
  Future<void> getUser() async {
    // Set loading to true before starting API call
    state = state.copyWith(isLoading: true);

    try {
      final apiClient = ApiClient();

      final response = await apiClient.get(ApiUrls.getUser);

      if (response.statusCode == 200) {
        final user = UserModel.fromJson(response.data);
        state = state.copyWith(user: user, isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false);
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> getSongHistory() async {
    try {
      final apiClient = ApiClient();

      final response = await apiClient.get(ApiUrls.songHistory);

      if (response.statusCode == 200) {
        final songHistory = (response.data['songHistory'] as List)
            .map<SongHistoryList>((json) => SongHistoryList.fromJson(json))
            .toList();
        state = state.copyWith(songHistory: songHistory);
      }
    } catch (e) {
      print(e);
    }
  }
}

// Step 3: Create a provider for the UserNotifier.
final userProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  return UserNotifier();
});
