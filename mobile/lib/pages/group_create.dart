import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

String userID = "";
String name = "";
int currFields = 1;
List<String> emails = [""];

class GroupCreatePage extends StatefulWidget {
  const GroupCreatePage({Key? key}) : super(key: key);

  @override
  State<GroupCreatePage> createState() {
    return _GroupCreatePageState();
  }
}

class _GroupCreatePageState extends State<GroupCreatePage> {
  @override
  initState() {
    super.initState();
    initStateFunction();
  }

  initStateFunction() async {
    var prefs = await SharedPreferences.getInstance();
    userID = prefs.getString('userID')!;
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    Future createAlertDialog(BuildContext context, String title, String body) {
      return showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
                title: Text(title),
                content: Text(body),
                actions: <Widget>[
                  MaterialButton(
                    elevation: 5.0,
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text("OK"),
                  )
                ]);
          });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Group"),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 30.0, right: 30.0),
              child: TextField(
                decoration: const InputDecoration(hintText: "Group Name"),
                onChanged: (String str) {
                  setState(() {
                    name = str;
                  });
                },
              ),
            ),
            for (int i = 0; i < currFields; i++)
              Padding(
                padding: const EdgeInsets.only(left: 30.0, right: 30.0),
                child: TextField(
                  decoration:
                      InputDecoration(hintText: "Group Member ${i + 1} Email"),
                  onChanged: (String str) {
                    setState(() {
                      emails[i] = str;
                    });
                  },
                ),
              ),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              ElevatedButton(
                  onPressed: currFields == 1
                      ? null
                      : () {
                          setState(() {
                            currFields--;
                          });
                        },
                  child: const Text("- Email")),
              const Padding(padding: EdgeInsets.all(10.0)),
              ElevatedButton(
                  onPressed: () {
                    setState(() {
                      currFields++;
                    });
                  },
                  child: const Text("+ Email")),
            ]),
            ListTile(
                title: ElevatedButton(
                    onPressed: () async {
                      Response response = await post(
                          Uri.parse('http://www.squadzz.us/createGroup'),
                          headers: {
                            "Content-type": "application/json",
                            "Origin": "*",
                          },
                          body: jsonEncode({
                            "userID": userID,
                            "groupName": name,
                            "memberInfo": emails
                          }));
                      if (response.statusCode == 200) {
                        if (context.mounted) {
                          Navigator.of(context).pop();
                        }
                      } else {
                        if (context.mounted) {
                          createAlertDialog(context, "Invalid group",
                              "You have included email addresses that do not have associated Squadzz accounts. Please check the emails and try again.");
                        }
                      }
                    },
                    child: const Text("Submit"))),
          ],
        ),
      ),
    );
  }
}
