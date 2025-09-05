import 'dart:async';
import 'package:doctorapp/AppCommon/app_constant.dart';
import 'package:doctorapp/Utils/get_it.dart';
import 'package:doctorapp/Utils/shared_preferance.dart';
import '../Models/error_model.dart';
import 'package:dio/dio.dart';
import 'base_api_services.dart';
import 'dio_client.dart';

class NetworkApiService extends BaseApiService {
  @override
  Future getResponse(String url, {Map<String, dynamic>? queryParameter}) async {
    token = await getIt<SharedPref>()
        .getString(key: getIt<SharedPref>().accessToken);

    try {
      final response = await dio.get(url,
          queryParameters: queryParameter,
          options: token != null
              ? Options(
                  contentType: 'application/json; charset=UTF-8',
                  headers: {'Authorization': "Bearer $token"})
              : null);
      return returnResponse(response);
    } on DioException catch (error) {
      return {
        "success": error.response?.data["success"],
        "message": error.response?.data["message"],
        "data": error.response?.data["data"]
      };
    }
  }

  @override
  Future postResponse(String url, dynamic jsonBody, {Options? options}) async {
    // token = await getIt<SharedPref>().getString(key: getIt<SharedPref>().accessToken);

    try {
      final response = await dio.post(url,
          data: jsonBody,
          options: token != null
              ? Options(
                  contentType: 'application/json; charset=UTF-8',
                  headers: {'Authorization': "Bearer $token"})
              : null);

      return returnResponse(response);
    } on DioException catch (error) {
      return {
        "success": error.response?.data["success"],
        "message": error.response?.data["message"],
        "data": error.response?.data["data"]
      };
    }
  }

  dynamic returnResponse(Response response) {
    switch (response.statusCode) {
      case 200:
        CommonModel commonModel = CommonModel.fromJson(response.data);
        return {
          "success": commonModel.success,
          "message": commonModel.message,
          "data": commonModel.data
        };

        case 201:
        CommonModel commonModel = CommonModel.fromJson(response.data);
        return {
          "success": commonModel.success,
          "message": commonModel.message,
          "data": commonModel.data
        };
    }
  }

  @override
  Future putResponse(String url, jsonBody) async {
    // token = await  SharedPref.getString(key: "accessToken");
    token = await getIt<SharedPref>()
        .getString(key: getIt<SharedPref>().accessToken);
    try {
      final response = await dio.put(url,
          data: jsonBody,
          options: token != null
              ? Options(
                  contentType: 'application/json; charset=UTF-8',
                  headers: {'Authorization': "Bearer $token"})
              : null);
      return returnResponse(response);
    } on DioException catch (error) {
      return {
        "success": error.response?.data["success"],
        "message": error.response?.data["message"],
        "data": error.response?.data["data"]
      };
    }
  }

  @override
  Future deleteResponse(String url) async {
    token = await getIt<SharedPref>()
        .getString(key: getIt<SharedPref>().accessToken);

    try {
      final response = await dio.delete(url,
          options: token != null
              ? Options(
                  contentType: 'application/json; charset=UTF-8',
                  headers: {'Authorization': "Bearer $token"})
              : null);
      return returnResponse(response);
    } on DioException catch (error) {
      return {
        "success": error.response?.data["success"],
        "message": error.response?.data["message"],
        "data": error.response?.data["data"]
      };
    }
  }
}
