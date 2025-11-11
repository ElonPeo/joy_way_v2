import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:joy_way/config/general_specifications.dart';
import 'package:joy_way/models/post/components/start_info.dart';
import 'package:joy_way/screens/post/edit_post/components/choose_vehicle_type.dart';
import 'package:joy_way/services/data_processing/time_processing.dart';
import 'package:joy_way/services/mapbox_services/mapbox_config.dart';
import 'package:joy_way/widgets/custom_input/custom_date_picker.dart';
import 'package:joy_way/widgets/map/view/photo_map_url_view.dart';

import '../../../../widgets/animated_container/custom_animated_button.dart';
import '../../../../widgets/custom_input/custom_text_box.dart';
import '../../../../widgets/map/select_location/select_location.dart';





class StartInformationScreen extends StatefulWidget {
  final StartInfo? startInfo;
  final Function(StartInfo) onStartInfoChanged;

  const StartInformationScreen({
    super.key,
    this.startInfo,
    required this.onStartInfoChanged,
  });

  @override
  State<StartInformationScreen> createState() => _StartInformationScreenState();
}

class _StartInformationScreenState extends State<StartInformationScreen> {
  final _borderRadius = BorderRadius.circular(15);

  late StartInfoBuilder _draft;
  final _seatsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _draft = widget.startInfo != null
        ? StartInfoBuilder.from(widget.startInfo!)
        : StartInfoBuilder();
    _seatsController.text = widget.startInfo?.availableSeats.toString() ?? '';
  }

  @override
  void dispose() {
    _seatsController.dispose();
    super.dispose();
  }

  void _emitIfReady() {
    final built = _draft.tryBuild();
    if (built != null) widget.onStartInfoChanged(built);
  }

  @override
  Widget build(BuildContext context) {
    final specs = GeneralSpecifications(context);

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Departure Information",
                  style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w500)),
              const SizedBox(height: 20),

              // Địa điểm xuất phát
              CustomTextBox(
                width: specs.screenWidth - 40,
                text: _draft.departureName,
                hiddenText: "Place of departure",
                onTap: () async {
                  Navigator.push(context, CupertinoPageRoute(
                    builder: (_) => SelectLocation(
                      onGeoPoint: (v) => setState(() {
                        _draft.departureCoordinate = v;
                        _emitIfReady();
                      }),
                      onAddress: (v) => setState(() {
                        _draft.departureName = v;
                        _emitIfReady();
                      }),
                    ),
                  ));
                },
              ),
              const SizedBox(height: 10),

              // Thời gian xuất phát
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomTextBox(
                    width: specs.screenWidth - 150,
                    text: TimeProcessing.formattedDepartureTime(_draft.departureTime),
                    hiddenText: "Departure time",
                    onTap: () async {
                      Navigator.push(context, CupertinoPageRoute(
                        builder: (_) => CustomDatePicker(
                          child: _hint(specs),
                          date: _draft.departureTime,
                          onDateTimeChanged: (DateTime value) => setState(() {
                            _draft.departureTime = value;
                            _emitIfReady();
                          }),
                        ),
                      ));
                    },
                  ),
                  CustomAnimatedButton(
                    width: 100, height: 40, pressedScale: 0.9,
                    borderRadius: _borderRadius,
                    color: specs.turquoise1.withAlpha(150),
                    shadowColor: Colors.transparent,
                    child: Center(child: Text("Set Time",
                        style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w500))),
                    onTap: () {
                      Navigator.push(context, CupertinoPageRoute(
                        builder: (_) => CustomDatePicker(
                          child: _hint(specs),
                          date: _draft.departureTime,
                          onDateTimeChanged: (DateTime value) => setState(() {
                            _draft.departureTime = value;
                            _emitIfReady();
                          }),
                        ),
                      ));
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Preview map
              PhotoMapUrlView(
                borderRadius: 15,
                geoPoint: _draft.departureCoordinate,
                address: _draft.departureName ?? "",
                width: specs.screenWidth - 40,
                height: 160,
                mapboxToken: MapboxConfig.accessToken,
              ),

              const SizedBox(height: 20),
              Text("Vehicles and seats",
                  style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w500)),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Chọn loại xe
                  ChooseVehicleType(
                    vehicleType: _draft.vehicleType,
                    onVehicleChanged: (value) {
                      setState(() {
                        _draft.vehicleType = value;
                        _emitIfReady();
                      });
                    },
                  ),

                  // Số chỗ
                  Container(
                    height: 55,
                    width: specs.screenWidth / 2 - 30,
                    decoration: BoxDecoration(
                      border: Border.all(width: 1, color: const Color.fromRGBO(240, 240, 240, 1)),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Center(
                      child: TextField(
                        controller: _seatsController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(2),
                        ],
                        style: GoogleFonts.outfit(fontSize: 13, color: Colors.black),
                        decoration: InputDecoration(
                          hint: Text.rich(TextSpan(children: [
                            TextSpan(text: 'Seats', style: GoogleFonts.outfit(
                                color: specs.black150, fontSize: 13)),
                            TextSpan(text: ' *', style: GoogleFonts.outfit(color: specs.rSlight)),
                          ])),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        onChanged: (v) {
                          setState(() {
                            _draft.availableSeats = int.tryParse(v);
                            _emitIfReady();
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: specs.screenHeight * 0.3),
      ],
    );
  }

  Widget _hint(GeneralSpecifications specs) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: RichText(
        text: TextSpan(
          style: GoogleFonts.outfit(color: specs.black80, fontSize: 13),
          children: [
            const TextSpan(text: "Fields with "),
            TextSpan(text: "*", style: TextStyle(color: specs.rSlight, fontWeight: FontWeight.bold)),
            const TextSpan(text: " cannot be blank, the maximum time is 7 days from now, and cannot be set in the past."),
          ],
        ),
      ),
    );
  }
}

