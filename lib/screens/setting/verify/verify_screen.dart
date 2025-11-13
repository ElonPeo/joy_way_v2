import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:joy_way/config/general_specifications.dart';
import 'package:joy_way/screens/setting/verify/verify.dart';

import '../../../models/verify/user_verification.dart';
import '../../../services/firebase_services/user_verification_firestore.dart';
import '../../../widgets/animated_container/custom_animated_button.dart';

import 'components/verification_status_card.dart';

class VerifyScreen extends StatefulWidget {
  const VerifyScreen({super.key});
  @override
  State<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {
  final _verFs = UserVerificationFirestore();

  @override
  Widget build(BuildContext context) {
    final specs = GeneralSpecifications(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: specs.backgroundColor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Header
          Container(
            width: specs.screenWidth,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(width: 1, color: specs.black240)),
            ),
            child: Column(
              children: [
                SizedBox(
                  height: 80,
                  width: specs.screenWidth,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SizedBox(
                        width: 50,
                        child: CustomAnimatedButton(
                          onTap: () async {
                            FocusScope.of(context).unfocus();
                            await Future.delayed(const Duration(milliseconds: 300));
                            Navigator.pop(context);
                          },
                          height: 30,
                          width: 20,
                          color: Colors.transparent,
                          shadowColor: Colors.transparent,
                          child: SizedBox(
                            height: 23,
                            width: 23,
                            child: Image.asset(
                              'assets/icons/other_icons/angle-left.png',
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 30,
                        width: specs.screenWidth - 140,
                        child: Center(
                          child: Text(
                            'Verify identity',
                            style: GoogleFonts.outfit(
                              color: Colors.black,
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 50),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),

          Expanded(
            child: StreamBuilder<UserVerification?>(
              stream: _verFs.watchUserVerification(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final ver = snapshot.data;

                final faceStatus = ver?.faceStatus ?? 'pending';
                final similarity = ver?.faceSimilarity ?? 0.0;
                final threshold = ver?.faceSimilarityThreshold ?? 0.0;
                final isVerified = ver?.isVerified ?? false;

                return ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  children: [
                    Text(
                      'Verification status',
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),

                    VerificationStatusCard(
                      faceStatus: faceStatus,
                      similarity: similarity,
                      threshold: threshold,
                      isVerified: isVerified,
                    ),

                    const SizedBox(height: 24),

                    if (ver == null)
                      Text(
                        'Chưa gửi thông tin xác thực.',
                        style: GoogleFonts.outfit(fontSize: 15),
                      )
                    else
                      Text(
                        'Last updated: ${ver.updatedAt ?? ver.createdAt}',
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    SizedBox(
                      height: 20,
                    ),
                    CustomAnimatedButton(
                      height: 45,
                      width: specs.screenWidth - 40,
                      child: Text(
                        "Submit a re-verification",
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 14
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Verify()),
                        );
                      },
                    )
                  ],
                );


              },
            ),
          ),
        ],
      ),
    );
  }
}
