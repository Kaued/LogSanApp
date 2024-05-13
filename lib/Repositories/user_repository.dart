import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logsan_app/Models/person.dart';

class UserRepository {
  static final UserRepository instance = UserRepository._internal();
  final firestore = FirebaseFirestore.instance;

  factory UserRepository() {
    return instance;
  }

  UserRepository._internal();

  Future<bool> update(
    String id, {
    String? email,
    String? name,
    bool? isAdmin,
    bool? isDisabled,
  }) async {
    if (email != null) {
      await firestore.collection('users').doc(id).update({
        "email": email,
      });
    }

    if (name != null) {
      await firestore.collection('users').doc(id).update({
        "name": name,
      });
    }

    if (isAdmin != null) {
      await firestore.collection('users').doc(id).update({
        "isAdmin": isAdmin,
      });
    }

    return true;
  }

  Future<bool> delete(String id) async {
    await firestore.collection('users').doc(id).update({
      "isDisabled": true,
    });

    return true;
  }

  Future<bool> create(
    String email,
    String password,
    String name,
    bool isAdmin,
    bool isDisabled,
  ) async {
    var userCredential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);

    await firestore.collection('users').add({
      "uid": userCredential.user!.uid,
      "email": email,
      "name": name,
      "isAdmin": isAdmin,
      "isDisabled": isDisabled,
    });

    return true;
  }

  final _userCollection = FirebaseFirestore.instance
      .collection("users")
      .withConverter<Person>(
        fromFirestore: (snapshot, options) => Person.fromJson(snapshot.data()!),
        toFirestore: (person, options) => person.toJson(),
      );

  Stream<QuerySnapshot<Person>> listUsers({String? field, String value = ""}) {
    if (field != null && field.isNotEmpty) {
      return _userCollection.orderBy(field).startAt([value]).snapshots();
    }

    return _userCollection.snapshots();
  }

  Future<Person> getById(String id) async {
    var user = await firestore.collection('users').doc(id).get();

    return Person.fromJson({
      "id": user.id,
      "uid": user.get("uid"),
      "email": user.get("email"),
      "name": user.get("name"),
      "isAdmin": user.get("isAdmin"),
      "isDisabled": user.get("isDisabled"),
    });
  }
}
