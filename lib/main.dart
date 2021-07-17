import 'package:cached_network_image/cached_network_image.dart';
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
          onSubmitted: (value) async {
            _search(value);
          },
          controller: _searchTextController,
          decoration: InputDecoration(
            hintText: 'Search Giphy',
            hintStyle: const TextStyle(
                color: Colors.grey, fontStyle: FontStyle.italic),
            suffixIcon: IconButton(
              icon: const Icon(Icons.search),
              onPressed: () async {
                FocusScope.of(context).unfocus();
                _search(_searchTextController.text.trim());
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
                              .loadMore();
                          return const ShimmerPlaceholder();
                        }
                        return CachedNetworkImage(
                          imageUrl: gifList.gifs[index].url,
                          placeholder: (context, _) =>
                              const ShimmerPlaceholder(),
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

  void _search(String value) async {
    final _query = value.trim();
    if (_query.isNotEmpty) {
      await context.read(searchStateNotifierProvider.notifier).search(_query);
    }
  }
}

class ShimmerPlaceholder extends StatelessWidget {
  const ShimmerPlaceholder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      color: Colors.white,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
        ),
      ),
    );
  }
}
