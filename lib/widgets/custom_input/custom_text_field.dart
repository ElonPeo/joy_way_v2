import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../config/general_specifications.dart';

class CustomTextField extends StatefulWidget {
  final bool isHidden;
  final String iconAsset;
  final String title;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;

  const CustomTextField({
    super.key,
    this.isHidden = false,
    required this.iconAsset,
    required this.title,
    this.onChanged,
    this.controller,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  final FocusNode _focusNode = FocusNode();
  late TextEditingController _controller;
  bool _isFocused = false;
  bool _isObscure = false;

  @override
  void initState() {
    super.initState();

    _controller = widget.controller ?? TextEditingController();
    _isObscure = widget.isHidden; // nếu là password thì mặc định ẩn

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
      height: 70,
      width: specs.screenWidth -40 ,
      padding: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        border: Border.all(
          color: specs.black240,
          width: 1.5,
          style: BorderStyle.solid,
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            child: Center(
              child: Image.asset(
                height: 25,
                width: 25,
                widget.iconAsset,
              ),
            ),
          ),
          SizedBox(
            width: widget.isHidden
                ? specs.screenWidth - 170
                : specs.screenWidth - 130,
            child: Stack(
              children: [
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 150),
                  top: _isFocused ? 0 : 13,
                  child: SizedBox(
                    height: 30,
                    child: Center(
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 180),
                        curve: Curves.easeInOut,
                        style: GoogleFonts.outfit(
                          fontSize: _isFocused ? 12 : 14,
                          color: _isFocused ? specs.black150 : Colors.black,
                          fontWeight: FontWeight.w400,
                        ),
                        child: Text(widget.title),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 60,
                  child: Center(
                    child: TextField(
                      focusNode: _focusNode,
                      controller: _controller,
                      obscureText: _isObscure,
                      onChanged: widget.onChanged,
                      maxLength: 100,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isCollapsed: true,
                        contentPadding: EdgeInsets.only(top: 18),
                        counterText: '',
                      ),
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (widget.isHidden)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                setState(() {
                  _isObscure = !_isObscure;
                });
              },
              child: SizedBox(
                width: 40,
                child: ImageIcon(
                  AssetImage(
                    _isObscure
                        ? 'assets/icons/authentication/eye-crossed.png'
                        : 'assets/icons/authentication/eye.png',
                  ),
                  size: 25,
                  color: specs.pantoneColor3.withOpacity(0.6),
                ),
              ),
            )
        ],
      ),
    );
  }
}
