import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:joy_way/screens/setting/edit_profile/components/avatar_and_background_image.dart';
import 'package:joy_way/screens/setting/edit_profile/components/choose_gender.dart';
import 'package:joy_way/screens/setting/edit_profile/components/custom_title_input_profile.dart';
import 'package:joy_way/screens/setting/edit_profile/components/social_links.dart';
import 'package:joy_way/services/data_processing/time_processing.dart';
import 'package:joy_way/services/firebase_services/profile_services/profile_fire_storage_image.dart';
import 'package:joy_way/services/firebase_services/profile_services/profile_firestore.dart';
import 'package:joy_way/widgets/animated_container/loading_container.dart';
import 'package:joy_way/widgets/custom_input/custom_date_picker.dart';
import 'package:joy_way/widgets/notifications/show_loading.dart';

import '../../../config/general_specifications.dart';
import '../../../widgets/ShowGeneralDialog.dart';
import '../../../widgets/custom_scaffold/custom_scaffold.dart';
import '../../../widgets/map/select_location/select_location.dart';
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
  final List<TextEditingController> _socialLinkControllers = [];

  bool _saving = false;
  bool dataFetched = true;
  String? _name;
  String? _userName;
  String? _phoneNumber;
  String? _sex;
  String? _email;
  DateTime? _dateOfBirth;
  File? _avatarImage;
  File? _bgImage;
  GeoPoint? _livingCoordinate;
  String? _livingPlace;
  List<String>? _socialLinks;


  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final result = await ProfileFirestore().getCurrentUserInformation(context);
    if (!mounted) return;

    if (result != null) {
      final String? userName = result['userName'] as String?;
      final String? name = result['name'] as String?;
      final String? sex = result['sex'] as String?;
      final String? email = result['email'] as String?;
      final String? phoneNumber = result['phoneNumber'] as String?;
      final dynamic dobRaw = result['dateOfBirth'];
      final String? livingPlace = result['livingPlace'] as String?;
      final GeoPoint? livingCoordinate = result['livingCoordinate'] as GeoPoint?;
      final List<dynamic>? linksRaw = result['socialLinks'] as List<dynamic>?;

      DateTime? dateOfBirth;
      if (dobRaw is Timestamp) dateOfBirth = dobRaw.toDate();
      if (dobRaw is DateTime) dateOfBirth = dobRaw;

      final List<String>? socialLinks = linksRaw
          ?.map((e) => (e ?? '').toString().trim())
          .where((s) => s.isNotEmpty)
          .take(3)
          .toList();

      setState(() {
        _userName = userName;
        _name = name;
        _sex = sex;
        _email = email;
        _phoneNumber = phoneNumber;
        _dateOfBirth = dateOfBirth;
        _livingPlace = livingPlace;
        _livingCoordinate = livingCoordinate;
        _socialLinks = socialLinks;

        if (_name != null) _nameController.text = _name!;
        if (_userName != null) _userNameController.text = _userName!;
        if (_phoneNumber != null) _phoneNumberController.text = _phoneNumber!;

        _socialLinkControllers
          ..clear()
          ..addAll((socialLinks ?? const <String>[])
              .map((s) => TextEditingController(text: s)));
      });
    }
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      setState(() => dataFetched = false);
    });
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
    double inputWidth = specs.screenWidth - 60;
    return CustomScaffold(
      backgroundColor: specs.backgroundColor,
      onConfirm: () async {
        if (_saving) return;
        _saving = true;
        FocusScope.of(context).unfocus();

        final loading = ShowLoadingController();
        // mở loading
        ShowLoading.show(
          context: context,
          controller: loading,
          message: "We are updating your profile...",
        );
        await Future.delayed(const Duration(milliseconds: 1000));

        try {
          // 1) Validate
          final check = await ProfileFirestore().checkInformationBeforeSending(
            _userNameController.text.trim(),
            _phoneNumberController.text.trim(),
          );
          if (check != null) {
            loading.close(false);
            ShowNotification.showAnimatedSnackBar(
                context, check, 0, const Duration(milliseconds: 300));
            return;
          }

          // 2) Upload ảnh
          final imageResult =
              await ProfileFireStorageImage().uploadAvatarAndBackgroundImages(
            avatarFile: _avatarImage,
            backgroundFile: _bgImage,
          );

          // 3) Cập nhật profile
          setState(() {
            _socialLinks = _socialLinkControllers
                .map((c) => c.text.trim())
                .where((t) => t.isNotEmpty)
                .toList();
          });
          final result = await ProfileFirestore().editProfile(
            userName: _userNameController.text.trim(),
            name: _nameController.text.trim(),
            sex: _sex,
            phoneNumber: _phoneNumberController.text.trim(),
            dateOfBirth: _dateOfBirth,
            livingPlace: _livingPlace,
            livingCoordinate: _livingCoordinate,
            socialLinks: _socialLinks,
          );

          // 4) Thông báo
          final triedUploadImages =
              (_avatarImage != null) || (_bgImage != null);
          String? errorMsg;
          String? successMsg;

          if (imageResult != null && result != null) {
            errorMsg =
                'Failed to update images: $imageResult\nFailed to update profile: $result';
          } else if (imageResult != null) {
            errorMsg = 'Failed to update avatar/background: $imageResult';
            if (result == null) errorMsg += '\nProfile updated successfully.';
          } else if (result != null) {
            errorMsg = 'Failed to update profile: $result';
            if (triedUploadImages)
              errorMsg += '\nAvatar/background may have been updated.';
          } else {
            successMsg = triedUploadImages
                ? 'Profile & images updated successfully'
                : 'Profile update successful';
          }

          if (errorMsg != null) {
            loading.close(false);
            ShowNotification.showAnimatedSnackBar(
                context, errorMsg, 0, const Duration(milliseconds: 500));
          } else {
            loading.close(true);
            ShowNotification.showAnimatedSnackBar(
                context, successMsg!, 3, const Duration(milliseconds: 500));
            Future.delayed(const Duration(seconds: 1), () {
              Navigator.pop(context);
              Navigator.pop(context);
            });
          }
        } catch (e) {
          loading.close(false);
          ShowNotification.showAnimatedSnackBar(
              context, e.toString(), 0, const Duration(milliseconds: 500));
        } finally {
          _saving = false;
        }
      },
      title: "Edit profile",
      children: [
        const SizedBox(height: 25),
        AvatarAndBackgroundImage(
          onAvatarImage: (value) => {
            setState(() {
              _avatarImage = value;
            })
          },
          onBgImage: (value) => {
            setState(() {
              _bgImage = value;
            }),
          },
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
        const SizedBox(height: 10),
        Container(
          width: specs.screenWidth,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              CustomTitleInputProfile(
                titleInput: "Name",
                child: dataFetched
                    ? LoadingContainer(width: inputWidth - 110, height: 30)
                    : SizedBox(
                        width: inputWidth - 110,
                        child: TextField(
                          controller: _nameController,
                          maxLength: 50,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[A-Za-z ]')),
                          ],
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            isCollapsed: true,
                            contentPadding: const EdgeInsets.only(top: 3.5),
                            counterText: '',
                            hintText: "Your name",
                            hintStyle: GoogleFonts.outfit(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: specs.black200),
                          ),
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: specs.pantoneColor4,
                          ),
                        ),
                      ),
              ),
              const SizedBox(
                height: 5,
              ),
              CustomTitleInputProfile(
                titleInput: "User name",
                child: dataFetched
                    ? const LoadingContainer(width: 120, height: 30)
                    : Row(
                        children: [
                          SizedBox(
                            width: 18,
                            child: Text(
                              "@",
                              style: GoogleFonts.outfit(
                                color: specs.pantoneColor,
                                fontSize: 20,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: inputWidth - 130,
                            child: TextField(
                              controller: _userNameController,
                              maxLength: 50,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'[A-Za-z ]')),
                              ],
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                isCollapsed: true,
                                contentPadding: const EdgeInsets.only(top: 3.5),
                                counterText: '',
                                hintText: "Username",
                                hintStyle: GoogleFonts.outfit(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
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
              ),
              const SizedBox(
                height: 5,
              ),
              CustomTitleInputProfile(
                titleInput: "Email",
                child: dataFetched
                    ? const LoadingContainer(width: 100, height: 30)
                    : SizedBox(
                        width: inputWidth - 130,
                        child: Text(
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
        const SizedBox(height: 10),
        Container(
            width: specs.screenWidth,
            padding:
                const EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
            ),
            child: Column(
              children: [
                CustomTitleInputProfile(
                  titleInput: "Phone number",
                  child: dataFetched
                      ? LoadingContainer(width: inputWidth - 110, height: 30)
                      : Container(
                          width: specs.screenWidth * 0.55 - 10,
                          color: Colors.transparent,
                          child: TextField(
                            controller: _phoneNumberController,
                            maxLength: 10,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              isCollapsed: true,
                              contentPadding: const EdgeInsets.only(top: 3.5),
                              counterText: '',
                              hintText: 'Phone number',
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
                ),
                const SizedBox(
                  height: 5,
                ),
                CustomTitleInputProfile(
                  titleInput: "DOB",
                  child: dataFetched
                      ? LoadingContainer(width: inputWidth - 201, height: 30)
                      : CustomDatePicker(
                          title: '',
                          onDateTimeChanged: (value) {
                            setState(() {
                              _dateOfBirth = value;
                            });
                          },
                          child: SizedBox(
                              width: inputWidth - 110,
                              height: 30,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                        ),
                ),
                const SizedBox(
                  height: 5,
                ),
                CustomTitleInputProfile(
                  titleInput: "Living PLace",
                  child: dataFetched
                      ? LoadingContainer(width: inputWidth - 150, height: 30)
                      : GestureDetector(
                          onTap: () {
                            ShowGeneralDialog.General_Dialog(
                              context: context,
                              beginOffset: const Offset(1, 0),
                              child: SelectLocation(onGeoPoint: (v) {
                                setState(() {
                                  _livingCoordinate = v;
                                });
                              }, onAddress: (v) {
                                _livingPlace = v;
                              }),
                            );
                          },
                          child: SizedBox(
                              width: inputWidth - 110,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    width: inputWidth - 130,
                                    child: Text(
                                      _livingPlace ?? "Where you live",
                                      textAlign: TextAlign.left,
                                      style: GoogleFonts.outfit(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: (_livingPlace ?? '').isEmpty
                                            ? specs.black200
                                            : specs.pantoneColor4,
                                      ),
                                    ),
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        height: 15,
                                        width: 15,
                                        child: Image.asset(
                                            "assets/icons/other_icons/angle-right.png"),
                                      ),
                                    ],
                                  )
                                ],
                              )),
                        ),
                ),
                const SizedBox(
                  height: 5,
                ),
                ChooseGender(
                  sex: _sex,
                  dataFetched: dataFetched,
                  onSex: (value) => setState(() {
                    _sex = value;
                  }),
                ),
              ],
            )),
        const SizedBox(height: 25),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(width: 10),
            Text(
              "Social links",
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.w500,
                color: specs.black150,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SocialLinks(
          controllers: _socialLinkControllers,
        ),
        SizedBox(
          height: specs.screenHeight - 300,
          width: specs.screenWidth,
        ),
      ],
    );
  }
}
