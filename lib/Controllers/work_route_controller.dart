import 'package:logsan_app/Repositories/order_route_repository.dart';
import 'package:logsan_app/Repositories/status_repository.dart';
import 'package:logsan_app/Repositories/work_route_repository.dart';

class WorkRouteController {
  final WorkRouteRepository _workRouteRepository = WorkRouteRepository.instance;
  final OrderRouteRepository _orderRouteRepository =
      OrderRouteRepository.instance;
  final StatusRepository _statusRepository = StatusRepository.instance;

  static WorkRouteController instance = WorkRouteController._();

  WorkRouteController._();
}
