import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:date_time_picker/date_time_picker.dart';

String userID = "";
String name = "";
String date = "";
String groupSelected = "";
int currFields = 0;
List<String> emails = [];
List<dynamic> groupList = [];
List<String> groupNameList = [];
Map<String, String> groupMapping = {};

class TripCreatePage extends StatefulWidget {
  const TripCreatePage({Key? key}) : super(key: key);

  @override
  State<TripCreatePage> createState() {
    return _TripCreatePageState();
  }
}

class _TripCreatePageState extends State<TripCreatePage> {
  @override
  initState() {
    super.initState();
    initStateFunction();
  }

  initStateFunction() async {
    var prefs = await SharedPreferences.getInstance();
    userID = prefs.getString('userID')!;
    Response response = await post(Uri.parse('http://www.squadzz.us/getGroups'),
        headers: {
          "Content-type": "application/json",
          "Origin": "*",
        },
        body: jsonEncode({"userID": userID}));
    var responseJSON = jsonDecode(response.body);
    setState(() {
      groupList = responseJSON["groups"];
      groupNameList = [];
      for(var group in groupList){
        groupNameList.add(group["name"]);
        groupMapping[group["name"]] = group["id"];
      }
    });
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
        title: const Text("Create Trip"),
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
                decoration: const InputDecoration(hintText: "Trip Name"),
                onChanged: (String str) {
                  setState(() {
                    name = str;
                  });
                },
              ),
            ),
            Padding(
                padding: const EdgeInsets.only(left: 30.0, right: 30.0),
                child: DateTimePicker(
                  type: DateTimePickerType.date,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                  dateLabelText: "Trip Date",
                  onChanged: (val) {
                    date = val;
                  },
                )),
            Padding(
                padding: const EdgeInsets.only(left: 30.0, right: 30.0),
                child: Autocomplete<String>(
                  onSelected: (groupName){
                    groupSelected = groupName;
                  },
              optionsBuilder: (TextEditingValue textEditingValue) {
                return groupNameList.where((String group) {
                  return group.toLowerCase().contains(textEditingValue.text.toLowerCase());
                });
              }
            ),),
            for (int i = 0; i < currFields; i++)
              Padding(
                padding: const EdgeInsets.only(left: 30.0, right: 30.0),
                child: TextField(
                  decoration:
                      InputDecoration(hintText: "Additional Member ${i + 1} Email"),
                  onChanged: (String str) {
                    setState(() {
                      emails[i] = str;
                    });
                  },
                ),
              ),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              ElevatedButton(
                  onPressed: currFields == 0
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
                          Uri.parse('http://www.squadzz.us/createTrip'),
                          headers: {
                            "Content-type": "application/json",
                            "Origin": "*",
                          },
                          body: jsonEncode({
                            "userID": userID,
                            "tripName": name,
                            "groupID": groupMapping[groupSelected],
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
