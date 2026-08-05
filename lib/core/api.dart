import 'package:dio/dio.dart';

class AzamApi {
  final Dio dio;
  AzamApi(String baseUrl, String token)
      : dio = Dio(BaseOptions(
          baseUrl: baseUrl,
          headers: {'X-Azam-Token': token},
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 20),
        ));
}
