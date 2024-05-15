class Status {
  Status({
    required this.name,
    required this.discount,
  });

  Status.fromJson(Map<String, Object?> json)
      : this(
          name: json["name"]! as String,
          discount: json["discount"]! as double,
        );

  String name;
  double discount;

  Map<String, Object?> toJson() {
    return {
      "name": name,
      "discount": discount,
    };
  }
}
