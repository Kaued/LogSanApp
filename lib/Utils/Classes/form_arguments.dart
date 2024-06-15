class FormArguments<T> {
  FormArguments({
    required this.isAddMode,
    this.isFromMyAccount,
    this.values,
    this.id,
  });

  bool isAddMode;
  T? values;
  String? id;
  bool? isFromMyAccount;
}
