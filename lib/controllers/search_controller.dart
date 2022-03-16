import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workua_test/data/models/gif_model.dart';
import 'package:workua_test/data/repositories/search_repository.dart';

class SearchController extends StateNotifier<AsyncValue<GifList>> {
  SearchController(Reader _reader)
      : _repository = _reader(searchRepositoryProvider),
        super(const AsyncValue.loading());

  final ISearchRepositry _repository;
  String _query = '';

  Future<void> search(String query) async {
    state = const AsyncValue.loading();
    _query = query;
    final _gifList = await _repository.loadSearchResults(query: query);
    _gifList.when(
      success: (results) {
        state = AsyncValue.data(results);
      },
      failure: (error) {
        state = AsyncValue.error(error.errorMessage);
      },
    );
  }

  Future<void> loadMore() async {
    state.whenData(
      (value) async {
        if (value.totalCount - value.offset >= value.count) {
          final _addedGifList = await _repository.loadSearchResults(
            query: _query,
            offset: value.offset + value.count,
          );
          _addedGifList.when(
            success: (results) {
              if (results.gifs.isNotEmpty) {
                state = AsyncValue.data(
                  value.copyWith(
                    offset: results.offset,
                    totalCount: results.totalCount,
                    count: results.count,
                    gifs: [...value.gifs, ...results.gifs],
                  ),
                );
              }
            },
            failure: (error) {
              state = AsyncValue.error(error.errorMessage);
            },
          );
        }
      },
    );
  }
}

final searchControllerProvider =
    StateNotifierProvider<SearchController, AsyncValue<GifList>>(
  (ref) => SearchController(ref.read),
);
