import 'package:dio/dio.dart';

import 'dio_interceptor.dart';

class DioCustom {
  final _dio = Dio();

  DioCustom() {
    _dio.options.baseUrl = "";
    _dio.interceptors.add(DioInterceptor());
  }

  Dio get dio => _dio;
}
