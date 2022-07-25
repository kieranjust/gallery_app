String? validateEmail(String? formEmail) {
  if (formEmail == null || formEmail.isEmpty) {
    return 'Email address is required.';
  }

  String pattern = r'\w+@\w+\.\w+';
  RegExp regex = RegExp(pattern);
  if (!regex.hasMatch(formEmail)) {
    return 'Invalid email address format.';
  }

  return null;
}

String? validateFileName(String? formFileName) {
  if (formFileName == null || formFileName.isEmpty) {
    return null;
  }

  String pattern = r'^[^\W_]+$';
  RegExp regex = RegExp(pattern);
  if (!regex.hasMatch(formFileName)) {
    return '''
        User Name must only contain letters, numbers and underscores(_).
        ''';
  }

  return null;
}

String? validateUserName(String? formUserName) {
  if (formUserName == null || formUserName.isEmpty) {
    return 'User Name is required.';
  }

  String pattern = r'^[^\W_]+$';
  RegExp regex = RegExp(pattern);
  if (!regex.hasMatch(formUserName)) {
    return '''
        User Name must only contain letters, numbers and underscores(_).
        ''';
  }

  return null;
}

String? validatePassword(String? formPassword) {
  if (formPassword == null || formPassword.isEmpty) {
    return 'Password is required.';
  }

  String pattern =
      r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
  RegExp regex = RegExp(pattern);
  if (!regex.hasMatch(formPassword)) {
    return '''
      Password must be at least 8 characters,
      include an uppercase letter, number and symbol.
      ''';
  }

  return null;
}
