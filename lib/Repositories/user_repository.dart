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

  Future<List<QueryDocumentSnapshot<Person>>> getUsers() async {
    var users = await _userCollection.get();

    return users.docs;
  }

  Future<bool> update(
    String id, {
    String? name,
    bool? isAdmin,
    bool? isDisabled,
  }) async {
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

  Stream<QuerySnapshot<Person>> listUsers() {
    return _userCollection.where("isDisabled", isEqualTo: false).snapshots();
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

  Future<Person> getByUid(String uid) async {
    var user = await firestore
        .collection('users')
        .where(
          "uid",
          isEqualTo: uid,
        )
        .get();

    return Person.fromJson({
      "id": user.docs.first.id,
      "uid": user.docs.first.get("uid"),
      "email": user.docs.first.get("email"),
      "name": user.docs.first.get("name"),
      "isAdmin": user.docs.first.get("isAdmin"),
      "isDisabled": user.docs.first.get("isDisabled"),
    });
  }
}
