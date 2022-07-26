// ignore_for_file: avoid_function_literals_in_foreach_calls

import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lets_park/globals/globals.dart' as globals;
import 'package:lets_park/models/parking_space.dart';
import 'package:lets_park/screens/popups/parking_area_info.dart';

class FirebaseServices {
  late Stream<List<ParkingSpace>> _spaces;
  final Set<Marker> _markers = {};

  static Future uploadParkingSpace() async {
    int id = globals.parkinSpaceQuantity + 1;
    DateTime date = DateTime.now();
    String time = date.month.toString() +
        date.day.toString() +
        date.year.toString() +
        date.hour.toString() +
        date.minute.toString() +
        date.second.toString();

    globals.parkingSpace.setSpaceId = "PS$time$id";

    final docUser = FirebaseFirestore.instance
        .collection('parking-spaces')
        .doc('PS$time$id');

    await docUser.set(globals.parkingSpace.toJson());
  }

  static Future<String> uploadImage(File file, String destination) async {
    final storageRef = FirebaseStorage.instance.ref(destination);
    await storageRef.putFile(file);
    String url = "";
    await storageRef.getDownloadURL().then((value) {
      url = value;
    });
    return url;
  }

  static void getOwnedParkingAreas(AsyncSnapshot<List<ParkingSpace>> snapshot) {
    List<ParkingSpace> ownedSpaces = [];
    snapshot.data!.forEach((parkingSpace) {
      if (parkingSpace.getOwnerId!
              .compareTo(FirebaseAuth.instance.currentUser!.uid) ==
          0) {
        ownedSpaces.add(parkingSpace);
      }
    });

    globals.userData.setOwnedParkingSpaces = ownedSpaces;
  }

  Stream<List<ParkingSpace>> getParkingSpacesFromDatabase() {
    _spaces = FirebaseFirestore.instance
        .collection('parking-spaces')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map<ParkingSpace>((doc) => ParkingSpace.fromJson(doc.data()))
            .toList());
    return _spaces;
  }

  Set<Marker> getMarkers(BuildContext context) {
    late BitmapDescriptor reservableMarker, nonReservableMarker, monthlyMarker;

    _getReservableIcon().then((BitmapDescriptor value) {
      reservableMarker = value;
    });

    _getNonReservableIcon().then((BitmapDescriptor value) {
      nonReservableMarker = value;
    });

    _getMonthlyIcon().then((BitmapDescriptor value) {
      monthlyMarker = value;
    });

    _spaces.first.then((value) {
      globals.parkinSpaceQuantity = value.length;
      globals.currentParkingSpaces = value;
      value.forEach((parkingSpace) {
        _markers.add(
          Marker(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  fullscreenDialog: true,
                  builder: (context) => ParkingAreaInfo(
                    parkingSpace: parkingSpace,
                  ),
                ),
              );
            },
            icon: parkingSpace.getType!.compareTo("Reservable") == 0 &&
                    parkingSpace.getDailyOrMonthly!.compareTo("Daily") == 0
                ? reservableMarker
                : parkingSpace.getType!.compareTo("Reservable") == 0 &&
                        parkingSpace.getDailyOrMonthly!.compareTo("Monthly") ==
                            0
                    ? monthlyMarker
                    : nonReservableMarker,
            markerId: MarkerId(parkingSpace.getLatLng.toString()),
            position: parkingSpace.getLatLng!,
          ),
        );
      });
    });

    return _markers;
  }

  Future<BitmapDescriptor> _getReservableIcon() async {
    BitmapDescriptor markerbitmap = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(),
      "assets/icons/parking-marker.png",
    );
    return markerbitmap;
  }

  Future<BitmapDescriptor> _getNonReservableIcon() async {
    BitmapDescriptor markerbitmap = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(),
      "assets/icons/parking-marker-pay.png",
    );
    return markerbitmap;
  }

  Future<BitmapDescriptor> _getMonthlyIcon() async {
    BitmapDescriptor markerbitmap = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(),
      "assets/icons/parking-marker-monthly.png",
    );
    return markerbitmap;
  }

  Map<ParkingSpace, double> getNearbyParkingSpaces(LatLng userLocation) {
    Map<ParkingSpace, double> _nearbyParkings = {};
    Map<ParkingSpace, double> _map = {};

    globals.currentParkingSpaces.forEach((parkingSpace) {
      _map[parkingSpace] = calculateDistance(
        userLocation.latitude,
        userLocation.longitude,
        parkingSpace.getLatLng!.latitude,
        parkingSpace.getLatLng!.longitude,
      );
    });

    var sortedMap = Map.fromEntries(
        _map.entries.toList()..sort((p1, p2) => p1.value.compareTo(p2.value)));

    int limiter = sortedMap.length < 5 ? sortedMap.length : 5;

    for (int i = 0; i < limiter; i++) {
      _nearbyParkings[sortedMap.keys.elementAt(i)] =
          sortedMap.values.elementAt(i);
    }

    return _nearbyParkings;
  }

  static List<ParkingSpace> getHighestRatedParkings() {
    List<ParkingSpace> firstFiveHighestRating = globals.currentParkingSpaces;

    firstFiveHighestRating.sort((spaceA, spaceB) {
      double timeA = spaceA.getRating!;
      double timeB = spaceB.getRating!;
      return timeB.compareTo(timeA);
    });

    return firstFiveHighestRating;
  }

  static List<ParkingSpace> getSecuredParkingSpaces() {
    List<ParkingSpace> securedParkingSpaces = [];

    globals.currentParkingSpaces.forEach((space) {
      if (space.getFeatures!.contains("CCTV")) {
        securedParkingSpaces.add(space);
      }
    });

    return securedParkingSpaces;
  }

  static List<ParkingSpace> getMonthlyParkings() {
    List<ParkingSpace> monthlyParkingSpaces = [];

    globals.currentParkingSpaces.forEach((space) {
      if (space.getDailyOrMonthly!.compareTo("Monthly") == 0) {
        monthlyParkingSpaces.add(space);
      }
    });

    return monthlyParkingSpaces;
  }

  static double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }
}
