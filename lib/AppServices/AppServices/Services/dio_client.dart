import 'package:dio/dio.dart';

import 'api_end_points.dart';

final Dio dio = Dio(
    BaseOptions(
  baseUrl: ApiEndPoints.baseUrl,
  contentType: 'application/json',
  connectTimeout: const Duration(
      milliseconds: 5000
  ),
  receiveTimeout: const Duration(
      milliseconds: 5000
  ),
    )
);


