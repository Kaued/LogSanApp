import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logsan_app/Models/equipment.dart';

class EquipmentRepository {
  EquipmentRepository._();

  static final EquipmentRepository instance = EquipmentRepository._();
  final _equipmentCollection = FirebaseFirestore.instance
      .collection("equipments")
      .withConverter<Equipment>(
        fromFirestore: (snapshot, options) =>
            Equipment.fromJson(snapshot.data()!),
        toFirestore: (serviceOrder, options) => serviceOrder.toJson(),
      );

  Stream<QuerySnapshot<Equipment>> listEquipments(
      {String? field, String value = ""}) {
    if (field != null && field.isNotEmpty) {
      return _equipmentCollection.orderBy(field).startAt([value]).snapshots();
    }

    return _equipmentCollection.snapshots();
  }

  Future<DocumentSnapshot<Equipment>> findEquipment(String id) async {
    return await _equipmentCollection.doc(id).get();
  }

  Future<DocumentReference<Equipment>> createEquipment(
      Equipment equipment) async {
    return _equipmentCollection.add(equipment);
  }

  Future<void> updateEquipment(Equipment equipment, String id) {
    return _equipmentCollection.doc(id).update(equipment.toJson());
  }

  Future<void> removeEquipment(String id) async {
    return await _equipmentCollection.doc(id).delete();
  }
}
