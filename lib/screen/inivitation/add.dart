import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uts_flutter/screen/inivitation/invitation.dart';
import 'package:uts_flutter/screen/login_page.dart';
import 'package:http/http.dart' as http;

class Add extends StatefulWidget {
  const Add({super.key});

  @override
  State<Add> createState() => _AddState();
}

class _AddState extends State<Add> {
  final _formKey = GlobalKey<FormState>();
  String id = "";
  String username = "";

  var desc = TextEditingController();
  var IDUser = TextEditingController();
  final _dateC = TextEditingController();
  final _timeC = TextEditingController();

  DateTime selected = DateTime.now();
  DateTime initial = DateTime(2000);
  DateTime last = DateTime(2025);

  TimeOfDay timeOfDay = TimeOfDay.now();

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
    _getData();
  }

  Future _getData() async {
    print(username);
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      var islogin = pref.getBool("is_login");
      setState(() {
        username = pref.getString("username")!;
      });
      final response = await http.get(Uri.parse(
          "https://nscis.nsctechnology.com/index.php?r=user/view-api&id=$username"));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          id = data["id"];
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future _onSubmit() async {
    try {
      EasyLoading.show(status: 'Saving...');
      return await http.post(
        Uri.parse(
            "https://nscis.nsctechnology.com/index.php?r=t-invitation/create-api"),
        body: {
          "user_id": id,
          "schedule_date": _dateC.text,
          "time_schedule": _timeC.text,
          "description": desc.text,
        },
      ).then((value) {
        EasyLoading.showSuccess('data successfully saved');
        var data = jsonDecode(value.body);
        print(data["message"]);
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => MainInvite()),
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
      resizeToAvoidBottomInset: false,
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
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _dateC,
                decoration: const InputDecoration(
                  labelText: 'Schedule Date',
                  border: OutlineInputBorder(),
                ),
              ),
              ElevatedButton(
                onPressed: () => displayDatePicker(context),
                child: const Text("Pick Date"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[800],
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _timeC,
                decoration: const InputDecoration(
                  labelText: 'Time',
                  border: OutlineInputBorder(),
                ),
              ),
              ElevatedButton(
                onPressed: () => displayTimePicker(context),
                child: const Text("Pick Time"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[800],
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: desc,
                keyboardType: TextInputType.multiline,
                minLines: 5,
                maxLines: null,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Note Address is Required!';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 10,
                  minimumSize: const Size(200, 45),
                  backgroundColor: Colors.green[800],
                ),
                child: const Text(
                  "Submit",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _onSubmit();
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  Future displayDatePicker(BuildContext context) async {
    var date = await showDatePicker(
      context: context,
      initialDate: selected,
      firstDate: initial,
      lastDate: last,
    );
    if (date != null) {
      setState(() {
        _dateC.text = date.toLocal().toString().split(" ")[0];
      });
    }
  }

  Future displayTimePicker(BuildContext context) async {
    var time = await showTimePicker(context: context, initialTime: timeOfDay);
    if (time != null) {
      setState(() {
        _timeC.text = "${time.hour}:${time.minute}";
      });
    }
  }
}
