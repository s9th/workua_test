import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:workua_test/state/search_state.dart';

void main() {
  runApp(const ProviderScope(child: GiphySearchApp()));
}

class GiphySearchApp extends StatelessWidget {
  const GiphySearchApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Giphy Search',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const HomePage(title: 'Giphy Search'),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _searchTextController = TextEditingController();
  int oldLength = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _searchTextController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        title: TextField(
          controller: _searchTextController,
          decoration: InputDecoration(
            hintText: 'Enter the search query',
            hintStyle: const TextStyle(
                color: Colors.grey, fontStyle: FontStyle.italic),
            suffixIcon: IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                FocusScope.of(context).unfocus();
                final _query = _searchTextController.text.trim();
                if (_query.isNotEmpty) {
                  context
                      .read(searchStateNotifierProvider.notifier)
                      .search(_query);
                }
              },
            ),
          ),
        ),
      ),
      body: ProviderListener<SearchState>(
        provider: searchStateNotifierProvider,
        onChange: (context, state) {
          state.maybeWhen(
            error: (message) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(message)),
              );
            },
            orElse: () {},
          );
        },
        child: RefreshIndicator(
          onRefresh: () async {
            await context
                .read(searchStateNotifierProvider.notifier)
                .search(_searchTextController.text.trim());
          },
          child: Consumer(
            builder: (context, watch, child) {
              final state = watch(searchStateNotifierProvider);

              return state.maybeWhen(
                loading: () => const Center(child: CircularProgressIndicator()),
                empty: () => const Center(
                  child: Text('Nothing was found. Try changing your query'),
                ),
                loaded: (gifList) {
                  oldLength = gifList.gifs.length;

                  return GridView.builder(
                      itemCount: gifList.gifs.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: MediaQuery.of(context).orientation ==
                                Orientation.portrait
                            ? 2
                            : 3,
                        childAspectRatio: 1.5,
                        crossAxisSpacing: 2,
                        mainAxisSpacing: 2,
                      ),
                      itemBuilder: (context, index) {
                        if (index >= gifList.gifs.length - 2) {
                          context
                              .read(searchStateNotifierProvider.notifier)
                              .loadMore(_searchTextController.text.trim());
                          return ClipRRect(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(32)),
                            child: Shimmer(
                                color: Colors.white,
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.circular(32)),
                                )),
                          );
                        }
                        return Image.network(
                          gifList.gifs[index].url,
                          fit: BoxFit.cover,
                        );
                      });
                },
                orElse: () => const SizedBox(),
              );
            },
          ),
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
