import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class LoadingRiveIcon extends StatefulWidget {
  final double fatherWidth;
  final double fatherHeight;
  final Color fatherColor;
  final bool activeFail;
  final bool activeSuccessful;
  final bool activeLoading;

  const LoadingRiveIcon({
    super.key,
    required this.fatherHeight,
    required this.fatherWidth,
    this.fatherColor = Colors.transparent,
    this.activeFail = false,
    this.activeSuccessful = false,
    this.activeLoading = false,
  });

  @override
  _LoadingRiveIconState createState() => _LoadingRiveIconState();
}

class _LoadingRiveIconState extends State<LoadingRiveIcon> {
  late StateMachineController _riveController;
  SMIBool? _inputFail;
  SMIBool? _inputSuc;

  @override
  void initState() {
    super.initState();
  }

  void _onRiveInit(Artboard artboard) {
    _riveController =
    StateMachineController.fromArtboard(artboard, 'state machine')!;
    artboard.addController(_riveController);
    _inputFail = _riveController.findInput<bool>('payment failed') as SMIBool?;
    _inputSuc =
    _riveController.findInput<bool>('payment successful') as SMIBool?;
    _updateRiveInputs();
  }

  @override
  void didUpdateWidget(covariant LoadingRiveIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.activeFail != widget.activeFail ||
        oldWidget.activeSuccessful != widget.activeSuccessful ||
        oldWidget.activeLoading != widget.activeLoading) {
      _updateRiveInputs();
    }
  }

  void _updateRiveInputs() {
    if (widget.activeLoading) {
      _inputFail?.value = false;
      _inputSuc?.value = false;
    }
    else {
      _inputFail?.value = widget.activeFail;
      _inputSuc?.value = widget.activeSuccessful;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: widget.fatherHeight,
        width: widget.fatherWidth,
        color: widget.fatherColor,
        child: ClipOval(
          child: Transform.scale(
            scale: 2.4,
            child: RiveAnimation.asset(
              'assets/icons/success_and_failure.riv',
              fit: BoxFit.cover,
              onInit: _onRiveInit,
              alignment: Alignment.center,
            ),
          ),
        )
    );
  }

  @override
  void dispose() {
    _riveController.dispose();
    super.dispose();
  }
}