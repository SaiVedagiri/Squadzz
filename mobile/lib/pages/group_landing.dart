import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:async';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../helpers/hex_color.dart';

String userID = "";
List<dynamic> displayList = [];

class GroupLandingPage extends StatefulWidget {
  const GroupLandingPage({Key? key}) : super(key: key);

  @override
  State<GroupLandingPage> createState() {
    return _GroupLandingPageState();
  }
}

class _GroupLandingPageState extends State<GroupLandingPage> {
  @override
  initState() {
    super.initState();
    initStateFunction();
  }

  initStateFunction() async {
    var prefs = await SharedPreferences.getInstance();
    userID = prefs.getString('userID')!;
    Response response =
        await post(Uri.parse('http://www.squadzz.us/getGroups'),
            headers: {
              "Content-type": "application/json",
              "Origin": "*",
            },
            body: jsonEncode({"userID": userID}));
    var responseJSON = jsonDecode(response.body);
    setState(() {
      displayList = responseJSON["groups"];
    });
  }

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
                  child: Text("OK"),
                )
              ]);
        });
  }

  Future helpContext(BuildContext context, String title, Widget body) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              title: Text(title),
              content: body,
              actions: <Widget>[
                MaterialButton(
                  elevation: 5.0,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("OK"),
                )
              ]);
        });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Squadzz Groups"),
        actions: <Widget>[
          IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () async {
                Response response =
                    await post(Uri.parse('http://www.squadzz.us/getGroups'),
                        headers: {
                          "Content-type": "application/json",
                          "Origin": "*",
                        },
                        body: jsonEncode({"user_id": userID}));
                var responseJSON = jsonDecode(response.body);
                setState(() {
                  displayList = responseJSON["groups"];
                });
              }),
          IconButton(
              icon: const Icon(Icons.help),
              onPressed: () async {
                helpContext(
                    context,
                    "Help",
                    const Text.rich(
                      TextSpan(
                        children: <TextSpan>[
                          TextSpan(
                            text: 'Squadzz Groups\n',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline),
                          ),
                          TextSpan(
                            text:
                                'This screen will allow you to view your groups and access your group chats. Press the refresh icon to see newly added groups.\n',
                            style: TextStyle(fontSize: 20),
                          ),
                        ],
                      ),
                    ));
              }),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add your onPressed code here!
        },
        child: Icon(Icons.chat),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.group),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.travel_explore),
              onPressed: () {
                Navigator.pushReplacementNamed(context, "/trips");
              },
            ),
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                Navigator.pushReplacementNamed(context, "/settings");
              },
            ),
          ],
        ),
      ),
      body: ListView.builder(
          itemCount: displayList.length,
          itemBuilder: (context, index) {
            return Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 1.0, horizontal: 4.0),
                child: Card(
                  child: ListTile(
                      onTap: () {
                        dispose() {
                          SystemChrome.setPreferredOrientations([
                            DeviceOrientation.landscapeRight,
                            DeviceOrientation.landscapeLeft,
                            DeviceOrientation.portraitUp,
                            DeviceOrientation.portraitDown,
                          ]);
                          super.dispose();
                        }

                        // TODO: Navigate to group chat
                        // Navigator.push(
                        //     context,
                        //     MaterialPageRoute(
                        //         builder: (context) => GroupChatPage(
                        //             groupID: displayList[index]["id"])));
                      },
                      leading: const CircleAvatar(
                        backgroundImage: AssetImage('assets/images/gc.png'),
                      ),
                      title: Text(displayList[index]["name"]!),
                      subtitle: const Text("lastMessage")),
                ));
          }),
    );
  }
}
