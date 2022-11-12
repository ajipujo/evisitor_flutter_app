import 'dart:async';

import "package:flutter/material.dart";
import "./login_page.dart";

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  final Color backgroundColor = Colors.white;
  final TextStyle styleTextUnderTheLoader = const TextStyle(
      fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.black);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String _versionName = 'V1.0';
  final splashDelay = 7;
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    _loadWidget();
  }

  _loadWidget() async {
    var duration = Duration(seconds: splashDelay);
    return Timer(duration, navigationPage);
  }

  void navigationPage() {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => const LoginPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: InkWell(
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  flex: 4,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Image.asset(
                        'assets/images/biu.png',
                        height: 150,
                        width: 150,
                      ),
                      Text(
                        "BIU - Human Resource",
                        style: TextStyle(
                            color: Colors.green[800],
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(top: 10.0),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: <Widget>[
                      CircularProgressIndicator(
                        color: Colors.green[800],
                      ),
                      Container(
                        height: 100,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          const Spacer(),
                          Text(
                            _versionName,
                            style: TextStyle(
                                color: Colors.green[800],
                                fontSize: 12,
                                fontWeight: FontWeight.bold),
                          ),
                          const Spacer(
                            flex: 4,
                          ),
                          Text(
                            'Bina Insani University',
                            style: TextStyle(
                                color: Colors.green[800],
                                fontSize: 12,
                                fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                        ],
                      )
                    ],
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
