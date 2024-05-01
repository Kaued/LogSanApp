import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceOrder {
  ServiceOrder({
    required this.openingHours,
    required this.phoneNumber,
    required this.placeName,
    required this.referenceNumber,
    required this.responsible,
    required this.typeOrderId,
    required this.cep,
    required this.city,
    required this.neighborhood,
    required this.number,
    required this.state,
    required this.street,
    required this.maxDate,
    this.complement,
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
          cep: json["cep"]! as String,
          city: json["city"]! as String,
          complement: json["complement"]! as String,
          neighborhood: json["neighborhood"]! as String,
          number: json["number"]! as int,
          state: json["state"]! as String,
          street: json["street"]! as String,
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
  String cep;
  String city;
  String? complement;
  String neighborhood;
  int number;
  String state;
  String street;
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
      "cep": cep,
      "city": city,
      "complement": complement,
      "neighborhood": neighborhood,
      "number": number,
      "state": state,
      "street": street,
      "installEquipment": installEquipment,
      "removeEquipment": removeEquipment,
    };
  }
}
