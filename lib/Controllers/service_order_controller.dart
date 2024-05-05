import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logsan_app/Models/service_order.dart';
import 'package:logsan_app/Models/type_order.dart';
import 'package:logsan_app/Repositories/address_repository.dart';
import 'package:logsan_app/Repositories/service_order_repository.dart';
import 'package:logsan_app/Repositories/type_order_repository.dart';
import 'package:logsan_app/Utils/Classes/address.dart';

class ServiceOrderController {
  final ServiceOrderRepository _serviceOrderRepository =
      ServiceOrderRepository.instance;
  final TypeOrderRepository _typeOrderRepository = TypeOrderRepository.instance;
  final AddressRepository _addressRepository = AddressRepository.instance;

  static ServiceOrderController instance = ServiceOrderController._();

  final Map<String, String> columns = {
    "Numero de Referência": "referenceNumber",
    "Estabelecimento": "placeName",
  };

  ServiceOrderController._();

  Stream<QuerySnapshot<ServiceOrder>> getServiceOrders(
      {String? field, String value = ""}) {
    if (value.isNotEmpty && field != null) {
      final orders = _serviceOrderRepository.listServiceOrders(
        field: field,
        value: value,
      );
      return orders;
    }

    final orders = _serviceOrderRepository.listServiceOrders();
    return orders;
  }

  Future<List<QueryDocumentSnapshot<TypeOrder>>> getTypeOrders() async {
    final types = await _typeOrderRepository.listTypeOrder();

    return types;
  }

  Map<String, String> getColumns() {
    return columns;
  }

  Future<Address> getAddress(String cep) async {
    if (cep.isNotEmpty) {
      try {
        return await _addressRepository.getAddressByCep(cep);
      } catch (error) {
        throw Exception("Não foi possível encontra o cep.");
      }
    }

    throw Exception("Cep não pode estar vazio");
  }
}
