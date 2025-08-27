import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:joy_way/widgets/animated_container/move_and_fade_container.dart';
import 'package:joy_way/widgets/animated_container/scale_container.dart';
import 'package:joy_way/widgets/custom_text_field/custom_text_field.dart';

import '../../../../config/general_specifications.dart';
import '../../../../services/firebase_services/authentication.dart';
import '../../../../widgets/animated_container/animated_blur_overlay.dart';
import '../../../../widgets/notifications/show_notification.dart';

class LoginScreen extends StatefulWidget {
  final int type;
  final Function(int) onChanged;
  final Function(bool) onScaleForLoading;
  final Function(int) onStatus;
  final Function(List<String>) onMessage;

  const LoginScreen({
    super.key,
    required this.type,
    required this.onChanged,
    required this.onStatus,
    required this.onMessage,
    required this.onScaleForLoading,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const double padding = 40.0;
  Curve _curves = Curves.easeOutBack;
  Duration _duration = const Duration(milliseconds: 800);

  /// value
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  /// animation flags
  bool _animationEmail = false;
  bool _animationPassword = false;
  bool _animationRecoveryPassword = false;
  bool _animationConfirmButton = false;
  bool _animationOrContinueWith = false;
  bool _animationAccountLink1 = false;
  bool _animationAccountLink2 = false;
  bool _animationAccountLink3 = false;

  /// button
  bool _isTapDown = false;

  /// Token để vô hiệu hóa các callback trễ khi dispose / rebuild
  int _lifecycleToken = 0;

  /// setState an toàn
  void _safeSetState(VoidCallback fn) {
    if (!mounted) return;
    setState(fn);
  }

  Future<void> startAnimations(int token) async {
    Future<void> step(Duration d, VoidCallback apply) async {
      await Future.delayed(d);
      if (!mounted || token != _lifecycleToken) return;
      _safeSetState(apply);
    }
    await const Duration(milliseconds: 200);
    await step(const Duration(milliseconds: 50),  () => _animationEmail = true);
    await step(const Duration(milliseconds: 100), () => _animationPassword = true);
    await step(const Duration(milliseconds: 150), () => _animationRecoveryPassword = true);
    await step(const Duration(milliseconds: 200), () => _animationConfirmButton = true);
    await step(const Duration(milliseconds: 250), () => _animationOrContinueWith = true);
    await step(const Duration(milliseconds: 300), () => _animationAccountLink1 = true);
    await step(const Duration(milliseconds: 450), () => _animationAccountLink2 = true);
    await step(const Duration(milliseconds: 500), () => _animationAccountLink3 = true);
  }

  Future<String?> loginWithValidation(
      BuildContext context,
      String email,
      String password,
      ) async {
    final isValid = Authentication().checkBeforeSendingSignIn(email, password);
    if (!isValid) {
      final mess = Authentication().validateInputSignIn(email, password);
      ShowNotification.showAnimatedSnackBar(context, mess, 0, Duration(milliseconds: 500));
    } else {
      widget.onScaleForLoading(true);
      await Future.delayed(const Duration(milliseconds: 3000));
      final err = await Authentication().signIn(email, password);
      if (err != null) {
        List<String> message = ['Warning!','$err'];
        setState(() {
          widget.onStatus(1);
          widget.onMessage(message);
        });
        return err;
      } else{
        return null;
      }
    }
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
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final specs = GeneralSpecifications(context);
    return Container(
      height: specs.screenHeight * 0.7 - 70,
      width: specs.screenWidth,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const SizedBox(height: 20),
          /// Email
          MoveAndFadeContainer(
            fatherHeight: 80,
            fatherWidth: specs.screenWidth,
            heightOfChild: 70,
            widthOfChild: specs.screenWidth - padding,
            animation: _animationEmail,
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

          /// Password
          MoveAndFadeContainer(
            fatherHeight: 80,
            fatherWidth: specs.screenWidth,
            heightOfChild: 70,
            widthOfChild: specs.screenWidth - padding,
            animation: _animationPassword,
            curve: _curves,
            customizeTravelDistance: true,
            duration: _duration,
            type: 2,
            start: 40,
            end: 5,
            child: CustomTextField(
              title: 'Password',
              iconAsset: "assets/icons/authentication/password.png",
              isHidden: true,
              controller: passwordController,
            ),
          ),

          /// Recovery
          GestureDetector(
            onTap: () => widget.onChanged(2),
            child: MoveAndFadeContainer(
              fatherHeight: 40,
              fatherWidth: specs.screenWidth,
              heightOfChild: 20,
              widthOfChild: specs.screenWidth - padding,
              animation: _animationRecoveryPassword,
              curve: _curves,
              customizeTravelDistance: true,
              duration: _duration,
              type: 2,
              start: 30,
              end: 5,
              child: SizedBox(
                height: 20,
                width: specs.screenWidth - padding,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      "Recovery Password",
                      style: GoogleFonts.outfit(
                        color: specs.pantoneColor3,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          /// Confirm
          AnimatedScale(
            duration: const Duration(milliseconds: 150),
            scale: _isTapDown ? 0.9 : 1,
            child: MoveAndFadeContainer(
              fatherHeight: 70,
              fatherWidth: specs.screenWidth,
              heightOfChild: 50,
              widthOfChild: specs.screenWidth - padding,
              animation: _animationConfirmButton,
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
                    loginWithValidation(context,emailController.text, passwordController.text);
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
                          offset: _isTapDown ? const Offset(0, 0) : const Offset(0, 10),
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

          /// Or continue with
          SizedBox(
            width: specs.screenWidth - padding,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                MoveAndFadeContainer(
                  type: 3,
                  fatherHeight: 30,
                  fatherWidth: specs.screenWidth * 0.4,
                  heightOfChild: 1.5,
                  widthOfChild: specs.screenWidth * 0.35,
                  duration: const Duration(milliseconds: 1500),
                  curve: Curves.easeOutExpo,
                  animation: _animationOrContinueWith,
                  child: Container(
                    height: 1,
                    width: specs.screenWidth * 0.35,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: LinearGradient(
                        colors: [Colors.white, specs.black150],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                  ),
                ),
                AnimatedBlurOverlay(
                  fatherWidth: 30,
                  fatherHeight: 30,
                  animation: _animationOrContinueWith,
                  maxSigma: 20,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOutCubic,
                  child: Center(
                    child: Text(
                      "Or",
                      style: GoogleFonts.outfit(fontSize: 12, color: specs.black150),
                    ),
                  ),
                ),
                MoveAndFadeContainer(
                  type: 1,
                  fatherHeight: 30,
                  fatherWidth: specs.screenWidth * 0.4,
                  heightOfChild: 1.5,
                  widthOfChild: specs.screenWidth * 0.35,
                  animation: _animationOrContinueWith,
                  duration: const Duration(milliseconds: 1500),
                  curve: Curves.easeOutExpo,
                  child: Container(
                    height: 1,
                    width: specs.screenWidth * 0.35,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: LinearGradient(
                        colors: [specs.black150, Colors.white],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          /// Socials
          Align(
            alignment: Alignment.center,
            child: SizedBox(
              width: specs.screenWidth - padding,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ScaleContainer(
                    fatherHeight: 80,
                    fatherWidth: 100,
                    animation: _animationAccountLink1,
                    duration: const Duration(milliseconds: 1000),
                    curve: _curves,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {},
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          border: Border.all(color: specs.black240, width: 1.5, style: BorderStyle.solid),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: SizedBox(
                          width: 30,
                          height: 30,
                          child: Image.asset('assets/icons/account_link/google.png', fit: BoxFit.fill),
                        ),
                      ),
                    ),
                  ),
                  ScaleContainer(
                    fatherHeight: 80,
                    fatherWidth: 100,
                    animation: _animationAccountLink2,
                    duration: const Duration(milliseconds: 1000),
                    curve: _curves,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {},
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          border: Border.all(color: specs.black240, width: 1.5, style: BorderStyle.solid),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: SizedBox(
                          width: 30,
                          height: 30,
                          child: Image.asset('assets/icons/account_link/facebook.png', fit: BoxFit.fill),
                        ),
                      ),
                    ),
                  ),
                  ScaleContainer(
                    fatherHeight: 80,
                    fatherWidth: 100,
                    animation: _animationAccountLink3,
                    duration: const Duration(milliseconds: 1000),
                    curve: _curves,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {},
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          border: Border.all(color: specs.black240, width: 1.5, style: BorderStyle.solid),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: SizedBox(
                          width: 30,
                          height: 30,
                          child: Image.asset('assets/icons/account_link/apple.png', fit: BoxFit.fill),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
