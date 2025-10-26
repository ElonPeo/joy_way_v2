import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:joy_way/models/user/user_app.dart';
import 'package:joy_way/models/user/user_information.dart';
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

  String _email = '';
  bool _saving = false;
  bool dataFetched = true;
  List<String>? _socialLinks;
  File? _avatarImage;
  File? _bgImage;
  String? _sex;
  DateTime? _dateOfBirth;
  String? _livingPlace;
  GeoPoint? _livingCoordinate;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final userApp = await ProfileFirestore().getUserInformationById(context, uid: uid);
    if (userApp != null) {
      setState(() {
        _nameController.text = userApp.name ?? "";
        _userNameController.text = userApp.userName ?? "";
        _phoneNumberController.text = userApp.phoneNumber ?? "";
        _socialLinks = userApp.socialLinks ?? [];
        _socialLinkControllers
          ..clear()
          ..addAll(_socialLinks!.map((link) => TextEditingController(text: link)));
        _sex = userApp.sex;
        _dateOfBirth = userApp.dateOfBirth;
        _livingPlace = userApp.livingPlace;
        _livingCoordinate = userApp.livingCoordinate;
        _email = userApp.email;
      });
    }
    setState(() {
      dataFetched = false;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _userNameController.dispose();
    _phoneNumberController.dispose();
    for (final c in _socialLinkControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final specs = GeneralSpecifications(context);
    final double inputWidth = specs.screenWidth - 60;

    return CustomScaffold(
      backgroundColor: specs.backgroundColor,
      onConfirm: () async {
        if (_saving) return;
        _saving = true;
        FocusScope.of(context).unfocus();

        final loading = ShowLoadingController();
        ShowLoading.show(
          context: context,
          controller: loading,
          message: "We are updating your profile...",
        );

        await Future.delayed(const Duration(milliseconds: 300));

        try {
          // 1) Validate
          final errorMsg = await ProfileFirestore().checkInformationBeforeSending(
            _userNameController.text.trim(),
            _phoneNumberController.text.trim(),
          );
          if (errorMsg != null) {
            loading.close(false);
            ShowNotification.showAnimatedSnackBar(context, errorMsg, 0, const Duration(milliseconds: 300));
            return;
          }

          // 2) Upload ảnh
          final imageResult = await ProfileFireStorageImage().uploadAvatarAndBackgroundImages(
            avatarFile: _avatarImage,
            backgroundFile: _bgImage,
          );

          // 3) Social links
          setState(() {
            _socialLinks = _socialLinkControllers
                .map((c) => c.text.trim())
                .where((t) => t.isNotEmpty)
                .toList();
          });

          // 4) Update profile
          final userInfo = UserInformation(
            userName: _userNameController.text.trim(),
            name: _nameController.text.trim(),
            sex: _sex,
            phoneNumber: _phoneNumberController.text.trim(),
            dateOfBirth: _dateOfBirth,
            livingPlace: _livingPlace,
            livingCoordinate: _livingCoordinate,
            socialLinks: _socialLinks,
          );

          final result = await ProfileFirestore().editProfile(userInfo);

          // 5) Kết quả
          final triedUploadImages = (_avatarImage != null) || (_bgImage != null);
          String? failMessage;
          String? successMessage;

          if (imageResult != null && result != null) {
            failMessage = 'Failed to update images: $imageResult\nFailed to update profile: $result';
          } else if (imageResult != null) {
            failMessage = 'Failed to update avatar/background: $imageResult';
            if (result == null) failMessage += ' Profile updated successfully.';
          } else if (result != null) {
            failMessage = 'Failed to update profile: $result';
            if (triedUploadImages) failMessage += ' Avatar/background may have been updated.';
          } else {
            successMessage = triedUploadImages
                ? 'Profile & images updated successfully'
                : 'Profile updated successfully';
          }

          if (failMessage != null) {
            loading.close(false);
            ShowNotification.showAnimatedSnackBar(context, failMessage, 0, const Duration(milliseconds: 500));
          } else {
            loading.close(true);
            ShowNotification.showAnimatedSnackBar(context, successMessage!, 3, const Duration(milliseconds: 500));
            Future.delayed(const Duration(seconds: 1), () {
              Navigator.pop(context);
            });
          }
        } catch (e) {
          loading.close(false);
          ShowNotification.showAnimatedSnackBar(context, "Unexpected error: $e", 0, const Duration(milliseconds: 500));
        } finally {
          _saving = false;
        }
      },
      title: "Edit profile",
      children: [
        const SizedBox(height: 25),
        AvatarAndBackgroundImage(
          onAvatarImage: (value) => setState(() => _avatarImage = value),
          onBgImage: (value) => setState(() => _bgImage = value),
        ),
        const SizedBox(height: 25),

        // Account
        Container(
          width: specs.screenWidth,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.white),
          child: Column(
            children: [
              // Name
              CustomTitleInputProfile(
                titleInput: "Name",
                child: dataFetched
                    ? LoadingContainer(width: inputWidth - 110, height: 30)
                    : SizedBox(
                  width: inputWidth - 110,
                  child: TextField(
                    controller: _nameController,
                    maxLength: 50,
                    // Gợi ý: dùng validator thay vì chặn ký tự để hỗ trợ tiếng Việt
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      isCollapsed: true,
                      contentPadding: const EdgeInsets.only(top: 3.5),
                      counterText: '',
                      hintText: "Your name",
                      hintStyle: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w400, color: specs.black200),
                    ),
                    style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w500, color: specs.pantoneColor4),
                  ),
                ),
              ),
              const SizedBox(height: 5),
              // Username
              CustomTitleInputProfile(
                titleInput: "User name",
                child: dataFetched
                    ? const LoadingContainer(width: 120, height: 30)
                    : Row(
                  children: [
                    SizedBox(
                      width: 18,
                      child: Text("@", style: GoogleFonts.outfit(color: specs.pantoneColor, fontSize: 20)),
                    ),
                    SizedBox(
                      width: inputWidth - 130,
                      child: TextField(
                        controller: _userNameController,
                        maxLength: 30,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[a-z0-9._]')),
                          TextInputFormatter.withFunction((oldV, newV) =>
                              newV.copyWith(text: newV.text.toLowerCase())),
                        ],
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          isCollapsed: true,
                          contentPadding: const EdgeInsets.only(top: 3.5),
                          counterText: '',
                          hintText: "username",
                          hintStyle: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w400, color: specs.black200),
                        ),
                        style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w500, color: specs.pantoneColor4),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 5),
              // Email (read-only)
              CustomTitleInputProfile(
                titleInput: "Email",
                child: dataFetched
                    ? const LoadingContainer(width: 100, height: 30)
                    : SizedBox(
                  width: inputWidth - 130,
                  child: Text(
                    _email.isEmpty ? "Email" : _email,
                    textAlign: TextAlign.left,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: _email.isEmpty ? specs.black200 : specs.pantoneColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 25),

        // Personal information
        Container(
          width: specs.screenWidth,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.white),
          child: Column(
            children: [
              // Phone
              CustomTitleInputProfile(
                titleInput: "Phone number",
                child: dataFetched
                    ? LoadingContainer(width: inputWidth - 110, height: 30)
                    : SizedBox(
                  width: specs.screenWidth * 0.55 - 10,
                  child: TextField(
                    controller: _phoneNumberController,
                    maxLength: 10,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      isCollapsed: true,
                      contentPadding: const EdgeInsets.only(top: 3.5),
                      counterText: '',
                      hintText: 'Phone number',
                      hintStyle: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w500, color: specs.black200),
                    ),
                    style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w500, color: specs.pantoneColor4),
                  ),
                ),
              ),
              const SizedBox(height: 5),
              // DOB
              // CustomTitleInputProfile(
              //   titleInput: "DOB",
              //   child: dataFetched
              //       ? LoadingContainer(width: inputWidth - 201, height: 30)
              //       : CustomDatePicker(
              //     title: '',
              //     onDateTimeChanged: (value) => setState(() => _dateOfBirth = value),
              //     child: SizedBox(
              //       width: inputWidth - 110,
              //       height: 30,
              //       child: Builder(
              //         builder: (_) {
              //           final dobStr = TimeProcessing.dateToString(_dateOfBirth);
              //           final isEmpty = dobStr == null;
              //           return Row(
              //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //             children: [
              //               Text(
              //                 dobStr ?? "Date of birth",
              //                 textAlign: TextAlign.left,
              //                 style: GoogleFonts.outfit(
              //                   fontSize: 14,
              //                   fontWeight: FontWeight.w500,
              //                   color: isEmpty ? specs.black200 : specs.pantoneColor4,
              //                 ),
              //               ),
              //               SizedBox(height: 15, width: 15, child: Image.asset("assets/icons/other_icons/angle-right.png")),
              //             ],
              //           );
              //         },
              //       ),
              //     ),
              //   ),
              // ),
              // const SizedBox(height: 5),
              // Living place
              CustomTitleInputProfile(
                titleInput: "Living place",
                child: dataFetched
                    ? LoadingContainer(width: inputWidth - 150, height: 30)
                    : GestureDetector(
                  onTap: () {
                    ShowGeneralDialog.General_Dialog(
                      context: context,
                      beginOffset: const Offset(1, 0),
                      child: SelectLocation(
                        onGeoPoint: (v) => setState(() => _livingCoordinate = v),
                        onAddress: (v) => setState(() => _livingPlace = v),
                      ),
                    );
                  },
                  child: SizedBox(
                    width: inputWidth - 110,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: inputWidth - 130,
                          child: Text(
                            _livingPlace ?? "Where you live",
                            textAlign: TextAlign.left,
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: (_livingPlace ?? '').isEmpty ? specs.black200 : specs.pantoneColor4,
                            ),
                          ),
                        ),
                        SizedBox(height: 15, width: 15, child: Image.asset("assets/icons/other_icons/angle-right.png")),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 5),
              // Gender
              ChooseGender(
                sex: _sex,
                dataFetched: dataFetched,
                onSex: (value) => setState(() => _sex = value),
              ),
            ],
          ),
        ),

        const SizedBox(height: 25),

        // Social links
        SocialLinks(controllers: _socialLinkControllers),

        SizedBox(height: specs.screenHeight - 300, width: specs.screenWidth),
      ],
    );
  }
}

