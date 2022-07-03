extension ExtString on String {
  bool get isValidEmail {
    final emailRegExp = RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    return emailRegExp.hasMatch(this);
  }

  bool get isValidName{
    final nameRegExp = RegExp(r"^\s*([A-Za-z]{1,}([\.,] |[-']| ))+[A-Za-z]+\.?\s*$");
    return nameRegExp.hasMatch(this);
  }

  bool get isDigitPassword{
    return isValidPassword(r'(?=.*?[0-9])', this);
  }
  bool get isAtleastPassword{
    return isValidPassword(r'.{8,}', this);
  }



}

isValidPassword(String regex, String input){
  final passwordRegExp = RegExp(regex);
  return passwordRegExp.hasMatch(input);
}