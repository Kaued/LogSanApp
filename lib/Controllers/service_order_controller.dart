import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logsan_app/Models/equipment.dart';
import 'package:logsan_app/Models/service_order.dart';
import 'package:logsan_app/Models/type_order.dart';
import 'package:logsan_app/Repositories/address_repository.dart';
import 'package:logsan_app/Repositories/equipmet_repository.dart';
import 'package:logsan_app/Repositories/order_route_repository.dart';
import 'package:logsan_app/Repositories/search_geolocation_repository.dart';
import 'package:logsan_app/Repositories/service_order_repository.dart';
import 'package:logsan_app/Repositories/type_order_repository.dart';
import 'package:logsan_app/Utils/Classes/address.dart';

class ServiceOrderController {
  final ServiceOrderRepository _serviceOrderRepository =
      ServiceOrderRepository.instance;
  final TypeOrderRepository _typeOrderRepository = TypeOrderRepository.instance;
  final AddressRepository _addressRepository = AddressRepository.instance;
  final EquipmentRepository _equipmentRepository = EquipmentRepository.instance;
  final OrderRouteRepository _orderRouteRepository =
      OrderRouteRepository.instance;
  final SearchGeolLocationRepository _searchGeolLocationRepository =
      SearchGeolLocationRepository.instance;

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

  Future<DocumentSnapshot<Equipment>> findEquipment(String id) async {
    return await _equipmentRepository.findEquipment(id);
  }

  Future<void> createServiceOrder(
      {required ServiceOrder serviceOrder,
      required bool needInstallEquipment,
      required bool needRemoveEquipment,
      Equipment? installEquipment,
      Equipment? removeEquipment}) async {
    if (serviceOrder.address.cep.isEmpty) {
      throw Exception("Endereço do estabelecimento é necessário");
    }

    if (needInstallEquipment) {
      if (installEquipment == null) {
        throw Exception("Equipamento a Instalar é necessário");
      }

      final installEquipmentRegister =
          await _equipmentRepository.createEquipment(installEquipment);

      serviceOrder.installEquipment = installEquipmentRegister.id;
    }

    if (needRemoveEquipment) {
      if (removeEquipment == null) {
        throw Exception("Equipamento a Retirar é necessário");
      }

      final removeEquipmentRegister =
          await _equipmentRepository.createEquipment(removeEquipment);

      serviceOrder.removeEquipment = removeEquipmentRegister.id;
    }

    await _serviceOrderRepository.createServiceOrder(serviceOrder);
  }

  Future<void> updateServiceOrder(
      {required ServiceOrder serviceOrder,
      required String id,
      required bool needInstallEquipment,
      required bool needRemoveEquipment,
      Equipment? installEquipment,
      Equipment? removeEquipment}) async {
    if (serviceOrder.address.cep.isEmpty) {
      throw Exception("Endereço do estabelecimento é necessário");
    }

    if (needInstallEquipment) {
      if (installEquipment == null) {
        throw Exception("Equipamento a Instalar é necessário");
      }

      if (serviceOrder.installEquipment == null) {
        final installEquipmentRegister =
            await _equipmentRepository.createEquipment(installEquipment);

        serviceOrder.installEquipment = installEquipmentRegister.id;
      } else {
        await _equipmentRepository.updateEquipment(
            installEquipment, serviceOrder.installEquipment!);
      }
    } else {
      if (serviceOrder.installEquipment != null) {
        await _equipmentRepository
            .removeEquipment(serviceOrder.installEquipment!);
      }

      serviceOrder.installEquipment = null;
    }

    if (needRemoveEquipment) {
      if (removeEquipment == null) {
        throw Exception("Equipamento a Instalar é necessário");
      }

      if (serviceOrder.removeEquipment == null) {
        final removeEquipmentRegister =
            await _equipmentRepository.createEquipment(removeEquipment);

        serviceOrder.removeEquipment = removeEquipmentRegister.id;
      } else {
        await _equipmentRepository.updateEquipment(
            removeEquipment, serviceOrder.removeEquipment!);
      }
    } else {
      if (serviceOrder.removeEquipment != null) {
        await _equipmentRepository
            .removeEquipment(serviceOrder.removeEquipment!);
      }

      serviceOrder.removeEquipment = null;
    }

    await _serviceOrderRepository.updateServiceOrder(serviceOrder, id);
  }

  Future<void> deletedServiceOrder(String id) async {
    await _serviceOrderRepository.deleteServiceOrder(id);
  }

  Future<DocumentSnapshot<ServiceOrder>> getServiceOrderById(String id) async {
    return await _serviceOrderRepository.getServiceOrderById(id);
  }

  Future<void> updateStatusServiceOrder(
      {required String id, required String status, DateTime? newDate}) async {
    final orderRouteLast =
        await _orderRouteRepository.getLastOrderRouteByOrder(id);

    if (orderRouteLast.docs.isNotEmpty) {
      final orderRoute = orderRouteLast.docs.first;

      final orderRouteData = orderRoute.data();
      orderRouteData.statusId = status;

      await _orderRouteRepository.updateOrderRoute(
          orderRouteData, orderRoute.id);
    }

    if (newDate != null) {
      final serviceOrder =
          await _serviceOrderRepository.getServiceOrderById(id);

      final serviceOrderData = serviceOrder.data();

      serviceOrderData!.maxDate = Timestamp.fromDate(newDate);

      await _serviceOrderRepository.updateServiceOrder(serviceOrderData, id);
    }
  }

  Future<String?> getLastStatusInOrder(String id) async {
    final orderRouteLast =
        await _orderRouteRepository.getLastOrderRouteByOrder(id);

    if (orderRouteLast.docs.isNotEmpty) {
      final orderRoute = orderRouteLast.docs.first;

      final orderRouteData = orderRoute.data();

      return orderRouteData.statusId;
    }

    return null;
  }

  Future<GeoPoint> getGeoLocationByAddress(Address address) async {
    return await _searchGeolLocationRepository.getGeoLocationByAddress(address);
  }
}
