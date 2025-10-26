
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:joy_way/config/general_specifications.dart';

import '../../../../models/post/components/detail.dart';
import '../components/choose_expense_type.dart';






class DetailInformationScreen extends StatefulWidget {
  final DetailInfo? detailInfo;
  final Function(DetailInfo) onDetailInfoChanged;

  const DetailInformationScreen({
    super.key,
    required this.detailInfo,
    required this.onDetailInfoChanged,
  });

  @override
  State<DetailInformationScreen> createState() => _DetailInformationScreenState();
}

class _DetailInformationScreenState extends State<DetailInformationScreen> {
  late DetailInfoBuilder _draft;
  final _seatsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _draft = widget.detailInfo != null
        ? DetailInfoBuilder.from(widget.detailInfo!)
        : DetailInfoBuilder();
  }

  @override
  void dispose() {
    _seatsController.dispose();
    super.dispose();
  }

  void _emitIfReady() {
    final built = _draft.tryBuild();
    if (built != null) widget.onDetailInfoChanged(built);
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
              Text("More Detail", style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w500)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Chọn loại xe
                  ChooseExpenseType(
                    expenseType: _draft.type,
                    onExpenseChanged: (value) {
                      setState(() {
                        _draft.type = value;
                        _emitIfReady();
                      });
                    },
                  ),

                  // Số chỗ
                  Container(
                    height: 55,
                    width: specs.screenWidth - 180,
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
                          LengthLimitingTextInputFormatter(7),
                        ],
                        style: GoogleFonts.outfit(fontSize: 13, color: Colors.black),
                        decoration: InputDecoration(
                          hint: Text.rich(TextSpan(children: [
                            TextSpan(text: 'Amount', style: GoogleFonts.outfit(
                                color: specs.black150, fontSize: 13)),
                          ])),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        onChanged: (v) {
                          setState(() {
                            _draft.amount = int.tryParse(v);
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
        SizedBox(height: specs.screenHeight * 0.4),
      ],
    );
  }

}

