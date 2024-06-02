import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logsan_app/Models/person.dart';
import 'package:logsan_app/Models/work_route.dart';
import 'package:logsan_app/Repositories/order_route_repository.dart';
import 'package:logsan_app/Repositories/status_repository.dart';
import 'package:logsan_app/Repositories/user_repository.dart';
import 'package:logsan_app/Repositories/work_route_repository.dart';

class WorkRouteController {
  final WorkRouteRepository _workRouteRepository = WorkRouteRepository.instance;
  final OrderRouteRepository _orderRouteRepository =
      OrderRouteRepository.instance;
  final StatusRepository _statusRepository = StatusRepository.instance;
  final UserRepository _userRepository = UserRepository.instance;

  static WorkRouteController instance = WorkRouteController._();

  WorkRouteController._();

  final Map<String, String> columns = {
    "Usuário": "uid",
    "Data": "to_date",
    "Status": "finish",
  };

  Future<List<QueryDocumentSnapshot<Person>>> getUsers() async {
    return await _userRepository.getUsers();
  }

  Stream<QuerySnapshot<WorkRoute>> getWorkRoutes(
      {String? field, String value = ""}) {
    print(field);
    if (value.isNotEmpty && field != null) {
      if (field == "finish") {
        final orders = _workRouteRepository.getWorkRoutesbyStatus(
          value: value,
        );
        return orders;
      } else if (field == "to_date") {
        Timestamp date = Timestamp.fromDate(DateTime.parse(value));
        final orders = _workRouteRepository.getWorkRoutesbyDate(
          value: date,
        );
        return orders;
      } else if (field == "uid") {
        final orders = _workRouteRepository.getWorkRoutesbyUser(
          value: value,
        );
        return orders;
      }
    }

    final orders = _workRouteRepository.getWorkRoutes();
    return orders;
  }

  Map<String, String> getColumns() {
    return columns;
  }

  Future<bool> delete(String id) async {
    try {
      await _workRouteRepository.delete(id);
    } catch (e) {
      throw Exception(e);
    }

    return true;
  }
}
