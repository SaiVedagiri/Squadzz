import 'package:squadzz/pages/group_landing.dart';
import 'package:squadzz/pages/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:squadzz/pages/photo_landing.dart';
import 'package:squadzz/pages/sign_in.dart';
import 'package:squadzz/pages/sign_up.dart';
import 'package:squadzz/pages/trip_landing.dart';

Future main() async {
  await dotenv.load(fileName: "assets/.env");
  runApp(const SquadzzApp());
}

class SquadzzApp extends StatelessWidget {
  const SquadzzApp({super.key});

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
        "/trips": (_) => const TripLandingPage(),
        "/photos": (_) => const PhotoLandingPage(),
      },
    );
  }
}
