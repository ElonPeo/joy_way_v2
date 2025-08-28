import 'package:firebase_auth/firebase_auth.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
class Authentication {
  final FirebaseAuth _auth = FirebaseAuth.instance;


  bool checkNullSignInInput(String email ,String password){
    return email.trim().isNotEmpty && password.trim().isNotEmpty;
  }

  bool checkNullRegisterInput(String email ,String password, ){
    return email.trim().isNotEmpty && password.trim().isNotEmpty;
  }

  bool checkNullResetPasswordInput(String email){
    return email.trim().isNotEmpty;
  }

  bool checkValidPassword(String password) {
    String cleaned = password.replaceAll(RegExp(r'\s+'), '');
    return cleaned.length >= 6 && cleaned.length <= 128;
  }


  bool checkValidEmail(String email) {
    final allowedDomains = ['@gmail.com', '@hotmail.com', '@yahoo.com', '@icloud.com'];
    for (final domain in allowedDomains) {
      if (email.toLowerCase().endsWith(domain)) {
        return true;
      }
    }
    return false;
  }


  //------------------------------------------------------------
  bool checkBeforeSendingRegister(String email, String password) {
    return checkNullRegisterInput(email, password) &&
        checkValidEmail(email) && checkValidPassword(password);
  }
  String validateInputRegister(String email, String password) {
    if(!checkNullRegisterInput(email,password)){
      return 'Email, Password, and Confirm Password cannot be blank.';
    }
    if (!checkValidEmail(email)) {
      return 'Invalid email. Only @gmail.com, @hotmail.com, @yahoo.com, @icloud.com accepted.';
    }
    if (!checkValidPassword(password)) {
      return 'Password must be 6–128 characters (excluding spaces).';
    }

    return "Unknown error";
  }

  Future<String?> register( String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Registration failed';
    } catch (e) {
      return 'Unknown error: $e';
    }
  }


  //-----------------------------------------------------------------------------------
  bool checkBeforeSendingSignIn(String email, String password) {
    return checkNullSignInInput(email, password ) && checkValidEmail(email) && checkValidPassword(password);
  }
  String validateInputSignIn(String email, String password) {
    if (!checkNullSignInInput(email, password)) {
      return 'Email and Password cannot be blank.';
    }
    if (!checkValidPassword(password)) {
      return 'Password must be 6–128 characters (excluding spaces).';
    }
    if (!checkValidEmail(email)) {
      return 'Invalid email. Only @gmail.com, @hotmail.com, @yahoo.com, @icloud.com accepted.';
    }
    return 'Validate input successful';
  }

  Future<String?> signIn( String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Login failed';
    } catch (e) {
      return 'Unknown error: $e';
    }
  }


  //---------------------------------------------------------------------------------
  bool checkBeforeSendingResetPassword(String email) {
    return checkNullResetPasswordInput(email) && checkValidEmail(email);
  }
  String validateInputResetPassword(String email) {
    if(!checkNullResetPasswordInput(email)){
      return 'Email cannot be blank.';
    }
    if (!checkValidEmail(email)) {
      return 'Invalid email. Only @gmail.com, @hotmail.com, @yahoo.com, @icloud.com accepted.';
    }
    return "Unknown error";
  }
  Future<String?> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Failed to send password reset email';
    } catch (e) {
      return 'Unknown error: $e';
    }
  }


  //---------------------------------------
  Future<void> signOut() async {
    await _auth.signOut();
  }
  //---------------------------------------
  User? getCurrentUser() {
    return _auth.currentUser;
  }
  //---------------------------------------
  Future<String> checkNetwork() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      return "Check your network connection";
    } else {
      return "Good network connection";
    }
  }
}
