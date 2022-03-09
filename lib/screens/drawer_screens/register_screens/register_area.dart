// ignore_for_file: unused_catch_clause, empty_catches

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lets_park/globals/globals.dart' as globals;
import 'package:lets_park/screens/drawer_screens/register_screens/address_step.dart';
import 'package:lets_park/screens/drawer_screens/register_screens/info_and_features.dart';
import 'package:lets_park/screens/drawer_screens/register_screens/location_section.dart';
import 'package:lets_park/screens/popups/notice_dialog.dart';
import 'package:lets_park/shared/shared_widgets.dart';

class RegisterArea extends StatefulWidget {
  final int _pageId = 5;
  const RegisterArea({Key? key}) : super(key: key);

  @override
  State<RegisterArea> createState() => _RegisterAreaState();
}

class _RegisterAreaState extends State<RegisterArea> {
  final SharedWidget _sharedWidget = SharedWidget();
  LatLng latLng = const LatLng(14.7011, 120.9830);
  int _currentStep = 0;
  final GlobalKey<LocationSectionState> _locationState = GlobalKey();
  final GlobalKey<AddressSectionState> _addressState = GlobalKey();
  final GlobalKey<InfoAndFeaturesState> _informationState = GlobalKey();
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await _showDialog(
          imageLink: "assets/icons/marker.png",
          message: "Are you want to cancel renting out your space?",
          forConfirmation: true,
        );
        return globals.popWindow;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.black),
          centerTitle: true,
          title: const Text(
            "Rent out your space",
            style: TextStyle(
              color: Colors.black,
            ),
          ),
        ),
        body: Theme(
          data: ThemeData(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: Stepper(
            elevation: 1,
            controlsBuilder: (BuildContext context, ControlsDetails details) =>
                _buildControls(
              context,
              details,
            ),
            steps: _steps(),
            type: StepperType.horizontal,
            currentStep: _currentStep,
            onStepContinue: () async {
              setState(() {
                if (_currentStep == _steps().length - 1) {
                  if (_informationState.currentState!.getFormKey.currentState!
                      .validate()) {

                        globals.data.add(_informationState.currentState!.getCapacity);
                        globals.data.add(_informationState.currentState!.getInfo);
                        globals.data.add(_informationState.currentState!.getVerticalClearance);
                        globals.data.add(_informationState.currentState!.getType);
                        globals.data.add(_informationState.currentState!.getSelectedFeatures);

                        print(globals.data);

                      }
                }

                if (_currentStep == 1) {
                  globals.data.add(globals.latLng);
                  print(globals.data);
                }

                if (_currentStep < _steps().length - 1) {
                  if (_currentStep == 0) {
                    if (_addressState.currentState!.getImage == null) {
                      _showDialog(
                        imageLink: "assets/icons/marker.png",
                        message:
                            "Please provide the entrance image of your parking space.",
                      );
                    } else {
                      if (_addressState.currentState!.getFormKey.currentState!
                          .validate()) {
                        globals.data.add(_addressState.currentState!.getImage);
                        globals.data.add(globals.globalStreet.text.trim() + ", " + globals.globalBarangay + ", Valenzuela");
                        getCoordinatesAndRefresh();
                        _currentStep += 1;

                        print(globals.data);
                      }
                    }
                  } else {
                    _currentStep += 1;
                  }
                } else {
                  //TODO
                }
              });
            },
            onStepCancel: () {
              setState(() {
                if (_currentStep > 0) {
                  _currentStep -= 1;
                } else {
                  _currentStep = 0;
                }
              });
            },
          ),
        ),
      ),
    );
  }

  List<Step> _steps() => <Step>[
        Step(
          title: const Text("Address"),
          content: AddressSection(key: _addressState),
          isActive: _currentStep >= 0,
        ),
        Step(
          title: const Text("Location"),
          content: LocationSection(key: _locationState),
          isActive: _currentStep >= 1,
        ),
        Step(
          title: const Text("Info and Features"),
          content: InfoAndFeatures(key: _informationState),
          isActive: _currentStep >= 2,
        ),
      ];

  Widget _buildControls(BuildContext context, ControlsDetails details) {
    if (_currentStep == 0) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _sharedWidget.button(
            label: "Continue",
            onPressed: () {
              details.onStepContinue!();
            },
          ),
        ],
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: details.onStepCancel,
            child: Row(
              children: const [
                Icon(
                  Icons.arrow_back_ios,
                  color: Colors.black45,
                  size: 18,
                ),
                Text(
                  "Back",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black45,
                  ),
                ),
              ],
            ),
          ),
          _sharedWidget.button(
            label: "Continue",
            onPressed: () {
              details.onStepContinue!();
            },
          ),
        ],
      );
    }
  }

  Future getCoordinates(String street, String barangay) async {
    try {
      List<Location> locations = await locationFromAddress(
        street + ", " + barangay + ", Valenzuela",
      );
      globals.latLng =
          LatLng(locations.first.latitude, locations.first.longitude);
    } on Exception catch (e) {}
  }

  void getCoordinatesAndRefresh() async {
    await getCoordinates(
      globals.globalStreet.text.trim(),
      globals.globalBarangay,
    );
    _locationState.currentState!.refreshPage();
  }

  Future _showDialog(
      {required String imageLink,
      required String message,
      bool? forConfirmation = false}) {
    return showDialog(
      context: context,
      builder: (context) {
        return NoticeDialog(
          imageLink: imageLink,
          message: message,
          forConfirmation: forConfirmation!,
        );
      },
    );
  }
}