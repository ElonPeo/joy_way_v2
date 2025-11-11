import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:joy_way/config/general_specifications.dart';
import 'package:joy_way/models/passenger/passengers.dart';
import 'package:joy_way/models/user/basic_user_info.dart';
import 'package:joy_way/screens/journey_screen/components/companion/companion_detail.dart';
import 'package:joy_way/services/data_processing/time_processing.dart';
import 'package:joy_way/services/firebase_services/profile_services/profile_firestore.dart';
import 'package:joy_way/widgets/photo_view/avatar_view.dart';

class CompanionCard extends StatefulWidget {
  final Passenger passenger;
  const CompanionCard({
    super.key,
    required this.passenger,
  });

  @override
  State<CompanionCard> createState() => _CompanionCardState();
}

class _CompanionCardState extends State<CompanionCard> {
  BasicUserInfo? _basicUserInfo;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    try {
      final r =
      await ProfileFirestore().getBasicUserInfo(widget.passenger.userId);
      if (!mounted) return;
      setState(() {
        _basicUserInfo = r.user;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final specs = GeneralSpecifications(context);
    return GestureDetector(
      onTap: () {
        final info = _basicUserInfo;
        if (info != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CompanionDetail(
                requestId: widget.passenger.requestId,
                basicUserInfo: info,
                passenger: widget.passenger,
              ),
            ),
          );
        }
      },
      child: Container(
        margin: EdgeInsets.all(15),
        width: specs.screenWidth - 30,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(width: 1, color: specs.black240),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ---- Avatar + Tên ----
                Row(
                  children: [
                    _loading
                        ? const CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.black12,
                    )
                        : AvatarView(
                      imageId: _basicUserInfo?.avatarImageId,
                      nameUser: _basicUserInfo?.userName,
                      size: 50,
                    ),
                    const SizedBox(width: 10),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _loading
                              ? "Loading..."
                              : "@${_basicUserInfo?.userName ?? 'unknown'}",
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          _basicUserInfo?.phoneNumber ?? "",
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // ---- Trạng thái ----
                Container(
                  height: 30,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: const Color.fromRGBO(233, 182, 59, 1),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Center(
                    child: Text(
                      widget.passenger.status.name,
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 5,
            ),
            Text("Last update: ${TimeProcessing.formatTimestamp(widget.passenger.lastUpdatedAt)}",
            style: GoogleFonts.outfit(
              color: specs.black150,
              fontWeight: FontWeight.w400,
              fontSize: 12,
            ),
            )
          ],
        ),
      ),
    );
  }
}
