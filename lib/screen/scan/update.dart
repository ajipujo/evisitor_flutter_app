import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uts_flutter/screen/home_page.dart';
import 'package:uts_flutter/screen/login_page.dart';
import 'package:http/http.dart' as http;
import 'package:uts_flutter/screen/scan/report_visit.dart';

class Update extends StatefulWidget {
  Update({required this.id});
  String? id;

  @override
  State<Update> createState() => _UpdateState();
}

class _UpdateState extends State<Update> {
  final _formKey = GlobalKey<FormState>();

  String username = "";
  var status_visit = TextEditingController();
  var status_done = TextEditingController();

  String? id_visitor,
      schedule_date,
      host,
      time_schedule,
      invitation_code,
      email,
      no_phone,
      full_name,
      company,
      address,
      status,
      visitor_code,
      security;

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

  _getDataSecurity() async {
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      var islogin = pref.getBool("is_login");
      setState(() {
        username = pref.getString("username")!;
      });
      print(username);
      final response = await http.get(Uri.parse(
          "https://nscis.nsctechnology.com/index.php?r=t-visitor/view-security&id=$username"));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          security = data['item_name'];
        });
      }
    } catch (e) {
      print(e);
    }
  }

  _getData() async {
    try {
      final response = await http.get(Uri.parse(
          "http://nscis.nsctechnology.com/index.php?r=t-visitor/view-api&id=${widget.id}"));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          schedule_date = data['schedule_date'];
          time_schedule = data['time_schedule'];
          status = data['status'];
          full_name = data['full_name'];
          email = data['email'];
          no_phone = data['no_phone'];
          full_name = data['full_name'];
          company = data['company'];
          address = data['address'];
          status_visit = TextEditingController(text: 'Validasi');
          status_done = TextEditingController(text: 'Finish');
          id_visitor = data['id_visitor'];
        });
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    getPref();
    _getData();
    _getDataSecurity();
  }

  Future _onUpdateSecurity(context) async {
    EasyLoading.show(status: 'Saving...');
    try {
      return await http.post(
        Uri.parse(
            "https://nscis.nsctechnology.com/index.php?r=t-visitor/update-api"),
        body: {
          "id_visitor": id_visitor,
          "status": "Validasi",
        },
      ).then((value) {
        EasyLoading.showSuccess('data successfully saved');
        var data = jsonDecode(value.body);
        print(data["message"]);

        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const HomePage()),
            (Route<dynamic> route) => false);
        EasyLoading.dismiss();
      });
    } catch (e) {
      print(e);
    }
  }

  Future _onUpdateHost(context) async {
    EasyLoading.show(status: 'Saving...');
    try {
      return await http.post(
        Uri.parse(
            "https://nscis.nsctechnology.com/index.php?r=t-visitor/update-api"),
        body: {
          "id_visitor": id_visitor,
          "status": "Finish",
        },
      ).then((value) {
        EasyLoading.showSuccess('data successfully saved');
        var data = jsonDecode(value.body);
        print(data["message"]);
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const ReportVisit()),
            (Route<dynamic> route) => false);
        EasyLoading.dismiss();
      });
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
                  'Date: $schedule_date',
                  style: const TextStyle(color: Colors.black),
                ),
                Text(
                  'Time: $time_schedule',
                  style: const TextStyle(color: Colors.black),
                ),
                Text(
                  'Name: $full_name',
                  style: const TextStyle(color: Colors.black),
                ),
                Text(
                  'Company: $company',
                  style: const TextStyle(color: Colors.black),
                ),
                Text(
                  'Email: $email',
                  style: const TextStyle(color: Colors.black),
                ),
                Text(
                  'Phone Number: $no_phone',
                  style: const TextStyle(color: Colors.black),
                ),
                Text(
                  'Status: $status',
                  style: const TextStyle(color: Colors.black),
                ),
                Text(
                  'Address: $address',
                  style: const TextStyle(color: Colors.black),
                ),
                const SizedBox(
                  height: 10,
                ),
                if (status == 'Created' && security == 'security')
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: const Text(
                        "Accept",
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _onUpdateSecurity(context);
                        }
                      },
                    ),
                  ),
                if (status == 'Validasi' && username == host)
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: const Text(
                        "Accept",
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _onUpdateHost(context);
                        }
                      },
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
