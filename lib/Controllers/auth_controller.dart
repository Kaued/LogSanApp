import 'package:logsan_app/Controllers/user_controller.dart';
import 'package:logsan_app/Models/person.dart';
import 'package:logsan_app/Repositories/auth_repository.dart';

class AuthController {
  static final AuthController instance = AuthController._internal();
  final _authRepository = AuthRepository.instance;
  final userController = UserController.instance;
  Person user = Person(
    id: '',
    uid: '',
    email: '',
    name: '',
    isAdmin: false,
    isDisabled: false,
  );

  factory AuthController() {
    return instance;
  }

  AuthController._internal();

  Future<bool> login(String email, String password) async {
    LoginResponse loginResponse = await _authRepository.login(email, password);

    user = await userController.getByUid(loginResponse.userData!.uid);

    return loginResponse.success;
  }

  Future<bool> logout() async {
    return await _authRepository.logout();
  }

  bool isAuthenticated() {
    return _authRepository.isAuthenticated();
  }

  Person getAuthenticatedUser() {
    if (user.uid.isEmpty && isAuthenticated()) {
      logout();
    }

    return user;
  }

  bool setAuthenticatedUser(Person user) {
    this.user = user;

    return true;
  }

  Future<bool> updateEmail(String email) async {
    return await _authRepository.changeEmail(email);
  }

  Future<bool> updatePassword(String password) async {
    return await _authRepository.changePassword(password);
  }
}
