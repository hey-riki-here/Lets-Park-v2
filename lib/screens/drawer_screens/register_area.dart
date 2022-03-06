import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lets_park/shared/shared_widgets.dart';

class RegisterArea extends StatefulWidget {
  final int _pageId = 5;
  const RegisterArea({Key? key}) : super(key: key);

  @override
  State<RegisterArea> createState() => _RegisterAreaState();
}

class _RegisterAreaState extends State<RegisterArea> {
  final SharedWidget _sharedWidget = SharedWidget();
  final ScrollController _scrollController = ScrollController();
  bool needScroll = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      body: Scrollbar(
        controller: _scrollController,
        thickness: 5,
        isAlwaysShown: true,
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Location",
                  style: TextStyle(
                    fontSize: 32,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 10),
                const PhotoPicker(),
                const SizedBox(height: 20),
                const Text(
                  "Provide the address of your area",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const AreaAdress(),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _sharedWidget.button(

                      label: "Continue",
                      onPressed: () {},

                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PhotoPicker extends StatefulWidget {
  const PhotoPicker({Key? key}) : super(key: key);

  @override
  State<PhotoPicker> createState() => _PhotoPickerState();
}

class _PhotoPickerState extends State<PhotoPicker> {
  File? image;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Please provide an image of the entrace of your parking space",
          style: TextStyle(
            fontSize: 16,
            color: Colors.black45,
          ),
        ),
        const SizedBox(height: 15),
        Center(
          child: DottedBorder(
            color: Colors.blue,
            child: image != null ? displayImage() : placeHolder(),
            borderType: BorderType.RRect,
            radius: const Radius.circular(12),
          ),
        )
      ],
    );
  }

  Future chooseImage() async {
    try {
      final image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
      );
      if (image == null) return;
      final imageTemp = File(image.path);
      setState(() => this.image = imageTemp);
      print("Loaded");
    } on Exception catch (e) {
      // TODO
    }
  }

  Widget displayImage() => Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(28.0),
            child: SizedBox(
              child: Image.file(
                image!,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  child: const Icon(Icons.close),
                  onTap: () {
                    setState(() {
                      image = null;
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      );

  Widget placeHolder() => InkWell(

        onTap: () {
          chooseImage();
        },
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        child: Container(
          width: 300,
          height: 200,
          padding: const EdgeInsets.all(35),
          child: Column(
            children: const [
              Icon(
                Icons.cloud_upload,
                size: 80,
                color: Colors.grey,
              ),
              SizedBox(height: 10),
              Text("Browse for an image")
            ],
          ),
        ),
      );
}

class AreaAdress extends StatefulWidget {
  const AreaAdress({Key? key}) : super(key: key);

  @override
  State<AreaAdress> createState() => _AreaAdressState();
}

class _AreaAdressState extends State<AreaAdress> {
  int _currentStep = 0;
  TextEditingController barangay = TextEditingController();
  TextEditingController street = TextEditingController();
  late GoogleMapController googleMapController;
  MapType mapType = MapType.normal;
  String mapTypeAsset = "assets/icons/map-type-1.png";
  final SharedWidget _sharedWidgets = SharedWidget();
  final _formKey = GlobalKey<FormState>();
  final barangays = <String>[
    'Arkong Bato',
    'Bagbaguin',
    'Balangkas',
    'Bignay',
    'Bisig',
    'Canumay East',
    'Canumay West',
    'Coloong',
    'Dalandanan',
    'Gen. T. De Leon',
    'Isla',
    'Karuhatan',
    'Lawang Bato',
    'Lingunan',
    'Mabolo',
    'Malanday',
    'Malinta',
    'Mapulang Lupa',
    'Marulas',
    'Maysan',
    'Palasan',
    'Parada',
    'Pariancillo Villa',
    'Paso De Blas',
    'Pasolo',
    'Poblacion',
    'Pulo',
    'Punturin',
    'Rincon',
    'Tagalag',
    'Ugong',
    'Viente Reales',
    'Wawang Pulo',
  ];
  String selectedBarangay = 'Arkong Bato';
  String stepOneSubtitle = "";
  @override
  Widget build(BuildContext context) {
    return Stepper(
      steps: _steps(),
      currentStep: _currentStep,
      onStepTapped: (step) {
        if (_formKey.currentState!.validate()) {
          setState(() {
            _currentStep = step;
          });
        }
      },
      onStepContinue: () {
        if (_currentStep == 0) {
          if (_formKey.currentState!.validate()) {
            setState(() {
              if (_currentStep < _steps().length - 1) {
                stepOneSubtitle =
                    street.text + ", " + selectedBarangay + ", Valenzuela";
                moveCamera(street.text.trim(), selectedBarangay);
                _currentStep += 1;
              } else {
                //TODO
              }
            });
          }
        } else {
          setState(() {
            if (_currentStep < _steps().length - 1) {
              _currentStep += 1;
            } else {
              //TODO
            }
          });
        }
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
    );
  }

  void moveCamera(String street, String barangay) async {
    List<Location> locations = await locationFromAddress(
      street + ", " + barangay + ", Valenzuela",
    );
    googleMapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          zoom: 15,
          tilt: 0,
          bearing: 0,
          target: LatLng(locations.first.latitude, locations.first.longitude),
        ),
      ),
    );
  }

  List<Step> _steps() {
    List<Step> steps = [
      Step(
        subtitle: Text(stepOneSubtitle),
        title: const Text("Enter address"),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  const Text(
                    "House No./Blk Lot/Street",
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _sharedWidgets.textFormField(
                    action: TextInputAction.next,
                    controller: street,
                    label: '',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter street";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Barangay",
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: const BorderRadius.all(Radius.circular(12)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedBarangay,
                        icon: const Icon(
                          Icons.arrow_drop_down_rounded,
                          size: 32,
                        ),
                        elevation: 16,
                        isExpanded: true,
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedBarangay = newValue!;
                          });
                        },
                        items: barangays.map(dropdownItem).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        isActive: _currentStep >= 0,
      ),
      Step(
        title: const Text("Pinpoint your space location"),
        content: SizedBox(
          width: double.infinity,
          height: 400,
          child: Stack(
            children: [
              Material(
                elevation: 3,
                child: GoogleMap(
                  initialCameraPosition: const CameraPosition(
                    zoom: 15,
                    tilt: 0,
                    bearing: 0,
                    target: LatLng(14.7011, 120.9830),
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
        isActive: _currentStep >= 1,
      ),
    ];

    return steps;
  }

  DropdownMenuItem<String> dropdownItem(String item) {
    return DropdownMenuItem(
      child: Text(
        item,
      ),
      value: item,
    );
  }
}