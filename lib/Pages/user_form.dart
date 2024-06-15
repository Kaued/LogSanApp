import 'package:flutter/material.dart';
import 'package:logsan_app/Controllers/auth_controller.dart';
import 'package:logsan_app/Controllers/user_controller.dart';
import 'package:logsan_app/Models/person.dart';
import 'package:logsan_app/Utils/Classes/form_arguments.dart';

class UserForm extends StatefulWidget {
  const UserForm({super.key, this.arguments});

  final FormArguments<Person?>? arguments;
  @override
  State<UserForm> createState() => _UserFormState();
}

class _UserFormState extends State<UserForm> {
  Person? user;

  final UserController _controller = UserController.instance;
  final AuthController _authController = AuthController.instance;

  // Key do formulário
  final formKey = GlobalKey<FormState>();

  // Variaveis dos campos do formulário
  final nome = TextEditingController();
  final email = TextEditingController();
  final senha = TextEditingController();
  final tipoUsuario = TextEditingController();
  bool isAdmin = true;

  final Map<String, bool> typeUser = {
    "Administrador": true,
    "Comum": false,
  };

  @override
  void initState() {
    super.initState();

    setState(() {
      if (widget.arguments != null &&
          !widget.arguments!.isAddMode &&
          widget.arguments!.values != null) {
        user = widget.arguments!.values!;
        nome.text = user!.name;
        email.text = user!.email;
      }
    });
  }

  Future<void> onSubmit(context) async {
    if (formKey.currentState!.validate()) {
      final emailText = email.text;
      final nomeText = nome.text;

      if (widget.arguments == null || widget.arguments!.isAddMode) {
        final senhaText = senha.text;
        try {
          await _controller.create(
            emailText,
            senhaText,
            nomeText,
            isAdmin,
            false,
          );

          Navigator.of(context).pop();
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                e.toString(),
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }

        return;
      }

      try {
        await _controller.update(
          widget.arguments!.id!,
          name: nomeText,
          isAdmin: isAdmin,
          email: widget.arguments!.isFromMyAccount != null &&
                  widget.arguments!.isFromMyAccount == true &&
                  email.text.isNotEmpty &&
                  email.text != _authController.getAuthenticatedUser().email
              ? email.text
              : null,
        );

        if (widget.arguments!.isFromMyAccount != null &&
            widget.arguments!.isFromMyAccount == true) {
          if (senha.text.isNotEmpty) {
            await _authController.updatePassword(senha.text);
          }

          if (email.text.isNotEmpty &&
              (email.text != _authController.getAuthenticatedUser().email)) {
            await _authController.updateEmail(email.text);
          }

          _authController.setAuthenticatedUser(await _controller
              .getByUid(_authController.getAuthenticatedUser().uid));
        }

        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString(),
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Regex do email - validação
    final theme = Theme.of(context);
    final RegExp regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          widget.arguments == null || widget.arguments!.isAddMode
              ? "Adicionar usuário"
              : "Editar usuário",
          style: theme.textTheme.titleMedium!.copyWith(
            color: Colors.white,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary,
              Colors.white,
            ],
            begin: const FractionalOffset(0, 0),
            end: const FractionalOffset(0, 1),
            stops: const [0, .65],
            tileMode: TileMode.clamp,
          ),
        ),
        padding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 8,
        ),
        child: Card(
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: Form(
              key: formKey,
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: TextFormField(
                        controller: nome,
                        decoration: const InputDecoration(
                          labelText: "Nome",
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira um nome';
                          }
                          return null;
                        },
                      ),
                    ),
                    widget.arguments == null ||
                            widget.arguments!.isAddMode ||
                            (widget.arguments!.isFromMyAccount != null &&
                                widget.arguments!.isFromMyAccount == true)
                        ? Padding(
                            padding: const EdgeInsets.only(bottom: 10.0),
                            child: TextFormField(
                              controller: email,
                              decoration: const InputDecoration(
                                labelText: "E-mail",
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor, insira um e-mail';
                                }
                                if (!regex.hasMatch(value)) {
                                  return 'Por favor, insira um e-mail válido';
                                }
                                return null;
                              },
                            ),
                          )
                        : Container(),
                    widget.arguments == null ||
                            widget.arguments!.isAddMode ||
                            (widget.arguments!.isFromMyAccount != null &&
                                widget.arguments!.isFromMyAccount == true)
                        ? Padding(
                            padding: const EdgeInsets.only(bottom: 10.0),
                            child: TextFormField(
                              controller: senha,
                              obscureText: true,
                              decoration: const InputDecoration(
                                labelText: "Senha",
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if ((widget.arguments!.isFromMyAccount !=
                                        null &&
                                    widget.arguments!.isFromMyAccount ==
                                        true)) {
                                  return null;
                                }
                                if (value == null || value.isEmpty) {
                                  return 'Por favor, insira uma senha';
                                }
                                if (value.length < 8) {
                                  return 'Por favor, insira uma senha válida';
                                }
                                return null;
                              },
                            ),
                          )
                        : Container(),
                    widget.arguments == null ||
                            (widget.arguments!.isFromMyAccount != null &&
                                widget.arguments!.isFromMyAccount == true)
                        ? Container()
                        : Padding(
                            padding: const EdgeInsets.only(bottom: 10.0),
                            child: ButtonTheme(
                              alignedDropdown: false,
                              child: DropdownButtonHideUnderline(
                                child: DropdownButtonFormField(
                                  validator: (value) {
                                    if (value == null) {
                                      return 'Por favor, insira o tipo de usuário';
                                    }
                                    return null;
                                  },
                                  value: user == null
                                      ? typeUser.values.first
                                      : user!.isAdmin,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: "Tipo de Usuário",
                                  ),
                                  items: typeUser.entries
                                      .map<DropdownMenuItem>((value) {
                                    return DropdownMenuItem(
                                      value: value.value,
                                      child: Text(value.key),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      isAdmin = value;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),
                    SizedBox(
                      height: 40,
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => onSubmit(context),
                        child: Text(widget.arguments == null ||
                                widget.arguments!.isAddMode
                            ? "Cadastrar"
                            : "Editar"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
