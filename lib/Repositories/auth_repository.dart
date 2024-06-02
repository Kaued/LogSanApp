import 'package:firebase_auth/firebase_auth.dart';

class LoginResponse {
  final bool success;
  final User? userData;

  LoginResponse({
    required this.success,
    this.userData,
  });
}

class AuthRepository {
  static final AuthRepository instance = AuthRepository._internal();

  factory AuthRepository() {
    return instance;
  }

  AuthRepository._internal();

  Future<LoginResponse> login(String email, String password) async {
    try {
      UserCredential data =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return LoginResponse(success: true, userData: data.user);
    } on FirebaseAuthException catch (ex) {
      throw Exception(ex.message);
    }
  }

  Future<bool> logout() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      return false;
    }

    return true;
  }

  bool isAuthenticated() {
    return FirebaseAuth.instance.currentUser != null;
  }

  User getAuthenticatedUser() {
    return FirebaseAuth.instance.currentUser!;
  }
}
