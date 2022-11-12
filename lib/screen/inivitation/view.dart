import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:uts_flutter/screen/login_page.dart';

class View extends StatefulWidget {
  View({required this.id});
  String id;

  @override
  State<View> createState() => _ViewState();
}

class _ViewState extends State<View> {
  final _formKey = GlobalKey<FormState>();

  String username = "";
  var code = TextEditingController();
  var address = TextEditingController();
  String? schedule_date, invitation_code, time_schedule, status, description;

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
          builder: (BuildContext context) => const LoginPage(),
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
        builder: (BuildContext context) => const LoginPage(),
      ),
      (route) => false,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text(
        "Berhasil logout",
        style: TextStyle(fontSize: 16),
      )),
    );
  }

  @override
  dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
//in first time, this method will be executed getPref();
    _getData();
  }

  Future _getData() async {
    try {
      final response = await http.get(Uri.parse(
          "https://nscis.nsctechnology.com/index.php?r=t-invitation/view-api&id=${widget.id}"));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          schedule_date = data['schedule_date'];
          time_schedule = data['time_schedule'];
          status = data['status'];
          description = data['description'];
        });
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[800],
        elevation: 2,
        title: const Text(
          "BIU",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              logOut();
            },
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Card(
          child: Container(
            height: 200,
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Invitation Code: $invitation_code',
                  style: const TextStyle(color: Colors.black),
                ),
                Text(
                  'Date: $schedule_date',
                  style: const TextStyle(color: Colors.black),
                ),
                Text(
                  'Time: $time_schedule',
                  style: const TextStyle(color: Colors.black),
                ),
                Text(
                  'Status: $status',
                  style: const TextStyle(color: Colors.black),
                ),
                Text(
                  'Description: $description',
                  style: const TextStyle(color: Colors.black),
                ),
                const SizedBox(
                  height: 10,
                ),
                if (status == 'Created')
                  Center(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          side: const BorderSide(color: Colors.white),
                        ),
                        elevation: 10,
                        minimumSize: const Size(150, 40),
                      ),
                      onPressed: () async {
                        const visit =
                            'Detail information, please visit the site';
                        const url =
                            'https://nscis.nsctechnology.com/index.php?r=site%2Fvisit';
                        const info =
                            'Select the "Visit" menu and insert these codes:';
                        await Share.share('$visit $url $info $invitation_code');
                      },
                      icon: const Icon(Icons.share),
                      label: const Text(
                        "Share",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
