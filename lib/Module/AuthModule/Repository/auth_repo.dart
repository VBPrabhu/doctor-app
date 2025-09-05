import 'package:doctorapp/AppServices/AppServices/Services/api_end_points.dart';
import 'package:doctorapp/AppServices/AppServices/Services/network_api_service.dart';
import 'package:flutter/foundation.dart';

class AuthRepo {
  NetworkApiService apiService = NetworkApiService();
  Future<dynamic> login({jsonBody}) async {
    try {
      final response =
          await apiService.postResponse(ApiEndPoints.login, jsonBody);

      if (response != null) {
        return response;
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<dynamic> signUp({jsonBody}) async {
    try {
      final response =
          await apiService.postResponse(ApiEndPoints.register, jsonBody);

      if (response != null) {
        return response;
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  Future<dynamic> verifyOtp({jsonBody}) async {
    try {
      final response =
          await apiService.postResponse(ApiEndPoints.verifyOtp, jsonBody);

      if (response != null) {
        return response;
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  Future<dynamic> fetchOtp({email}) async {
    try {
      final response = await apiService.getResponse(ApiEndPoints.verifyOtp + email);


      if (response != null) {
        return response;
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }
}
