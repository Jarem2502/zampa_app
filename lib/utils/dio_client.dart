import 'package:dio/dio.dart';

class DioClient {
  static final Dio dio = Dio(BaseOptions(
      baseUrl: 'https://digi-api.com/api/v1/digimon?pageSize=50',
      headers: {'Content-Type': 'application/json'}));
}