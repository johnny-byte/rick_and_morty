import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:rick_and_morty/custom_grid.dart';
import 'package:rick_and_morty/model/character.dart';
import 'package:rick_and_morty/model/episode.dart';
import 'package:dartx/dartx.dart';
import 'package:rick_and_morty/theme_data.dart';
import 'api/api.dart';

void main(List<String> args) {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: BrandTheme.defaultTheme,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class CharacterCard extends StatelessWidget {
  const CharacterCard({
    Key? key,
    required this.characterName,
    required this.status,
    required this.spice,
    required this.lastKnownLocation,
    required this.firstEpisodeName,
    required this.imageURL,
  }) : super(key: key);

  final String characterName;
  final String status;
  final String spice;
  final String lastKnownLocation;
  final String firstEpisodeName;
  final String imageURL;

  @override
  Widget build(BuildContext context) {
    final Color iconColor;
    if (status == "Alive") {
      iconColor = Colors.green;
    } else if (status == "Dead") {
      iconColor = Colors.red;
    } else if (status == "unknown") {
      iconColor = Colors.grey[400]!;
    } else {
      throw "unexpected error no such status: '$status'";
    }

    return Card(
      //TODO remove radius from here
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      //TODO
      color: const Color.fromARGB(255, 60, 62, 68),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              //TODO remove radius from here
              topLeft: Radius.circular(16),
              bottomLeft: Radius.circular(16),
            ),
            child: Image.network(
              imageURL,
              fit: BoxFit.fill,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(),
                  Text(
                    characterName,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.circle,
                        color: iconColor,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: Text(
                          "${status.capitalize()} - $spice",
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      )
                    ],
                  ),
                  const Spacer(),
                  Text(
                    "Last known location:",
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    lastKnownLocation,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const Spacer(),
                  Text(
                    "First seen in:",
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    firstEpisodeName,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomePageState extends State<HomePage> {
  var characterCards = <Widget>[];
  bool itemsInitialized = false;

  Future<CharacterCard> _loadCharacterCard(Dio dio, Character character) async {
    var episodeAnswer = await dio.get(character.episode[0]);
    var episode = Episode.fromJson(episodeAnswer.data);
    return CharacterCard(
      characterName: character.name,
      status: character.status,
      spice: character.species,
      lastKnownLocation: character.location.name,
      firstEpisodeName: episode.name,
      imageURL: character.image,
    );
  }

  Future<void> initItems() async {
    Dio dio = Dio();
    RestClient client = RestClient(dio);
    var answer = await client.getAllCharacters();

    var characters = Stream.fromFutures(answer.characters
        .map((character) => _loadCharacterCard(dio, character)));

    await for (var character in characters) {
      characterCards.add(character);
    }

    itemsInitialized = true;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    initItems();
  }

  void loadMore() {
    setState(() {
      // if ((present + perPage) > originalItems.length) {
      //   items.addAll(originalItems.getRange(present, originalItems.length));
      // } else {
      //   items.addAll(originalItems.getRange(present, present + perPage));
      // }
      // present = present + perPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //TODO
      backgroundColor: const Color.fromARGB(255, 32, 35, 41),
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(
            expandedHeight: 400,
            collapsedHeight: 200,
            flexibleSpace: Center(
              child: Text(
                "The Rick and Morty",
                style: TextStyle(
                    fontSize: 100,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              
            ),
            backgroundColor: Colors.white,
          ),
          itemsInitialized
              ? SliverPadding(
                  padding: const EdgeInsets.symmetric(vertical: 24,horizontal: 8),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => characterCards[index],
                      childCount: characterCards.length,
                    ),
                    gridDelegate: const CustomSliverGridDelegate(
                        height: 220, width: 600, spacing: 30),
                  ),
                )
              : const SliverToBoxAdapter(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
