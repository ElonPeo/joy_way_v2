import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../config/general_specifications.dart';
import '../../../../services/firebase_services/authentication.dart';
import '../../../../widgets/animated_container/move_and_fade_container.dart';
import '../../../../widgets/custom_text_field/custom_text_field.dart';
import '../../../../widgets/notifications/show_notification.dart';

class RecoveryScreen extends StatefulWidget {
  final Function(int) onChanged;
  final Function(bool) onScaleForLoading;
  final Function(int) onStatus;
  final Function(List<String>) onMessage;
  final bool hideRecoveryPassword;

  const RecoveryScreen({
    super.key,
    required this.onScaleForLoading,
    required this.hideRecoveryPassword,
    required this.onStatus,
    required this.onMessage,
    required this.onChanged,
  });

  @override
  State<RecoveryScreen> createState() => _RecoveryScreenState();
}

class _RecoveryScreenState extends State<RecoveryScreen> {
  static const double padding = 40.0;
  Curve _curves = Curves.easeOutBack;
  Duration _duration = const Duration(milliseconds: 800);

  /// value
  final TextEditingController emailController = TextEditingController();

  /// button
  bool _isTapDown = false;

  /// animation flags
  bool animationEmail = false;
  bool animationConfirmButton = false;
  bool animationInstruct = false;

  /// Token để vô hiệu hóa các callback trễ khi dispose / rebuild
  int _lifecycleToken = 0;

  Future<void> startAnimations(int token) async {
    Future<void> step(Duration d, VoidCallback apply) async {
      await Future.delayed(d);
      if (!mounted || token != _lifecycleToken) return;
      _safeSetState(apply);
    }

    await step(const Duration(milliseconds: 50), () => animationEmail = true);
    await step(
        const Duration(milliseconds: 100), () => animationConfirmButton = true);
    await step(
        const Duration(milliseconds: 150), () => animationInstruct = true);
  }

  Future<String?> recoveryPassword(
      BuildContext context,
      String email,

      ) async {

    final isValid = Authentication().checkBeforeSendingResetPassword(email);
    if (!isValid) {
      final mess = Authentication().validateInputResetPassword(email);
      ShowNotification.showAnimatedSnackBar(
          context, mess, 0, const Duration(milliseconds: 300));
    } else {
      widget.onScaleForLoading(true);
      await Future.delayed(const Duration(milliseconds: 2000));
      final err = await Authentication().resetPassword(email);
      if (err != null) {
        List<String> message = ['Warning!', '$err'];
        setState(() {
          widget.onStatus(0);
          widget.onMessage(message);
        });
        return err;
      } else {
        setState(() {
          List<String> message = ['Congratulations!', 'If the email exists, we have sent a password reset link.'];
          widget.onStatus(2);
          widget.onMessage(message);
        });
        return null;
      }
    }
  }

  void _safeSetState(VoidCallback fn) {
    if (!mounted) return;
    setState(fn);
  }

  @override
  void initState() {
    super.initState();
    _lifecycleToken++;
    startAnimations(_lifecycleToken);
  }

  @override
  void dispose() {
    _lifecycleToken++; // vô hiệu hóa mọi callback trễ còn lại
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final specs = GeneralSpecifications(context);
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 10),
      opacity: widget.hideRecoveryPassword ? 0 : 1,
      child: SizedBox(
        height: specs.screenHeight * 0.7,
        width: specs.screenWidth,
        child: ListView(
          padding: const EdgeInsets.all(0),
          children: [

            /// Email
            MoveAndFadeContainer(
              fatherHeight: 80,
              fatherWidth: specs.screenWidth,
              heightOfChild: 70,
              widthOfChild: specs.screenWidth - padding,
              animation: animationEmail,
              curve: _curves,
              customizeTravelDistance: true,
              duration: _duration,
              type: 2,
              start: 40,
              end: 5,
              child: CustomTextField(
                title: 'Email address',
                iconAsset: "assets/icons/authentication/envelope.png",
                isHidden: false,
                controller: emailController,
              ),
            ),
            const SizedBox(height: 15),
            AnimatedScale(
              duration: const Duration(milliseconds: 150),
              scale: _isTapDown ? 0.9 : 1,
              child: MoveAndFadeContainer(
                fatherHeight: 70,
                fatherWidth: specs.screenWidth,
                heightOfChild: 50,
                widthOfChild: specs.screenWidth - padding,
                animation: animationConfirmButton,
                curve: _curves,
                customizeTravelDistance: true,
                duration: _duration,
                type: 2,
                start: 40,
                end: 5,
                child: Align(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapDown: (details) async {
                      if (!mounted) return;
                      _safeSetState(() => _isTapDown = true);
                      await Future.delayed(const Duration(milliseconds: 150));
                      if (!mounted) return;
                      _safeSetState(() => _isTapDown = false);
                      await Future.delayed(const Duration(milliseconds: 150));
                      recoveryPassword(context,emailController.text);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      height: 50,
                      width: specs.screenWidth - padding,
                      decoration: BoxDecoration(
                        color: specs.pantoneColor3,
                        borderRadius: BorderRadius.circular(50),
                        boxShadow: [
                          BoxShadow(
                            color: specs.pantoneShadow2,
                            spreadRadius: 5,
                            blurRadius: 10,
                            offset: _isTapDown
                                ? const Offset(0, 0)
                                : const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          "Confirm",
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            MoveAndFadeContainer(
              fatherHeight: 300,
              fatherWidth: specs.screenWidth,
              heightOfChild: 70,
              widthOfChild: specs.screenWidth - padding,
              animation: animationInstruct,
              curve: _curves,
              customizeTravelDistance: true,
              duration: _duration,
              type: 2,
              start: 40,
              end: 5,
              child: Align(
                alignment: Alignment.center,
                child: SizedBox(
                  width: specs.screenWidth - 40,
                  child: Text(
                    "1.Enter the email address you used to register.\n"
                    "2.Click Confirm.\n"
                    "3.Open your inbox (Inbox/Spam/Ads) and find an email titled “Reset Password”.\n"
                    "4.Click the link in the email, enter your new password and confirm.\n",
                    textAlign: TextAlign.left,
                    style: GoogleFonts.outfit(
                      color: specs.black150,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
