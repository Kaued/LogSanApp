import 'package:logsan_app/Repositories/auth_repository.dart';

class LayoutController {
  final AuthRepository _authRepository = AuthRepository.instance;

  static final LayoutController instance = LayoutController._();
  LayoutController._();

  bool isAuthenticated() {
    return _authRepository.isAuthenticated();
  }
}
