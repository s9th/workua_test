import 'dart:io';

import 'package:dio/dio.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'network_exceptions.freezed.dart';

@freezed
class NetworkException with _$NetworkException {
  const NetworkException._();

  const factory NetworkException.requestCancelled() = _RequestCancelled;

  const factory NetworkException.unauthorisedRequest() = _UnauthorisedRequest;

  const factory NetworkException.badRequest() = _BadRequest;

  const factory NetworkException.notFound(String reason) = _NotFound;

  const factory NetworkException.methodNotAllowed() = _MethodNotAllowed;

  const factory NetworkException.notAcceptable() = _NotAcceptable;

  const factory NetworkException.requestTimeout() = _RequestTimeout;

  const factory NetworkException.sendTimeout() = _SendTimeout;

  const factory NetworkException.conflict() = _Conflict;

  const factory NetworkException.internalServerError() = _InternalServerError;

  const factory NetworkException.notImplemented() = _NotImplemented;

  const factory NetworkException.serviceUnavailable() = _ServiceUnavailable;

  const factory NetworkException.noInternetConnection() = _NoInternetConnection;

  const factory NetworkException.formatException() = _FormatException;

  const factory NetworkException.unableToProcess() = _UnableToProcess;

  const factory NetworkException.defaultError(String error) = _DefaultError;

  const factory NetworkException.unexpectedError() = _UnexpectedError;

  factory NetworkException.getException(error) {
    if (error is Exception) {
      try {
        if (error is DioError) {
          switch (error.type) {
            case DioErrorType.cancel:
              return const NetworkException.requestCancelled();
            case DioErrorType.connectTimeout:
              return const NetworkException.requestTimeout();
            case DioErrorType.other:
              return const NetworkException.noInternetConnection();
            case DioErrorType.receiveTimeout:
              return const NetworkException.sendTimeout();
            case DioErrorType.response:
              switch (error.response?.statusCode) {
                case 400:
                  return const NetworkException.badRequest();
                case 401:
                  return const NetworkException.unauthorisedRequest();
                case 403:
                  return const NetworkException.unauthorisedRequest();
                case 404:
                  return const NetworkException.notFound('Not found');
                case 405:
                  return const NetworkException.methodNotAllowed();
                case 406:
                  return const NetworkException.notAcceptable();
                case 409:
                  return const NetworkException.conflict();
                case 408:
                  return const NetworkException.requestTimeout();
                case 500:
                  return const NetworkException.internalServerError();
                case 501:
                  return const NetworkException.notImplemented();
                case 503:
                  return const NetworkException.serviceUnavailable();
                default:
                  final responseCode = error.response?.statusCode;
                  return NetworkException.defaultError(
                    'Received invalid status code: $responseCode',
                  );
              }
            case DioErrorType.sendTimeout:
              return const NetworkException.sendTimeout();
          }
        } else if (error is SocketException) {
          return const NetworkException.noInternetConnection();
        } else if (error is FormatException) {
          return const NetworkException.formatException();
        } else {
          return const NetworkException.unexpectedError();
        }
      } on FormatException {
        return const NetworkException.formatException();
      } catch (_) {
        return const NetworkException.unexpectedError();
      }
    } else {
      if (error.toString().contains('is not a subtype of')) {
        return const NetworkException.unableToProcess();
      } else {
        return const NetworkException.unexpectedError();
      }
    }
  }

  String get errorMessage => when(
        notImplemented: () => 'Not Implemented',
        requestCancelled: () => 'Request Cancelled',
        internalServerError: () => 'Internal Server Error',
        notFound: (String reason) => reason,
        serviceUnavailable: () => 'Service unavailable',
        methodNotAllowed: () => 'Method not allowed',
        badRequest: () => 'Bad request',
        unauthorisedRequest: () => 'Unauthorised request',
        unexpectedError: () => 'Unexpected error occurred',
        requestTimeout: () => 'Connection request timeout',
        noInternetConnection: () => 'No internet connection',
        conflict: () => 'Error due to a conflict',
        sendTimeout: () => 'Send timeout connnecting with API server',
        unableToProcess: () => 'Unable to process the data',
        defaultError: (String error) => error,
        formatException: () => 'Unexpected error occurred',
        notAcceptable: () => 'Not acceptable',
      );
}
