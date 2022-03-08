// ignore_for_file: unused_catch_clause, empty_catches

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lets_park/globals/globals.dart' as globals;

class LocationSection extends StatefulWidget {
  const LocationSection({required Key key}) : super(key: key);

  @override
  State<LocationSection> createState() => LocationSectionState();
}

class LocationSectionState extends State<LocationSection> {
  late GoogleMapController googleMapController;
  MapType mapType = MapType.normal;
  String mapTypeAsset = "assets/icons/map-type-1.png";
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Location",
          style: TextStyle(
            fontSize: 32,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 30),
        const Text(
          "Pinpoint the location of the entrance of your space",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w300,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          "(If you think the location is incorrect please double check your given address.)",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w300,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 400,
          child: Stack(
            children: [
              Material(
                elevation: 3,
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    zoom: 15,
                    tilt: 0,
                    bearing: 0,
                    target: globals.latLng,
                  ),
                  mapType: mapType,
                  minMaxZoomPreference: const MinMaxZoomPreference(15, 20),
                  gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                    Factory<OneSequenceGestureRecognizer>(
                      () => EagerGestureRecognizer(),
                    ),
                  },
                  onMapCreated: (GoogleMapController controller) {
                    googleMapController = controller;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Material(
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                      elevation: 5,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () {
                          setState(() {
                            if (mapType == MapType.normal) {
                              mapType = MapType.satellite;
                              mapTypeAsset = "assets/icons/map-type-2.png";
                            } else {
                              mapType = MapType.normal;
                              mapTypeAsset = "assets/icons/map-type-1.png";
                            }
                          });
                        },
                        child: Ink(
                          height: 40,
                          width: 40,
                          child: Center(
                            child: Image(
                              width: 30,
                              image: AssetImage(
                                mapTypeAsset,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Center(
                child: Image(
                  image: AssetImage("assets/icons/marker.png"),
                  width: 30,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 30),
      ],
    );
  }

  void refreshPage() {
    googleMapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: globals.latLng),
      ),
    );
  }
}
