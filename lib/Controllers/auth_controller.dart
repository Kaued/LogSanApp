import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:logsan_app/Repositories/auth_repository.dart';

class AuthController {
  static final AuthController instance = AuthController._internal();
  final _authRepository = AuthRepository.instance;
  final firestore = FirebaseFirestore.instance;

  factory AuthController() {
    return instance;
  }

  AuthController._internal();

  Future<bool> login(
    BuildContext context,
    String email,
    String password,
  ) async {
    try {
      // var userData = await firestore
      //     .collection("usersRoles")
      //     .where('__name__', isEqualTo: user!.uid)
      //     .get();

      // bool isAdmin = userData.docs.first['isAdmin'];

      // String route = '/home';
      // if (isAdmin) {
      //   route = '/home';
      // }
      var isSuccessLogin = await _authRepository.login(email, password);

      if (isSuccessLogin) {
        // ignore: use_build_context_synchronously
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }

    return true;
  }

  Future<bool> logout(context) async {
    var isSuccessLogout = await _authRepository.logout();

    if (isSuccessLogout) {
      Navigator.pushReplacementNamed(context, "/login");
    }

    return isSuccessLogout;
  }
}
