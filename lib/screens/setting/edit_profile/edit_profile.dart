import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:joy_way/screens/setting/edit_profile/components/choose_gender.dart';
import 'package:joy_way/widgets/custom_text_field/custome_select.dart';

import '../../../config/general_specifications.dart';
import '../../../widgets/animated_container/flashing_container.dart';
import '../../../widgets/custom_scaffold/custom_scaffold.dart';


class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();

  String? _sex;
  String? _email;
  String? _dateOfBirth;
  String? _currentAddress;




  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _userNameController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final specs = GeneralSpecifications(context);
    return CustomScaffold(
      backgroundColor: specs.backgroundColor,
      onConfirm: () async {
        print(_nameController.text);
      },
      title: "Edit profile",
      children: [
        const SizedBox(height: 25),
        Container(
            height: 250,
            width: specs.screenWidth,
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(40)),
            child: Center(
              child: GestureDetector(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: Container(
                    height: 100,
                    width: 100,
                    color: const Color.fromRGBO(98, 125, 142, 1),
                    child: Stack(
                      children: [
                        const Center(
                          child: ImageIcon(
                            AssetImage(
                              'assets/icons/other_icons/user.png',
                            ),
                            color: Colors.white,
                            size: 50,
                          ),
                        ),
                        Center(
                          child: Container(
                            height: 100,
                            width: 100,
                            decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color.fromRGBO(0, 0, 0, 0.6)),
                            child: const Center(
                              child: ImageIcon(
                                AssetImage(
                                  'assets/icons/other_icons/camera.png',
                                ),
                                color: Colors.white,
                                size: 50,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )),
        const SizedBox(height: 25),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(width: 10),
            Text(
              "Account",
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.w500,
                color: specs.black150,
                fontSize: 12,
              ),
            ),
          ],
        ),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          width: specs.screenWidth,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
          ),
          child: Column(
            children: [
              CustomProfileTextField(
                oldValue: null,
                nullValue: "Your name",
                title: "Name",
                controller: _nameController,
                padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
              ),
              CustomProfileTextField(
                oldValue: null,
                nullValue: "Set username",
                title: "User Name",
                controller: _userNameController,
                padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                width: specs.screenWidth,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: specs.screenWidth * 0.3,
                      child: Text(
                        "Email",
                        style: GoogleFonts.outfit(
                            fontSize: 14, color: specs.black100),
                      ),
                    ),
                    SizedBox(
                        width: specs.screenWidth * 0.55 - 10,
                        height: 30,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              textAlign: TextAlign.left,
                              _email ?? "Email",
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: (_email ?? '').isEmpty
                                    ? specs.black200
                                    : specs.pantoneColor,
                              ),
                            ),
                          ],
                        )
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 25),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(width: 10),
            Text(
              "Personal information",
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.w500,
                color: specs.black150,
                fontSize: 12,
              ),
            ),
          ],
        ),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          width: specs.screenWidth,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
          ),
          child: Column(
            children: [
              CustomProfileTextField(
                oldValue: null,
                nullValue: "Your phone number",
                title: "Phone number",
                controller: _phoneNumberController,
                isNumber: true,
                padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
              ),
              Container(
                padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
                width: specs.screenWidth,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: specs.screenWidth * 0.3,
                      child: Text(
                        "DOB",
                        style: GoogleFonts.outfit(
                            fontSize: 14, color: specs.black100),
                      ),
                    ),
                    SizedBox(
                        width: specs.screenWidth * 0.55 - 10,
                        height: 30,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              textAlign: TextAlign.left,
                              _dateOfBirth ?? "Date of birth",
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: (_dateOfBirth ?? '').isEmpty
                                    ? specs.black200
                                    : specs.pantoneColor,
                              ),
                            ),
                          ],
                        )
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
                width: specs.screenWidth,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: specs.screenWidth * 0.3,
                      child: Text(
                        "Current address",
                        style: GoogleFonts.outfit(
                            fontSize: 14, color: specs.black100),
                      ),
                    ),
                    SizedBox(
                        width: specs.screenWidth * 0.55 - 10,
                        height: 30,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              textAlign: TextAlign.left,
                              _currentAddress ?? "Where you live",
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: (_currentAddress ?? '').isEmpty
                                    ? specs.black200
                                    : specs.pantoneColor,
                              ),
                            ),
                          ],
                        )
                    ),
                  ],
                ),
              ),
              ChooseGender(
                sex: _sex,
                onSex: (value) => setState(() {
                  _sex = value;
                }),
              )
            ],
          ),
        ),
        SizedBox(
          height: specs.screenHeight - 300,
          width: specs.screenWidth,
        ),
      ],
    );
  }
}

class CustomProfileTextField extends StatefulWidget {
  final String? oldValue;
  final String nullValue;
  final String title;
  final int maxLength;
  final bool isNumber;
  final EdgeInsets padding;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;

  const CustomProfileTextField({
    super.key,
    required this.oldValue,
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
          SizedBox(
            width: specs.screenWidth * 0.55 - 10,
            height: 30,
            child: Stack(
              children: [
                SizedBox(
                    width: specs.screenWidth * 0.55,
                    height: 30,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          textAlign: TextAlign.left,
                          widget.oldValue ?? widget.nullValue,
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: (widget.oldValue ?? '').isEmpty
                                ? specs.black200
                                : specs.pantoneColor,
                          ),
                        ),
                      ],
                    )),
                Container(
                  width: specs.screenWidth * 0.55,
                  height: 30,
                  color: _controller.text.isNotEmpty
                      ? Colors.white
                      : Colors.transparent,
                  child: TextField(
                    focusNode: _focusNode,
                    controller: _controller,
                    onChanged: widget.onChanged,
                    maxLength: widget.maxLength,
                    keyboardType: widget.isNumber ? TextInputType.number : null,
                    inputFormatters: [
                      widget.isNumber
                          ? FilteringTextInputFormatter.digitsOnly
                          : FilteringTextInputFormatter.allow(
                              RegExp(r'[a-zA-Z]')),
                    ],
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isCollapsed: true,
                      contentPadding: EdgeInsets.only(top: 3.5),
                      counterText: '',
                    ),
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
