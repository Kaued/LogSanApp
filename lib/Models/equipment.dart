class Equipment {
  Equipment({
    required this.logicalNumber,
    required this.model,
    required this.producer,
    required this.serial,
  });

  Equipment.fromJson(Map<String, Object?> json)
      : this(
          logicalNumber: json["logicalNumber"]! as String,
          model: json["model"]! as String,
          producer: json["producer"]! as String,
          serial: json["serial"]! as String,
        );

  String logicalNumber;
  String model;
  String producer;
  String serial;

  Map<String, Object?> toJson() {
    return {
      "logicalNumber": logicalNumber,
      "model": model,
      "producer": producer,
      "serial": serial,
    };
  }
}
