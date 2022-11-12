import 'dart:async';
import 'dart:convert';

import "package:flutter/material.dart";
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uts_flutter/screen/clocking.dart';
import 'package:uts_flutter/screen/login_page.dart';
import 'package:http/http.dart' as http;
import 'package:uts_flutter/screen/sample_page.dart';

// class HomePage extends StatelessWidget {
//   const HomePage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Container();
//   }
// }

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String photo = "";
  String username = "";
  String firstName = "";
  String lastName = "";
  List precenseUser = [];
  Timer? _timer;

  getPref() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var islogin = pref.getBool("is_login");
    if (islogin != null && islogin == true) {
      setState(() {
        username = pref.getString("username")!;
      });
    } else {
      Navigator.of(context, rootNavigator: true).pop();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => LoginPage(),
        ),
        (route) => false,
      );
    }
  }

  logOut() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      preferences.remove("is_login");
      preferences.remove("username");
    });

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => LoginPage(),
      ),
      (route) => false,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Berhasil logout",
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    getPref();
    _getData();
    _getPrecence();
  }

  Future _getData() async {
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      var islogin = pref.getBool("is_login");
      setState(() {
        username = pref.getString("username")!;
      });
      print(username);
      final response = await http.get(Uri.parse(
//you have to take the ip address of your computer. //because using localhost will cause an error
//get detail data with id
          "https://nscis.nsctechnology.com/index.php?r=user/view-api&id=" +
              username));
// if response successful
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          photo = data["photo"];
          firstName = data["first_name"];
          lastName = data["last_name"];
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future _getPrecence() async {
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      var islogin = pref.getBool("is_login");
      setState(() {
        username = pref.getString("username")!;
      });
      final response = await http.get(
        Uri.parse(
            "https://nscis.nsctechnology.com/index.php?r=precense/user-api&id='${username}'"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          precenseUser = data;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[600],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const Icon(Icons.menu),
        title: const Text("BIU"),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              logOut();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(20.0),
          child: Column(
            children: <Widget>[
              Container(
                width: double.infinity,
                height: 180,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(
                      image: AssetImage('assets/images/background1.jpg'),
                      fit: BoxFit.cover),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      begin: Alignment.bottomRight,
                      colors: [
                        Colors.black.withOpacity(.4),
                        Colors.black.withOpacity(.2),
                      ],
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        "Hi, $firstName $lastName",
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                      const Text(
                        "Welcome to N-HR Mobile",
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                        height: 50,
                        margin: const EdgeInsets.symmetric(horizontal: 40),
                        child: Center(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => Clocking(),
                                  // builder: (_) => const SamplePage(),
                                ),
                              );
                              setState(() {});
                            },
                            icon: const Icon(Icons.arrow_right_alt),
                            label: const Text(
                              "Clocking",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              SizedBox(
                height: 30,
                child: Column(
                  children: const [
                    Text(
                      "MENU",
                      textAlign: TextAlign.right,
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    )
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  child: GridView(
                    shrinkWrap: true,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    children: [
                      GestureDetector(
                        onTap: () async {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              // builder: (_) => MainInvite(),
                              builder: (_) => const SamplePage(),
                            ),
                          );
                          setState(() {});
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.grey,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                Icons.insert_invitation,
                                size: 50,
                                color: Colors.amber,
                              ),
                              SizedBox(
                                height: 3,
                              ),
                              Text(
                                "Invitation",
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              // builder: (_) => const QRViewExample(),
                              builder: (_) => const SamplePage(),
                            ),
                          );
                          setState(() {});
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.grey,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                Icons.qr_code_scanner,
                                size: 50,
                                color: Colors.amber,
                              ),
                              SizedBox(
                                height: 3,
                              ),
                              Text(
                                "Scanner",
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              // builder: (_) => ReportVisit(),
                              builder: (_) => const SamplePage(),
                            ),
                          );
                          setState(() {});
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.grey,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                Icons.file_copy_outlined,
                                size: 50,
                                color: Colors.amber,
                              ),
                              SizedBox(
                                height: 3,
                              ),
                              Text(
                                "Data Visit",
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              // builder: (_) => Report(),
                              builder: (_) => const SamplePage(),
                            ),
                          );
                          setState(() {});
                        },
                      )
                    ],
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
