class TypeOrder {
  TypeOrder({
    required this.name,
    required this.value,
  });

  TypeOrder.fromJson(Map<String, Object?> json)
      : this(
          name: json["name"]! as String,
          value: json["value"]! as double,
        );

  String name;
  double value;

  Map<String, Object?> toJson() {
    return {
      "name": name,
      "value": value,
    };
  }
}
