class CommonModel {
  bool success = false;
  String message;
  dynamic data;

  CommonModel({required this.success, required this.message, required this.data});

  factory CommonModel.fromJson(Map<String, dynamic> json) {
    return CommonModel(
      success: json['success'],
      message: json['message'],
      data: json['data'],
    );
  }
}



