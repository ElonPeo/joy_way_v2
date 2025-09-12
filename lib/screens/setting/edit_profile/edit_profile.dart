import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:joy_way/screens/setting/edit_profile/components/choose_gender.dart';
import 'package:joy_way/services/data_processing/time_processing.dart';
import 'package:joy_way/services/firebase_services/profile_services.dart';
import 'package:joy_way/widgets/custom_input/custom_date_picker.dart';

import '../../../config/general_specifications.dart';
import '../../../widgets/custom_scaffold/custom_scaffold.dart';
import '../../../widgets/notifications/show_notification.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final service = ProfileService();
  bool _saving = false;

  String? _sex;
  String? _email;
  DateTime? _dateOfBirth;
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
        if (_saving) return;
        _saving = true;
        FocusScope.of(context).unfocus();

        // 1) Validate
        final check = await service.checkInformationBeforeSending(
          _userNameController.text.trim(),
          _phoneNumberController.text.trim(),
        );
        if (check != null) {
          ShowNotification.showAnimatedSnackBar(
              context, check, 0, const Duration(milliseconds: 300));
          _saving = false;
          return;
        }

        // 2) Ghi dữ liệu
        final result = await service.editProfile(
          userName: _userNameController.text.trim(),
          name: _nameController.text.trim(),
          sex: _sex,
          phoneNumber: _phoneNumberController.text.trim(),
          dateOfBirth: _dateOfBirth,
          currentAddress: _currentAddress,
        );
        // 3) Thông báo
        if (result != null) {
          ShowNotification.showAnimatedSnackBar(
              context, result, 0, const Duration(milliseconds: 300));
        } else {
          ShowNotification.showAnimatedSnackBar(
              context, "Profile update successful", 3, const Duration(milliseconds: 300));
        }
        _saving = false;

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
              Container(
                padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
                width: specs.screenWidth,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: specs.screenWidth * 0.3,
                      child: Text(
                        'User name',
                        style: GoogleFonts.outfit(
                            fontSize: 14, color: specs.black100),
                      ),
                    ),
                    Container(
                      width: specs.screenWidth * 0.55 - 10,
                      height: 30,

                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: 15,
                            child: Text(
                              '@',
                              style: GoogleFonts.outfit(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: specs.pantoneColor,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: specs.screenWidth * 0.55 - 25,
                            height: 30,
                            child: TextField(
                              controller: _userNameController,
                              maxLength: 100,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'[a-zA-Z]')),
                              ],
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                isCollapsed: true,
                                contentPadding: EdgeInsets.only(top: 3.5),
                                counterText: '',
                                hintText: 'Set username',
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
                          )

                        ],
                      ),
                    ),
                  ],
                ),
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
                        )),
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
                    CustomDatePicker(
                      title: '',
                      onDateTimeChanged: (value) {
                        setState(() {
                          _dateOfBirth = value;
                        });
                      },
                      child: SizedBox(
                          width: specs.screenWidth * 0.55 - 10,
                          height: 30,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                textAlign: TextAlign.left,
                                TimeProcessing.dateToString(_dateOfBirth) ??
                                    "Date of birth",
                                style: GoogleFonts.outfit(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: TimeProcessing.dateToString(
                                      _dateOfBirth) ==
                                      null
                                      ? specs.black200
                                      : specs.pantoneColor4,
                                ),
                              ),
                              SizedBox(
                                height: 15,
                                width: 15,
                                child: Image.asset(
                                    "assets/icons/other_icons/angle-right.png"
                                ),
                              )
                            ],
                          )),
                    )
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
                                    : specs.pantoneColor4,
                              ),
                            ),
                            SizedBox(
                              height: 15,
                              width: 15,
                              child: Image.asset(
                                  "assets/icons/other_icons/angle-right.png"
                              ),
                            )
                          ],
                        )),
                  ],
                ),
              ),
              ChooseGender(
                sex: _sex,
                onSex: (value) =>
                    setState(() {
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
