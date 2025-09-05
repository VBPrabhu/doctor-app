

class Validation{



  static String? emptyNullValidator(
      String? value, {
        String? errorMessage,
      }) {
    if (value?.trim().isEmpty ?? true) return errorMessage;

    return null;
  }

  static String ? validPassword(String? password) {
    String pattern =
        r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$%^&*_,.?\-.:’;“”"]).{8,}$';
    RegExp regex = RegExp(pattern);
    if(password == null|| password.isEmpty){
      return "Password is required";
    }
    else if(password.length < 8){
      return "your password is too short";
    }
    else if(!regex.hasMatch(password)){
      return "Password must be strong";
    }

    return null;

  }


  static String ? validEmail(String ? email) {
    String pattern =
        r'^[a-zA-Z0-9.a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+';
    RegExp regex = RegExp(pattern);

    if(email == null|| email.isEmpty){
      return "email is required";
    }

    else if(!regex.hasMatch(email)){
      return "Enter a valid email address";
    }
    return null;
  }





}