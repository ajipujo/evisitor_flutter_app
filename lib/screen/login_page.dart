import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:uts_flutter/widgets/dialogs.dart';
import 'package:uts_flutter/screen/home_page.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class HeadClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height);
    path.quadraticBezierTo(
        size.width / 4, size.height - 40, size.width / 2, size.height - 20);
    path.quadraticBezierTo(
        3 / 4 * size.width, size.height, size.width, size.height - 30);
    path.lineTo(size.width, 0);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  var txtEditUsername = TextEditingController();
  var txtEditPwd = TextEditingController();

  Widget inputUsername() {
    return TextFormField(
      cursorColor: Colors.green[800],
      keyboardType: TextInputType.text,
      autofocus: false,
      validator: (String? arg) {
        if (arg == null || arg.isEmpty) {
          return 'Username can not blank';
        } else {
          return null;
        }
      },
      controller: txtEditUsername,
      onSaved: (String? val) {
        txtEditUsername.text = val!;
      },
      decoration: InputDecoration(
        hintText: 'Username',
        hintStyle: TextStyle(color: Colors.green[800]),
        labelText: "Enter an Username",
        labelStyle: TextStyle(color: Colors.green[800]),
        prefixIcon: Icon(
          Icons.person,
          color: Colors.green[800],
        ),
        fillColor: Colors.white,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25.0),
          borderSide: BorderSide(
            color: (Colors.green[800])!,
            width: 2.0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25.0),
          borderSide: BorderSide(
            color: (Colors.green[800])!,
          ),
        ),
      ),
      style: TextStyle(fontSize: 16.0, color: Colors.green[800]),
    );
  }

  Widget inputPassword() {
    return TextFormField(
      cursorColor: Colors.green[800],
      keyboardType: TextInputType.text,
      autofocus: false,
      obscureText: true,
      validator: (String? arg) {
        if (arg == null || arg.isEmpty) {
          return 'Password can not blank';
        } else {
          return null;
        }
      },
      controller: txtEditPwd,
      onSaved: (String? val) {
        txtEditPwd.text = val!;
      },
      decoration: InputDecoration(
        hintText: 'Password',
        hintStyle: TextStyle(color: Colors.green[800]),
        labelText: "Enter a Password",
        labelStyle: TextStyle(color: Colors.green[800]),
        prefixIcon: Icon(
          Icons.lock_outline,
          color: Colors.green[800],
        ),
        fillColor: Colors.green[800],
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25.0),
          borderSide: BorderSide(
            color: (Colors.green[800])!,
            width: 2.0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25.0),
          borderSide: BorderSide(
            color: (Colors.green[800])!,
            // width: 2.0,
          ),
        ),
      ),
      style: TextStyle(fontSize: 16.0, color: Colors.green[800]),
    );
  }

  void _validateInputs() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      doLogin(txtEditUsername.text, txtEditPwd.text);
    }
  }

  doLogin(username, password) async {
    final GlobalKey<State> _keyLoader = GlobalKey<State>();
    Dialogs.loading(context, _keyLoader, "Proses ...");

    try {
      final response = await http.post(
          Uri.parse("https://nscis.nsctechnology.com/index.php?r=auth/login"),
          body: {
            "username": username,
            "password": password,
          }).then(
        (value) {
          var data = jsonDecode(value.body);
          Navigator.of(_keyLoader.currentContext!, rootNavigator: false).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                data['message'],
                style: const TextStyle(fontSize: 16),
              ),
            ),
          );

          if (data['success'] == true) {
            saveSession(username);
          }
        },
      );
    } catch (e) {
      Navigator.of(_keyLoader.currentContext!, rootNavigator: false).pop();
      Dialogs.popUp(context, '$e');
      debugPrint('$e');
    }
  }

  saveSession(String username) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setString("username", username);
    await pref.setBool("is_login", true);
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => HomePage(),
      ),
      (route) => false,
    );
  }

  void ceckLogin() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var islogin = pref.getBool("is_login");
    if (islogin != null && islogin) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => HomePage(),
        ),
        (route) => false,
      );
    }
  }

  @override
  void initState() {
    ceckLogin();
    super.initState();
  }

  @override
  dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        margin: const EdgeInsets.all(0),
        // decoration: const BoxDecoration(
        //   gradient: LinearGradient(
        //     begin: Alignment.topCenter,
        //     end: Alignment.bottomCenter,
        //     colors: [Colors.grey, Color.fromARGB(255, 5, 6, 6)],
        //   ),
        // ),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              ClipPath(
                clipper: HeadClipper(),
                child: Container(
                  margin: const EdgeInsets.all(0),
                  width: double.infinity,
                  height: 180,
                  decoration: const BoxDecoration(
                    color: Colors.white24,
                    image: DecorationImage(
                      image: AssetImage('assets/images/biu.png'),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(8.0),
                alignment: Alignment.center,
                child: const Text(
                  "LOGIN APP BIU-HRIS",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.only(top: 35.0, left: 20.0, right: 20.0),
                child: Column(
                  children: <Widget>[
                    inputUsername(),
                    const SizedBox(height: 20.0),
                    inputPassword(),
                    const SizedBox(height: 5.0),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.only(top: 35.0, left: 20.0, right: 20.0),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[800],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      side: BorderSide(
                        color: (Colors.green[800])!,
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.arrow_right_alt),
                  onPressed: () => _validateInputs(),
                  label: const Text(
                    "Hello",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
