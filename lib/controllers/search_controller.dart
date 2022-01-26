import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workua_test/controllers/search_state.dart';
import 'package:workua_test/data/models/gif_model.dart';
import 'package:workua_test/data/repositories/search_repository.dart';

class SearchController extends StateNotifier<SearchState> {
  SearchController(Reader _reader)
      : _repository = _reader(searchRepositoryProvider),
        super(SearchState.initial());

  final ISearchRepositry _repository;
  String _query = '';

  Future<void> search(String query) async {
    state = SearchState.loading();
    _query = query;
    final _gifList = await _repository.loadSearchResults(query: query);
    _gifList.when(
      success: (results) {
        state = SearchState.loaded(gifs: results);
      },
      failure: (error) {
        state = SearchState.error(error.errorMessage);
      },
    );
  }

  Future<void> loadMore() async {
    await state.maybeWhen(
      loaded: (gifList) async {
        if (gifList.totalCount - gifList.offset >= gifList.count) {
          final _addedGifList = await _repository.loadSearchResults(
            query: _query,
            offset: gifList.offset + gifList.count,
          );
          _addedGifList.when(
            success: (results) {
              if ((results as GifList).gifs.isNotEmpty) {
                state = SearchState.loaded(
                  gifs: gifList.copyWith(
                    offset: results.offset,
                    totalCount: results.totalCount,
                    count: results.count,
                    gifs: [...gifList.gifs, ...results.gifs],
                  ),
                );
              }
            },
            failure: (error) {
              state = SearchState.error(error.errorMessage);
            },
          );
        }
      },
      orElse: () => null,
    );
  }
}

final searchControllerProvider =
    StateNotifierProvider<SearchController, SearchState>(
  (ref) => SearchController(ref.read),
);
