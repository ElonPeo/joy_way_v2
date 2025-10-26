import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:joy_way/config/general_specifications.dart';
import 'package:joy_way/models/post/post.dart';
import 'package:joy_way/widgets/custom_input/custom_select.dart';

import '../../../../widgets/animated_container/flashing_container.dart';


class ChooseExpenseType  extends StatelessWidget {
  final Function(ExpenseType) onExpenseChanged;
  final ExpenseType? expenseType;
  const ChooseExpenseType({super.key,
    required this.onExpenseChanged,
    required this.expenseType,
  });
  @override
  Widget build(BuildContext context) {
    final specs = GeneralSpecifications(context);
    return  CustomSelect(
      child: Container(
          height: 55,
          width: 130,
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
              expenseType == null ?
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Expense type',
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
                expenseType!.name,
                style: GoogleFonts.outfit(
                  color: Colors.black,
                ),
              )
            ],
          )),
      children: [
        FlashingContainer(
          onTap: () async {
            await onExpenseChanged(ExpenseType.free);
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
                  ExpenseType.free.name,
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
            await onExpenseChanged(ExpenseType.share);
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
                  ExpenseType.share.name,
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