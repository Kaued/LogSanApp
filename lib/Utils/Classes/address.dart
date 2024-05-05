class Address {
  Address({
    required this.cep,
    required this.street,
    required this.neighborhood,
    required this.city,
    required this.state,
    this.number,
    this.complement,
  });

  Address.fromJson(Map<String, Object?> json)
      : this(
          cep: json["cep"]! as String,
          city: json["localidade"]! as String,
          complement:
              json["complemento"] != null ? json["complemento"] as String : "",
          neighborhood: json["bairro"]! as String,
          state: json["uf"]! as String,
          street: json["logradouro"]! as String,
        );

  String cep;
  String street;
  String neighborhood;
  int? number;
  String city;
  String state;
  String? complement;
}
