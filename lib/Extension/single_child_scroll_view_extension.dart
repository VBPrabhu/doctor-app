




 import 'package:flutter/cupertino.dart';

extension SingleChildScrollViewExtension on Column{

  toScrollable()=>SingleChildScrollView(
    child: this,
  );
}