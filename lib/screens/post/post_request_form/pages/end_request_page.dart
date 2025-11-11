import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../config/general_specifications.dart';
import '../../../../models/request/request_journey/components/end_request_info.dart';
import '../../../../services/data_processing/time_processing.dart';
import '../../../../widgets/animated_container/custom_animated_button.dart';
import '../../../../widgets/custom_input/custom_date_picker.dart';
import '../../../../widgets/custom_input/custom_text_box.dart';
import '../../../../widgets/map/select_location/select_location.dart';

class EndRequestPage extends StatefulWidget {
  final EndRequestInfo? endRequestInfo;
  final Function(EndRequestInfo) onEndRequestInfoChanged;

  const EndRequestPage({
    super.key,
    required this.endRequestInfo,
    required this.onEndRequestInfoChanged,
  });

  @override
  State<EndRequestPage> createState() => _EndRequestPageState();
}

class _EndRequestPageState extends State<EndRequestPage> {

  final _borderRadius = BorderRadius.circular(15);

  late EndRequestInfoBuilder _draft;

  @override
  void initState() {
    super.initState();
    if (widget.endRequestInfo != null) {
      _draft = EndRequestInfoBuilder.from(widget.endRequestInfo!);
    } else {
      _draft = EndRequestInfoBuilder();
    }
  }

  void _emitIfReady() {
    final built = _draft.tryBuild();
    if (built != null) widget.onEndRequestInfoChanged(built);
  }


  @override
  Widget build(BuildContext context) {
    final specs = GeneralSpecifications(context);
    return ListView(
      padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
      children: [
        Text("Preferred drop-off",
            style:
            GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w500)),
        const SizedBox(height: 20),
        // Địa điểm xuất phát
        CustomTextBox(
          width: specs.screenWidth - 40,
          text: _draft.dropOffName,
          hiddenText: "Drop-off location",
          onTap: () async {
            Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (_) => SelectLocation(
                    onGeoPoint: (v) => setState(() {
                      _draft.dropOffPoint = v!;
                      _emitIfReady();
                    }),
                    onAddress: (v) => setState(() {
                      _draft.dropOffName = v;
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
              text: TimeProcessing.formattedDepartureTime(_draft.desiredDropOffTime),
              hiddenText: "Desired arrival time",
              onTap: () async {
                Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (_) => CustomDatePicker(
                        child: _hint(specs),
                        date: _draft.desiredDropOffTime,
                        onDateTimeChanged: (DateTime value) => setState(() {
                          _draft.desiredDropOffTime = value;
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
                        date: _draft.desiredDropOffTime,
                        onDateTimeChanged: (DateTime value) => setState(() {
                          _draft.desiredDropOffTime = value;
                          _emitIfReady();
                        }),
                      ),
                    ));
              },
            ),
          ],
        ),
        const SizedBox(height: 10),
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
