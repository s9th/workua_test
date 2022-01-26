import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ApiService {
  ApiService() {
    _dio.options = getOptions();
  }

  final _dio = Dio();

  BaseOptions getOptions() {
    final options = BaseOptions()
      ..baseUrl = 'https://api.giphy.com/v1/gifs/search'
      ..connectTimeout = 10000;
    return options;
  }

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map? data,
    Function? errorCallback,
  }) {
    return request(
      path,
      method: 'get',
      queryParameters: queryParameters,
      data: data,
      errorCallback: errorCallback,
    );
  }

  Future<dynamic> post(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map? data,
    Function? errorCallback,
  }) {
    return request(
      path,
      method: 'post',
      queryParameters: queryParameters,
      data: data,
      errorCallback: errorCallback,
    );
  }

  Future<dynamic> request(
    String path, {
    required String method,
    Map<String, dynamic>? queryParameters,
    Map? data,
    Function? errorCallback,
  }) async {
    final response = await _dio.request(
      path,
      data: data,
      options: Options(method: method),
      queryParameters: (queryParameters ?? {})
        ..putIfAbsent('api_key', () => '7qiN8opzNhetYLvxwntzF8lEFMeky8Yn'),
    );
    return response.data;
  }
}

final apiServiceProvider = Provider((ref) {
  return ApiService();
});
