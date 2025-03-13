part of 'shared.dart';

final colorPrimary = '1D1C36FF'.toColor();
final colorWhite = 'FFFFFF'.toColor();

// image
final imageLogo = AssetImage('assets/images/hiu.png');
final imageGoogle = 'assets/icons/google.png';
final imageFacebook = 'assets/icons/facebook.png';

final welcomeBackTextLogin = 'Welcome Back!';
final welcomeTextRegister = 'Create An Account';
final welcomeText = 'Welcome to My App 🙏';
final subWelcomeTextLogin = 'Please enter your details to continue.';
final subWelcomeTextRegister = 'Start managing attendance efficiently, register now!';
final hintFirstName = ' First Name';
final hintLastName = ' Last Name';
final hintEmail = ' Email Address';
final hintPassword = ' Password';
final hintConfirmPassword = ' Confirm Password';
final hintForgotPassword = 'Forgot Password?';
final hintCurrentPassword = ' Current Password';
final hintNewPassword = 'New Password';
final hintChangePassword = 'Change Password';
final hintLogin = 'Login';
final hintRegister = 'Register';
final hintOtherSignInOptions = 'Other SignIn Options';
final hintOtherSignUpOptions = 'Other SignUp Options';
final hintTextGoogle = 'Google';
final hintTextFacebook = 'Facebook';
final hintDoesntHaveAccount = 'Doesn\'t have an account? ';
final hintAlreadyHaveAccount = 'Already have an account? ';

TextStyle welcomeTextStyle = GoogleFonts.poppins(
  fontSize: 20,
  fontWeight: FontWeight.w500,
  color: Colors.black
);

TextStyle subWelcomeTextStyle = GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Colors.black54
);

TextStyle hintTextStyle = GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: colorWhite
);