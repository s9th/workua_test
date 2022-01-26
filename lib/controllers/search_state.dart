import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:workua_test/data/models/gif_model.dart';

part 'search_state.freezed.dart';

@freezed
class SearchState with _$SearchState {
  factory SearchState.initial() = _SearchStateInitial;
  factory SearchState.loading() = _SearchStateLoading;
  factory SearchState.loaded({
    required GifList gifs,
  }) = _SearchStateLoaded;
  factory SearchState.error(String error) = _SearchStateError;
}
