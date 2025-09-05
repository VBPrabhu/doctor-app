abstract class BaseApiService {
  Future<dynamic> getResponse(String url);
  Future<dynamic> postResponse(String url,dynamic jsonBody);
  Future<dynamic> putResponse(String url,dynamic jsonBody);
  Future<dynamic> deleteResponse(String url);

}