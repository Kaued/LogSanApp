import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logsan_app/Models/type_order.dart';

class TypeOrderRepository {
  TypeOrderRepository._();

  static final TypeOrderRepository instance = TypeOrderRepository._();

  final _typeOrderCollection = FirebaseFirestore.instance
      .collection("typeOrder")
      .withConverter<TypeOrder>(
        fromFirestore: (snapshot, options) =>
            TypeOrder.fromJson(snapshot.data()!),
        toFirestore: (typeOrder, options) => typeOrder.toJson(),
      );

  Future<List<QueryDocumentSnapshot<TypeOrder>>> listTypeOrder() async {
    final types = await _typeOrderCollection.get().then((value) => value.docs);

    return types;
  }
}
