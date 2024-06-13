import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "My Application",
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.greenAccent),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
  var favorites = <WordPair>[];
  var history = <WordPair>[]; // tambahkan ini untuk history

  void getNext() {
    current = WordPair.random();
    history.add(current); // tambahkan ke history
    notifyListeners();
  }

  void toggleFavorite(WordPair pair) {
    if (favorites.contains(pair)) {
      favorites.remove(pair);
    } else {
      favorites.add(pair);
    }
    notifyListeners();
  }

  void clearHistory() {
    history.clear();
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // index untuk bottom navigation bar
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    // kondisi untuk pindah page
    switch (selectedIndex) {
      case 0:
        page = const GeneratorPage();
        break;
      case 1:
        page = const FavoritePage();
        break;
      case 2:
        page = const HistoryPage();
        break;
      default:
        page = const Placeholder();
    }

    return Scaffold(
      backgroundColor: Color(0xffF1F8E8),
      bottomNavigationBar: NavigationBar(
        // user nge tap tombol akan menjalankan on destination
        onDestinationSelected: (value) {
          setState(() {
            selectedIndex = value;
          });
        },
        // tambahkan selected index
        selectedIndex: selectedIndex,
        destinations: const [
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.favorite),
            icon: Icon(Icons.favorite_border_outlined),
            label: 'Favorite',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.history),
            icon: Icon(Icons.history),
            label: 'History',
          ),
        ],
      ),
      body: Container(
        child: page,
      ),
    );
  }
}

class GeneratorPage extends StatelessWidget {
  const GeneratorPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    // buat icon yang beriis tipe data icon, ketik afavorit sudah ada kata-kata yang ditampilkan, maka setnya akan di set favorit
    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/wordle.json',
            width: 300,
            height: 200,
          ),
          Text("Guess Random Words !"),
          BigCard(pair: pair),
          Row(
            // button di tengah
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  appState.getNext();
                },
                child: Text("Next Word"),
              ),
              SizedBox(
                width: 10,
              ),
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavorite(pair);
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      SnackBar(
                        content: Text("It's ${appState.current}!"),
                      ),
                    );
                },
                label: Text("Favorite"),
                icon: Icon(icon),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.primary,
      fontSize: 60,
    );

    return Card(
      color: Color(0xffF1F8E8),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Text(
          pair.asLowerCase,
          style: style,
        ),
      ),
    );
  }
}

class FavoritePage extends StatelessWidget {
  const FavoritePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Container(
      child: Padding(
        padding: EdgeInsets.only(left: 25, right: 25, top: 20),
        child: ListView(
          children: [
            Text(
              "Your Favorite Words",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 20),
            // Menampilkan daftar favorit
            ...appState.favorites.map(
              (wp) => Card(
                color: Color(0xffD8EFD3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ListTile(
                  title: Text(wp.asCamelCase),
                  onTap: () {
                    appState.toggleFavorite(wp); // Hapus kata favorit
                  },
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              "You have ${appState.favorites.length} favorite words",
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class HistoryPage extends StatelessWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Scaffold(
      appBar: AppBar(
        title: Text('History'),
      ),
      body: ListView.builder(
        itemCount: appState.history.length,
        itemBuilder: (context, index) {
          var word = appState.history[index];
          return Card(
            color: Color(0xffD8EFD3),
            margin: EdgeInsets.symmetric(
                vertical: 5,
                horizontal: 10), // Margin untuk memberikan jarak antar card
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15), // Membuat rounded corner
            ),
            elevation: 3, // Shadow elevation
            child: ListTile(
              title: Text(word.asUpperCase),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("It's ${word.asPascalCase}!"),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          appState.clearHistory();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Cleared all history."),
            ),
          );
        },
        backgroundColor: Color(0xffD8EFD3),
        foregroundColor: Color(0xff55AD9B),
        child: Icon(Icons.delete),
      ),
    );
  }
}
