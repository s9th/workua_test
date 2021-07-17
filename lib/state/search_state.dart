import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:workua_test/data/models/gif_model.dart';
import 'package:workua_test/data/repositories/search_repository.dart';

part 'search_state.freezed.dart';

@freezed
class SearchState with _$SearchState {
  factory SearchState.initial() = _SearchStateInitial;
  factory SearchState.loading() = _SearchStateLoading;
  factory SearchState.loaded({
    required GifList gifs,
  }) = _SearchStateLoaded;
  factory SearchState.error(String error) = _SearchStateError;
  factory SearchState.empty() = _SearchStateEmpty;
}

class SearchStateNotifier extends StateNotifier<SearchState> {
  SearchStateNotifier(Reader _reader)
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
        if ((results as GifList).gifs.isNotEmpty) {
          state = SearchState.loaded(gifs: results);
        } else {
          state = SearchState.empty();
        }
      },
      failure: (error) {
        state = SearchState.error(error);
      },
    );
  }

  Future<void> loadMore() async {
    await state.maybeWhen(loaded: (gifList) async {
      if (gifList.totalCount - gifList.offset >= gifList.count) {
        final _addedGifList = await _repository.loadSearchResults(
            query: _query, offset: gifList.offset + gifList.count);
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
            state = SearchState.error(error);
          },
        );
      }
    }, orElse: () {
      return;
    });
  }
}

final searchStateNotifierProvider =
    StateNotifierProvider<SearchStateNotifier, SearchState>(
        (ref) => SearchStateNotifier(ref.read));
