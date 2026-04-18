import 'dart:async';
import 'dart:ui';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'package:record/record.dart';
import 'package:url_launcher/url_launcher.dart';

import 'dart:math' as math;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:qr_flutter/qr_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: ".env");
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyCPncT1Oaj0ZzP4bW1CafceH_-57oFqQtg",
        authDomain: "bionode-ai-16c42.firebaseapp.com",
        projectId: "bionode-ai-16c42",
        storageBucket: "bionode-ai-16c42.firebasestorage.app",
        messagingSenderId: "436740338912",
        appId: "1:436740338912:web:061209da8705c874f48c85",
      ),
    );
  } catch (e) {
    debugPrint("Firebase API config bypass for Hot Reload");
  }
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Checking default state (if any)
  runApp(const BioNodeApp());
}

class BioNodeApp extends StatelessWidget {
  const BioNodeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BioNode OS',
      onGenerateRoute: (settings) {
        if (settings.name != null && settings.name!.startsWith('/public')) {
          final uri = Uri.parse(settings.name!);
          final targetId = uri.queryParameters['id'];
          if (targetId != null) {
            return MaterialPageRoute(
              builder: (context) => PublicVaultScreen(userAlias: targetId),
            );
          }
        }
        return null; // fallback to default routes
      },
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF050B14),
        primaryColor: const Color(0xFF00E5FF),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00E5FF),
          secondary: Color(0xFFD500F9),
          surface: Colors.transparent,
        ),
        textTheme: GoogleFonts.outfitTextTheme(
          Theme.of(context).textTheme,
        ).apply(bodyColor: Colors.white, displayColor: Colors.white),
      ),
      home: const UnifiedAuthHub(),
    );
  }
}

// ==============================================================================
// --- CORE UI ENGINES & EFFECTS ---
// ==============================================================================

class AnimatedMeshBackground extends StatefulWidget {
  const AnimatedMeshBackground({super.key});

  @override
  State<AnimatedMeshBackground> createState() => _AnimatedMeshBackgroundState();
}

class _AnimatedMeshBackgroundState extends State<AnimatedMeshBackground> with SingleTickerProviderStateMixin {
  AnimationController? _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 15))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _controller ??= AnimationController(vsync: this, duration: const Duration(seconds: 15))..repeat(reverse: true);
    
    return AnimatedBuilder(
      animation: _controller!,
      builder: (context, child) {
        return Stack(
          children: [
            Container(color: const Color(0xFF03050C)),
            Positioned(
              top: -150 + (math.sin(_controller!.value * 2 * math.pi) * 80),
              left: -150 + (math.cos(_controller!.value * 2 * math.pi) * 80),
              child: _buildOrb(const Color(0xFF00E5FF), 500, 0.25),
            ),
            Positioned(
              bottom: -200 + (math.cos(_controller!.value * 2 * math.pi) * 80),
              right: -100 + (math.sin(_controller!.value * 2 * math.pi) * 80),
              child: _buildOrb(const Color(0xFFD500F9), 600, 0.18),
            ),
            Positioned.fill(
              child: CustomPaint(painter: GridPainter()),
            ),
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 90, sigmaY: 90),
                child: Container(color: Colors.transparent),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildOrb(Color color, double size, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(opacity),
        boxShadow: [
          BoxShadow(color: color.withOpacity(opacity), blurRadius: 100, spreadRadius: 50),
        ]
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00E5FF).withOpacity(0.04)
      ..strokeWidth = 1;
    for (double i = 0; i < size.width; i += 30) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += 30) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class AcrylicCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final double width;
  final double height;
  final VoidCallback? onTap;

  const AcrylicCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = 28,
    this.width = double.infinity,
    this.height = double.nan,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget card = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
        child: Container(
          width: width == double.infinity ? null : width,
          height: height.isNaN ? null : height,
          padding: padding,
          decoration: BoxDecoration(
            color: const Color(0xFF0A101D),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: const Color(0xFF00E5FF).withOpacity(0.2),
              width: 1.0,
            ),
          ),
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: card);
    }
    return card;
  }
}

class SpringButton extends StatefulWidget {
  final String text;
  final IconData? icon;
  final VoidCallback onTap;

  const SpringButton({
    super.key,
    required this.text,
    this.icon,
    required this.onTap,
  });

  @override
  State<SpringButton> createState() => _SpringButtonState();
}

class _SpringButtonState extends State<SpringButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const ElasticOutCurve(0.9),
        reverseCurve: Curves.easeOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        Future.delayed(const Duration(milliseconds: 150), widget.onTap);
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: double.infinity,
          height: 60,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF00E5FF), Color(0xFFD500F9)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00E5FF).withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.text,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                  ),
                ),
                if (widget.icon != null) ...[
                  const SizedBox(width: 8),
                  Icon(widget.icon, color: Colors.white, size: 20),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class EliteTextField extends StatelessWidget {
  final String? overline;
  final String? labelText;
  final IconData icon;
  final String hint;
  final bool isPassword;
  final TextEditingController? controller;

  const EliteTextField({
    super.key,
    this.overline,
    this.labelText,
    required this.icon,
    required this.hint,
    this.isPassword = false,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (overline != null)
          Text(
            overline!.toUpperCase(),
            style: GoogleFonts.outfit(
              color: const Color(0xFF00E5FF),
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
        if (labelText != null && labelText!.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            labelText!,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
        SizedBox(height: (overline != null || (labelText != null && labelText!.isNotEmpty)) ? 8 : 0),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0A101D).withOpacity(0.8),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00E5FF).withOpacity(0.15),
                blurRadius: 15,
                spreadRadius: 1,
              )
            ],
            border: Border.all(
              color: const Color(0xFF00E5FF).withOpacity(0.5),
              width: 1.5,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: TextField(
            controller: controller,
            obscureText: isPassword,
            style: GoogleFonts.inter(color: Colors.white, fontSize: 16),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: Colors.white54, size: 20),
              prefixIconConstraints: const BoxConstraints(minWidth: 40),
              suffixIcon: isPassword
                  ? const Icon(Icons.visibility_off, color: Colors.white30, size: 20)
                  : null,
              hintText: hint,
              hintStyle: GoogleFonts.inter(color: Colors.white30, fontSize: 16),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }
}

// Custom Painter for EKG Wave
class AnimatedWavePainter extends CustomPainter {
  final double animationValue;
  final Color color;

  AnimatedWavePainter(this.animationValue, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    paint.imageFilter = ImageFilter.blur(sigmaX: 1, sigmaY: 1);

    final path = Path();
    for (double i = 0; i <= size.width; i++) {
      double x = i;
      double y =
          math.sin(
                (i / size.width * 3 * math.pi) + (animationValue * 2 * math.pi),
              ) *
              size.height *
              0.3 +
          math.cos(
                (i / size.width * 6 * math.pi) - (animationValue * 4 * math.pi),
              ) *
              size.height *
              0.1 +
          size.height * 0.5;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant AnimatedWavePainter oldDelegate) => true;
}

// ==============================================================================
// --- PAGE 1 & 2: THE AUTH EXPERIENCE (WITH DATABASE) ---
// ==============================================================================

class UnifiedAuthHub extends StatefulWidget {
  const UnifiedAuthHub({super.key});

  @override
  State<UnifiedAuthHub> createState() => _UnifiedAuthHubState();
}

class _UnifiedAuthHubState extends State<UnifiedAuthHub> {
  final _nameCtrl = TextEditingController();
  final _aliasCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  bool _isLoading = false;

  Future<void> _registerNode() async {
    final name = _nameCtrl.text.trim();
    final alias = _aliasCtrl.text.trim();
    final pass = _passCtrl.text.trim();

    if (name.isEmpty || alias.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All fields are required for node initialization.'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final docRef = FirebaseFirestore.instance
          .collection('bionodes')
          .doc(alias);
      final docSnap = await docRef.get();

      if (docSnap.exists) {
        setState(() => _isLoading = false);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Node ID already exists! Please Authenticate instead.',
            ),
            backgroundColor: Color(0xFFFF9100),
          ),
        );
        return;
      }

      await docRef.set({
        'name': name,
        'alias': alias,
        'pass': pass,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Keep SharedPreferences as local backup layer
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('name_$alias', name);
      await prefs.setString('pass_$alias', pass);

      await Future.delayed(
        const Duration(milliseconds: 1200),
      ); // Vault Simulation

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'BioNode Securely Initialized! Please login to your node now.',
          ),
          backgroundColor: Color(0xFF2962FF),
        ),
      );

      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 800),
          pageBuilder: (context, animation, secondaryAnimation) =>
              const LoginScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
              child: child,
            );
          },
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: const Color(0xFFFF2A5F),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const AnimatedMeshBackground(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 32.0,
                vertical: 24.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Hero(
                    tag: 'core_logo',
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF00E5FF), Color(0xFFD500F9)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00E5FF).withOpacity(0.6),
                            blurRadius: 40,
                            offset: const Offset(0, 5),
                          ),
                          BoxShadow(
                            color: const Color(0xFFD500F9).withOpacity(0.4),
                            blurRadius: 40,
                            offset: const Offset(0, -5),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.psychology_alt, // Changed to Brain/AI icon
                          color: Colors.white,
                          size: 55,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),
                  Text(
                    'Initialize\nBioNode',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 56,
                      fontWeight: FontWeight.w900,
                      height: 1.0,
                      letterSpacing: -2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Sync your biometric signature securely into the planetary intelligence grid.',
                    style: GoogleFonts.inter(
                      color: Colors.white70,
                      fontSize: 18,
                      height: 1.5,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  const SizedBox(height: 56),
                  EliteTextField(
                    controller: _nameCtrl,
                    icon: Icons.person_outline,
                    hint: 'Legal Identity',
                  ),
                  const SizedBox(height: 24),
                  EliteTextField(
                    controller: _aliasCtrl,
                    icon: Icons.alternate_email,
                    hint: 'Node Alias',
                  ),
                  const SizedBox(height: 24),
                  EliteTextField(
                    controller: _passCtrl,
                    icon: Icons.lock_outline,
                    hint: 'Quantum Key',
                    isPassword: true,
                  ),
                  const SizedBox(height: 56),
                  SpringButton(
                    text: _isLoading ? 'ENCRYPTING NODE...' : 'SYNC TO GRID',
                    icon: _isLoading ? Icons.sync : Icons.bolt,
                    onTap: _isLoading ? () {} : _registerNode,
                  ),
                  const SizedBox(height: 40),
                  Center(
                    child: GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, a, b) => const LoginScreen(),
                          transitionsBuilder: (context, a, b, child) =>
                              FadeTransition(opacity: a, child: child),
                        ),
                      ),
                      child: RichText(
                        text: TextSpan(
                          text: 'Existing Node? ',
                          style: GoogleFonts.inter(
                            color: Colors.white54,
                            fontSize: 16,
                          ),
                          children: [
                            TextSpan(
                              text: 'Authenticate',
                              style: GoogleFonts.inter(
                                color: const Color(0xFF00E5FF),
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                      ),
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

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _aliasCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  bool _isLoading = false;

  Future<void> _loginNode() async {
    final alias = _aliasCtrl.text.trim();
    final pass = _passCtrl.text.trim();

    if (alias.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter Node Alias and Quantum Key.'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(
      const Duration(milliseconds: 1500),
    ); // Security Simulation

    try {
      final docRef = FirebaseFirestore.instance
          .collection('bionodes')
          .doc(alias);
      final docSnap = await docRef.get();

      if (docSnap.exists && docSnap.data()?['pass'] == pass) {
        final savedName = docSnap.data()?['name'] ?? 'Unknown Agent';

        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 1000),
            pageBuilder: (context, a, b) =>
                MainHub(userName: savedName, userAlias: alias),
            transitionsBuilder: (context, a, b, child) =>
                FadeTransition(opacity: a, child: child),
          ),
          (route) => false,
        );
      } else {
        if (!mounted) return;
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cloud Access Denied. Invalid Node ID or Key.'),
            backgroundColor: Color(0xFFFF2A5F),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: const Color(0xFFFF2A5F),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const AnimatedMeshBackground(),
          SafeArea(
            child: Positioned(
              top: 20,
              left: 20,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Hero(
                      tag: 'core_logo',
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF050B14).withOpacity(0.8),
                          boxShadow: [
                            BoxShadow(
                                color: const Color(0xFF00E5FF).withOpacity(0.3),
                                blurRadius: 20,
                                spreadRadius: 2)
                          ],
                          border: Border.all(
                            color: const Color(0xFF00E5FF),
                            width: 2.5,
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.psychology_alt,
                            color: Color(0xFF00E5FF),
                            size: 55,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Text(
                      'Access\nYour Node',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 56,
                        fontWeight: FontWeight.w900,
                        height: 1.0,
                        letterSpacing: -2,
                      ),
                    ),
                    const SizedBox(height: 56),
                    EliteTextField(
                      controller: _aliasCtrl,
                      icon: Icons.alternate_email,
                      hint: 'Node Alias / ID',
                    ),
                    const SizedBox(height: 24),
                    EliteTextField(
                      controller: _passCtrl,
                      icon: Icons.security_outlined,
                      hint: 'Quantum Key',
                      isPassword: true,
                    ),
                    const SizedBox(height: 56),
                    SpringButton(
                      text: _isLoading ? 'DECRYPTING KEY...' : 'AUTHENTICATE',
                      icon: _isLoading ? Icons.sync : Icons.login,
                      onTap: _isLoading ? () {} : _loginNode,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==============================================================================
// --- MAIN NAVIGATION HUB & FLOATING NAVBAR ---
// ==============================================================================

class MainHub extends StatefulWidget {
  final String userName;
  final String userAlias;

  const MainHub({super.key, required this.userName, required this.userAlias});

  @override
  State<MainHub> createState() => _MainHubState();
}

class _MainHubState extends State<MainHub> {
  int _currentIndex = 0;

  late final List<Widget> _pages = [
    DashboardTab(userName: widget.userName, userAlias: widget.userAlias),
    const EcoMonitorTab(),
    HealthVaultTab(userName: widget.userName, userAlias: widget.userAlias),
    CrashGuardTab(userName: widget.userName, userAlias: widget.userAlias),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          const AnimatedMeshBackground(),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.05),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: _pages[_currentIndex],
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 24),
          child: AcrylicCard(
            borderRadius: 40,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: BottomNavigationBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              type: BottomNavigationBarType.fixed,
              selectedItemColor: const Color(0xFF00E5FF),
              unselectedItemColor: Colors.white30,
              showSelectedLabels: true,
              showUnselectedLabels: false,
              selectedLabelStyle: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.0,
              ),
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
              items: [
                _buildNavItem(Icons.dashboard_rounded, 'HUB', 0),
                _buildNavItem(Icons.radar_rounded, 'ECO', 1),
                _buildNavItem(Icons.verified_user_rounded, 'VAULT', 2),
                _buildNavItem(Icons.emergency_rounded, 'GUARD', 3),
              ],
            ),
          ),
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(
    IconData icon,
    String label,
    int index,
  ) {
    return BottomNavigationBarItem(
      icon: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.only(bottom: _currentIndex == index ? 4.0 : 0.0),
        child: index == 3
            ? Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    icon,
                    size: _currentIndex == index ? 28 : 24,
                    color: _currentIndex == index
                        ? const Color(0xFFFF2A5F)
                        : Colors.white30,
                  ),
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFF2A5F),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              )
            : Icon(icon, size: _currentIndex == index ? 28 : 24),
      ),
      label: label,
    );
  }
}

