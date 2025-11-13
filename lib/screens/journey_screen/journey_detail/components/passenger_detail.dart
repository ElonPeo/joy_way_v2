import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:joy_way/config/general_specifications.dart';
import 'package:joy_way/models/user/basic_user_info.dart';
import 'package:joy_way/screens/post/post_detail/components/schedule/drop_off_schedule.dart';
import 'package:joy_way/screens/post/post_detail/components/schedule/pick_up_schedule.dart';
import 'package:joy_way/widgets/photo_view/avatar_view.dart';
import '../../../../../models/passenger/passengers.dart';
import '../../../../../services/firebase_services/passenger_services/passenger_firestore.dart';
import '../../../../../widgets/animated_container/custom_animated_button.dart';
import '../../../message_screen/message_room_screen.dart';
import '../../../profile_screen/profile_screen.dart';

class PassengerDetail extends StatefulWidget {
  final BasicUserInfo basicUserInfo;
  final Passenger passenger;
  final String requestId;

  const PassengerDetail({
    super.key,
    required this.basicUserInfo,
    required this.requestId,
    required this.passenger,
  });

  @override
  State<PassengerDetail> createState() => _PassengerDetailState();
}

class _PassengerDetailState extends State<PassengerDetail> {
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

                        },
                        height: 30,
                        width: 80,
                        shadowColor: Colors.transparent,
                        color: specs.rSlight,
                        child: Text(
                            "Remove",
                            style: GoogleFonts.outfit(color: Colors.white)),
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
              padding: EdgeInsets.all(10),
              children: [
                Text(
                  "User Info",
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
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
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(

                          children: [
                            Row(
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
                                          '@${widget.basicUserInfo.userName}',
                                          style: GoogleFonts.outfit(fontWeight: FontWeight.w500, fontSize: 16),
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
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                              height: 1,
                              decoration: BoxDecoration(
                                color: specs.black240
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  "Note",
                                style: GoogleFonts.outfit(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16
                                ),
                                ),
                              ],
                            ),

                            Text(
                              "Hello I want to join this journey with you.",
                              style: GoogleFonts.outfit(
                                color: Colors.black,
                                fontWeight: FontWeight.w400,

                              ),
                            ),

                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 15),


                Text(
                  "Request detail",
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: specs.screenWidth - 30,
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        children: [
                          PickupSchedule(passenger: widget.passenger, index: 0),
                          DropOffSchedule(passenger: widget.passenger, index: 0)
                        ],
                      ),
                    )
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
                        borderRadius: BorderRadius.circular(10),
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

              ],
            ),
          ),
        ],
      ),
    );
  }
}
