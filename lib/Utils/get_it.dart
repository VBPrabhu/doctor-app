import 'package:doctorapp/Utils/shared_preferance.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

final getIt = GetIt.instance;

Future<void> setup() async{
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPref>(SharedPref(sharedPreferences));
}