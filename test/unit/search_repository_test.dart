import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:workua_test/data/models/gif_model.dart';
import 'package:workua_test/data/repositories/search_repository.dart';
import 'package:workua_test/services/api_result.dart';

import 'package:workua_test/services/api_service.dart';

import 'search_repository_test.mocks.dart';

@GenerateMocks([ApiService])
void main() {
  final mockApiService = MockApiService();
  final container = ProviderContainer(
      overrides: [apiServiceProvider.overrideWithValue(mockApiService)]);

  group('Search repository', () {
    test('executes a search and returns a result', () async {
      const query = 'test';
      const positiveResult = {'data': [], 'pagination': {}};

      when(mockApiService.get('', queryParameters: {
        'offset': 0,
        'q': query,
      })).thenAnswer((_) async => positiveResult);
      final results = await container
          .read(searchRepositoryProvider)
          .loadSearchResults(query: query);
      expect(
          results,
          ApiResult<dynamic>.success(
            data: GifList.fromJson(positiveResult),
          ));
      verify(mockApiService.get('', queryParameters: {
        'offset': 0,
        'q': query,
      })).called(1);
    });
    test('returns an error message in case of an exception', () async {
      const query = 'test';
      final _apiError = DioError(
          requestOptions: RequestOptions(path: '/foo'),
          type: DioErrorType.response,
          response: Response(
            requestOptions: RequestOptions(path: '/foo'),
            statusCode: 400,
          ));
      when(mockApiService.get('', queryParameters: {
        'offset': 0,
        'q': query,
      })).thenThrow(_apiError);
      final results = await container
          .read(searchRepositoryProvider)
          .loadSearchResults(query: query);
      expect(
          results,
          const ApiResult<dynamic>.failure(
            error: 'Bad request',
          ));
    });
  });
}
