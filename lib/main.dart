import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:rick_and_morty/custom_grid.dart';
import 'package:rick_and_morty/model/character.dart';
import 'package:rick_and_morty/model/episode.dart';
import 'package:dartx/dartx.dart';
import 'api/api.dart';

void main(List<String> args) {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: TestPage(),
    );
  }
}

class TestPage extends StatefulWidget {
  const TestPage({Key? key}) : super(key: key);

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  var items = <Widget>[];

  Future<void> initItems() async {
    Dio dio = Dio();
    RestClient client = RestClient(dio);
    var answer = await client.getAllCharacters();
    for (var character in answer.characters) {
      var episode_answer = await dio.get(character.episode[0]);
      var episode = Episode.fromJson(episode_answer.data);

      items.add(_generateCharacterCard(character, episode));
    }
    print("Completed!");
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
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return Container(
                    color: Colors.amber,
                  );
                },
              ),
              gridDelegate: CustomSliverGridDelegate(
                  height: 220, width: 600, spacing: 30),
            ),
          )
        ],
      ),
    );
  }

  static Card _generateCharacterCard(Character character, Episode episode) {
    final Color color;
    if (character.status == "Alive") {
      color = Colors.green;
    } else if (character.status == "Dead") {
      color = Colors.red;
    } else if (character.status == "unknown") {
      color = Colors.grey[400]!;
    } else {
      var status = character.status;
      throw "unexpected error no such status: '$status'";
    }
    var status = character.status.capitalize();

    var species = character.species;

    return Card(
      color: Colors.grey,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 24),
            child: Image.network(character.image),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(),
                Text(
                  character.name,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 28, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Icon(
                        Icons.circle,
                        color: color,
                        size: 10,
                      ),
                    ),
                    Text("$status - $species",
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 16)),
                  ],
                ),
                const Spacer(),
                const Text("Last known location:",
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 16)),
                Text(character.location.name,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 20)),
                const Spacer(),
                const Text("First seen in:",
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 16)),
                Text(episode.name,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 20)),
                const Spacer(),
              ],
            ),
          ),
        ],
      ),
    );

    return Card(
      color: Color(Random().nextInt(0xFFFFFFFF)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Image.network(
            "https://rickandmortyapi.com/api/character/avatar/422.jpeg",
            // fit: BoxFit.scaleDown,
          ),
          const Expanded(
            flex: 3,
            child: Text(
              "Some name",
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return GridView.extent(
      maxCrossAxisExtent: 800,
      children: [
        for (int i = 1; i < 10; i++)
          FutureBuilder(
            future: _getCharacterAndGenerateCard(i),
            builder: (context, snapshot) =>
                snapshot.connectionState == ConnectionState.done
                    ? snapshot.data as Widget
                    : const Center(child: CircularProgressIndicator()),
          )
      ],
    );
    return Scaffold(
        body: GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                mainAxisSpacing: 8, crossAxisSpacing: 8, crossAxisCount: 2),
            itemBuilder: (context, index) {
              // return SizedBox(
              //   height: 100,
              //   width: 300,
              //   child: Center(child: Text("$index")),
              // );
              return FutureBuilder(
                future: _getCharacterAndGenerateCard(index),
                builder: (context, snapshot) =>
                    snapshot.connectionState == ConnectionState.done
                        ? snapshot.data as Widget
                        : const Center(child: CircularProgressIndicator()),
              );
            }
            //   body: Center(
            // child: Row(
            //   children: [
            //     FutureBuilder(
            //       future: _getCharacterAndGenerateCard(127),
            //       builder: (context, snapshot) =>
            //           snapshot.connectionState == ConnectionState.done
            //               ? snapshot.data as Widget
            //               : const Center(child: CircularProgressIndicator()),
            //     ),
            //   ],
            // ),
            )
        // GridView.builder(
        //   padding: const EdgeInsets.all(8),
        //   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        //       mainAxisSpacing: 8, crossAxisSpacing: 8, crossAxisCount: 2),
        //   itemBuilder: (context, index) {
        //     return GridTile(
        //         child: Container(
        //             color: Colors.amber, child: Center(child: Text("$index"))));
        //   },
        );
  }

  Future<Widget> _getCharacterAndGenerateCard(int id) async {
    final dio = Dio();
    final client = RestClient(dio);
    var character = await client.getCharacter(id);

    var episode = await dio
        .get(character.episode[0])
        .then((value) => Episode.fromJson(value.data));

    return _genCharacterCard(character, episode);
  }

  Future<Widget> _genCharacterCard(Character character, Episode episode) async {
    final Color color;
    if (character.status == "Alive") {
      color = Colors.green;
    } else if (character.status == "Dead") {
      color = Colors.red;
    } else if (character.status == "unknown") {
      color = Colors.grey[400]!;
    } else {
      var status = character.status;
      throw "unexpected error no such status: '$status'";
    }
    var status = character.status.capitalize();

    var species = character.species;

    return Card(
      color: Colors.grey,
      child: LimitedBox(
        maxHeight: 220,
        maxWidth: 600,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 24),
              child: Image.network(character.image),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(),
                  Text(
                    character.name,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: Icon(
                          Icons.circle,
                          color: color,
                          size: 10,
                        ),
                      ),
                      Text("$status - $species",
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                  const Spacer(),
                  const Text("Last known location:",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 16)),
                  Text(character.location.name,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 20)),
                  const Spacer(),
                  const Text("First seen in:",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 16)),
                  Text(episode.name,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 20)),
                  const Spacer(),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    // return Text("Data");
  }
}

