


import 'package:shared_preferences/shared_preferences.dart';

class SharedPref {

  String accessToken = "accessToken";
  String userID = "userId";


  final SharedPreferences  prefs;

  SharedPref(this.prefs);

  Future<void> setString({key,value})async{
    await  prefs.setString(key, value);
  }



  getString({key})async{
    return prefs.getString(key);
  }


  removeString({key})async{
    await  prefs.remove(key);
  }


  bool containsKey({required String key}) {
    return prefs.containsKey(key);
  }










}