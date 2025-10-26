import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:joy_way/services/data_processing/time_processing.dart';

import '../../config/general_specifications.dart';
import '../animated_container/custom_animated_button.dart';
import 'custom_text_box.dart';
import 'confirm_button.dart';

class CustomDatePicker extends StatefulWidget {
  final DateTime? date;
  final TimeOfDay? time;
  final bool? isDate;
  final String title;
  final ValueChanged<DateTime>? onDateSelected;
  final ValueChanged<TimeOfDay>? onTimeSelected;
  final ValueChanged<DateTime>? onDateTimeChanged;

  final Widget child;

  const CustomDatePicker({
    super.key,
    required this.child,
    this.title = "Date Picker",
    this.date,
    this.time,
    this.isDate,
    this.onDateSelected,
    this.onTimeSelected,
    this.onDateTimeChanged,
  });

  @override
  State<CustomDatePicker> createState() => _CustomDatePickerState();
}

class _CustomDatePickerState extends State<CustomDatePicker> {
  bool _isTapSelectDate = false;
  bool _isTapSelectTime = false;

  static const _switcherDuration = Duration(milliseconds: 350);
  static const _curveIn = Curves.easeOutCubic;
  static const _curveOut = Curves.easeInCubic;

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;


  DateTime _combine(DateTime d, TimeOfDay t) =>
      DateTime(d.year, d.month, d.day, t.hour, t.minute);

  DateTime _initialTimeDateTime() {
    final base = _selectedDate ?? widget.date ?? DateTime.now();
    final t = _selectedTime ?? widget.time ?? TimeOfDay.fromDateTime(DateTime.now());
    return _combine(base, t);
  }


  @override
  void initState() {
    super.initState();
    setState(() {
      if(widget.date != null) {
        _selectedDate = DateUtils.dateOnly(widget.date!);
        _selectedTime = TimeOfDay.fromDateTime(widget.date!);
      }
    });

  }

  @override
  Widget build(BuildContext context) {
    final specs = GeneralSpecifications(context);
    final showDate = (widget.isDate == null) || (widget.isDate == true);
    final showTime = (widget.isDate == null) || (widget.isDate == false);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 50),
            decoration: BoxDecoration(color: specs.black240),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SizedBox(
                  width: 50,
                  child: CustomAnimatedButton(
                    onTap: () async {
                      FocusScope.of(context).unfocus();
                      await Future.delayed(const Duration(milliseconds: 300));
                      if (mounted) Navigator.pop(context);
                    },
                    height: 30,
                    width: 20,
                    color: Colors.transparent,
                    shadowColor: Colors.transparent,
                    child: SizedBox(
                      height: 23,
                      width: 23,
                      child: Image.asset("assets/icons/other_icons/angle-left.png"),
                    ),
                  ),
                ),
                SizedBox(
                  height: 30,
                  width: specs.screenWidth - 130,
                  child: Center(
                    child: Text(
                      widget.title,
                      style: GoogleFonts.outfit(
                        color: Colors.black,
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 40),
              ],
            ),
          ),

          // Content
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                setState(() {
                  _isTapSelectDate = false;
                  _isTapSelectTime = false;
                });
              },
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  const SizedBox(height: 20),

                  widget.child,


                  if (showDate)
                    Row(
                      children: [
                        const SizedBox(width: 20),
                        CustomTextBox(
                          width: specs.screenWidth - 40,
                          text: TimeProcessing.dateToString(_selectedDate),        // hoặc "Date", dùng hiddenText hiển thị
                          hiddenText: "Set date",
                          onTap: () async {
                            setState(() {
                              _isTapSelectDate = true;
                              _isTapSelectTime = false;
                              _selectedDate = DateUtils.dateOnly(
                                (widget.date ?? DateTime.now()),
                              );
                            });
                          },
                        ),
                      ],
                    ),

                  const SizedBox(height: 20),

                  if (showTime)
                    Row(
                      children: [
                        const SizedBox(width: 20),
                        CustomTextBox(
                          width: 160,
                          text: TimeProcessing.timeToString(_selectedTime, context),
                          hiddenText: "Time",
                          onTap: () async {
                            setState(() {
                              _isTapSelectDate = false;
                              _isTapSelectTime = true;
                              _selectedTime = widget.time ?? TimeOfDay.fromDateTime(DateTime.now());
                            });
                          },
                        ),
                      ],
                    ),

                  const SizedBox(height: 400),
                ],
              ),
            ),
          ),

          // Confirm
          ConfirmButton(
            onConfirm: () async {
              // 1) Date-only mode
              if (widget.isDate == true) {
                if (_selectedDate == null) {
                  _toast(context, "Please select a date");
                  return;
                }
                widget.onDateSelected?.call(_selectedDate!);
                Navigator.pop(context);
                return;
              }
              // 2) Time-only mode
              if (widget.isDate == false) {
                if (_selectedTime == null) {
                  _toast(context, "Please select a time");
                  return;
                }
                widget.onTimeSelected?.call(_selectedTime!);
                Navigator.pop(context);
                return;
              }
              // 3) Both (bắt buộc đủ)
              if (_selectedDate == null || _selectedTime == null) {
                _toast(context, "Please set both Date and Time");
                return;
              }

              final dt = DateTime(
                _selectedDate!.year,
                _selectedDate!.month,
                _selectedDate!.day,
                _selectedTime!.hour,
                _selectedTime!.minute,
              );
              widget.onDateTimeChanged?.call(dt);
              Navigator.pop(context);
            },
          ),

          // Date picker
          AnimatedSwitcher(
            duration: _switcherDuration,
            switchInCurve: _curveIn,
            switchOutCurve: _curveOut,
            transitionBuilder: (child, anim) => SizeTransition(
              sizeFactor: anim,
              axis: Axis.vertical,
              child: FadeTransition(opacity: anim, child: child),
            ),
            child: _isTapSelectDate && showDate
                ? SizedBox(
              key: const ValueKey('date-on'),
              height: 220,
              width: specs.screenWidth,
              child: Column(
                children: [
                  SizedBox(
                    height: 200,
                    child: CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.date,
                      initialDateTime: _selectedDate ?? widget.date ?? DateTime.now(),
                      use24hFormat: true,
                      onDateTimeChanged: (d) {
                        setState(() => _selectedDate = DateUtils.dateOnly(d));
                      },
                    ),
                  ),
                ],
              ),
            )
                : const SizedBox.shrink(key: ValueKey('date-off')),
          ),

          // Time picker
          AnimatedSwitcher(
            duration: _switcherDuration,
            switchInCurve: _curveIn,
            switchOutCurve: _curveOut,
            transitionBuilder: (child, anim) => SizeTransition(
              sizeFactor: anim,
              axis: Axis.vertical,
              child: FadeTransition(opacity: anim, child: child),
            ),
            child: _isTapSelectTime && showTime
                ? SizedBox(
              key: const ValueKey('time-on'),
              height: 220,
              width: specs.screenWidth,
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 200,
                    child: CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.time,
                      initialDateTime: _initialTimeDateTime(),
                      use24hFormat: true,
                      onDateTimeChanged: (d) {
                        setState(() => _selectedTime = TimeOfDay.fromDateTime(d));
                      },
                    ),
                  ),
                ],
              ),
            )
                : const SizedBox.shrink(key: ValueKey('time-off')),
          ),
        ],
      ),
    );
  }

  void _toast(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }
}
