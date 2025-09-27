import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:joy_way/config/general_specifications.dart';
import 'package:joy_way/widgets/notifications/show_notification.dart';

class SocialLinks extends StatefulWidget {
  final List<TextEditingController> controllers;

  const SocialLinks({
    super.key,
    required this.controllers,
  });

  @override
  State<SocialLinks> createState() => _SocialLinksState();
}

class _SocialLinksState extends State<SocialLinks> {
  @override
  void initState() {
    super.initState();
    if (widget.controllers.isEmpty) {
      widget.controllers.add(TextEditingController());
    }
  }

  void _addNewLink() {
    if (widget.controllers.length >= 3) {
      ShowNotification.showAnimatedSnackBar(context, "You can add up to 3 links only.", 2, Duration(milliseconds: 200));
      return;
    };
    setState(() {
      widget.controllers.add(TextEditingController());
    });
  }

  void _removeAt(int i) {
    setState(() {
      widget.controllers.removeAt(i);
      if (widget.controllers.isEmpty) {
        widget.controllers.add(TextEditingController());
      }
    });
  }

  void _onChanged() {

  }

  @override
  Widget build(BuildContext context) {
    final specs = GeneralSpecifications(context);

    return Container(
      width: specs.screenWidth,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      child: Column(
        children: [
          // danh sách input
          for (int i = 0; i < widget.controllers.length; i++)
            Container(
              height: 50,
              margin: const EdgeInsets.only(bottom: 10),
              child: TextField(
                controller: widget.controllers[i],
                onChanged: (_) => _onChanged(),
                keyboardType: TextInputType.url,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  hintText: "Enter social link",
                  hintStyle: GoogleFonts.outfit(fontSize: 14, color: specs.black80),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  suffixIcon: IconButton(
                    icon: const ImageIcon(
                      AssetImage('assets/icons/setting/minus.png'),
                      size: 15,
                    ),
                    onPressed: () => _removeAt(i),
                    tooltip: 'Remove',
                  ),
                ),
              ),
            ),

          // nút add
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _addNewLink,
            child: SizedBox(
              width: specs.screenWidth - 40,
              height: 30,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      "Add new link",
                      textAlign: TextAlign.left,
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: specs.black200,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                    width: 20,
                    child: ImageIcon(
                      AssetImage('assets/icons/setting/add.png'),
                      size: 20,
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
