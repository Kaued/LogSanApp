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
}
