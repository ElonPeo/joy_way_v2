import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../config/general_specifications.dart';

class StepBar extends StatefulWidget {
  final int page;
  final int totalSteps;

  const StepBar({
    super.key,
    required this.page,
    this.totalSteps = 4,
  });

  @override
  State<StepBar> createState() => _StepBarState();
}

class _StepBarState extends State<StepBar> {
  final _containerKey = GlobalKey();
  late final List<GlobalKey> _dotKeys;
  List<double> _centers = [];
  static const double _barHeight = 30;
  static const double _dotSize = 25;

  int _page = 0;

  @override
  void initState() {
    super.initState();
    setState(() {
      _page = widget.page;
    });
    _dotKeys = List.generate(widget.totalSteps, (_) => GlobalKey());
    WidgetsBinding.instance.addPostFrameCallback((_) => _measureCenters());
  }


  @override
  void didUpdateWidget(covariant StepBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if(oldWidget.page != widget.page) {
      setState(() {
        _page = widget.page;
      });
    }

    if (oldWidget.totalSteps != widget.totalSteps) {
      _dotKeys
        ..clear()
        ..addAll(List.generate(widget.totalSteps, (_) => GlobalKey()));
      WidgetsBinding.instance.addPostFrameCallback((_) => _measureCenters());
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) => _measureCenters());
    }
  }

  void _measureCenters() {
    final containerBox = _containerKey.currentContext?.findRenderObject() as RenderBox?;
    if (containerBox == null) return;

    final newCenters = <double>[];
    for (final key in _dotKeys) {
      final rb = key.currentContext?.findRenderObject() as RenderBox?;
      if (rb == null) continue;
      final topLeftGlobal = rb.localToGlobal(Offset.zero);
      final size = rb.size;
      final topLeftLocal = containerBox.globalToLocal(topLeftGlobal);
      final centerX = topLeftLocal.dx + size.width / 2;
      newCenters.add(centerX);
    }

    if (newCenters.length == widget.totalSteps) {
      setState(() {
        _centers = newCenters;
      });
    }
  }

  // Lấy chiều rộng progress theo tâm step hiện tại
  double _progressWidth(double totalWidth) {
    if (_centers.length == widget.totalSteps) {
      final idx = _page.clamp(0, widget.totalSteps - 1);
      return _centers[idx].clamp(0, totalWidth);
    }
    if (widget.totalSteps <= 1) return 0;
    final t = _page / (widget.totalSteps - 1);
    return (t * totalWidth).clamp(0, totalWidth);
  }

  @override
  Widget build(BuildContext context) {
    final specs = GeneralSpecifications(context);
    final double totalWidth = specs.screenWidth - 40;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        child: Container(
          key: _containerKey,
          height: _barHeight,
          width: totalWidth,
          color: specs.black240,
          child: Stack(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                height: _barHeight,
                width: _progressWidth(totalWidth) + 15,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: specs.pantoneColor4
                ),
              ),
              Center(
                child: SizedBox(
                  height: _dotSize,
                  width: totalWidth - 5,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(widget.totalSteps, (index) {
                      final bool isActive = _page >= index;
                      return Container(
                        key: _dotKeys[index],
                        height: _dotSize,
                        width: _dotSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isActive ? Colors.white : specs.black200,
                          border: isActive ? null : Border.all(width: 1.2, color: Colors.white),
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: GoogleFonts.roboto(
                              color: isActive ? Colors.black : Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
