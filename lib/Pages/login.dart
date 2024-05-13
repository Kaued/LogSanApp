import 'package:flutter/material.dart';
import 'package:logsan_app/Controllers/auth_controller.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final txtEmail = TextEditingController();
  final txtPassword = TextEditingController();
  bool _obscureText = true;
  final authController = AuthController.instance;

  Future<void> _login(context) async {
    try {
      // var userData = await firestore
      //     .collection("usersRoles")
      //     .where('__name__', isEqualTo: user!.uid)
      //     .get();

      // bool isAdmin = userData.docs.first['isAdmin'];

      // String route = '/home';
      // if (isAdmin) {
      //   route = '/home';
      // }
      var isSuccessLogin = await authController.login(txtEmail.text, txtPassword.text);

      if (isSuccessLogin) {
        Navigator.of(context).pushReplacementNamed('/casquinha');
      }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/background2.png"),
            fit: BoxFit.cover,
            // opacity: 0.5,
          ),
          // color: Colors.black,
        ),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(22),
            height: 260, // 430
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // const Image(
                //   image: AssetImage("assets/images/logo.png"),
                // ),
                const Text(
                  "LOGSAN",
                  style: TextStyle(
                    color: Colors.black, // Colors.white
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextField(
                  style: const TextStyle(
                    color: Colors.black,
                  ),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    fillColor: Colors.white,
                    filled: true,
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color.fromRGBO(99, 140, 244, 1),
                      ),
                    ),
                    hintText: "seuemail@email.com",
                    hintStyle: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  controller: txtEmail,
                ),
                TextField(
                  style: const TextStyle(
                    color: Colors.black,
                  ),
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    fillColor: Colors.white,
                    filled: true,
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color.fromRGBO(99, 140, 244, 1),
                      ),
                    ),
                    hintText: "sua senha",
                    hintStyle: const TextStyle(
                      color: Colors.black,
                    ),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                      icon: Icon(
                        _obscureText ? Icons.visibility : Icons.visibility_off,
                        color: Colors.black,
                      ),
                    ),
                    // apply padding to the right of the button
                    suffixIconConstraints: const BoxConstraints.tightFor(
                      width: 60,
                      height: 48,
                    ),
                  ),
                  obscureText: _obscureText,
                  controller: txtPassword,
                ),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(17),
                          backgroundColor: const Color.fromRGBO(
                              14, 83, 255, 1), // 99, 140, 244, 1
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        child: const Text(
                          "Login",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: () => _login(context),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
