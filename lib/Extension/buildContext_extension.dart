import 'package:flutter/cupertino.dart';

extension CustomBuildContextExtension on BuildContext {
  double get screenWidth => MediaQuery.of(this).size.width;

  double get screenHeight => MediaQuery.of(this).size.height;

  NavigatorState get navigator => Navigator.of(this);
}

extension SizedBoxHeight on int {

  toHeight()=>SizedBox(height: toDouble());

}

extension SizedBoxWidth on int {

  toWidth()=>SizedBox(width: toDouble());

}


extension BorderRadiusExtension on int {
  toBorderRadius()=>BorderRadius.circular(toDouble());
}

extension CustomPadding on Widget{

  toHorizontalPadding({double ? horizontalPadding})=>Padding(padding: EdgeInsets.symmetric(horizontal: horizontalPadding ?? 12),child: this,);

}
