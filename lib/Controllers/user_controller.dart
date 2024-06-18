import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logsan_app/Models/person.dart';
import 'package:logsan_app/Repositories/user_repository.dart';

class UserController {
  static final UserController instance = UserController._internal();
  final _userRepository = UserRepository.instance;

  factory UserController() {
    return instance;
  }

  UserController._internal();

  Stream<QuerySnapshot<Person>> list() {
    final users = _userRepository.listUsers();
    return users;
  }

  Future<Person> getById(String id) async {
    try {
      var user = await _userRepository.getById(id);
      return user;
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<Person> getByUid(String uid) async {
    try {
      var user = await _userRepository.getByUid(uid);
      return user;
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<bool> create(
    String email,
    String password,
    String name,
    bool isAdmin,
    bool isDisabled,
  ) async {
    try {
      await _userRepository.create(email, password, name, isAdmin, isDisabled);
    } catch (e) {
      throw Exception(e);
    }

    return true;
  }

  Future<bool> update(
    String id, {
    required String name,
    required bool isAdmin,
    String? email,
  }) async {
    try {
      await _userRepository.update(
        id,
        name: name,
        isAdmin: isAdmin,
        email: email,
      );
    } catch (e) {
      throw Exception(e);
    }

    return true;
  }

  Future<bool> delete(String id) async {
    try {
      await _userRepository.delete(id);
    } catch (e) {
      throw Exception(e);
    }

    return true;
  }
}
