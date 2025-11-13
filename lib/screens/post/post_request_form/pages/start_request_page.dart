import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../config/general_specifications.dart';
import '../../../../models/request/request_journey/request_join_journey/start_request_info.dart';
import '../../../../services/data_processing/time_processing.dart';
import '../../../../services/mapbox_services/mapbox_config.dart';
import '../../../../widgets/animated_container/custom_animated_button.dart';
import '../../../../widgets/custom_input/custom_date_picker.dart';
import '../../../../widgets/custom_input/custom_text_box.dart';
import '../../../../widgets/map/select_location/select_location.dart';
import '../../../../widgets/map/view/photo_map_url_view.dart';

class StartRequestPage extends StatefulWidget {
  final StartRequestInfo? startRequestInfo;
  final Function(StartRequestInfo) onStartRequestInfoChanged;

  const StartRequestPage({
    super.key,
    required this.startRequestInfo,
    required this.onStartRequestInfoChanged,
  });

  @override
  State<StartRequestPage> createState() => _StartRequestPageState();
}

class _StartRequestPageState extends State<StartRequestPage> {
  final _borderRadius = BorderRadius.circular(15);

  late StartRequestInfoBuilder _draft;

  @override
  void initState() {
    super.initState();
    if (widget.startRequestInfo != null) {
      _draft = StartRequestInfoBuilder.from(widget.startRequestInfo!);
    } else {
      _draft = StartRequestInfoBuilder();
    }
  }

  void _emitIfReady() {
    final built = _draft.tryBuild();
    if (built != null) widget.onStartRequestInfoChanged(built);
  }

  @override
  Widget build(BuildContext context) {
    final specs = GeneralSpecifications(context);
    return ListView(
      padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
      children: [
        Text("Preferred pick-up",
            style:
            GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w500)),
        const SizedBox(height: 20),
        // Địa điểm xuất phát
        CustomTextBox(
          width: specs.screenWidth - 40,
          text: _draft.pickUpName,
          hiddenText: "Place of departure",
          onTap: () async {
            Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (_) => SelectLocation(
                    onGeoPoint: (v) => setState(() {
                      _draft.pickUpPoint = v;
                      _emitIfReady();
                    }),
                    onAddress: (v) => setState(() {
                      _draft.pickUpName = v;
                      _emitIfReady();
                    }),
                  ),
                ));
          },
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CustomTextBox(
              width: specs.screenWidth - 150,
              text: TimeProcessing.formattedDepartureTime(_draft.desiredPickUpTime),
              hiddenText: "Departure time",
              onTap: () async {
                Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (_) => CustomDatePicker(
                        child: _hint(specs),
                        date: _draft.desiredPickUpTime,
                        onDateTimeChanged: (DateTime value) => setState(() {
                          _draft.desiredPickUpTime = value;
                          _emitIfReady();
                        }),
                      ),
                    ));
              },
            ),
            CustomAnimatedButton(
              width: 100,
              height: 40,
              pressedScale: 0.9,
              borderRadius: _borderRadius,
              color: specs.turquoise1.withAlpha(150),
              shadowColor: Colors.transparent,
              child: Center(
                  child: Text("Set Time",
                      style: GoogleFonts.outfit(
                          color: Colors.white, fontWeight: FontWeight.w500))),
              onTap: () {
                Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (_) => CustomDatePicker(
                        child: _hint(specs),
                        date: _draft.desiredPickUpTime,
                        onDateTimeChanged: (DateTime value) => setState(() {
                          _draft.desiredPickUpTime = value;
                          _emitIfReady();
                        }),
                      ),
                    ));
              },
            ),
          ],
        ),
        const SizedBox(height: 10),
        PhotoMapUrlView(
          borderRadius: 15,
          geoPoint: _draft.pickUpPoint,
          address: _draft.pickUpName ?? "",
          width: specs.screenWidth - 40,
          height: 160,
          mapboxToken: MapboxConfig.accessToken,
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
            TextSpan(
                text: "*",
                style: TextStyle(
                    color: specs.rSlight, fontWeight: FontWeight.bold)),
            const TextSpan(
                text:
                " cannot be blank, the maximum time is 7 days from now, and cannot be set in the past."),
          ],
        ),
      ),
    );
  }
}
