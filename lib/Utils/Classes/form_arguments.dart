class FormArguments<T> {
  FormArguments({
    required this.isAddMode,
    this.values,
    this.id,
  });

  bool isAddMode;
  T? values;
  String? id;
}
