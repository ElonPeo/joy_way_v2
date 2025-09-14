import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../config/general_specifications.dart';

class CustomProfileTextField extends StatefulWidget {
  final String nullValue;
  final String title;
  final int maxLength;
  final bool isNumber;
  final EdgeInsets padding;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;

  const CustomProfileTextField({
    super.key,
    required this.nullValue,
    required this.title,
    this.isNumber = false,
    this.maxLength = 100,
    this.padding = const EdgeInsets.symmetric(vertical: 15),
    this.onChanged,
    this.controller,
  });

  @override
  State<CustomProfileTextField> createState() => _CustomProfileTextFieldState();
}

class _CustomProfileTextFieldState extends State<CustomProfileTextField> {
  final FocusNode _focusNode = FocusNode();
  late TextEditingController _controller;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode.addListener(_updateFocus);
    _controller.addListener(_updateFocus);
  }

  void _updateFocus() {
    setState(() {
      _isFocused = _focusNode.hasFocus || _controller.text.isNotEmpty;
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final specs = GeneralSpecifications(context);
    return Container(
      padding: widget.padding,
      width: specs.screenWidth,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: specs.screenWidth * 0.3,
            child: Text(
              widget.title,
              style: GoogleFonts.outfit(fontSize: 14, color: specs.black100),
            ),
          ),
          Container(
            width: specs.screenWidth * 0.55 - 10,
            height: 30,
            color: Colors.transparent,
            child: TextField(
              focusNode: _focusNode,
              controller: _controller,
              onChanged: widget.onChanged,
              maxLength: widget.maxLength,
              keyboardType: widget.isNumber ? TextInputType.number : null,
              inputFormatters: [
                widget.isNumber
                    ? FilteringTextInputFormatter.digitsOnly
                    : FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z ]')),
              ],
              decoration: InputDecoration(
                border: InputBorder.none,
                isCollapsed: true,
                contentPadding: EdgeInsets.only(top: 3.5),
                counterText: '',
                hintText: widget.nullValue,
                hintStyle: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: specs.black200),
              ),
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: specs.pantoneColor4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
