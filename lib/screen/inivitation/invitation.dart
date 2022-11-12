import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:http/http.dart' as http;
// import 'package:biu_project/invitation/view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uts_flutter/screen/inivitation/add.dart';
import 'package:uts_flutter/screen/sample_page.dart';
import '../login_page.dart';
// import 'add.dart';

class MainInvite extends StatefulWidget {
  const MainInvite({super.key});

  @override
  State<MainInvite> createState() => _MainInviteState();
}

class _MainInviteState extends State<MainInvite> {
  String id = "";
  String username = "";
  List _get = [];

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
        ),
      ),
    );
  }

  final _lightColors = [
    Colors.amber.shade300,
    Colors.lightGreen.shade300,
    Colors.lightBlue.shade300,
    Colors.orange.shade300,
    Colors.pinkAccent.shade100,
    Colors.tealAccent.shade100
  ];

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
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      var islogin = pref.getBool("is_login");
      setState(() {
        username = pref.getString("username")!;
      });

      final response = await http.get(Uri.parse(
          "https://nscis.nsctechnology.com/index.php?r=t-invitation/invitation-api&id=$username"));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _get = data;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.grey[600],
      appBar: AppBar(
        backgroundColor: Colors.green[800],
        elevation: 0,
//leading: Icon(Icons.menu),
        title: const Text(
          "BIU",
          style: TextStyle(fontWeight: FontWeight.bold),
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
      body: _get.isNotEmpty
          ? MasonryGridView.count(
              crossAxisCount: 2,
              itemCount: _get.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          // builder: (context) => View(
                          //   id: _get[index]['id_invitation'],
                          // ),
                          builder: (context) => const SamplePage()),
                    );
                  },
                  child: Card(
                    color: _lightColors[index % _lightColors.length],
                    child: Container(
                      padding: EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Date: ${_get[index]['schedule_date']}',
                            style: const TextStyle(color: Colors.black),
                          ),
                          Text(
                            'Time: ${_get[index]['time_schedule']}',
                            style: const TextStyle(color: Colors.black),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Invitation Code: ${_get[index]['invitation_code']}',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Status: ${_get[index]['status']}',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Desc: ${_get[index]['description']}',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            )
          : const Center(
              child: Text(
                "No Data Available",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 50.0),
        child: FloatingActionButton.extended(
          backgroundColor: Colors.green[800],
          elevation: 4.0,
          icon: const Icon(Icons.add_rounded),
          label: const Text('Add Guest'),
          onPressed: () {
            Navigator.push(
                context,
//routing into add page
                MaterialPageRoute(builder: (context) => Add()));
          },
        ),
      ),
    );
  }
}
