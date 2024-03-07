import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:kp_music/widget/search_widget.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class SearchScreen extends StatefulWidget {
  final AudioPlayer audioPlayer;
  final Function updateMiniPlayer;

  const SearchScreen(
      {super.key, required this.audioPlayer, required this.updateMiniPlayer});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _srarchController = TextEditingController();
  List<Video> searchResult = [];

  Future<void> _search(String query) async {
    var yt = YoutubeExplode();
    searchResult = await yt.search.getVideos(query);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _srarchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                height: 70,
                child: TextFormField(
                  controller: _srarchController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    labelText: 'Search',
                    suffixIcon: IconButton(
                      onPressed: () {
                        _srarchController.clear();
                      },
                      icon: const Icon(Icons.close),
                    ),
                    suffixIconColor: Theme.of(context).colorScheme.primary,
                  ),
                  onChanged: (value) => _search(value),
                  onFieldSubmitted: (value) => _search(value),
                ),
              ),
              SearchWidget(
                searchResult: searchResult,
                audioPlayer: widget.audioPlayer,
                updateMiniPlayer: widget.updateMiniPlayer,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
