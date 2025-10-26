import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../config/general_specifications.dart';
import '../../../../../models/user/star_rating.dart';

class StarRatingCard extends StatefulWidget {
  final StarRating starRating;

  const StarRatingCard({
    super.key,
    required this.starRating,
  });

  @override
  State<StarRatingCard> createState() => _StarRatingCardState();
}

class _StarRatingCardState extends State<StarRatingCard> {
  late double averageStar;

  @override
  void initState() {
    super.initState();
    averageStar = widget.starRating.average;
  }

  @override
  Widget build(BuildContext context) {
    final specs = GeneralSpecifications(context);
    final color = Color.lerp(
      const Color.fromRGBO(220, 20, 60, 1),
      const Color.fromRGBO(255, 217, 61 ,1),
      (averageStar.clamp(0, 5)) / 5,
    );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: color,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(width: 2),
          Text(
            averageStar.toStringAsFixed(1),
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 3),
          const Icon(
            Icons.star_rounded,
            color: Colors.white,
            size: 14,
          ),
        ],
      ),
    );
  }
}
