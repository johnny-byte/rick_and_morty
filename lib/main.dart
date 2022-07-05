import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:rick_and_morty/custom_grid.dart';
import 'package:rick_and_morty/model/character.dart';
import 'package:rick_and_morty/model/episode.dart';
import 'package:rick_and_morty/theme_data.dart';
import 'api/api.dart';
import 'character_card.dart';
import 'dart:math' as math;

void main(List<String> args) {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: BrandTheme.defaultTheme,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var characterCardsData = <CharacterCardData>[];
  bool itemsInitialized = false;

  bool _loadingInPrgogress = false;
  String? _nextLoadingURL = null;

  Future<CharacterCardData> _loadCharacterCardData(
      Dio dio, Character character) async {
    var episodeAnswer = await dio.get(character.episode[0]);
    var episode = Episode.fromJson(episodeAnswer.data);
    return CharacterCardData(
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

    var charactersData = Stream.fromFutures(answer.characters
        .map((character) => _loadCharacterCardData(dio, character)));

    await for (var characterData in charactersData) {
      characterCardsData.add(characterData);
    }

    _nextLoadingURL = answer.info.next;
    itemsInitialized = true;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    initItems();
  }

  void _loadMore() async {
    if (_nextLoadingURL != null && !_loadingInPrgogress) {
      _loadingInPrgogress = true;
      Dio dio = Dio();
      //TODO
      // RestClient client = RestClient(dio);

      var answer = await dio.get(_nextLoadingURL!);
      var allCharacterAnswer = AllCharacterAnswer.fromJson(answer.data);

      var characters = Stream.fromFutures(allCharacterAnswer.characters
          .map((character) => _loadCharacterCardData(dio, character)));

      await for (var character in characters) {
        characterCardsData.add(character);
      }

      _nextLoadingURL = allCharacterAnswer.info.next;
      itemsInitialized = true;

      _loadingInPrgogress = false;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    MediaQuery.of(context).size;
    const double verticalPadding = 24;
    const double horizontalPadding = 8;

    const double bigPageCardHeight = 220;
    const double bigPageCardWidth = 600;

    const double smallPageCardHeight = 540;

    const double cardRadius = 16;

    const double spacing = 30;

    final Widget body;
    if (itemsInitialized) {
      body = SliverPadding(
        padding: const EdgeInsets.symmetric(
          vertical: verticalPadding,
          horizontal: horizontalPadding,
        ),
        sliver: MediaQuery.of(context).size.width >
                2 * horizontalPadding + bigPageCardWidth
            ? SliverBigPageBody(
                cardHeight: bigPageCardHeight,
                cardWidth: bigPageCardWidth,
                spacing: spacing,
                cardRadius: cardRadius,
                characterCardsData: characterCardsData,
              )
            : SliverSmallPageBody(
                cardHeight: smallPageCardHeight,
                spacing: spacing,
                cardRadius: cardRadius,
                characterCardsData: characterCardsData,
              ),
      );
    } else {
      body = const SliverFillRemaining(
        child: Center(
          child: CircularProgressIndicator(
            //TODO
            color: Colors.amber,
          ),
        ),
      );
    }
    return Scaffold(
      //TODO
      backgroundColor: const Color.fromARGB(255, 32, 35, 41),
      body: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification.metrics.pixels >=
              notification.metrics.maxScrollExtent / 2) {
            _loadMore();
          }
          // print("notification.metrics.atEdge: ${notification.metrics.atEdge}");
          return true;
        },
        child: CustomScrollView(
          slivers: [_genAppBar(), body],
        ),
      ),
    );
  }

  SliverAppBar _genAppBar() {
    return const SliverAppBar(
      expandedHeight: 400,
      collapsedHeight: 200,
      flexibleSpace: Center(
        child: Text(
          "The Rick and Morty",
          style: TextStyle(
              fontSize: 100, fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
      backgroundColor: Colors.white,
    );
  }
}

class SliverBigPageBody extends StatefulWidget {
  const SliverBigPageBody({
    Key? key,
    required this.characterCardsData,
    required this.cardHeight,
    required this.cardWidth,
    required this.spacing,
    required this.cardRadius,
  }) : super(key: key);

  final double cardHeight;
  final double cardWidth;
  final double spacing;
  final double cardRadius;

  final List<CharacterCardData> characterCardsData;
  @override
  State<SliverBigPageBody> createState() => _SliverBigPageBodyState();
}

class _SliverBigPageBodyState extends State<SliverBigPageBody> {
  @override
  Widget build(BuildContext context) {
    return SliverGrid(
      delegate: SliverChildBuilderDelegate(
        (context, index) => CharacterCard.horizontal(
            width: widget.cardWidth,
            height: widget.cardHeight,
            radius: widget.cardRadius,
            cardData: widget.characterCardsData[index]),
        childCount: widget.characterCardsData.length,
      ),
      gridDelegate: CustomSliverGridDelegate(
          height: widget.cardHeight,
          width: widget.cardWidth,
          spacing: widget.spacing),
    );
  }
}

class SliverSmallPageBody extends StatefulWidget {
  const SliverSmallPageBody(
      {Key? key,
      required this.characterCardsData,
      required this.cardHeight,
      required this.spacing,
      required this.cardRadius})
      : super(key: key);

  final double cardHeight;
  final double spacing;
  final double cardRadius;

  final List<CharacterCardData> characterCardsData;

  @override
  State<SliverSmallPageBody> createState() => _SliverSmallPageBodyState();
}

class _SliverSmallPageBodyState extends State<SliverSmallPageBody> {
  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          final int itemIndex = index ~/ 2;
          if (index.isEven) {
            //FIXME
            return CharacterCard.vertical(
              cardData: widget.characterCardsData[itemIndex],
              height: widget.cardHeight,
              radius: widget.cardRadius,
            );
          }
          return SizedBox(height: widget.spacing);
        },
        semanticIndexCallback: (Widget widget, int localIndex) {
          if (localIndex.isEven) {
            return localIndex ~/ 2;
          }
          return null;
        },
        childCount: math.max(0, widget.characterCardsData.length * 2 - 1),
      ),
    );
  }
}
