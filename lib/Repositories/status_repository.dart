import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logsan_app/Models/status.dart';

class StatusRepository {
  StatusRepository._();

  static final StatusRepository instance = StatusRepository._();
  final _statusCollection = FirebaseFirestore.instance
      .collection("status")
      .withConverter<Status>(
        fromFirestore: (snapshot, options) => Status.fromJson(snapshot.data()!),
        toFirestore: (status, options) => status.toJson(),
      );
}
