import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workua_test/controllers/search_controller.dart';
import 'package:workua_test/controllers/search_state.dart';
import 'package:workua_test/ui/shimmer_placeholder.dart';

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

class HomePage extends ConsumerStatefulWidget {
  const HomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final _searchTextController = TextEditingController();

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
    ref.listen<SearchState>(searchControllerProvider, (_, state) {
      state.maybeWhen(
        error: (message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
        },
        orElse: () {},
      );
    });
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        title: TextField(
          onSubmitted: _search,
          controller: _searchTextController,
          decoration: InputDecoration(
            hintText: 'Search Giphy',
            hintStyle: const TextStyle(
              color: Colors.grey,
              fontStyle: FontStyle.italic,
            ),
            suffixIcon: IconButton(
              icon: const Icon(Icons.access_alarms),
              onPressed: () {
                FocusScope.of(context).unfocus();
                _search(_searchTextController.text.trim());
              },
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref
              .read(searchControllerProvider.notifier)
              .search(_searchTextController.text.trim());
        },
        child: Consumer(
          builder: (context, watch, child) {
            final state = ref.watch(searchControllerProvider);

            return state.maybeWhen(
              loading: () => const Center(child: CircularProgressIndicator()),
              loaded: (gifList) {
                if (gifList.gifs.isEmpty) {
                  return const Center(
                    child: Text('Nothing was found. Try changing your query'),
                  );
                }
                return GridView.builder(
                  itemCount: gifList.gifs.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: MediaQuery.of(context).orientation ==
                            Orientation.portrait
                        ? 4
                        : 3,
                    childAspectRatio: 1.5,
                    crossAxisSpacing: 2,
                    mainAxisSpacing: 2,
                  ),
                  itemBuilder: (context, index) {
                    if (index >= gifList.gifs.length - 2) {
                      ref.read(searchControllerProvider.notifier).loadMore();
                      return const ShimmerPlaceholder();
                    }
                    return CachedNetworkImage(
                      imageUrl: gifList.gifs[index].url,
                      placeholder: (context, _) => const ShimmerPlaceholder(),
                      fit: BoxFit.cover,
                    );
                  },
                );
              },
              orElse: () => const SizedBox(),
            );
          },
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void _search(String value) {
    final _query = value.trim();
    if (_query.isNotEmpty) {
      ref.read(searchControllerProvider.notifier).search(_query);
    }
  }
}
