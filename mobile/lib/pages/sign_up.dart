import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:async';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/hex_color.dart';

String username = "";
String password = "";
String firstName = "";
String lastName = "";
String confirmPassword = "";

GoogleSignIn googleSignIn = GoogleSignIn(
  scopes: ['email', 'profile'],
);

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() {
    return _SignUpPageState();
  }
}

class _SignUpPageState extends State<SignUpPage> {
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
    googleSignIn.signOut();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sign Up"),
        actions: <Widget>[
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
                            text: 'Sign Up\n',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline),
                          ),
                          TextSpan(
                            text: 'Create a new account.\n',
                            style: TextStyle(fontSize: 20),
                          ),
                        ],
                      ),
                    ));
              })
        ],
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 30.0, right: 30.0),
              child: TextField(
                decoration: const InputDecoration(hintText: "First Name"),
                onChanged: (String str) {
                  setState(() {
                    firstName = str;
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 30.0, right: 30.0),
              child: TextField(
                decoration: const InputDecoration(hintText: "Last Name"),
                onChanged: (String str) {
                  setState(() {
                    lastName = str;
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 30.0, right: 30.0),
              child: TextField(
                decoration: const InputDecoration(hintText: "Email Address"),
                onChanged: (String str) {
                  setState(() {
                    username = str;
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 30.0, right: 30.0),
              child: TextField(
                decoration: const InputDecoration(hintText: "Password"),
                obscureText: true,
                onChanged: (String str) {
                  setState(() {
                    password = str;
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 30.0, right: 30.0),
              child: TextField(
                decoration: const InputDecoration(hintText: "Confirm Password"),
                obscureText: true,
                onChanged: (String str) {
                  setState(() {
                    confirmPassword = str;
                  });
                },
              ),
            ),
            ListTile(
                title: ElevatedButton(
                    onPressed: () async {
                      Response response = await post(
                          Uri.parse('http://www.squadzz.us/userSignUp'),
                          headers: {
                            "Content-type": "application/json",
                            "Origin": "*"
                          },
                          body: jsonEncode({
                            "firstname": firstName,
                            "lastname": lastName,
                            "email": username,
                            "password": password,
                            "passwordconfirm": confirmPassword
                          }));
                      //createAlertDialog(context);
                      var userJSON = jsonDecode(response.body);
                      if (userJSON["success"]) {
                        var userID = userJSON["data"];
                        var prefs = await SharedPreferences.getInstance();
                        prefs.setString('userID', userID);
                        prefs.setString('userJSON', response.body);
                        dispose() {
                          SystemChrome.setPreferredOrientations([
                            DeviceOrientation.landscapeRight,
                            DeviceOrientation.landscapeLeft,
                            DeviceOrientation.portraitUp,
                            DeviceOrientation.portraitDown,
                          ]);
                          super.dispose();
                        }

                        if (context.mounted) {
                          Navigator.pushReplacementNamed(context, "/groups");
                        }
                      } else {
                        if (context.mounted) {
                          createAlertDialog(context, "Error", userJSON["data"]);
                        }
                      }
                    },
                    child: const Text("Submit"))),
            const Padding(
              padding: EdgeInsets.only(top: 30.0),
              child: Text(
                "OR",
                style: TextStyle(
                  fontSize: 20.0,
                ),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24.0)),
                backgroundColor: HexColor("ffffff"),
                // padding: const EdgeInsets.all(12.0),
              ),
              onPressed: () async {
                final GoogleSignInAccount? googleSignInAccount =
                    await googleSignIn.signIn();
                Response response = await post(
                    Uri.parse('http://www.squadzz.us/userGoogleSignIn'),
                    headers: {
                      "Content-type": "application/json",
                      "Origin": "*"
                    },
                    body: jsonEncode({
                      "email": googleSignInAccount!.email,
                      "name": googleSignInAccount.displayName!
                    }));
                //createAlertDialog(context);
                var userJSON = jsonDecode(response.body);
                var userID = userJSON["data"];
                var prefs = await SharedPreferences.getInstance();
                prefs.setString('userID', userID);
                prefs.setString('userJSON', response.body);
                dispose() {
                  SystemChrome.setPreferredOrientations([
                    DeviceOrientation.landscapeRight,
                    DeviceOrientation.landscapeLeft,
                    DeviceOrientation.portraitUp,
                    DeviceOrientation.portraitDown,
                  ]);
                  super.dispose();
                }

                if (context.mounted) {
                  Navigator.pushReplacementNamed(context, "/setup");
                }
              },
              child: const Padding(
                padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image(
                        image: AssetImage("assets/images/google_logo.png"),
                        height: 35.0),
                    Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: Text(
                        'Sign in with Google',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
