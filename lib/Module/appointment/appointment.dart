import 'package:doctorapp/AppCommon/CommonWidget/common_appbar.dart';
import 'package:doctorapp/AppCommon/CommonWidget/common_large_button.dart';
import 'package:doctorapp/AppCommon/app_colors.dart';
import 'package:doctorapp/AppCommon/app_textStyle.dart';
import 'package:doctorapp/Extension/buildContext_extension.dart';
import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:intl/intl.dart';

class AppointmentScreen extends StatefulWidget {
  const AppointmentScreen({super.key});

  @override
  State<AppointmentScreen> createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  DateTime selectedDate = DateTime.now();
  late DateTime startOfWeek;
  late DateTime endOfWeek;

  RxBool isMale = true.obs;
  RxBool isFemale = false.obs;

  final List<String> timeSlots = [
    '09:00 AM',
    '09:30 AM',
    '10:00 AM',
    '10:30 AM',
    '12:00 PM',
    '12:30 PM',
    '01:00 PM',
    '01:30 PM',
    '02:00 AM',
    '03:00 PM',
    '04:30 PM',
    '05:00 PM',
    '05:30 AM'
  ];

  String selectedSlot = '';

  @override
  void initState() {
    startOfWeek =
        selectedDate.subtract(Duration(days: selectedDate.weekday - 1));
    endOfWeek = startOfWeek.add(Duration(days: 6));
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String monthYear = DateFormat('MMMM, yyyy').format(selectedDate);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBgColor,
      appBar: CustomAppBar(),
      body: SingleChildScrollView(
        child:  Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Service",
              style: AppTextStyle.s14
                  .copyWith(fontWeight: FontWeight.w500, fontSize: 16),
            ),
            5.toHeight(),
            Text(
              monthYear,
              style: AppTextStyle.s14
                  .copyWith(fontWeight: FontWeight.w500, fontSize: 16),
            ),
            Container(
              height: 100,
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 7,
                itemBuilder: (context, index) {
                  DateTime currentDate = startOfWeek.add(Duration(days: index));
                  String formattedDate = DateFormat('d').format(currentDate);
                  String weekday = DateFormat('EEE').format(currentDate);

                  bool isSelected = selectedDate.day == currentDate.day &&
                      selectedDate.month == currentDate.month &&
                      selectedDate.year == currentDate.year;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedDate = currentDate;
                      });
                    },
                    child: Container(
                      width: 60,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.amber : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? Colors.amber : Colors.grey.shade300,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            formattedDate,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            weekday,
                            style: TextStyle(
                              fontSize: 12,
                              color: isSelected ? Colors.white : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            25.toHeight(),
            Text(
              "Available Time",
              style: AppTextStyle.s14
                  .copyWith(fontWeight: FontWeight.w500, fontSize: 16),
            ),
            14.toHeight(),
            slotView(),
            25.toHeight(),
            Text(
              "Patient Details",
              style: AppTextStyle.s14
                  .copyWith(fontWeight: FontWeight.w500, fontSize: 16),
            ),
            Text("Full name",style: AppTextStyle.s14.copyWith(
              color: Color(0xff6B779A)
            ),),
            4.toHeight(),
            greyTextField(),
            16.toHeight(),
            Text("Age",style: AppTextStyle.s14.copyWith(
              color: Color(0xff6B779A)
            ),),
            4.toHeight(),
            greyTextField(),

            16.toHeight(),
            Text("Gender",style: AppTextStyle.s14.copyWith(
                color: Color(0xff6B779A)
            ),),
            4.toHeight(),
            Row(
              children: [
                Obx(()=> InkWell(
                    onTap: (){
                      isFemale.value = false;
                      isMale.value = true;
                    },
                    child: button(
                      label: "Male",
                      borderColor: isMale.value == true ? Colors.transparent: Color(0xff6B779A).withValues(alpha: .1),
                      color: isMale.value == true ?
                      AppColors.primaryColor : Colors.transparent
                    ),
                  ),
                ),
                10.toWidth(),
                Obx(()=> InkWell(
                    onTap: (){
                      isFemale.value = true;
                      isMale.value = false;
                    },
                    child: button(
                        label: "Female",
                        borderColor: isFemale.value == true ? Colors.transparent:Color(0xff6B779A).withValues(alpha: .1),
                        color: isFemale.value == true ?
                        AppColors.primaryColor : Colors.transparent
                    ),
                  ),
                )
              ],
            ),

            16.toHeight(),
            Text("Write your problem",style: AppTextStyle.s14.copyWith(
                color: Color(0xff6B779A),
            ),),
            4.toHeight(),
            greyTextField(
              maxLine: 4
            ),
            20.toHeight(),
            CommonLargeButton(
              title: "Set Appointment",
            ),

            20.toHeight()
          ],
        ).toHorizontalPadding(horizontalPadding: 16),
      )


    );
  }

  Widget slotView() => GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4, // 4 slots per row
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 16 / 9),
        physics: NeverScrollableScrollPhysics(),
        itemCount: timeSlots.length,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          String timeSlot = timeSlots[index];

          bool isSelected = selectedSlot == timeSlot;

          Color textColor = isSelected ? Colors.white : Color(0xff6B779A);

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedSlot = timeSlot; // Update the selected slot
              });
            },
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryColor : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected
                      ? Colors.transparent
                      : Color(0xff6B779A).withValues(alpha: .1),
                  width: 1,
                ),
              ),
              child: Text(timeSlot,
                  style: AppTextStyle.s18
                      .copyWith(fontSize: 14, color: textColor)),
            ),
          );
        },
      );

  Widget greyTextField({int ? maxLine}) => TextFormField(
        controller: TextEditingController(),
        cursorColor: Colors.black,
        maxLines:maxLine ,
        decoration:  InputDecoration(
          filled: true,
            border: InputBorder.none,
            fillColor: Color(0xff6B779A).withValues(alpha: .1),
            enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: Colors.transparent
            )
          ),
          isDense: true,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                  color: Colors.transparent
              )
          ),

        ),
        // Validation function
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter some text';
          }
          return null;
        },
      );



  Widget button({Color ? color,isMale = true,String ? label,
   Color ? borderColor,
   Color ? textColor

  })=>Container(
    width  : context.screenWidth * .22,
    height : context.screenWidth * .12,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: color,
      border: Border.all(color:borderColor!),
      borderRadius: 12.toBorderRadius()
    ),
    child: Text(label??"",
     style: AppTextStyle.s14.copyWith(
       color: textColor
     ),
    ),
  );

}
