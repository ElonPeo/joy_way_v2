import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:joy_way/config/general_specifications.dart';
import 'package:joy_way/models/post/post.dart';
import 'package:joy_way/widgets/custom_input/custom_select.dart';

import '../../../../widgets/animated_container/flashing_container.dart';


class ChooseVehicleType extends StatelessWidget {
  final Function(VehicleType) onVehicleChanged;
  final VehicleType? vehicleType;
  const ChooseVehicleType({super.key,
    required this.onVehicleChanged,
    required this.vehicleType,
  });
  @override
  Widget build(BuildContext context) {
    final specs = GeneralSpecifications(context);
    return  CustomSelect(
      child: Container(
          height: 55,
          width: specs.screenWidth/ 2 - 30,
          decoration: BoxDecoration(
              border: Border.all(
                width: 1,
                color: const Color.fromRGBO(240, 240, 240, 1),
              ),
              borderRadius: BorderRadius.circular(15)),
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              vehicleType == null ?
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Vehicle type',
                      style: GoogleFonts.outfit(
                        color: specs.black150,
                        fontSize: 13,
                      ),
                    ),
                    TextSpan(
                      text: ' *',
                      style: GoogleFonts.outfit(
                        color: specs.rSlight,
                      ),
                    ),
                  ],
                ),
              ) :
                  Text(
                   vehicleType!.name,
                    style: GoogleFonts.outfit(
                      color: Colors.black,
                    ),
                  )
            ],
          )),
      children: [
        FlashingContainer(
          onTap: () async {
            await onVehicleChanged(VehicleType.car);
            Navigator.pop(context);
          },
          height: 50,
          width: specs.screenWidth,
          borderRadius: BorderRadius.circular(0),
          color: Colors.white,
          flashingColor: specs.black240,
          child: Container(
            width: specs.screenWidth,
            padding: const EdgeInsets.symmetric(vertical: 15),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: specs.black240,
                  width: 1,
                  style: BorderStyle.solid,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(
                  width: 10,
                ),
                Text(
                  VehicleType.car.name,
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                    fontSize: 15,
                    decoration: TextDecoration.none,
                  ),
                )
              ],
            ),
          ),
        ),
        FlashingContainer(
          onTap: () async {
            await onVehicleChanged(VehicleType.motorbike);
            Navigator.pop(context);
          },
          height: 50,
          width: specs.screenWidth,
          borderRadius: BorderRadius.circular(0),
          color: Colors.white,
          flashingColor: specs.black240,
          child: Container(
            width: specs.screenWidth,
            padding: const EdgeInsets.symmetric(vertical: 15),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: specs.black240,
                  width: 1,
                  style: BorderStyle.solid,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(
                  width: 10,
                ),
                Text(
                  VehicleType.motorbike.name,
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                    fontSize: 15,
                    decoration: TextDecoration.none,
                  ),
                )
              ],
            ),
          ),
        ),
        FlashingContainer(
          onTap: () async {
            await onVehicleChanged(VehicleType.other);
            Navigator.pop(context);
          },
          height: 50,
          width: specs.screenWidth,
          borderRadius: BorderRadius.circular(0),
          color: Colors.white,
          flashingColor: specs.black240,
          child: Container(
            width: specs.screenWidth,
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(
                  width: 10,
                ),
                Text(
                  VehicleType.other.name,
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                    fontSize: 15,
                    decoration: TextDecoration.none,
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}