import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:joy_way/screens/setting/edit_profile/components/choose_gender.dart';
import 'package:joy_way/screens/setting/edit_profile/components/edit_avatar_bgimage.dart';
import 'package:joy_way/services/data_processing/time_processing.dart';
import 'package:joy_way/services/firebase_services/profile_services.dart';
import 'package:joy_way/widgets/custom_input/custom_date_picker.dart';

import '../../../config/general_specifications.dart';
import '../../../widgets/custom_scaffold/custom_scaffold.dart';
import '../../../widgets/notifications/show_notification.dart';
import 'components/custom_profile_text_field.dart';

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

  String? _name;
  String? _userName;
  String? _phoneNumber;
  String? _sex;
  String? _email;
  DateTime? _dateOfBirth;
  String? _currentAddress;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final result = await service.getCurrentUserInformation();
    if (result != null) {
      setState(() {
        _userName = result['userName'];
        _name = result['name'];
        _sex = result['sex'];
        _email = result['email'];
        _phoneNumber = result['phoneNumber'];
        _dateOfBirth = result['dateOfBirth'];
        _currentAddress = result['currentAddress'];
        if (_name != null) _nameController.text = _name!;
        if (_userName != null) _userNameController.text = _userName!;
        if (_phoneNumber != null) _phoneNumberController.text = _phoneNumber!;
      });
      print(result);
    }
    print(_email);
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
              context,
              "Profile update successful",
              3,
              const Duration(milliseconds: 300));
        }
        _saving = false;
      },
      title: "Edit profile",
      children: [
        const SizedBox(height: 25),
        EditAvatarBgimage(

        ),
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
                            child: _userName == null
                                ? TextField(
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
                                  )
                                : SizedBox(
                                    width: specs.screenWidth * 0.55 - 25,
                                    height: 30,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _userName ?? 'Set username',
                                          style: GoogleFonts.outfit(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: specs.pantoneColor,
                                          ),
                                        ),
                                      ],
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
                                    "assets/icons/other_icons/angle-right.png"),
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
                                  "assets/icons/other_icons/angle-right.png"),
                            )
                          ],
                        )),
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

