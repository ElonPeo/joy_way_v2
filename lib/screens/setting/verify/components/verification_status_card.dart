import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VerificationStatusCard extends StatelessWidget {
  final String faceStatus;
  final double similarity;
  final double threshold;
  final bool isVerified;

  const VerificationStatusCard({
    super.key,
    required this.faceStatus,
    required this.similarity,
    required this.threshold,
    required this.isVerified,
  });

  Color _statusColor() {
    switch (faceStatus) {
      case 'verified':
        return Colors.green;
      case 'failed':
        return Colors.red;
      case 'submitted':
        return Colors.orange;
      case 'pending':
        return Colors.grey;
      case 'error':
        return Colors.black;
      default:
        return Colors.grey.shade600;
    }
  }

  String _statusText() {
    switch (faceStatus) {
      case 'verified':
        return 'Verified';
      case 'failed':
        return 'Failed';
      case 'submitted':
        return 'Submitted';
      case 'pending':
        return 'Pending';
      case 'error':
        return 'Error';
      default:
        return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor();
    final sim = (similarity * 100).clamp(0, 100);
    final thr = (threshold * 100).clamp(0, 100);

    double confidence = 0;
    if (threshold > 0) {
      confidence = (similarity / threshold).clamp(0, 2.0);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color, width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// status
          Row(
            children: [
              Icon(
                isVerified ? Icons.verified : Icons.verified_user_outlined,
                color: color,
                size: 26,
              ),
              const SizedBox(width: 8),
              Text(
                _statusText(),
                style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          Text(
            'Similarity: ${sim.toStringAsFixed(2)}%',
            style: GoogleFonts.outfit(fontSize: 16),
          ),
          Text(
            'Threshold: ${thr.toStringAsFixed(2)}%',
            style: GoogleFonts.outfit(fontSize: 16),
          ),
          const SizedBox(height: 10),

          Text(
            'Confidence level',
            style: GoogleFonts.outfit(fontSize: 16),
          ),
          const SizedBox(height: 6),

          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: confidence.clamp(0.0, 1.0),
              minHeight: 10,
              color: color,
              backgroundColor: Colors.grey.shade300,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${(confidence * 100).clamp(0, 100).toStringAsFixed(1)}%',
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
