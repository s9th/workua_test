import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workua_test/data/models/gif_model.dart';
import 'package:workua_test/services/api_result.dart';
import 'package:workua_test/services/api_service.dart';
import 'package:workua_test/services/network_exceptions.dart';

abstract class ISearchRepositry {
  Future<ApiResult> loadSearchResults({
    required String query,
    int? offset,
  });
}

class SearchRepository implements ISearchRepositry {
  SearchRepository(Reader _reader) : _client = _reader(apiServiceProvider);
  final ApiService _client;

  @override
  Future<ApiResult> loadSearchResults({
    required String query,
    int? offset,
  }) async {
    try {
      final results = await _client.get('', queryParameters: {
        'offset': offset ?? 0,
        'q': query,
      });
      return ApiResult.success(data: GifList.fromJson(results));
    } catch (e) {
      return ApiResult.failure(
          error: NetworkException.getException(e).errorMessage);
    }
  }
}

final searchRepositoryProvider = Provider((ref) => SearchRepository(ref.read));
