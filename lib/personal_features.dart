import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// --- 1. Cyber-Therapy Vault (Mind & Memory Blackbox) ---
class MindBlackboxWidget extends StatelessWidget {
  const MindBlackboxWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Accessing Encrypted Voice Diary...')),
        );
      },
      child: _buildPersonalCard(
        title: 'MIND & MEMORY BLACKBOX',
        subtitle: 'AI analyzes daily voice entries for emotional trajectory. Rescue Protocol is standby.',
        icon: Icons.psychology,
        color: const Color(0xFFD500F9), // Purple neon
        actionText: 'RECORD THOUGHT',
      ),
    );
  }
}

// --- 2. AR Chemical Decoder (Nutri-Scan) ---
class ARChemicalDecoderWidget extends StatelessWidget {
  const ARChemicalDecoderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Starting AR Lens... Point at Ingredient List.')),
        );
      },
      child: _buildPersonalCard(
        title: 'AR CHEMICAL DECODER',
        subtitle: 'Point camera at product labels. Gemini Vision identifies toxins based on your vault.',
        icon: Icons.document_scanner,
        color: const Color(0xFF00FFCC), // Mint/Cyan
        actionText: 'OPEN AR LENS',
      ),
    );
  }
}

// --- 3. Sleep-Apnea Acoustic Guardian ---
class SleepGuardianWidget extends StatefulWidget {
  const SleepGuardianWidget({super.key});

  @override
  State<SleepGuardianWidget> createState() => _SleepGuardianWidgetState();
}

class _SleepGuardianWidgetState extends State<SleepGuardianWidget> {
  bool isNightMode = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => isNightMode = !isNightMode),
      child: _buildPersonalCard(
        title: 'SLEEP-APNEA GUARDIAN',
        subtitle: isNightMode 
            ? 'Night mode active. Monitoring for breathing cessation and acute snoring patterns.'
            : 'Sleep guard inactive. Enable before sleeping.',
        icon: Icons.bedtime,
        color: isNightMode ? const Color(0xFFFF9100) : Colors.white30,
        actionText: isNightMode ? 'ACTIVE' : 'INACTIVE',
      ),
    );
  }
}

// --- 4. Circadian Energy Predictor ---
class CircadianPredictorWidget extends StatelessWidget {
  const CircadianPredictorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return _buildPersonalCard(
      title: 'QUANTUM ROUTINE PREDICTOR',
      subtitle: 'Predicted Energy Crash: 14:30 PM today (caused by barometric drop). Recommended action: Hydrate now.',
      icon: Icons.auto_graph,
      color: const Color(0xFF00E5FF),
      actionText: 'VIEW PREDICTIONS',
    );
  }
}

// --- 5. Digital Legacy Handshake ---
class DigitalLegacyWidget extends StatelessWidget {
  const DigitalLegacyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Verifying Multi-Sig Biometrics for Legacy Access...')),
        );
      },
      child: _buildPersonalCard(
        title: 'DIGITAL LEGACY HANDSHAKE',
        subtitle: 'Dead-man\'s switch for secure assets & final voice notes. Released only upon verified Triage fatality.',
        icon: Icons.fingerprint,
        color: const Color(0xFFFF2A5F), // Red
        actionText: 'MANAGE ASSETS',
      ),
    );
  }
}

// Reusable Advanced UI Card for Personal Features
Widget _buildPersonalCard({
  required String title,
  required String subtitle,
  required IconData icon,
  required Color color,
  required String actionText,
}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 20),
    decoration: BoxDecoration(
      color: Colors.black.withOpacity(0.4),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withOpacity(0.4), width: 1.5),
      boxShadow: [
        BoxShadow(color: color.withOpacity(0.05), blurRadius: 20, spreadRadius: 2)
      ]
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: color, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      title,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 12),
              Text(
                subtitle,
                style: GoogleFonts.inter(color: Colors.white70, fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  actionText,
                  style: GoogleFonts.jetBrainsMono(
                    color: color, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    ),
  );
}
