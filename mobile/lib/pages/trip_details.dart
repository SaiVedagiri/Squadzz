import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

String userID = "";
String tripID = "";
dynamic initialDetails;

class TripDetailsPage extends StatefulWidget {
  String tripID;

  TripDetailsPage({Key? key, required this.tripID}) : super(key: key);

  @override
  State<TripDetailsPage> createState() {
    return _TripDetailsPageState();
  }
}

class _TripDetailsPageState extends State<TripDetailsPage> {
  late Location location;
  late bool serviceEnabled;
  late PermissionStatus permissionGranted;
  late LocationData locationData;
  late GoogleMapController mapController;
  final Map<String, Marker> _markers = {};
  late BitmapDescriptor pinLocation;
  double latitude = 40.3086875;
  double longitude = -74.6535625;

  @override
  initState() {
    super.initState();
    initStateFunction();
  }

  initStateFunction() async {
    var prefs = await SharedPreferences.getInstance();
    userID = prefs.getString('userID')!;
    tripID = widget.tripID;
    Response response =
        await post(Uri.parse('http://www.squadzz.us/getTripData'),
            headers: {
              "Content-type": "application/json",
              "Origin": "*",
            },
            body: jsonEncode({"tripID": tripID}));
    var responseJSON = jsonDecode(response.body);
    setState(() {
      initialDetails = responseJSON;
    });
  }

  void _onMapCreated(GoogleMapController controller) async {
    mapController = controller;
    pinLocation = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(devicePixelRatio: 2.5),
        'assets/currentLocation.png');
    location = Location();
    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }
    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    locationData = await location.getLocation();

    setState(() {
      latitude = locationData.latitude!;
      longitude = locationData.longitude!;
    });

    location.onLocationChanged.listen((LocationData currentLocation) async {
      try {
        LocationData tempLocationData = await location.getLocation();
        locationData = tempLocationData;

        setState(() async {
          _markers.clear();
          var userKeys = initialDetails["trip"]["users"];
          for(int i = 0; i < userKeys.length; i++){
            Response response = await post(
                Uri.parse('http://www.squadzz.us/getLatLong'),
                headers: {
                  "Content-type": "application/json",
                  "Origin": "*",
                },
                body: jsonEncode({"address": initialDetails[userKeys[i]]["address"]}));
            var responseJSON = jsonDecode(response.body);

            var newMarker = Marker(
                markerId: MarkerId(userKeys[i]),
                position:
                    LatLng(responseJSON["latitude"], responseJSON["longitude"]),
                infoWindow: InfoWindow(
                  title: initialDetails[userKeys[i]]["name"],
                ));
            _markers[userKeys[i]] = newMarker;
          }
          var marker = Marker(
            markerId: const MarkerId("currentLocation"),
            icon: pinLocation,
            position: LatLng(latitude, longitude),
            infoWindow: const InfoWindow(
              title: "Current Location",
            ),
          );
          _markers["currentLocation"] = marker;
        });
      } catch (ex) {}
    });

    setState(() async {
      _markers.clear();
      var userKeys = initialDetails["trip"]["users"];
      for(int i = 0; i < userKeys.length; i++){
        Response response =
        await post(Uri.parse('http://www.squadzz.us/getLatLong'),
            headers: {
              "Content-type": "application/json",
              "Origin": "*",
            },
            body: jsonEncode({"address": initialDetails[userKeys[i]]["address"]}));
        var responseJSON = jsonDecode(response.body);

        var newMarker = Marker(
            markerId: MarkerId(userKeys[i]),
            position:
            LatLng(responseJSON["latitude"], responseJSON["longitude"]),
            infoWindow: InfoWindow(
              title: initialDetails[userKeys[i]]["name"],
            ));
        _markers[userKeys[i]] = newMarker;
      }


      var marker = Marker(
        markerId: const MarkerId("currentLocation"),
        position: LatLng(latitude, longitude),
        icon: pinLocation,
        infoWindow: const InfoWindow(
          title: "Current Location",
        ),
      );
      _markers["currentLocation"] = marker;
    });

    location.onLocationChanged.timeout(Duration(seconds: 5));
  }

  @override
  void dispose() {
    super.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
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
        title: Text("Trip Map"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.help),
            onPressed: () {
              helpContext(
                  context,
                  "Help",
                  const Text.rich(
                    TextSpan(
                      children: <TextSpan>[
                        TextSpan(
                          text: 'Trip Info\n',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline),
                        ),
                        TextSpan(
                          text:
                              'View a map with all labeled locations. This will show all the starting locations and the central meeting point.\n',
                          style: TextStyle(fontSize: 20),
                        ),
                      ],
                    ),
                  ));
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          SizedBox(
            height: MediaQuery.of(context).size.height - 128,
            width: MediaQuery.of(context).size.width,
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              mapType: MapType.hybrid,
              initialCameraPosition: CameraPosition(
                target: LatLng(latitude, longitude),
                zoom: 17.0,
              ),
              markers: _markers.values.toSet(),
            ),
          ),
        ],
      ),
    );
  }
}
