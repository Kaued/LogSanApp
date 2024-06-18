import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logsan_app/Models/work_route.dart';

class WorkRouteRepository {
  WorkRouteRepository._();

  static final WorkRouteRepository instance = WorkRouteRepository._();
  final _workRouteCollection = FirebaseFirestore.instance
      .collection("workRoute")
      .withConverter<WorkRoute>(
        fromFirestore: (snapshot, options) =>
            WorkRoute.fromJson(snapshot.data()!),
        toFirestore: (workRoute, options) => workRoute.toJson(),
      );

  Stream<QuerySnapshot<WorkRoute>> getWorkRoutes() {
    return _workRouteCollection
        .orderBy("to_date", descending: true)
        .where("deleted", isEqualTo: false)
        .snapshots();
  }

  Stream<QuerySnapshot<WorkRoute>> getWorkRoutesbyUser({String value = ""}) {
    if (value.isNotEmpty) {
      return _workRouteCollection
          .where("uid", isEqualTo: value)
          .where("deleted", isEqualTo: false)
          .orderBy("to_date", descending: true)
          .snapshots();
    }
    return _workRouteCollection.where("deleted", isEqualTo: false).snapshots();
  }

  Stream<QuerySnapshot<WorkRoute>> getWorkRoutesbyDate(
      {Timestamp? value, bool admin = true, String uid = ""}) {
    if (value != null) {
      Timestamp initalOfDay = Timestamp.fromDate(DateTime(
          value.toDate().year, value.toDate().month, value.toDate().day));
      Timestamp endOfDay = Timestamp.fromDate(DateTime(value.toDate().year,
          value.toDate().month, value.toDate().day, 23, 59, 59));
      if (admin) {
        return _workRouteCollection
            .where("to_date", isGreaterThanOrEqualTo: initalOfDay)
            .where("to_date", isLessThanOrEqualTo: endOfDay)
            .where("deleted", isEqualTo: false)
            .snapshots();
      }
      return _workRouteCollection
          .where("to_date", isGreaterThanOrEqualTo: initalOfDay)
          .where("to_date", isLessThanOrEqualTo: endOfDay)
          .where("deleted", isEqualTo: false)
          .where("uid", isEqualTo: uid)
          .snapshots();
    }
    return _workRouteCollection.where("deleted", isEqualTo: false).snapshots();
  }

  Stream<QuerySnapshot<WorkRoute>> getWorkRoutesbyStatus(
      {String value = "", bool admin = true, String uid = ""}) {
    if (value.isNotEmpty) {
      if (admin) {
        return _workRouteCollection
            .where("finish", isEqualTo: value == '1' ? true : false)
            .where("deleted", isEqualTo: false)
            .snapshots();
      }
      return _workRouteCollection
          .where("finish", isEqualTo: value == '1' ? true : false)
          .where("deleted", isEqualTo: false)
          .where("uid", isEqualTo: uid)
          .snapshots();
    }
    return _workRouteCollection.where("deleted", isEqualTo: false).snapshots();
  }

  Future<bool> delete(String id) async {
    await _workRouteCollection.doc(id).update({
      "deleted": true,
    });

    return true;
  }

  Future<String> createWorkRoute(WorkRoute workRoute) async {
    final document = await _workRouteCollection.add(workRoute);

    return document.id;
  }

  Future<void> updateWorkRoute(WorkRoute workRoute, String id) async {
    await _workRouteCollection.doc(id).update(workRoute.toJson());
  }

  Future<DocumentSnapshot<WorkRoute>> getWorkRoute(String id) async {
    return await _workRouteCollection.doc(id).get();
  }

  Future<void> updateRoute(String id, WorkRoute route) async {
    await _workRouteCollection.doc(id).update(route.toJson());
  }
}
