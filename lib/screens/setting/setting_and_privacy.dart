import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:joy_way/services/firebase_services/authentication.dart';
import 'package:joy_way/widgets/custom_scaffold/custom_scaffold.dart';

import '../../config/general_specifications.dart';
import '../../widgets/notifications/confirm_notification.dart';

class SettingAndPrivacy extends StatefulWidget {
  const SettingAndPrivacy({super.key});

  @override
  State<SettingAndPrivacy> createState() => _SettingAndPrivacyState();
}

class _SettingAndPrivacyState extends State<SettingAndPrivacy> {
  @override
  Widget build(BuildContext context) {
    final specs = GeneralSpecifications(context);
    final user = FirebaseAuth.instance.currentUser;
    return CustomScaffold(
      backgroundColor: specs.backgroundColor,
      title: "Setting and privacy",
      children: [
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
                fontSize: 14,
              ),
            ),
          ],
        ),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          width: specs.screenWidth,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
          ),
          child: Column(
            children: [
              SettingTile(
                title: "Verify identity",
                assetIcon: "assets/icons/setting/id-badge.png",
                onTap: () {
                  print("Verify identity tapped");
                },
              ),
              SettingTile(
                title: "Change Password",
                assetIcon: "assets/icons/setting/password-lock.png",
                onTap: () {
                  print("Verify identity tapped");
                },
              ),
              SettingTile(
                title: "Sign out",
                assetIcon: "assets/icons/setting/exit.png",
                iconColor: specs.rSlight,
                hasBottomBorder: false,
                onTap: () async {
                  final result = await ShowConfirmNotification.showAnimatedSnackBar(
                    context,
                    "Are you sure you want to log out?",
                    2,
                    onConfirm: () async {
                      await Authentication().signOut();
                      if (!context.mounted) return;
                      Navigator.pushNamedAndRemoveUntil(context, '/auth', (route) => false);
                    },
                  );
                },
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
              "Support and terms",
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.w500,
                color: specs.black150,
                fontSize: 14,
              ),
            ),
          ],
        ),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          width: specs.screenWidth,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
          ),
          child: Column(
            children: [
              SettingTile(
                title: "Support",
                assetIcon: "assets/icons/setting/user-headset.png",
                onTap: () {
                  print("");
                },
              ),
              SettingTile(
                hasBottomBorder: false,
                title: "Terms and services",
                assetIcon: "assets/icons/setting/terms-info.png",
                onTap: () {

                },
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
              "Language",
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.w500,
                color: specs.black150,
                fontSize: 14,
              ),
            ),
          ],
        ),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          width: specs.screenWidth,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
          ),
          child: Column(
            children: [
              SettingTile(
                hasBottomBorder: false,
                title: "Language",
                assetIcon: "assets/icons/setting/language.png",
                onTap: () {
                },
              ),

            ],
          ),
        ),
        Container(
          height: specs.screenHeight - 200,
          width: specs.screenWidth,
        ),
      ],
    );
  }
}

class SettingTile extends StatefulWidget {
  final String title;
  final String assetIcon;
  final Color iconColor;
  final VoidCallback? onTap;
  final bool hasBottomBorder;

  const SettingTile({
    super.key,
    required this.title,
    required this.assetIcon,
    this.iconColor = const Color.fromRGBO(150, 150, 150, 1),
    this.onTap,
    this.hasBottomBorder = true,
  });

  @override
  State<SettingTile> createState() => _SettingTileState();
}

class _SettingTileState extends State<SettingTile> {
  bool _isTapDown = false;

  void _safeSetState(VoidCallback fn) {
    if (!mounted) return;
    setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) {
        _safeSetState(() => _isTapDown = true);
      },
      onTapUp: (_) async {
        await Future.delayed(const Duration(milliseconds: 50));
        if (!mounted) return;
        _safeSetState(() => _isTapDown = false);
        widget.onTap?.call();
      },
      onTapCancel: () {
        _safeSetState(() => _isTapDown = false);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        width: width,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: _isTapDown ? const Color.fromRGBO(225, 225, 225, 1) : Colors.white,
          border: widget.hasBottomBorder
              ? const Border(
                  bottom: BorderSide(color: Color(0xFFEEEEEE), width: 1),
                )
              : null,
        ),
        child: Row(
          children: [
            const SizedBox(width: 10),
            ImageIcon(
              AssetImage(widget.assetIcon),
              size: 20,
              color: widget.iconColor,
            ),
            const SizedBox(width: 10),
            Text(
              widget.title,
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.w500,
                color: Colors.black,
                fontSize: 14,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
