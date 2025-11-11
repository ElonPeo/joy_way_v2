import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:joy_way/config/general_specifications.dart';
import 'package:joy_way/models/request/request_journey/request_journey.dart';
import 'package:joy_way/models/user/basic_user_info.dart';
import 'package:joy_way/services/firebase_services/request_services/request_firestore.dart';
import 'package:joy_way/widgets/photo_view/avatar_view.dart';
import '../../../../models/passenger/passengers.dart';
import '../../../../services/firebase_services/passenger_services/passenger_firestore.dart';
import '../../../../widgets/animated_container/custom_animated_button.dart';
import '../../../message_screen/message_room_screen.dart';
import '../../../profile_screen/profile_screen.dart';

class CompanionDetail extends StatefulWidget {
  final BasicUserInfo basicUserInfo;
  final Passenger passenger;
  final String requestId; // ✅ bắt buộc

  const CompanionDetail({
    super.key,
    required this.basicUserInfo,
    required this.requestId,
    required this.passenger,
  });

  @override
  State<CompanionDetail> createState() => _CompanionDetailState();
}

class _CompanionDetailState extends State<CompanionDetail> {
  @override
  Widget build(BuildContext context) {
    final specs = GeneralSpecifications(context);

    return Scaffold(
      backgroundColor: specs.backgroundColor,
      body: Column(
        children: [
          // Header
          Container(
            width: specs.screenWidth,
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(width: 1, color: specs.black240)),
            ),
            child: SizedBox(
              height: 80,
              width: specs.screenWidth,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SizedBox(
                    width: 50,
                    child: CustomAnimatedButton(
                      onTap: () => Navigator.maybePop(context),
                      height: 30,
                      width: 20,
                      color: Colors.transparent,
                      shadowColor: Colors.transparent,
                      child: const SizedBox(
                        height: 23, width: 23,
                        child: Image(image: AssetImage("assets/icons/other_icons/angle-left.png")),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      CustomAnimatedButton(
                        onTap: () {
                          // TODO: Remove passenger
                        },
                        height: 30,
                        width: 80,
                        shadowColor: Colors.transparent,
                        color: specs.rSlight,
                        child: Text("Remove", style: GoogleFonts.outfit(color: Colors.white)),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),

          // Body
          Expanded(
            child: ListView(
              children: [
                // Card user
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          CupertinoPageRoute(
                            builder: (_) => ProfileScreen(
                              isOwnerProfile: false,
                              userId: widget.basicUserInfo.uid,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        width: specs.screenWidth - 30,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                AvatarView(imageId: widget.basicUserInfo.avatarImageId, size: 54),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.basicUserInfo.userName ?? 'unknown',
                                      style: GoogleFonts.outfit(fontWeight: FontWeight.w500, fontSize: 12),
                                    ),
                                    Text(
                                      widget.basicUserInfo.phoneNumber ?? "Not set yet",
                                      style: GoogleFonts.outfit(fontWeight: FontWeight.w400, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => MessageRoomScreen(
                                      userName: widget.basicUserInfo.userName ?? 'unknown',
                                      userId: widget.basicUserInfo.uid,
                                      imageId: widget.basicUserInfo.avatarImageId,
                                    ),
                                  ),
                                );
                              },
                              child: SizedBox(
                                width: 30,
                                child: ImageIcon(
                                  const AssetImage("assets/icons/messenger/message.png"),
                                  size: 24, color: specs.black100,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 15),

                // Card journey detail (Stream trực tiếp theo requestId)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: specs.screenWidth - 30,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: StreamBuilder<RequestJourney?>(
                        stream: RequestFirestore().streamJourneyDetail(widget.requestId),
                        builder: (context, snap) {
                          if (snap.connectionState == ConnectionState.waiting) {
                            return Text("Loading journey...", style: GoogleFonts.outfit(fontSize: 12));
                          }
                          final j = snap.data;
                          if (j == null) {
                            return Text("No journey found.",
                                style: GoogleFonts.outfit(fontSize: 12, color: specs.black150));
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Location and time",
                                  style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w500)),
                              Container(
                                margin: const EdgeInsets.symmetric(vertical: 10),
                                height: 1, color: specs.black240,
                              ),
                              Text("Pick up: ${j.pickUpName ?? '-'}", style: GoogleFonts.outfit(fontSize: 13)),
                              const SizedBox(height: 6),
                              Text("Drop off: ${j.dropOffName ?? '-'}", style: GoogleFonts.outfit(fontSize: 13)),
                              const SizedBox(height: 6),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),

                SizedBox(
                  height: 15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomAnimatedButton(
                        onTap: () async {
                          try {
                            await PassengerFirestore().updatePassengerStatus(
                              passengerId: widget.passenger.id,
                              newStatus: PassengerStatus.preparingPickup,
                            );

                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Cập nhật trạng thái thành công'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              Navigator.pop(context); // quay lại trang trước
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Lỗi cập nhật: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                        height: 45,
                        borderRadius: BorderRadius.circular(24),
                        width: specs.screenWidth - 30,
                        child: Text(
                          "Prepare to pick up",
                          style: GoogleFonts.outfit(
                            color: Colors.white
                          ),
                        )
                    ),
                  ],
                ),


                SizedBox(
                  height: 15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomAnimatedButton(
                        onTap: () async {
                          try {
                            await PassengerFirestore().updatePassengerStatus(
                              passengerId: widget.passenger.id,
                              newStatus: PassengerStatus.pickedUp,
                            );
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Cập nhật trạng thái thành công'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              Navigator.pop(context); // quay lại trang trước
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Lỗi cập nhật: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                        height: 45,
                        borderRadius: BorderRadius.circular(24),
                        width: specs.screenWidth - 30,
                        child: Text(
                          "Picked Up",
                          style: GoogleFonts.outfit(
                              color: Colors.white
                          ),
                        ),

                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
