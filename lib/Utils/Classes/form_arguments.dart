class FormArguments<T> {
  FormArguments({
    required this.isAddMode,
    this.values,
  });

  bool isAddMode;
  T? values;
}
