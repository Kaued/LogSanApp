import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logsan_app/Utils/Classes/address.dart';

class ServiceOrder {
  ServiceOrder({
    required this.openingHours,
    required this.phoneNumber,
    required this.placeName,
    required this.referenceNumber,
    required this.responsible,
    required this.typeOrderId,
    required this.maxDate,
    required this.address,
    this.removeEquipment,
    this.installEquipment,
  });

  ServiceOrder.fromJson(Map<String, Object?> json)
      : this(
          openingHours: json["openingHours"]! as String,
          phoneNumber: json["phoneNumber"]! as String,
          placeName: json["placeName"]! as String,
          referenceNumber: json["referenceNumber"]! as String,
          responsible: json["responsible"]! as String,
          typeOrderId: json["typeOrderId"]! as String,
          address: Address(
            cep: json["cep"]! as String,
            city: json["city"]! as String,
            complement: json["complement"]! as String,
            neighborhood: json["neighborhood"]! as String,
            number: json["number"]! as int,
            state: json["state"]! as String,
            street: json["street"]! as String,
          ),
          maxDate: json["maxDate"]! as Timestamp,
          installEquipment: json["installEquipment"]! as String,
          removeEquipment: json["removeEquipnment"]! as String,
        );

  String openingHours;
  String phoneNumber;
  String placeName;
  String referenceNumber;
  String responsible;
  String typeOrderId;
  Address address;
  Timestamp maxDate;
  String? installEquipment;
  String? removeEquipment;

  Map<String, Object?> toJson() {
    return {
      "openingHours": openingHours,
      "phoneNumber": phoneNumber,
      "placeName": placeName,
      "referenceNumber": referenceNumber,
      "responsible": responsible,
      "typeOrderId": typeOrderId,
      "maxDate": maxDate,
      "cep": address.cep,
      "city": address.city,
      "complement": address.complement,
      "neighborhood": address.neighborhood,
      "number": address.number,
      "state": address.state,
      "street": address.street,
      "installEquipment": installEquipment,
      "removeEquipment": removeEquipment,
    };
  }
}
