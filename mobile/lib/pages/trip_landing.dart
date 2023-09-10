import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:squadzz/pages/trip_create.dart';
// import 'package:squadzz/pages/trip_create.dart';

String userID = "";
List<dynamic> displayList = [];

class TripLandingPage extends StatefulWidget {
  const TripLandingPage({Key? key}) : super(key: key);

  @override
  State<TripLandingPage> createState() {
    return _TripLandingPageState();
  }
}

class _TripLandingPageState extends State<TripLandingPage> {
  @override
  initState() {
    super.initState();
    initStateFunction();
  }

  initStateFunction() async {
    var prefs = await SharedPreferences.getInstance();
    userID = prefs.getString('userID')!;
    Response response = await post(Uri.parse('http://www.squadzz.us/getTrips'),
        headers: {
          "Content-type": "application/json",
          "Origin": "*",
        },
        body: jsonEncode({"userID": userID}));
    var responseJSON = jsonDecode(response.body);
    setState(() {
      displayList = responseJSON["trips"];
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
                  child: const Text("OK"),
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
                  child: const Text("OK"),
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
        title: const Text("Squadzz Trips"),
        actions: <Widget>[
          IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () async {
                Response response =
                    await post(Uri.parse('http://www.squadzz.us/getTrips'),
                        headers: {
                          "Content-type": "application/json",
                          "Origin": "*",
                        },
                        body: jsonEncode({"userID": userID}));
                var responseJSON = jsonDecode(response.body);
                setState(() {
                  displayList = responseJSON["trips"];
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
                            text: 'Squadzz Trips\n',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline),
                          ),
                          TextSpan(
                            text:
                                'This screen will allow you to view your trips and access all related details. Press the refresh icon to see newly created trips.\n',
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
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const TripCreatePage()));
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.group),
              onPressed: () {
                Navigator.pushReplacementNamed(context, "/groups");
              },
            ),
            IconButton(
              icon: const Icon(Icons.travel_explore),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.image),
              onPressed: () {
                Navigator.pushReplacementNamed(context, "/photos");
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

                        // TODO: Navigate to trip details
                        // Navigator.push(
                        //     context,
                        //     MaterialPageRoute(
                        //         builder: (context) => TripDetailPage(
                        //             tripID: displayList[index]["id"])));
                      },
                      title: Text(displayList[index]["name"]!),
                      subtitle: const Text("Location")),
                ));
          }),
    );
  }
}