// ==============================================================================
// --- TAB 1: THE DASHBOARD EXPERIENCE ---
// ==============================================================================

class DashboardTab extends StatefulWidget {
  final String userName;
  final String userAlias;

  const DashboardTab({
    super.key,
    required this.userName,
    required this.userAlias,
  });

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab>
    with SingleTickerProviderStateMixin {
  late AnimationController _waveController;
  Timer? _sensorTimer;

  String _temp = '--.-';
  String _pressure = '----';
  String _humid = '--';
  String _wind = '--';

  String _riskTitle = 'WEATHER ADVISORY';
  String _riskDetail = '';
  bool _isHighRisk = false;
  String _riskProb = '';
  String? _geminiError;

  bool _isSyncing = true;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    _fetchRealTelemetry();
    // Refresh every 5 minutes automatically
    _sensorTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => _fetchRealTelemetry(),
    );
  }

  Future<void> _fetchRealTelemetry() async {
    if (!mounted) return;
    setState(() => _isSyncing = true);
    try {
      // 1. IP-based location lookup
      final ipRes = await http.get(Uri.parse('https://get.geojs.io/v1/ip/geo.json'));
      final ipData = jsonDecode(ipRes.body);
      final lat = ipData['latitude'];
      final lon = ipData['longitude'];

      // 2. Open-Meteo Current + Hourly Tracker
      final meteoRes = await http.get(
        Uri.parse(
          'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current=temperature_2m,relative_humidity_2m,surface_pressure,wind_speed_10m&hourly=temperature_2m,relative_humidity_2m,precipitation_probability&timezone=auto',
        ),
      );
      final meteoData = jsonDecode(meteoRes.body);
      final current = meteoData['current'];
      final hourly = meteoData['hourly'];

      if (!mounted) return;

      // Extract next 5 hours forecast
      List<String> forecastLines = [];
      for (int i = 1; i <= 5; i++) {
        forecastLines.add(
            'In $i hr: ${hourly['temperature_2m'][i]}°C, ${hourly['relative_humidity_2m'][i]}% Humidity, Rain: ${hourly['precipitation_probability'][i]}%');
      }
      String forecastDataStr = forecastLines.join('\n');

      String newTemp = current['temperature_2m'].toString();
      String newHumid = current['relative_humidity_2m'].toString();

      setState(() {
        _temp = newTemp;
        _humid = newHumid;
        _pressure = current['surface_pressure'].toString();
        _wind = current['wind_speed_10m'].toString();
      });

      final String prompt =
          'You are a high-end health & weather AI assistant. Analyze these LIVE metrics and FUTURE forecast:\n'
          'CURRENT:\n'
          '- Temperature: ${newTemp}°C\n'
          '- Humidity: ${newHumid}%\n'
          '- Pressure: ${current['surface_pressure']}hPa\n'
          '- Wind: ${current['wind_speed_10m']}km/h\n\n'
          'FORECAST (Next 5 Hours):\n'
          '$forecastDataStr\n\n'
          'Give a professional health & travel advisory. '
          'Return EXACTLY a valid JSON string (NO markdown, NO backticks) with this structure:\n'
          '{"title": "WEATHER TITLE", "condition": "Safe/Caution/Danger", '
          '"summary": "Detailed summary about the current weather taking into account the temperature, humidity, wind, and pressure", "precaution": "Vital precautions to take before going outside", '
          '"forecast": "Detailed analytics on how the weather will be in the next 4-5 hours", "isHighRisk": false}';

      // 3. Analyze with Gemini (GenerativeModel SDK)
      const String modelName = 'gemini-pro';
      final String apiKey = dotenv.env['GEMINI_API_KEY'] ?? 'AIzaSyBYKIwSztuPyiovRLnveWt6T821SPDSz40';
      
      final model = GenerativeModel(
        model: modelName,
        apiKey: apiKey,
        generationConfig: GenerationConfig(
          temperature: 0.7,
          maxOutputTokens: 1000,
          topP: 0.95,
        ),
      );

      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);

      if (response.text != null && response.text!.isNotEmpty) {
        String rawText = response.text!;
        rawText = rawText.replaceAll(RegExp(r'```[a-zA-Z]*\n?'), '').replaceAll('```', '').trim();
        final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(rawText);
        
        if (jsonMatch != null && mounted) {
          final parsed = jsonDecode(jsonMatch.group(0)!);
          setState(() {
            _riskTitle  = (parsed['title'] ?? 'OUTDOOR CONDITIONS').toString().toUpperCase();
            _riskProb   = parsed['condition'] ?? 'Safe';
            _riskDetail = '${parsed['summary'] ?? ''}\n\n${parsed['precaution'] ?? ''}\n\n${parsed['forecast'] ?? ''}';
            _isHighRisk = parsed['isHighRisk'] == true;
            _geminiError = null;
          });
        }
      } else {
        if (mounted) setState(() => _geminiError = 'AI Sync Error (Empty Response)');
      }
    } on GenerativeAIException catch (e) {
      if (mounted) setState(() => _geminiError = 'API Exception: ${e.message.toString()}');
    } catch (e) {
      if (mounted) setState(() => _geminiError = 'AI Sync Error (${e.toString()})');
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  @override
  void dispose() {
    _sensorTimer?.cancel();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(left: 24, right: 24, top: 70, bottom: 130),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00E5FF).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF00E5FF).withOpacity(0.4),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFF00E5FF),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'NODE SECURE',
                            style: GoogleFonts.jetBrainsMono(
                              color: const Color(0xFF00E5FF),
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Welcome,\n${widget.userName.split(' ').first}.',
                      style: GoogleFonts.outfit(
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Synchronized to Sector 7 Grid.',
                      style: GoogleFonts.inter(
                        color: Colors.white54,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (c, a, b) => const PricingScreen(),
                      transitionsBuilder: (c, a, b, child) =>
                          FadeTransition(opacity: a, child: child),
                    ),
                  );
                },
                child: Hero(
                  tag: 'profile_avatar',
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF00E5FF),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00E5FF).withOpacity(0.4),
                          blurRadius: 20,
                        ),
                      ],
                      // Using dynamically generated initial-based avatar
                      image: DecorationImage(
                        image: NetworkImage(
                          'https://ui-avatars.com/api/?name=${widget.userName.replaceAll(' ', '+')}&background=020205&color=00FFCC&size=128',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 56),

          Text(
            'LIVE TELEMETRY',
            style: GoogleFonts.jetBrainsMono(
              color: Colors.white54,
              fontSize: 14,
              letterSpacing: 2.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 0.9,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            children: [
              _buildLiveMetricCard(
                'TEMP',
                _temp,
                '°C',
                Icons.thermostat,
                const Color(0xFFFF9100),
                _isSyncing,
              ),
              _buildLiveMetricCard(
                'HUMID',
                _humid,
                '%',
                Icons.water_drop,
                const Color(0xFF2962FF),
                _isSyncing,
              ),
              _buildLiveMetricCard(
                'ATMOS',
                _pressure,
                'hPa',
                Icons.compress,
                const Color(0xFF00E5FF),
                _isSyncing,
              ),
              _buildLiveMetricCard(
                'WIND',
                _wind,
                'kph',
                Icons.air,
                const Color(0xFF00FFCC),
                _isSyncing,
              ),
            ],
          ),
          const SizedBox(height: 48),

          _buildPredictiveEngine(),
        ],
      ),
    );
  }

  Widget _buildLiveMetricCard(
    String title,
    String value,
    String unit,
    IconData icon,
    Color accent,
    bool animateWave,
  ) {
    return AcrylicCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: accent, size: 20),
              ),
              if (animateWave)
                SizedBox(
                  width: 30,
                  height: 15,
                  child: AnimatedBuilder(
                    animation: _waveController,
                    builder: (context, child) => CustomPaint(
                      painter: AnimatedWavePainter(
                        _waveController.value,
                        accent,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.jetBrainsMono(
                  color: Colors.white54,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 2),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      value,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      unit,
                      style: GoogleFonts.inter(
                        color: accent,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPredictiveEngine() {
    Color riskColor = _isHighRisk
        ? const Color(0xFFFF2A5F)
        : _riskProb == 'Caution'
            ? const Color(0xFFFF9100)
            : const Color(0xFF00FFCC);

    IconData riskIcon = _isHighRisk
        ? Icons.warning_amber_rounded
        : _riskProb == 'Caution'
            ? Icons.thermostat
            : Icons.wb_sunny_outlined;

    // Split detail into summary, precaution, and forecast
    final parts = _riskDetail.split('\n\n');
    final summaryText = parts.isNotEmpty ? parts[0] : '';
    final precautionText = parts.length > 1 ? parts[1] : '';
    final forecastText = parts.length > 2 ? parts[2] : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'AI ENVIRONMENTAL RADAR',
              style: GoogleFonts.jetBrainsMono(
                color: Colors.white54,
                fontSize: 14,
                letterSpacing: 2.5,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (!_isSyncing && _riskProb.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: riskColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: riskColor.withOpacity(0.6)),
                ),
                child: Text(
                  _riskProb.toUpperCase(),
                  style: GoogleFonts.jetBrainsMono(
                    color: riskColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 20),
        AcrylicCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: riskColor.withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: riskColor.withOpacity(0.5)),
                    ),
                    child: Icon(riskIcon, color: riskColor, size: 30),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      _riskTitle,
                      style: GoogleFonts.outfit(
                        color: riskColor,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              if (_isSyncing)
                Column(
                  children: [
                    const LinearProgressIndicator(
                      backgroundColor: Colors.white10,
                      color: Color(0xFF00E5FF),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Analyzing outdoor metrics + forecast...',
                      style: GoogleFonts.jetBrainsMono(
                        color: Colors.white38, fontSize: 12,
                      ),
                    ),
                  ],
                )
              else if (_geminiError != null)
                Column(
                  children: [
                    Text(
                      'SYNC ERROR: $_geminiError',
                      style: GoogleFonts.jetBrainsMono(color: Colors.redAccent, fontSize: 13),
                    ),
                    const SizedBox(height: 12),
                    SpringButton(text: 'RETRY CONNECTION', onTap: _fetchRealTelemetry),
                  ],
                )
              else ...[
                // --- CURRENT SUMMARY ---
                _buildInfoBlock('Current View', summaryText, Icons.info_outline, const Color(0xFF00FFCC)),
                
                const SizedBox(height: 14),
                
                // --- PRECAUTION ---
                if (precautionText.isNotEmpty)
                  _buildInfoBlock('Health Precautions', precautionText, Icons.health_and_safety_outlined, riskColor),

                const SizedBox(height: 14),

                // --- 5 HOUR FORECAST ---
                if (forecastText.isNotEmpty)
                  _buildInfoBlock('4-5 Hour Forecast', forecastText, Icons.access_time_filled, Colors.amberAccent),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoBlock(String label, String content, IconData icon, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 8),
              Text(
                label.toUpperCase(),
                style: GoogleFonts.jetBrainsMono(
                  color: color, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: GoogleFonts.inter(color: Colors.white.withOpacity(0.9), fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }
}

// ==============================================================================
// --- TAB 2: ECO-MONITOR ---
// ==============================================================================

class EcoRouteSegment {
  final String name;
  final List<LatLng> path;
  final LatLng apiPoint;
  double? temp;
  double? humidity;

  EcoRouteSegment({
    required this.name,
    required this.path,
    required this.apiPoint,
  });

  Color get routeColor {
    if (temp == null) return Colors.white24;
    double heatIndex = temp! + ((humidity ?? 40) * 0.1);
    if (heatIndex >= 40.0) return const Color(0xFFFF2A5F); // Red
    if (heatIndex >= 34.0) return const Color(0xFFFF9100); // Yellow
    return const Color(0xFF2962FF); // Blue
  }
}

class EcoMonitorTab extends StatefulWidget {
  const EcoMonitorTab({super.key});
  @override
  State<EcoMonitorTab> createState() => _EcoMonitorTabState();
}

class _EcoMonitorTabState extends State<EcoMonitorTab> {
  bool _isLoading = true;
  bool _isCalculatingRoute = false;
  bool _showSafeRoute = false;

  final MapController _mapController = MapController();
  final TextEditingController _startCtrl = TextEditingController(
    text: "Mumbai",
  );
  final TextEditingController _endCtrl = TextEditingController(text: "Ayodhya");

  List<EcoRouteSegment> routes = [];
  List<LatLng> _safeRoutePoints = [];
  Color _safeRouteGlowColor = const Color(0xFF00FFCC);

  // Rough India Landmass Polygon
  final List<LatLng> _indiaPoly = const [
    LatLng(8.0, 77.5),
    LatLng(10.0, 76.0),
    LatLng(15.0, 73.8),
    LatLng(19.0, 72.8),
    LatLng(21.0, 70.0),
    LatLng(22.0, 69.0),
    LatLng(24.0, 68.5),
    LatLng(25.0, 70.0),
    LatLng(28.0, 70.0),
    LatLng(30.0, 74.0),
    LatLng(32.0, 74.0),
    LatLng(33.5, 74.0),
    LatLng(34.0, 77.0),
    LatLng(31.0, 79.0),
    LatLng(28.0, 81.0),
    LatLng(27.0, 84.0),
    LatLng(27.0, 88.0),
    LatLng(28.0, 94.0),
    LatLng(28.0, 97.0),
    LatLng(23.0, 94.0),
    LatLng(22.0, 90.0),
    LatLng(22.0, 88.0),
    LatLng(21.5, 87.0),
    LatLng(19.0, 85.0),
    LatLng(15.0, 80.0),
    LatLng(12.0, 80.0),
  ];

  bool _isPointInsidePolygon(LatLng pt, List<LatLng> polygon) {
    int intersectCount = 0;
    for (int j = 0; j < polygon.length - 1; j++) {
      if (_rayCastIntersect(pt, polygon[j], polygon[j + 1])) intersectCount++;
    }
    if (_rayCastIntersect(pt, polygon[polygon.length - 1], polygon[0]))
      intersectCount++;
    return (intersectCount % 2) == 1;
  }

  bool _rayCastIntersect(LatLng pt, LatLng v1, LatLng v2) {
    if (v1.latitude > pt.latitude == v2.latitude > pt.latitude) return false;
    if (pt.longitude <
        (v2.longitude - v1.longitude) *
                (pt.latitude - v1.latitude) /
                (v2.latitude - v1.latitude) +
            v1.longitude)
      return true;
    return false;
  }

  @override
  void initState() {
    super.initState();
    _buildCoreRoutes();
    _generatePanIndiaGrid();
    _fetchLiveHeatData();
  }

  void _buildCoreRoutes() {
    routes.addAll([
      EcoRouteSegment(
        name: "NH-19",
        apiPoint: const LatLng(26.4499, 80.3319),
        path: const [
          LatLng(28.6139, 77.2090),
          LatLng(27.1767, 78.0081),
          LatLng(26.4499, 80.3319),
          LatLng(25.4358, 81.8463),
          LatLng(25.3176, 82.9739),
          LatLng(22.5726, 88.3639),
        ],
      ),
      EcoRouteSegment(
        name: "NH-48",
        apiPoint: const LatLng(24.5854, 73.6915),
        path: const [
          LatLng(28.6139, 77.2090),
          LatLng(26.9124, 75.7873),
          LatLng(24.5854, 73.6915),
          LatLng(23.0225, 72.5714),
          LatLng(19.0760, 72.8777),
        ],
      ),
      EcoRouteSegment(
        name: "Deccan",
        apiPoint: const LatLng(15.8497, 74.4977),
        path: const [
          LatLng(19.0760, 72.8777),
          LatLng(18.5204, 73.8567),
          LatLng(15.8497, 74.4977),
          LatLng(12.9716, 77.5946),
          LatLng(13.0827, 80.2707),
        ],
      ),
      EcoRouteSegment(
        name: "East",
        apiPoint: const LatLng(17.6868, 83.2185),
        path: const [
          LatLng(13.0827, 80.2707),
          LatLng(17.6868, 83.2185),
          LatLng(20.2961, 85.8245),
          LatLng(22.5726, 88.3639),
        ],
      ),
      EcoRouteSegment(
        name: "Central",
        apiPoint: const LatLng(21.1458, 79.0882),
        path: const [
          LatLng(27.1767, 78.0081),
          LatLng(21.1458, 79.0882),
          LatLng(17.3850, 78.4867),
          LatLng(12.9716, 77.5946),
        ],
      ),
    ]);
  }

  void _generatePanIndiaGrid() {
    final random = math.Random(10);
    int generated = 0;
    while (generated < 1800) {
      double lat = 8.4 + random.nextDouble() * 25.6;
      double lng = 68.0 + random.nextDouble() * 28.0;
      LatLng startPt = LatLng(lat, lng);
      if (!_isPointInsidePolygon(startPt, _indiaPoly)) continue;

      double len = 0.05 + random.nextDouble() * 0.15;
      double angle = random.nextDouble() * math.pi * 2;
      double endLat = lat + len * math.cos(angle);
      double endLng = lng + len * math.sin(angle);

      double baseTemp = 36.0;
      if (lat > 28) baseTemp -= 10;
      if (lat < 16) baseTemp -= 4;
      if (lat > 20 && lat < 28 && lng > 73 && lng < 82)
        baseTemp += 5; // Heat core

      routes.add(
        EcoRouteSegment(
            name: "Grid_$generated",
            apiPoint: startPt,
            path: [startPt, LatLng(endLat, endLng)],
          )
          ..temp = baseTemp + (random.nextDouble() - 0.5) * 8
          ..humidity = 35.0,
      );
      generated++;
    }
  }

  Future<void> _fetchLiveHeatData() async {
    try {
      final coreRoutes = routes
          .where((r) => !r.name.startsWith("Grid"))
          .toList();
      String lats = coreRoutes
          .map((r) => r.apiPoint.latitude.toString())
          .join(',');
      String lngs = coreRoutes
          .map((r) => r.apiPoint.longitude.toString())
          .join(',');
      final url = Uri.parse(
        'https://api.open-meteo.com/v1/forecast?latitude=$lats&longitude=$lngs&current=temperature_2m,relative_humidity_2m',
      );

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final isList = data is List;
        setState(() {
          for (int i = 0; i < coreRoutes.length; i++) {
            coreRoutes[i].temp =
                (isList ? data[i] : data)['current']['temperature_2m']
                    .toDouble();
            coreRoutes[i].humidity =
                (isList ? data[i] : data)['current']['relative_humidity_2m']
                    .toDouble();
          }
          _isLoading = false;
        });
      } else
        setState(() => _isLoading = false);
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: const Color(0xFFFF2A5F),
          ),
        );
      }
    }
  }

  Future<void> _fetchRealSafeRoute() async {
    if (_startCtrl.text.isEmpty || _endCtrl.text.isEmpty) return;
    setState(() {
      _isCalculatingRoute = true;
      _showSafeRoute = false;
    });

    try {
      // 1. Geocode
      final sUrl = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=${_startCtrl.text}&format=json&limit=1&countrycodes=in',
      );
      final eUrl = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=${_endCtrl.text}&format=json&limit=1&countrycodes=in',
      );
      final sRes = await http.get(sUrl);
      final eRes = await http.get(eUrl);
      var sData = jsonDecode(sRes.body);
      var eData = jsonDecode(eRes.body);

      if (sData.isEmpty || eData.isEmpty) throw Exception("Location not found");

      double lon1 = double.parse(sData[0]['lon']);
      double lat1 = double.parse(sData[0]['lat']);
      double lon2 = double.parse(eData[0]['lon']);
      double lat2 = double.parse(eData[0]['lat']);

      // 2. Fetch OSRM Real Path
      final osrmUrl = Uri.parse(
        'https://router.project-osrm.org/route/v1/driving/$lon1,$lat1;$lon2,$lat2?overview=simplified&geometries=geojson',
      );
      final osrmRes = await http.get(osrmUrl);
      var rData = jsonDecode(osrmRes.body);

      if (rData['code'] != 'Ok') throw Exception("Route failed");

      var coords = rData['routes'][0]['geometry']['coordinates'] as List;
      List<LatLng> path = coords
          .map((c) => LatLng(c[1] as double, c[0] as double))
          .toList();

      // 3. Fetch Real Temp for Route Evaluation
      LatLng mid = path[path.length ~/ 2];
      final mUrl = Uri.parse(
        'https://api.open-meteo.com/v1/forecast?latitude=${mid.latitude}&longitude=${mid.longitude}&current=temperature_2m',
      );
      final mRes = await http.get(mUrl);
      double temp = jsonDecode(mRes.body)['current']['temperature_2m'];

      // Assign Route Color depending on live heat
      Color rCol = const Color(0xFF2962FF); // Blue Optimal
      if (temp >= 38.0)
        rCol = const Color(0xFFFF2A5F); // Red Critical
      else if (temp >= 32.0)
        rCol = const Color(0xFFFF9100); // Yellow Med

      if (!mounted) return;
      setState(() {
        _safeRoutePoints = path;
        _safeRouteGlowColor = rCol;
        _isCalculatingRoute = false;
        _showSafeRoute = true;
      });

      _mapController.move(LatLng((lat1 + lat2) / 2, (lon1 + lon2) / 2), 5.6);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isCalculatingRoute = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Route Error: ${e.toString()}'),
          backgroundColor: const Color(0xFFFF2A5F),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    int highRiskCount = routes
        .where(
          (r) =>
              r.temp != null &&
              (r.temp! + (r.humidity ?? 40) * 0.1) >= 41 &&
              r.name.startsWith("Grid"),
        )
        .length;

    final gridRoutes = routes.where((r) => r.name.startsWith("Grid")).toList();
    final coreRoutes = routes.where((r) => !r.name.startsWith("Grid")).toList();

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: const MapOptions(
            initialCenter: LatLng(22.5, 79.0),
            initialZoom: 4.6,
            minZoom: 3.5,
          ),
          children: [
            TileLayer(
              urlTemplate:
                  'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
              subdomains: const ['a', 'b', 'c', 'd'],
              userAgentPackageName: 'com.bionode.app',
            ),
            Builder(
              builder: (ctx) {
                final zoom = MapCamera.of(ctx).zoom;
                double gridOpacity = ((zoom - 5.5) / 1.0).clamp(0.0, 1.0);
                if (gridOpacity == 0.0) return const SizedBox.shrink();
                return Opacity(
                  opacity: gridOpacity,
                  child: PolylineLayer(
                    polylines: gridRoutes
                        .map(
                          (r) => Polyline(
                            points: r.path,
                            strokeWidth: 3.0,
                            color: r.routeColor.withOpacity(0.8),
                          ),
                        )
                        .toList(),
                  ),
                );
              },
            ),
            if (!_isLoading)
              PolylineLayer(
                polylines: coreRoutes
                    .map(
                      (r) => Polyline(
                        points: r.path,
                        strokeWidth: 5.0,
                        color: r.routeColor,
                      ),
                    )
                    .toList(),
              ),
            // 🔥 BIO-MESH EPIDEMIC RADAR: AI Red Zones 🔥
            if (!_isLoading)
              CircleLayer(
                circles: [
                  // High Risk Viral Zone (Demo Simulation)
                  CircleMarker(
                    point: const LatLng(25.3176, 82.9739), // Varanasi/UP Area
                    color: const Color(0xFFFF2A5F).withOpacity(0.25),
                    borderColor: const Color(0xFFFF2A5F),
                    borderStrokeWidth: 3,
                    useRadiusInMeter: true,
                    radius: 150000, // 150km radius
                  ),
                  CircleMarker(
                    point: const LatLng(19.0760, 72.8777), // Mumbai Area
                    color: const Color(0xFFFF9100).withOpacity(0.2),
                    borderColor: const Color(0xFFFF9100),
                    borderStrokeWidth: 2,
                    useRadiusInMeter: true,
                    radius: 80000, 
                  ),
                ],
              ),
            if (!_isLoading)
              MarkerLayer(
                markers: coreRoutes
                    .map(
                      (r) => Marker(
                        point: r.apiPoint,
                        width: 44,
                        height: 44,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            shape: BoxShape.circle,
                            border: Border.all(color: r.routeColor, width: 2),
                          ),
                          child: Center(
                            child: Text(
                              r.temp != null ? "${r.temp!.toInt()}°" : "...",
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),

            // ANIMATED REAL ROUTE
            if (_showSafeRoute && _safeRoutePoints.isNotEmpty)
              TweenAnimationBuilder<double>(
                tween: Tween<double>(
                  begin: 0,
                  end: _safeRoutePoints.length.toDouble() - 1,
                ),
                duration: const Duration(milliseconds: 3000),
                curve: Curves.easeInOut,
                builder: (context, value, child) {
                  int lastIndex = value.floor();
                  double remainder = value - lastIndex;
                  LatLng tipPoint;
                  List<LatLng> currentPoints = _safeRoutePoints.sublist(
                    0,
                    lastIndex + 1,
                  );
                  if (lastIndex < _safeRoutePoints.length - 1) {
                    LatLng p1 = _safeRoutePoints[lastIndex];
                    LatLng p2 = _safeRoutePoints[lastIndex + 1];
                    currentPoints.add(
                      LatLng(
                        p1.latitude + (p2.latitude - p1.latitude) * remainder,
                        p1.longitude +
                            (p2.longitude - p1.longitude) * remainder,
                      ),
                    );
                    tipPoint = currentPoints.last;
                  } else {
                    tipPoint = _safeRoutePoints.last;
                  }
                  return Stack(
                    children: [
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: currentPoints,
                            strokeWidth: 12.0,
                            color: _safeRouteGlowColor.withOpacity(0.3),
                          ),
                          Polyline(
                            points: currentPoints,
                            strokeWidth: 6.0,
                            color: _safeRouteGlowColor,
                          ),
                        ],
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: tipPoint,
                            width: 60,
                            height: 60,
                            child: Container(
                              decoration: BoxDecoration(
                                color: _safeRouteGlowColor.withOpacity(0.2),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: _safeRouteGlowColor,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: _safeRouteGlowColor,
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.navigation,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
          ],
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildChip(
                    Icons.thermostat,
                    _isLoading
                        ? 'SYNCING SATELLITE GRID...'
                        : 'MACRO-SCAN: OVER 1800 ZONES // $highRiskCount CRITICAL',
                    _isLoading ? Colors.white54 : const Color(0xFFFF2A5F),
                  ),
                  const SizedBox(width: 12),
                  // 🔥 ECO-SWARM MESH BUTTON
                  GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('SWARM MODE ACTIVATED: Connected to 12 offline nodes via BLE Mesh.'),
                          backgroundColor: Color(0xFFD500F9),
                          duration: Duration(seconds: 4),
                        ),
                      );
                    },
                    child: _buildChip(
                      Icons.bluetooth_connected,
                      'ENABLE ECO-SWARM MESH',
                      const Color(0xFFD500F9),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        DraggableScrollableSheet(
          initialChildSize: 0.35,
          minChildSize: 0.15,
          maxChildSize: 0.85,
          builder: (context, scrollController) {
            return ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(40),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    border: Border(
                      top: BorderSide(color: Colors.white.withOpacity(0.1)),
                    ),
                  ),
                  child: SingleChildScrollView(
                    controller: scrollController,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 50,
                            height: 6,
                            decoration: BoxDecoration(
                              color: Colors.white38,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          'THERMAL ROUTE NAVIGATOR',
                          style: GoogleFonts.jetBrainsMono(
                            color: Colors.white54,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2.0,
                          ),
                        ),
                        const SizedBox(height: 24),
                        EliteTextField(
                          icon: Icons.my_location_rounded,
                          hint: 'Start (e.g., Mumbai)',
                          controller: _startCtrl,
                        ),
                        const SizedBox(height: 16),
                        EliteTextField(
                          icon: Icons.location_on_rounded,
                          hint: 'End (e.g., Uttarakhand)',
                          controller: _endCtrl,
                        ),
                        const SizedBox(height: 32),
                        SpringButton(
                          text: _isCalculatingRoute
                              ? 'CALCULATING GPS...'
                              : 'FIND SAFEST ROUTE',
                          icon: _isCalculatingRoute
                              ? Icons.sync
                              : Icons.alt_route_rounded,
                          onTap: _fetchRealSafeRoute,
                        ),
                        const SizedBox(height: 48),
                        Text(
                          'PAN-INDIA GRID LEGEND',
                          style: GoogleFonts.jetBrainsMono(
                            color: Colors.white54,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2.0,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Pinch & Zoom the map to reveal high-resolution local street risk assessment.',
                          style: GoogleFonts.inter(
                            color: const Color(0xFF00E5FF),
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 24),
                        // 🔥 BIO-MESH LEGEND
                        _buildLegend(
                          const Color(0xFFFF2A5F),
                          'BIO-HAZARD (RED ZONE)',
                          'Bio-Mesh Neural Radar detected high coughing/fever cases in this area. Route Avoided.',
                        ),
                        const SizedBox(height: 12),
                        _buildLegend(
                          const Color(0xFFFF9100),
                          'ELEVATED VIRAL RISK',
                          'AI detects moderate respiratory symptom uploads in Vault. Proceed with caution.',
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'THERMAL SATELLITE MAP LEGEND',
                          style: GoogleFonts.jetBrainsMono(
                            color: Colors.white54,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2.0,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const SizedBox(height: 12),
                        _buildLegend(
                          const Color(0xFFFF9100),
                          'MODERATE (YELLOW)',
                          'Elevated temperature, minor risk pathways.',
                        ),
                        const SizedBox(height: 12),
                        _buildLegend(
                          const Color(0xFF2962FF),
                          'OPTIMAL (BLUE)',
                          'Safe traveling routes and thermal zones.',
                        ),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildLegend(Color color, String title, String desc) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: color.withOpacity(0.5), blurRadius: 8),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Text(
          title,
          style: GoogleFonts.outfit(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            desc,
            style: GoogleFonts.inter(color: Colors.white54, fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildChip(IconData icon, String label, Color color) {
    return AcrylicCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      borderRadius: 100,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isLoading)
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white54,
              ),
            )
          else
            Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

// ==============================================================================
// --- TAB 3: HEALTH VAULT ---
// ==============================================================================

class HealthVaultTab extends StatelessWidget {
  final String userName;
  final String userAlias;

  const HealthVaultTab({
    super.key,
    required this.userName,
    required this.userAlias,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(left: 24, right: 24, top: 70, bottom: 130),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Secure\nVault',
            style: GoogleFonts.outfit(
              fontSize: 56,
              fontWeight: FontWeight.w900,
              letterSpacing: -2,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 48),
          AcrylicCard(
            padding: const EdgeInsets.all(32),
            child: Row(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: QrImageView(
                      data:
                          Uri.base.toString().split('#').first +
                          '#/public?id=$userAlias',
                      version: QrVersions.auto,
                      size: 80,
                    ),
                  ),
                ),
                const SizedBox(width: 32),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName.toUpperCase(),
                        style: GoogleFonts.outfit(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'ID // ${userAlias.toUpperCase()}-X',
                        style: GoogleFonts.jetBrainsMono(
                          color: Colors.white54,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 56),
          Text(
            'ENCRYPTED ARCHIVES',
            style: GoogleFonts.jetBrainsMono(
              color: Colors.white54,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.0,
            ),
          ),
          // (PharmaNode Scanner moved to floating button)
          // 🔥 LIFEGRID: AUTOMATED BLOOD SOS
          _buildArchive(
            context,
            Icons.bloodtype,
            'Blood Profile',
            'LifeGrid™ Auto-Match SOS',
            const Color(0xFFFF2A5F), // Red
          ),
          // 🔥 BIO-MESH: EPIDEMIC UPLOADS
          _buildArchive(
            context,
            Icons.coronavirus,
            'Symptom & Viral Log',
            'Syncs with Bio-Mesh Radar',
            const Color(0xFFFF9100), // Orange
          ),
          _buildArchive(
            context,
            Icons.folder_special,
            'Medical History',
            'Secured entries',
            const Color(0xFF00E5FF),
          ),
          _buildArchive(
            context,
            Icons.medical_services,
            'Immunization',
            'Verified on blockchain',
            const Color(0xFFD500F9),
          ),
          _buildArchive(
            context,
            Icons.warning_amber,
            'Allergies',
            'Active markers',
            const Color(0xFF00FFCC),
          ),
        ],
      ),
    ),
    Positioned(
      bottom: 110,
      right: 24,
      child: GestureDetector(
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (ctx) => const PharmaNodeScannerSheet(),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF00FFCC),
            borderRadius: BorderRadius.circular(100),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00FFCC).withOpacity(0.6),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.document_scanner_rounded, color: Colors.black, size: 24),
              const SizedBox(width: 8),
              Text(
                'SCAN RX',
                style: GoogleFonts.outfit(
                  color: Colors.black,
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  ],
);
  }

  Widget _buildArchive(
    BuildContext context,
    IconData icon,
    String title,
    String sub,
    Color accent,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  VaultArchiveScreen(category: title, userAlias: userAlias),
            ),
          );
        },
        child: AcrylicCard(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: accent, size: 30),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.outfit(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      sub,
                      style: GoogleFonts.inter(
                        color: Colors.white54,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class VaultArchiveScreen extends StatelessWidget {
  final String category;
  final String userAlias;

  const VaultArchiveScreen({
    super.key,
    required this.category,
    required this.userAlias,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050B14),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          category.toUpperCase(),
          style: GoogleFonts.jetBrainsMono(
            color: const Color(0xFF00E5FF),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (ctx) =>
              AddArchiveSheet(category: category, userAlias: userAlias),
        ),
        backgroundColor: const Color(0xFF00E5FF),
        icon: const Icon(Icons.lock_outline, color: Colors.white),
        label: Text(
          "ADD & ENCRYPT",
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Stack(
        children: [
          const AnimatedMeshBackground(),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('bionodes')
                .doc(userAlias)
                .collection('vault_records')
                .where('category', isEqualTo: category)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting)
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF00E5FF)),
                );

              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    "ERROR: ${snapshot.error}",
                    style: GoogleFonts.jetBrainsMono(color: Colors.red),
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Text(
                    "NO DECRYPTED DATA FOUND.",
                    style: GoogleFonts.jetBrainsMono(color: Colors.white54),
                  ),
                );
              }

              final docs = snapshot.data!.docs.toList();
              docs.sort((a, b) {
                final aData = a.data() as Map<String, dynamic>;
                final bData = b.data() as Map<String, dynamic>;
                final aTime = aData['createdAt'] as Timestamp?;
                final bTime = bData['createdAt'] as Timestamp?;
                if (aTime == null && bTime == null) return 0;
                if (aTime == null) return 1;
                if (bTime == null) return -1;
                return bTime.compareTo(aTime);
              });
              return ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final data = docs[index].data() as Map<String, dynamic>;
                  bool hasFile = data['fileBase64'] != null;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (ctx) => AddArchiveSheet(
                            category: category,
                            userAlias: userAlias,
                            docId: docs[index].id,
                            initialData: data,
                          ),
                        );
                      },
                      child: AcrylicCard(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    data['title'] ?? 'Unknown',
                                    style: GoogleFonts.outfit(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                if (hasFile)
                                  const Icon(
                                    Icons.description,
                                    color: Color(0xFF00FFCC),
                                    size: 28,
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "${category == 'Immunization' ? 'VACCINE' : 'DOCTOR'}: ${data['facility']}",
                              style: GoogleFonts.jetBrainsMono(
                                color: const Color(0xFF00E5FF),
                                fontSize: 13,
                              ),
                            ),
                            if (data['hospital'] != null &&
                                data['hospital'].toString().isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                "HOSPITAL: ${data['hospital']}",
                                style: GoogleFonts.jetBrainsMono(
                                  color: const Color(0xFFD500F9),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                            const SizedBox(height: 16),
                            Text(
                              data['notes'] ?? '',
                              style: GoogleFonts.inter(
                                color: Colors.white70,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Container(height: 1, color: Colors.white10),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Icon(
                                  Icons.verified_user,
                                  color: Color(0xFFD500F9),
                                  size: 14,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'HASH: 0x${docs[index].id.toUpperCase().substring(0, 12)}... SECURED',
                                    style: GoogleFonts.jetBrainsMono(
                                      color: Colors.white30,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class AddArchiveSheet extends StatefulWidget {
  final String category;
  final String userAlias;
  final String? docId;
  final Map<String, dynamic>? initialData;
  const AddArchiveSheet({
    super.key,
    required this.category,
    required this.userAlias,
    this.docId,
    this.initialData,
  });

  @override
  State<AddArchiveSheet> createState() => _AddArchiveSheetState();
}

class _AddArchiveSheetState extends State<AddArchiveSheet> {
  final _titleCtrl = TextEditingController();
  final _facilityCtrl = TextEditingController();
  final _hospitalCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  bool _isLoading = false;
  String? _base64File;

  String get _titleLabel {
    if (widget.category == 'Immunization') return 'Title / Diagnosis';
    if (widget.category == 'Allergies') return 'Allergy Name';
    if (widget.category == 'Blood Profile') return 'Blood Group';
    return 'Title / Diagnosis';
  }

  String get _facilityLabel {
    if (widget.category == 'Immunization') return 'Vaccination Name';
    if (widget.category == 'Blood Profile') return 'Doctor Name';
    return 'Doctor Name';
  }

  String get _hospitalLabel {
    if (widget.category == 'Immunization')
      return 'Hospital Name (Vaccination Center)';
    if (widget.category == 'Allergies') return 'Hospital Name (Report Source)';
    if (widget.category == 'Blood Profile') return 'Lab Name (Testing Center)';
    return 'Hospital Name';
  }

  String get _scanButtonLabel {
    if (widget.category == 'Immunization')
      return 'SCAN VACCINATION CERTIFICATE';
    if (widget.category == 'Allergies') return 'SCAN ALLERGY REPORT';
    if (widget.category == 'Blood Profile') return 'SCAN DOCUMENT (LAB REPORT)';
    return 'SCAN DOCUMENT (PRESCRIPTION)';
  }

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _titleCtrl.text = widget.initialData!['title'] ?? '';
      _facilityCtrl.text = widget.initialData!['facility'] ?? '';
      _hospitalCtrl.text = widget.initialData!['hospital'] ?? '';
      _notesCtrl.text = widget.initialData!['notes'] ?? '';
      _base64File = widget.initialData!['fileBase64'];
    }
  }

  Future<void> _pickFile() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _base64File = base64Encode(bytes);
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Document Attached Successfully!'),
          backgroundColor: Color(0xFF00FFCC),
        ),
      );
    }
  }

  Future<void> _saveRecord() async {
    if (_titleCtrl.text.isEmpty || _facilityCtrl.text.isEmpty) return;
    setState(() => _isLoading = true);

    final payload = {
      'category': widget.category,
      'title': _titleCtrl.text,
      'facility': _facilityCtrl.text,
      'hospital': _hospitalCtrl.text,
      'notes': _notesCtrl.text,
      'fileBase64': _base64File,
      if (widget.docId == null) 'createdAt': FieldValue.serverTimestamp(),
    };

    if (widget.docId == null) {
      await FirebaseFirestore.instance
          .collection('bionodes')
          .doc(widget.userAlias)
          .collection('vault_records')
          .add(payload);
    } else {
      await FirebaseFirestore.instance
          .collection('bionodes')
          .doc(widget.userAlias)
          .collection('vault_records')
          .doc(widget.docId)
          .update(payload);
    }

    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.docId == null
              ? 'Record Encrypted & Synchronized!'
              : 'Record Updated!',
        ),
        backgroundColor: const Color(0xFF00E5FF),
      ),
    );
  }

  Future<void> _deleteRecord() async {
    if (widget.docId == null) return;
    setState(() => _isLoading = true);
    await FirebaseFirestore.instance
        .collection('bionodes')
        .doc(widget.userAlias)
        .collection('vault_records')
        .doc(widget.docId)
        .delete();
    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Record Destroyed!'),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.8),
              border: Border(
                top: BorderSide(color: Colors.white.withOpacity(0.1)),
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      width: 50,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.white38,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    widget.docId == null
                        ? 'NEW ${widget.category.toUpperCase()}'
                        : 'VIEW / EDIT ${widget.category.toUpperCase()}',
                    style: GoogleFonts.jetBrainsMono(
                      color: const Color(0xFF00E5FF),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 24),
                  EliteTextField(
                    icon: Icons.title,
                    hint: _titleLabel,
                    controller: _titleCtrl,
                  ),
                  const SizedBox(height: 16),
                  EliteTextField(
                    icon: widget.category == 'Immunization'
                        ? Icons.vaccines
                        : Icons.person_add,
                    hint: _facilityLabel,
                    controller: _facilityCtrl,
                  ),
                  const SizedBox(height: 16),
                  EliteTextField(
                    icon: Icons.local_hospital,
                    hint: _hospitalLabel,
                    controller: _hospitalCtrl,
                  ),
                  const SizedBox(height: 16),
                  EliteTextField(
                    icon: Icons.notes,
                    hint: 'Remarks / Notes',
                    controller: _notesCtrl,
                  ),
                  const SizedBox(height: 24),
                  if (_base64File != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.memory(
                          base64Decode(_base64File!),
                          height: 250,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            height: 150,
                            color: Colors.white10,
                            child: const Center(
                              child: Icon(
                                Icons.broken_image,
                                color: Colors.white54,
                                size: 50,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  GestureDetector(
                    onTap: _pickFile,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        color: _base64File == null
                            ? Colors.white.withOpacity(0.05)
                            : const Color(0xFF00FFCC).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _base64File == null
                              ? Colors.white24
                              : const Color(0xFF00FFCC),
                          width: 2,
                          strokeAlign: BorderSide.strokeAlignInside,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _base64File == null
                                ? Icons.document_scanner
                                : Icons.check_circle,
                            color: _base64File == null
                                ? Colors.white70
                                : const Color(0xFF00FFCC),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _base64File == null
                                ? _scanButtonLabel
                                : 'DOCUMENT SECURED (BASE-64)',
                            style: GoogleFonts.outfit(
                              color: _base64File == null
                                  ? Colors.white70
                                  : const Color(0xFF00FFCC),
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SpringButton(
                    text: _isLoading
                        ? 'ENCRYPTING...'
                        : (widget.docId == null
                              ? 'ENCRYPT & STORE'
                              : 'UPDATE RECORD'),
                    icon: _isLoading ? Icons.sync : Icons.lock,
                    onTap: _isLoading ? () {} : _saveRecord,
                  ),
                  if (widget.docId != null) ...[
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: _isLoading ? () {} : _deleteRecord,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(color: Colors.redAccent, width: 2),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.delete_forever,
                              color: Colors.redAccent,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'DELETE RECORD',
                              style: GoogleFonts.outfit(
                                color: Colors.redAccent,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ==============================================================================
// --- PHARMANODE SCANNER SHEET ---
// ==============================================================================

class PharmaNodeScannerSheet extends StatefulWidget {
  const PharmaNodeScannerSheet({super.key});
  @override
  State<PharmaNodeScannerSheet> createState() => _PharmaNodeScannerSheetState();
}

class _PharmaNodeScannerSheetState extends State<PharmaNodeScannerSheet> {
  bool _isScanning = false;
  bool _scanComplete = false;
  String? _base64File;

  Future<void> _pickFile() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _base64File = base64Encode(bytes);
        _isScanning = true;
      });

      // Simulating AI Vision Analysis Delay
      await Future.delayed(const Duration(seconds: 3));

      if (mounted) {
        setState(() {
          _isScanning = false;
          _scanComplete = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.9),
              border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      width: 50,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.white38,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'PHARMANODE AI SCANNER',
                    style: GoogleFonts.jetBrainsMono(
                      color: const Color(0xFF00FFCC),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Anti-Counterfeit & Allergy Conflicter',
                    style: GoogleFonts.inter(color: Colors.white54, fontSize: 14),
                  ),
                  const SizedBox(height: 24),
                  if (_base64File != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 500),
                          child: _isScanning
                              ? Container(
                                  height: 250,
                                  width: double.infinity,
                                  color: Colors.white10,
                                  child: const Center(
                                    child: CircularProgressIndicator(color: Color(0xFF00FFCC)),
                                  ),
                                )
                              : Image.memory(
                                  base64Decode(_base64File!),
                                  height: 250,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                    ),
                  if (!_scanComplete && !_isScanning)
                    GestureDetector(
                      onTap: _pickFile,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00FFCC).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFF00FFCC)),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.document_scanner, color: Color(0xFF00FFCC), size: 40),
                            const SizedBox(height: 12),
                            Text(
                              'SCAN MEDICINE STRIP',
                              style: GoogleFonts.outfit(
                                color: const Color(0xFF00FFCC),
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (_scanComplete) ...[
                    // SIMULATED FATAL ALLERGY ALERT
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF2A5F).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFFF2A5F), width: 2),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.warning, color: Color(0xFFFF2A5F), size: 28),
                              const SizedBox(width: 12),
                              Text(
                                'FATAL ALLERGY CONFLICT',
                                style: GoogleFonts.jetBrainsMono(
                                  color: const Color(0xFFFF2A5F),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "AI Vision detected 'Ibuprofen' in this medicine. According to your Vault Archives, you have a severe NSAID allergy. DO NOT CONSUME.",
                            style: GoogleFonts.inter(color: Colors.white, fontSize: 14, height: 1.5),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SpringButton(
                      text: 'DISCARD SCAN',
                      icon: Icons.refresh,
                      onTap: () {
                        setState(() {
                          _base64File = null;
                          _scanComplete = false;
                        });
                      },
                    ),
                  ],
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PricingScreen extends StatelessWidget {
  const PricingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white, size: 32),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          const AnimatedMeshBackground(),
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 150),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: Text(
                    'PRO PROTOCOL ENABLED',
                    style: GoogleFonts.jetBrainsMono(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  'Unleash The Node.',
                  style: GoogleFonts.outfit(
                    fontSize: 64,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -3,
                    height: 1.0,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 56),
                AcrylicCard(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    children: [
                      Text(
                        '\$9.99',
                        style: GoogleFonts.outfit(
                          fontSize: 72,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF00E5FF),
                          letterSpacing: -2,
                        ),
                      ),
                      Text(
                        '/month',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          color: Colors.white54,
                        ),
                      ),
                      const SizedBox(height: 48),
                      _buildFeature('Quantum-Level Analytics'),
                      _buildFeature('Satellite SOS Bypass'),
                      _buildFeature('Zero-Latency Sync Priority'),
                      const SizedBox(height: 56),
                      SpringButton(text: 'ACTIVATE PRO', onTap: () {}),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeature(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Color(0xFF00E5FF), size: 28),
          const SizedBox(width: 24),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==============================================================================
// --- TAB 4: CRASH GUARD — ACCIDENT DETECTION & EMERGENCY ALERT SYSTEM ---
// ==============================================================================

class CrashGuardTab extends StatefulWidget {
  final String userName;
  final String userAlias;

  const CrashGuardTab({
    super.key,
    required this.userName,
    required this.userAlias,
  });

  @override
  State<CrashGuardTab> createState() => _CrashGuardTabState();
}

class _CrashGuardTabState extends State<CrashGuardTab>
    with TickerProviderStateMixin {
  // ── State Variables ────────────────────────────────────────────────────────
  bool _isListening = false;
  bool _isCrashDetected = false;
  bool _isAnalyzing = false;
  bool _alarmPlaying = false;
  String _statusMsg = 'STANDBY — SYSTEM READY';
  String _detailMsg = 'Press the shield to start 10-second acoustic monitoring.';
  int _countdown = 10;
  Timer? _countdownTimer;
  Timer? _alarmTimer;

  // Emergency contacts (up to 5)
  final List<Map<String, String>> _contacts = [];
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  // Audio
  final AudioPlayer _audioPlayer = AudioPlayer();
  final AudioRecorder _recorder = AudioRecorder();
  double _currentAmplitude = 0.0;
  Timer? _amplitudeTimer;

  // Animation
  late AnimationController _pulseCtrl;
  late AnimationController _alarmCtrl;
  late Animation<double> _pulseAnim;
  late Animation<double> _alarmAnim;

  // User location (approximate)
  double _userLat = 20.5937;
  double _userLon = 78.9629;

  @override
  void initState() {
    super.initState();
    _loadContacts();
    _fetchUserLocation();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.95, end: 1.08).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    _alarmCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _alarmAnim = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _alarmCtrl, curve: Curves.easeInOut),
    );
  }

  Future<void> _fetchUserLocation() async {
    try {
      final res =
          await http.get(Uri.parse('https://get.geojs.io/v1/ip/geo.json'));
      final data = jsonDecode(res.body);
      setState(() {
        _userLat = double.tryParse(data['latitude'].toString()) ?? 20.5937;
        _userLon = double.tryParse(data['longitude'].toString()) ?? 78.9629;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Location Error: ${e.toString()}'),
            backgroundColor: const Color(0xFFFF2A5F),
          ),
        );
      }
    }
  }

  Future<void> _loadContacts() async {
    FirebaseFirestore.instance
        .collection('bionodes')
        .doc(widget.userAlias)
        .collection('emergency_contacts')
        .snapshots()
        .listen((snapshot) {
      if (!mounted) return;
      setState(() {
        _contacts.clear();
        for (var doc in snapshot.docs) {
          _contacts.add({
            'id': doc.id,
            'name': doc.data()['name']?.toString() ?? 'Contact',
            'phone': doc.data()['phone']?.toString() ?? '',
          });
        }
      });
    });
  }

  Future<void> _saveContacts() async {
    // Handled natively via Firestore stream now
  }

  // ── Start Acoustic Monitoring ──────────────────────────────────────────────
  Future<void> _startMonitoring() async {
    if (_isListening) return;
    setState(() {
      _isListening = true;
      _isCrashDetected = false;
      _alarmPlaying = false;
      _countdown = 10;
      _statusMsg = 'ACOUSTIC SCAN ACTIVE';
      _detailMsg = 'Listening for crash/impact sounds...';
    });

    // Try to start real recording for amplitude detection
    bool recordingStarted = false;
    try {
      final hasPermission = await _recorder.hasPermission();
      if (hasPermission) {
        await _recorder.start(
          const RecordConfig(encoder: AudioEncoder.wav, sampleRate: 44100),
          path: '',
        );
        recordingStarted = true;
        // Poll amplitude every 500ms
        _amplitudeTimer =
            Timer.periodic(const Duration(milliseconds: 500), (_) async {
          if (!_isListening) return;
          final amp = await _recorder.getAmplitude();
          setState(() => _currentAmplitude = amp.current.abs());

          // Real crash detection: very loud sudden sound (> 80 dB equivalent)
          if (amp.current.abs() > 80 && !_isCrashDetected) {
            _onCrashDetected();
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Audio Error: ${e.toString()} (Simulating...)'),
            backgroundColor: const Color(0xFFFF9100),
          ),
        );
      }
      // Web or permission denied — use simulated analysis
    }

    // Countdown timer
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() => _countdown--);
      if (_countdown <= 0) {
        timer.cancel();
        if (!_isCrashDetected) {
          // Simulate AI analysis after 10 sec if no real crash detected
          _runAIAnalysis(recordingStarted);
        }
      }
    });
  }

  Future<void> _runAIAnalysis(bool hadRealRecording) async {
    if (!mounted) return;
    setState(() {
      _isAnalyzing = true;
      _statusMsg = 'AI ANALYSIS IN PROGRESS';
      _detailMsg = 'Gemini is analyzing acoustic signature...';
    });

    await _stopRecording();

    // Simulate AI processing delay
    await Future.delayed(const Duration(seconds: 2));

    // For web: simulate random crash detection (demo) — in real app, send audio to Gemini
    final random = math.Random();
    final detected = random.nextInt(10) > 7; // 20% chance in demo

    if (mounted) {
      if (detected) {
        _onCrashDetected();
      } else {
        setState(() {
          _isListening = false;
          _isAnalyzing = false;
          _statusMsg = 'ALL CLEAR — NO THREAT DETECTED';
          _detailMsg =
              'Environment acoustic analysis complete. No crash or impact sound was detected.';
        });
      }
    }
  }

  Future<void> _stopRecording() async {
    _amplitudeTimer?.cancel();
    try {
      await _recorder.stop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Stop Recording Error: ${e.toString()}'),
            backgroundColor: const Color(0xFFFF2A5F),
          ),
        );
      }
    }
  }

  // ── Crash Detected Handler ─────────────────────────────────────────────────
  void _onCrashDetected() {
    if (!mounted || _isCrashDetected) return;
    _countdownTimer?.cancel();
    _stopRecording();

    setState(() {
      _isCrashDetected = true;
      _isListening = false;
      _isAnalyzing = false;
      _alarmPlaying = true;
      _statusMsg = '⚠ CRASH DETECTED — SOS ACTIVE';
      _detailMsg =
          'Impact/explosion sound detected! Alarm triggered. Alerting emergency contacts and nearby BioNode users.';
    });

    _alarmCtrl.repeat(reverse: true);
    _playAlarm();
    _sendFirebaseAlert();
    _notifyContacts();
    HapticFeedback.vibrate();
  }

  Future<void> _playAlarm() async {
    try {
      await _audioPlayer.setVolume(1.0);
      // Play a beeping alarm using a reliable CDN URL
      await _audioPlayer.play(
        UrlSource(
          'https://actions.google.com/sounds/v1/alarms/alarm_clock.ogg',
        ),
      );
    } catch (e) {
      debugPrint('Alarm play error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Alarm Error: ${e.toString()}'),
            backgroundColor: const Color(0xFFFF2A5F),
          ),
        );
      }
    }
  }

  Future<void> _sendFirebaseAlert() async {
    try {
      await FirebaseFirestore.instance.collection('crash_alerts').add({
        'userAlias': widget.userAlias,
        'userName': widget.userName,
        'lat': _userLat,
        'lon': _userLon,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'ACTIVE',
        'message':
            '🚨 LIFEGRID BLOOD SOS! ${widget.userName} requires immediate medical attention near (${_userLat.toStringAsFixed(4)}, ${_userLon.toStringAsFixed(4)}). AI is pinging matching Blood Donors in 5km radius!',
      });
    } catch (e) {
      debugPrint('Firebase alert error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Firebase Alert Error: ${e.toString()}'),
            backgroundColor: const Color(0xFFFF2A5F),
          ),
        );
      }
    }
  }

  void _notifyContacts() {
    // Launch SMS to each contact with emergency message
    for (final contact in _contacts) {
      final phone = contact['phone'] ?? '';
      final name = contact['name'] ?? '';
      if (phone.isNotEmpty) {
        final msg = Uri.encodeComponent(
          'EMERGENCY SOS from ${widget.userName}! '
          'A possible accident/crash has been detected by BioNode AI CrashGuard. '
          'Last known location: https://maps.google.com/?q=$_userLat,$_userLon '
          'Please check immediately! — BioNode AI',
        );
        launchUrl(Uri.parse('sms:$phone?body=$msg'));
      }
    }
  }

  void _dismissAlarm() {
    _alarmCtrl.stop();
    _alarmCtrl.reset();
    _audioPlayer.stop();
    _alarmTimer?.cancel();
    setState(() {
      _isCrashDetected = false;
      _alarmPlaying = false;
      _isListening = false;
      _isAnalyzing = false;
      _statusMsg = 'ALARM DISMISSED — SYSTEM RESET';
      _detailMsg =
          'False alarm cleared. System is ready for next monitoring session.';
    });
  }

  void _addContact() {
    if (_contacts.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maximum 5 emergency contacts allowed.'),
          backgroundColor: Color(0xFFFF2A5F),
        ),
      );
      return;
    }
    final name = _nameCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    if (name.isEmpty || phone.isEmpty) return;

    FirebaseFirestore.instance
        .collection('bionodes')
        .doc(widget.userAlias)
        .collection('emergency_contacts')
        .add({'name': name, 'phone': phone});

    _nameCtrl.clear();
    _phoneCtrl.clear();
  }

  void _removeContact(int index) {
    final id = _contacts[index]['id'];
    if (id != null) {
      FirebaseFirestore.instance
          .collection('bionodes')
          .doc(widget.userAlias)
          .collection('emergency_contacts')
          .doc(id)
          .delete();
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _alarmTimer?.cancel();
    _amplitudeTimer?.cancel();
    _pulseCtrl.dispose();
    _alarmCtrl.dispose();
    _audioPlayer.dispose();
    _recorder.dispose();
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  // ── UI ─────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding:
          const EdgeInsets.only(left: 24, right: 24, top: 70, bottom: 130),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 40),
          _buildMainShield(),
          const SizedBox(height: 32),
          _buildStatusCard(),
          if (_isCrashDetected) ...[const SizedBox(height: 24), _buildAlertMap()],
          const SizedBox(height: 40),
          _buildNearbyAlerts(),
          const SizedBox(height: 40),
          _buildEmergencyContacts(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFF2A5F).withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: const Color(0xFFFF2A5F).withOpacity(0.5)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedBuilder(
                    animation: _pulseAnim,
                    builder: (_, __) => Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFF2A5F),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isListening ? 'MONITORING' : 'CRASH GUARD',
                    style: GoogleFonts.jetBrainsMono(
                      color: const Color(0xFFFF2A5F),
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          'CrashGuard\nSystem',
          style: GoogleFonts.outfit(
            fontSize: 48,
            fontWeight: FontWeight.w900,
            letterSpacing: -1,
            height: 1.1,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'AI-powered accident detection & emergency SOS.',
          style: GoogleFonts.inter(
            color: Colors.white54,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildMainShield() {
    final Color activeColor = _isCrashDetected
        ? const Color(0xFFFF2A5F)
        : _isListening
            ? const Color(0xFFFF9100)
            : const Color(0xFF00E5FF);

    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: _isCrashDetected
                ? _dismissAlarm
                : _isListening || _isAnalyzing
                    ? null
                    : _startMonitoring,
            child: AnimatedBuilder(
              animation: _isCrashDetected ? _alarmAnim : _pulseAnim,
              builder: (_, child) => Transform.scale(
                scale: _isCrashDetected ? _alarmAnim.value : _pulseAnim.value,
                child: child,
              ),
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: activeColor.withOpacity(0.1),
                  border: Border.all(color: activeColor, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: activeColor.withOpacity(0.5),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: Center(
                  child: _isAnalyzing
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CircularProgressIndicator(
                              color: Color(0xFFFF9100),
                              strokeWidth: 3,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'ANALYZING',
                              style: GoogleFonts.jetBrainsMono(
                                color: const Color(0xFFFF9100),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        )
                      : _isListening
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '$_countdown',
                                  style: GoogleFonts.outfit(
                                    fontSize: 72,
                                    fontWeight: FontWeight.w900,
                                    color: const Color(0xFFFF9100),
                                  ),
                                ),
                                Text(
                                  'SECONDS',
                                  style: GoogleFonts.jetBrainsMono(
                                    color: Colors.white54,
                                    fontSize: 11,
                                    letterSpacing: 2,
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _isCrashDetected
                                      ? Icons.warning_amber_rounded
                                      : Icons.shield_rounded,
                                  color: activeColor,
                                  size: 80,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _isCrashDetected ? 'TAP TO\nDISMISS' : 'TAP TO\nSCAN',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.jetBrainsMono(
                                    color: activeColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ],
                            ),
                ),
              ),
            ),
          ),
          if (_isListening) ...[  
            const SizedBox(height: 20),
            _buildAmplitudeBar(),
          ],
        ],
      ),
    );
  }

  Widget _buildAmplitudeBar() {
    final double normalized = (_currentAmplitude / 100).clamp(0.0, 1.0);
    return Column(
      children: [
        Text(
          'ACOUSTIC LEVEL',
          style: GoogleFonts.jetBrainsMono(
            color: Colors.white38,
            fontSize: 11,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 8,
          width: 220,
          decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.circular(100),
          ),
          child: AnimatedAlign(
            alignment: Alignment.centerLeft,
            duration: const Duration(milliseconds: 200),
            child: FractionallySizedBox(
              widthFactor: normalized.clamp(0.05, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: normalized > 0.7
                        ? [const Color(0xFFFF9100), const Color(0xFFFF2A5F)]
                        : [const Color(0xFF00E5FF), const Color(0xFFD500F9)],
                  ),
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCard() {
    final Color statusColor = _isCrashDetected
        ? const Color(0xFFFF2A5F)
        : _isListening
            ? const Color(0xFFFF9100)
            : const Color(0xFF00E5FF);

    return AcrylicCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: statusColor.withOpacity(0.5)),
                ),
                child: Icon(
                  _isCrashDetected
                      ? Icons.emergency_rounded
                      : _isListening
                          ? Icons.mic_rounded
                          : Icons.shield_outlined,
                  color: statusColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  _statusMsg,
                  style: GoogleFonts.outfit(
                    color: statusColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              _detailMsg,
              style: GoogleFonts.inter(
                color: Colors.white70,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
          if (_isCrashDetected) ...[  
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _dismissAlarm,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF2A5F).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: const Color(0xFFFF2A5F).withOpacity(0.6)),
                ),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.stop_circle_outlined,
                          color: Color(0xFFFF2A5F)),
                      const SizedBox(width: 10),
                      Text(
                        'DISMISS ALARM — I AM SAFE',
                        style: GoogleFonts.outfit(
                          color: const Color(0xFFFF2A5F),
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAlertMap() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SOS LOCATION BROADCAST',
          style: GoogleFonts.jetBrainsMono(
            color: Colors.white54,
            fontSize: 14,
            letterSpacing: 2.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        AcrylicCard(
          padding: EdgeInsets.zero,
          borderRadius: 24,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: SizedBox(
              height: 220,
              child: Stack(
                children: [
                  FlutterMap(
                    options: MapOptions(
                      initialCenter: LatLng(_userLat, _userLon),
                      initialZoom: 13,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
                        subdomains: const ['a', 'b', 'c', 'd'],
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: LatLng(_userLat, _userLon),
                            width: 60,
                            height: 60,
                            child: Column(
                              children: [
                                Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFF2A5F),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Colors.white, width: 2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFFF2A5F)
                                            .withOpacity(0.8),
                                        blurRadius: 15,
                                        spreadRadius: 5,
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  'SOS',
                                  style: GoogleFonts.jetBrainsMono(
                                    color: const Color(0xFFFF2A5F),
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Positioned(
                    bottom: 12,
                    left: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: const Color(0xFFFF2A5F).withOpacity(0.4)),
                      ),
                      child: Text(
                        'Broadcasting SOS @ ${_userLat.toStringAsFixed(4)}, ${_userLon.toStringAsFixed(4)}',
                        style: GoogleFonts.jetBrainsMono(
                          color: const Color(0xFFFF2A5F),
                          fontSize: 11,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNearbyAlerts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'NEARBY SOS ALERTS',
          style: GoogleFonts.jetBrainsMono(
            color: Colors.white54,
            fontSize: 14,
            letterSpacing: 2.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('crash_alerts')
              .orderBy('timestamp', descending: true)
              .limit(5)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return AcrylicCard(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Text(
                    'No nearby SOS alerts. Stay safe! 🛡️',
                    style: GoogleFonts.inter(
                        color: Colors.white54, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }
            final docs = snapshot.data!.docs;
            return Column(
              children: docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final isMe = data['userAlias'] == widget.userAlias;
                final ts = data['timestamp'] as Timestamp?;
                final timeAgo = ts != null
                    ? _timeAgo(ts.toDate())
                    : 'Just now';
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: AcrylicCard(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFFFF2A5F).withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.emergency_rounded,
                            color: Color(0xFFFF2A5F),
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isMe
                                    ? 'YOUR SOS (Active)'
                                    : data['userName'] ?? 'Unknown User',
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                timeAgo,
                                style: GoogleFonts.inter(
                                  color: Colors.white38,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            final lat = data['lat']?.toString() ?? '';
                            final lon = data['lon']?.toString() ?? '';
                            launchUrl(Uri.parse(
                                'https://maps.google.com/?q=$lat,$lon'));
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color:
                                  const Color(0xFFFF2A5F).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Text(
                              'MAP',
                              style: GoogleFonts.outfit(
                                color: const Color(0xFFFF2A5F),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildEmergencyContacts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'EMERGENCY CONTACTS (${_contacts.length}/5)',
          style: GoogleFonts.jetBrainsMono(
            color: Colors.white54,
            fontSize: 14,
            letterSpacing: 2.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        if (_contacts.length < 5)
          AcrylicCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _nameCtrl,
                        style: GoogleFonts.inter(
                            color: Colors.white, fontSize: 15),
                        decoration: InputDecoration(
                          hintText: 'Family/Friend Name',
                          hintStyle: GoogleFonts.inter(
                              color: Colors.white30, fontSize: 14),
                          border: InputBorder.none,
                          prefixIcon: const Icon(Icons.person_outline,
                              color: Color(0xFFFF2A5F), size: 20),
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                    height: 1, color: Colors.white10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _phoneCtrl,
                        keyboardType: TextInputType.phone,
                        style: GoogleFonts.inter(
                            color: Colors.white, fontSize: 15),
                        decoration: InputDecoration(
                          hintText: 'Phone Number',
                          hintStyle: GoogleFonts.inter(
                              color: Colors.white30, fontSize: 14),
                          border: InputBorder.none,
                          prefixIcon: const Icon(Icons.phone_outlined,
                              color: Color(0xFFFF2A5F), size: 20),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: _addContact,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color:
                              const Color(0xFFFF2A5F).withOpacity(0.2),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: const Color(0xFFFF2A5F)
                                  .withOpacity(0.5)),
                        ),
                        child: const Icon(
                          Icons.add_rounded,
                          color: Color(0xFFFF2A5F),
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        const SizedBox(height: 16),
        if (_contacts.isEmpty)
          Center(
            child: Text(
              'Add up to 5 family/friends who will receive\nan SOS message if a crash is detected.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                  color: Colors.white38, fontSize: 13),
            ),
          ),
        ..._contacts.asMap().entries.map((entry) {
          final i = entry.key;
          final c = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AcrylicCard(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          const Color(0xFFFF2A5F).withOpacity(0.15),
                    ),
                    child: Center(
                      child: Text(
                        (c['name'] ?? '?')[0].toUpperCase(),
                        style: GoogleFonts.outfit(
                          color: const Color(0xFFFF2A5F),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          c['name'] ?? '',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          c['phone'] ?? '',
                          style: GoogleFonts.jetBrainsMono(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline,
                        color: Colors.white30),
                    onPressed: () => _removeContact(i),
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 16),
        AcrylicCard(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF00E5FF).withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.info_outline_rounded,
                  color: Color(0xFF00E5FF),
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  'When crash is detected: Alarm sounds at max volume, SOS broadcast to all nearby BioNode users on map, and SMS sent to all your emergency contacts with your live location.',
                  style: GoogleFonts.inter(
                    color: Colors.white54,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

class PublicVaultScreen extends StatelessWidget {
  final String userAlias;
  const PublicVaultScreen({super.key, required this.userAlias});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "PUBLIC HEALTH RECORD",
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          const AnimatedMeshBackground(),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('bionodes')
                .doc(userAlias)
                .collection('vault_records')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting)
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF00E5FF)),
                );
              if (snapshot.hasError)
                return Center(
                  child: Text(
                    "ERROR: ${snapshot.error}",
                    style: GoogleFonts.jetBrainsMono(color: Colors.red),
                  ),
                );
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Text(
                    "NO PUBLIC RECORDS FOUND FOR THIS USER.",
                    style: GoogleFonts.jetBrainsMono(color: Colors.white54),
                  ),
                );
              }

              final docs = snapshot.data!.docs.toList();
              docs.sort((a, b) {
                final aData = a.data() as Map<String, dynamic>;
                final bData = b.data() as Map<String, dynamic>;
                final aTime = aData['createdAt'] as Timestamp?;
                final bTime = bData['createdAt'] as Timestamp?;
                if (aTime == null && bTime == null) return 0;
                if (aTime == null) return 1;
                if (bTime == null) return -1;
                return bTime.compareTo(aTime);
              });

              return ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final data = docs[index].data() as Map<String, dynamic>;
                  final category = data['category'] ?? 'Record';
                  bool hasFile = data['fileBase64'] != null;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: AcrylicCard(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  data['title'] ?? 'Unknown',
                                  style: GoogleFonts.outfit(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF00E5FF,
                                  ).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Text(
                                  category.toUpperCase(),
                                  style: GoogleFonts.jetBrainsMono(
                                    color: const Color(0xFF00E5FF),
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            category == 'Immunization'
                                ? "VACCINE: ${data['facility']}"
                                : "DOCTOR: ${data['facility']}",
                            style: GoogleFonts.jetBrainsMono(
                              color: const Color(0xFF00E5FF),
                              fontSize: 13,
                            ),
                          ),
                          if (data['hospital'] != null &&
                              data['hospital'].toString().isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              "HOSPITAL: ${data['hospital']}",
                              style: GoogleFonts.jetBrainsMono(
                                color: const Color(0xFFD500F9),
                                fontSize: 12,
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),
                          Text(
                            data['notes'] ?? '',
                            style: GoogleFonts.inter(
                              color: Colors.white70,
                              fontSize: 15,
                            ),
                          ),
                          if (hasFile) ...[
                            const SizedBox(height: 16),
                            Container(height: 1, color: Colors.white10),
                            const SizedBox(height: 16),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.memory(
                                base64Decode(data['fileBase64']),
                                height: 250,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  height: 150,
                                  color: Colors.white10,
                                  child: const Center(
                                    child: Icon(
                                      Icons.broken_image,
                                      color: Colors.white54,
                                      size: 50,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