// import 'package:flutter/material.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);

//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         // This is the theme of your application.
//         //
//         // Try running your application with "flutter run". You'll see the
//         // application has a blue toolbar. Then, without quitting the app, try
//         // changing the primarySwatch below to Colors.green and then invoke
//         // "hot reload" (press "r" in the console where you ran "flutter run",
//         // or simply save your changes to "hot reload" in a Flutter IDE).
//         // Notice that the counter didn't reset back to zero; the application
//         // is not restarted.
//         primarySwatch: Colors.blue,
//       ),
//       home: const MyHomePage(title: 'Flutter Demo Home Page'),
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({Key? key, required this.title}) : super(key: key);

//   // This widget is the home page of your application. It is stateful, meaning
//   // that it has a State object (defined below) that contains fields that affect
//   // how it looks.

//   // This class is the configuration for the state. It holds the values (in this
//   // case the title) provided by the parent (in this case the App widget) and
//   // used by the build method of the State. Fields in a Widget subclass are
//   // always marked "final".

//   final String title;

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   int _counter = 0;

//   void _incrementCounter() {
//     setState(() {
//       // This call to setState tells the Flutter framework that something has
//       // changed in this State, which causes it to rerun the build method below
//       // so that the display can reflect the updated values. If we changed
//       // _counter without calling setState(), then the build method would not be
//       // called again, and so nothing would appear to happen.
//       _counter++;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     // This method is rerun every time setState is called, for instance as done
//     // by the _incrementCounter method above.
//     //
//     // The Flutter framework has been optimized to make rerunning build methods
//     // fast, so that you can just rebuild anything that needs updating rather
//     // than having to individually change instances of widgets.
//     return Scaffold(
//       appBar: AppBar(
//         // Here we take the value from the MyHomePage object that was created by
//         // the App.build method, and use it to set our appbar title.
//         title: Text(widget.title),
//       ),
//       body: Center(
//         // Center is a layout widget. It takes a single child and positions it
//         // in the middle of the parent.
//         child: Column(
//           // Column is also a layout widget. It takes a list of children and
//           // arranges them vertically. By default, it sizes itself to fit its
//           // children horizontally, and tries to be as tall as its parent.
//           //
//           // Invoke "debug painting" (press "p" in the console, choose the
//           // "Toggle Debug Paint" action from the Flutter Inspector in Android
//           // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
//           // to see the wireframe for each widget.
//           //
//           // Column has various properties to control how it sizes itself and
//           // how it positions its children. Here we use mainAxisAlignment to
//           // center the children vertically; the main axis here is the vertical
//           // axis because Columns are vertical (the cross axis would be
//           // horizontal).
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             const Text(
//               'You have pushed the button this many times:',
//             ),
//             Text(
//               '$_counter',
//               style: Theme.of(context).textTheme.headline4,
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _incrementCounter,
//         tooltip: 'Increment',
//         child: const Icon(Icons.add),
//       ), // This trailing comma makes auto-formatting nicer for build methods.
//     );
//   }
// }
