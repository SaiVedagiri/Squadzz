import 'package:squadzz/pages/group_landing.dart';
import 'package:squadzz/pages/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:squadzz/pages/sign_in.dart';
import 'package:squadzz/pages/sign_up.dart';

Future main() async {
  await dotenv.load(fileName: "assets/.env");
  runApp(const HoloLensApp());
}

class HoloLensApp extends StatelessWidget {
  const HoloLensApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: {
        "/": (_) => const HomePage(),
        "/signin": (_) => const SignInPage(),
        "/signup": (_) => const SignUpPage(),
        "/groups": (_) => const GroupLandingPage(),
      },
    );
  }
}