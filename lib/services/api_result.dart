import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:workua_test/services/network_exceptions.dart';

part 'api_result.freezed.dart';

@freezed
class ApiResult<T> with _$ApiResult<T> {
  const factory ApiResult.success({required T data}) = Success<T>;
  const factory ApiResult.failure({required NetworkException error}) =
      Failure<T>;

  const ApiResult._();

  factory ApiResult.fromError(Object e) =>
      ApiResult.failure(error: NetworkException.getException(e));
}
