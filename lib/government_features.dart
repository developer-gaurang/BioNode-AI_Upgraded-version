import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// --- 1. Ad-Hoc Mesh Network Widget (CrashGuard Tab) ---
class AdHocMeshWidget extends StatelessWidget {
  const AdHocMeshWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return _buildFeatureCard(
      title: 'AD-HOC MESH NETWORK',
      subtitle: 'Offline SOS capability active. Searching for nearby BLE peers.',
      icon: Icons.bluetooth_audio,
      color: const Color(0xFF00E5FF),
      actionText: 'NETWORK STATUS: STANDBY',
    );
  }
}

// --- 2. Sentinel Mode Widget (CrashGuard Tab) ---
class SentinelModeWidget extends StatefulWidget {
  const SentinelModeWidget({super.key});

  @override
  State<SentinelModeWidget> createState() => _SentinelModeWidgetState();
}

class _SentinelModeWidgetState extends State<SentinelModeWidget> {
  bool isActive = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => isActive = !isActive),
      child: _buildFeatureCard(
        title: 'SENTINEL PREDICTIVE THREAT',
        subtitle: isActive 
          ? 'Monitoring gyroscope & route telemetry for anomalous behaviour.'
          : 'Predictive Threat Analysis is currently offline.',
        icon: Icons.radar,
        color: isActive ? const Color(0xFFFF2A5F) : Colors.white30,
        actionText: isActive ? 'ACTIVE' : 'INACTIVE',
      ),
    );
  }
}

// --- 3. AI Vitals Scanning (HealthVault Tab) ---
class VitalsScannerWidget extends StatelessWidget {
  const VitalsScannerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Initializing rPPG Camera Scanner...')),
        );
      },
      child: _buildFeatureCard(
        title: 'AI VITALS SCAN (rPPG)',
        subtitle: 'Uses front-camera to measure Heart Rate and SpO2 via micro-color variations.',
        icon: Icons.monitor_heart,
        color: const Color(0xFFFF9100),
        actionText: 'START SCAN',
      ),
    );
  }
}

// --- 4. Smart Triage Indicator (CrashGuard Tab - SOS State) ---
class SmartTriageWidget extends StatelessWidget {
  const SmartTriageWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFF2A5F).withOpacity(0.15),
        border: Border.all(color: const Color(0xFFFF2A5F).withOpacity(0.5)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.medication_liquid, color: Color(0xFFFF2A5F)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI SMART TRIAGE ACTIVE',
                  style: GoogleFonts.outfit(color: const Color(0xFFFF2A5F), fontWeight: FontWeight.w900),
                ),
                Text(
                  'Severity: Level 1 Trauma\nPreparing payload for 112 API Grid...',
                  style: GoogleFonts.inter(color: Colors.white70, fontSize: 12),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

// --- 5. Bio-Surveillance Heatmap (EcoMonitor Tab) ---
class EpidemicHeatmapWidget extends StatelessWidget {
  const EpidemicHeatmapWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Loading Regional Bio-Surveillance Map Data...')),
        );
      },
      child: _buildFeatureCard(
        title: 'CROWD-SOURCED BIO-SURVEILLANCE',
        subtitle: 'Real-time epidemic heatmap generated from global node telemetry.',
        icon: Icons.map_outlined,
        color: const Color(0xFFD500F9),
        actionText: 'VIEW GOV DASHBOARD',
      ),
    );
  }
}

// Custom Glassmorphic Card specifically tailored for Govt Features
Widget _buildFeatureCard({
  required String title,
  required String subtitle,
  required IconData icon,
  required Color color,
  required String actionText,
}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 20),
    decoration: BoxDecoration(
      color: Colors.black.withOpacity(0.3),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withOpacity(0.3), width: 1.5),
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
                style: GoogleFonts.inter(color: Colors.white70, fontSize: 14, height: 1.4),
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
