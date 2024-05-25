import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logsan_app/Models/person.dart';
import 'package:logsan_app/Pages/user_list.dart';
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

  Future<List<QueryDocumentSnapshot<Person>>> getUsers() async {
    return await _userRepository.getUsers();
  }
}
