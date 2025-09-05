import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

import '../AppCommon/app_colors.dart';



class FileUtils{
  FileUtils._();

  static Future<DateTime?> pickDate(BuildContext context,{bool isDpr = false,bool isFromTaskList = false}) async {
    final DateTime? selectedTime = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate:  DateTime(2000),
        lastDate: DateTime(3000),
        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: ThemeData(
              primaryColor: AppColors.primaryColor,
              colorScheme:
              const ColorScheme.light(primary: AppColors.primaryColor,),
              buttonTheme:
              const ButtonThemeData(textTheme: ButtonTextTheme.primary),
            ),
            child: child ?? const SizedBox.shrink(),
          );
        });
    if (selectedTime != null) {
      return selectedTime;
    } else {
      return null;
    }
  }


  // static getFormatDate(date) {
  //   if(date != null){
  //     var outputFormat = DateFormat('dd-MM-yyyy').format(date);
  //     return outputFormat;
  //   }
  //
  // }


  // static reFormatDate({inputDate}){
  //
  //   DateFormat inputFormat = DateFormat("dd-MM-yyyy");
  //   DateFormat outputFormat = DateFormat("yyyy-MM-dd");
  //
  //   DateTime dateTime = inputFormat.parse(inputDate);
  //   String  outputDate = outputFormat.format(dateTime);
  //
  //   return outputDate;
  // }


 }