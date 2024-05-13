import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  static final AuthRepository instance = AuthRepository._internal();

  factory AuthRepository() {
    return instance;
  }

  AuthRepository._internal();

  Future<bool> login(String email, String password) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (ex) {
      throw Exception(ex.message);
    }

    return true;
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
}
