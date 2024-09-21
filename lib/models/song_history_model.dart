class SongHistoryList {
  final String songId;
  final String? playedAt;

  SongHistoryList({required this.songId, this.playedAt});

  factory SongHistoryList.fromJson(Map<String, dynamic> json) {
    return SongHistoryList(
      songId: json['songId'],
      playedAt: json['playedAt'],
    );
  }
}
