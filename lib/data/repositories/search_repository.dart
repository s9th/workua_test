import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workua_test/data/models/gif_model.dart';
import 'package:workua_test/services/api_result.dart';
import 'package:workua_test/services/api_service.dart';

// ignore: one_member_abstracts
abstract class ISearchRepositry {
  Future<ApiResult<GifList>> loadSearchResults({
    required String query,
    int? offset,
  });
}

class SearchRepository implements ISearchRepositry {
  SearchRepository(Reader _reader) : _client = _reader(apiServiceProvider);
  final ApiService _client;

  @override
  Future<ApiResult<GifList>> loadSearchResults({
    required String query,
    int? offset,
  }) async {
    return ApiResult.guard(() async {
      final results = await _client.get(
        '',
        queryParameters: {
          'offset': offset ?? 0,
          'q': query,
        },
      );
      return GifList.fromJson(results);
    });
  }
}

final searchRepositoryProvider = Provider((ref) => SearchRepository(ref.read));
