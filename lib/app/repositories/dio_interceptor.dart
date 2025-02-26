import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class DioInterceptor extends Interceptor {
  var user = '';

  DioInterceptor();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    //options.headers["Token-User"] = user.userLogado.value.tokenUser ?? "";
    debugPrint("INTERCEPTOR HEADERS ${options.headers}");
    debugPrint("INTERCEPTOR PATH ${options.path}");
    debugPrint("INTERCEPTOR URI ${options.uri}");
    debugPrint("INTERCEPTOR URI ${options.data}");
    debugPrint("INTERCEPTOR DATE ${DateTime.now()}");
    debugPrint("---------------------------------------------------------");
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    super.onError(err, handler);
    debugPrint("DioInterceptor Err: ${err.response}");
    debugPrint("DioInterceptor handler: ${handler.toString()}");
  }
}
