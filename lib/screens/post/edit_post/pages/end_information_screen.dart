import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:joy_way/config/general_specifications.dart';
import 'package:joy_way/models/post/components/end_infor.dart';
import 'package:joy_way/models/post/components/start_info.dart';
import 'package:joy_way/services/mapbox_services/mapbox_config.dart';
import 'package:joy_way/widgets/map/view/route_view.dart';

import '../../../../services/data_processing/time_processing.dart';
import '../../../../widgets/animated_container/custom_animated_button.dart';
import '../../../../widgets/custom_input/custom_date_picker.dart';
import '../../../../widgets/custom_input/custom_text_box.dart';
import '../../../../widgets/map/select_location/select_location.dart';


class EndInformationScreen extends StatefulWidget {
  final EndInfo? endInfo;
  final StartInfo? startInfo;
  final Function(EndInfo) onEndInfoChanged;

  const EndInformationScreen({
    super.key,
    this.endInfo,
    required this.startInfo,
    required this.onEndInfoChanged,
  });

  @override
  State<EndInformationScreen> createState() => _EndInformationScreenState();
}

class _EndInformationScreenState extends State<EndInformationScreen> {
  late EndInfoBuilder _draft;
  @override
  void initState() {
    super.initState();
    _draft = widget.endInfo != null
        ? EndInfoBuilder.from(widget.endInfo!)
        : EndInfoBuilder();
  }

  void _emitIfReady() {
    final built = _draft.tryBuild();
    if (built != null) widget.onEndInfoChanged(built);
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
              Text("Arrival Information", style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w500)),
              const SizedBox(height: 20),
              // Địa điểm kết thúc
              CustomTextBox(
                width: specs.screenWidth - 40,
                text: _draft.arrivalName,
                hiddenText: "Place of Arrival",
                onTap: () async {
                  Navigator.push(context, CupertinoPageRoute(
                    builder: (_) => SelectLocation(
                      onGeoPoint: (v) => setState(() {
                        _draft.arrivalCoordinate = v;
                        _emitIfReady();
                      }),
                      onAddress: (v) => setState(() {
                        _draft.arrivalName = v;
                        _emitIfReady();
                      }),
                    ),
                  ));
                },
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextBox(
                    width: specs.screenWidth - 150,
                    text: TimeProcessing.formattedDepartureTime(_draft.arrivalTime),
                    hiddenText: "Arrival time",
                    isRequire: false,
                    onTap: () async {
                      Navigator.push(context, CupertinoPageRoute(
                        builder: (_) => CustomDatePicker(
                          child: _hint(specs),
                          date: _draft.arrivalTime,
                          onDateTimeChanged: (DateTime value) => setState(() {
                            _draft.arrivalTime = value;
                            _emitIfReady();
                          }),
                        ),
                      ));
                    },
                  ),
                  CustomAnimatedButton(
                    width: 100, height: 40, pressedScale: 0.9,
                    borderRadius: BorderRadius.circular(15),
                    color: specs.turquoise1.withAlpha(150),
                    shadowColor: Colors.transparent,
                    child: Center(child: Text("Set Time",
                        style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w500))),
                    onTap: () {
                      Navigator.push(context, CupertinoPageRoute(
                        builder: (_) => CustomDatePicker(
                          child: _hint(specs),
                          date: _draft.arrivalTime,
                          onDateTimeChanged: (DateTime value) => setState(() {
                            _draft.arrivalTime = value;
                            _emitIfReady();
                          }),
                        ),
                      ));
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text("Route suggestions", style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w500)),
              const SizedBox(height: 10),
              if(widget.startInfo != null && widget.endInfo != null)
                RoutePreviewBox(
                    start: widget.startInfo!.departureCoordinate,
                    end: widget.endInfo!.arrivalCoordinate,
                    accessToken: MapboxConfig.accessToken
                )


            ],
          ),
        ),
        SizedBox(
          height: specs.screenHeight * 0.4,
        ),
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