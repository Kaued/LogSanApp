class Person {
  Person({
    required this.uid,
    required this.email,
    required this.name,
    required this.isAdmin,
    required this.isDisabled,
  });

  Person.fromJson(Map<String, Object?> json)
      : this(
          uid: json["uid"]! as String,
          email: json["email"]! as String,
          name: json["name"]! as String,
          isAdmin: json["isAdmin"]! as bool,
          isDisabled: json["isDisabled"]! as bool,
        );

  String uid;
  String email;
  String name;
  bool isAdmin;
  bool isDisabled;

  Map<String, Object?> toJson() {
    return {
      "uid": uid,
      "email": email,
      "name": name,
      "isAdmin": isAdmin,
      "isDisabled": isDisabled,
    };
  }
}
