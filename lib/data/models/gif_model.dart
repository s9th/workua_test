import 'package:freezed_annotation/freezed_annotation.dart';

part 'gif_model.freezed.dart';

@freezed
class Gif with _$Gif {
  factory Gif({required String url}) = _Gif;

  factory Gif.fromJson(Map<String, dynamic> map) {
    return Gif(
      url: ((map['images'] as Map)['preview_gif'] as Map)['url'] as String,
    );
  }
}

@freezed
class GifList with _$GifList {
  factory GifList({
    required List<Gif> gifs,
    required int count,
    required int offset,
    required int totalCount,
  }) = _GifList;

  factory GifList.fromJson(Map<String, dynamic> map) {
    final _result = GifList(
      gifs: (map['data'] as List)
          .map((e) => e as Map<String, dynamic>)
          .map(Gif.fromJson)
          .toList(),
      offset: (map['pagination'] as Map)['offset'] ?? 0,
      count: (map['pagination'] as Map)['count'] ?? 0,
      totalCount: (map['pagination'] as Map)['total_count'] ?? 0,
    );
    return _result;
  }
}
