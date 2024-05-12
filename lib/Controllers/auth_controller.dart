import 'package:logsan_app/Repositories/auth_repository.dart';

class AuthController {
  static final AuthController instance = AuthController._internal();
  final _authRepository = AuthRepository.instance;

  factory AuthController() {
    return instance;
  }

  AuthController._internal();

  Future<bool> login(String email, String password) async {
    return await _authRepository.login(email, password);
  }

  Future<bool> logout() async {
    return await _authRepository.logout();
  }
}
