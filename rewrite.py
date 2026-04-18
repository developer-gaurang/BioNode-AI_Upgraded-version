import re

with open('lib/main.dart', 'r', encoding='utf-8') as f:
    code = f.read()

# 1. Replace SpringButton
new_spring_button = """class SpringButton extends StatefulWidget {
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
              colors: [Color(0xFFA855F7), Color(0xFFC084FC)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFA855F7).withOpacity(0.3),
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
}"""
s_btn = re.search(r'class SpringButton extends StatefulWidget \{.*?\n\}\n', code, re.DOTALL).group(0)
code = code.replace(s_btn, new_spring_button + '\n')

# 2. Replace EliteTextField
new_elite_tf = """class EliteTextField extends StatelessWidget {
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
              color: const Color(0xFFA855F7),
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
            color: const Color(0xFF0F0F0F),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFA855F7).withOpacity(0.2),
              width: 1.0,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
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
}"""
e_tf = re.search(r'class EliteTextField extends StatelessWidget \{.*?\n\}\n', code, re.DOTALL).group(0)
code = code.replace(e_tf, new_elite_tf + '\n')

# 3. Replace UnifiedAuthHub build
new_auth_build = """  @override
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
                  Row(
                    children: [
                      Hero(
                        tag: 'core_logo',
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFA855F7).withOpacity(0.1),
                            border: Border.all(
                              color: const Color(0xFFA855F7).withOpacity(0.3),
                            ),
                          ),
                          child: const Icon(
                            Icons.fingerprint,
                            color: Color(0xFFA855F7),
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Create Your BioNode',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Initialize your unique biometric signature and sync with the global eco-health grid.',
                    style: GoogleFonts.inter(
                      color: Colors.white70,
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 48),
                  EliteTextField(
                    controller: _nameCtrl,
                    overline: 'BIOMETRIC IDENTITY',
                    labelText: 'Full Name',
                    icon: Icons.person_outline,
                    hint: 'e.g. Dr. Aria Thorne',
                  ),
                  const SizedBox(height: 24),
                  EliteTextField(
                    controller: _aliasCtrl,
                    overline: 'COMMUNICATION ID',
                    labelText: 'Node Alias',
                    icon: Icons.alternate_email,
                    hint: 'aria.thorne',
                  ),
                  const SizedBox(height: 24),
                  EliteTextField(
                    controller: _passCtrl,
                    overline: 'ENCRYPTION KEY',
                    labelText: 'Password',
                    icon: Icons.lock_outline,
                    hint: '••••••••',
                    isPassword: true,
                  ),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFA855F7).withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFA855F7).withOpacity(0.2)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.shield_outlined, color: Color(0xFFA855F7), size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'AI PREDICTION',
                                style: GoogleFonts.outfit(
                                  color: const Color(0xFFA855F7),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Your data is encrypted using 256-bit Bio-Shield protocols. Only you hold the private key to your Health Vault.',
                                style: GoogleFonts.inter(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  SpringButton(
                    text: _isLoading ? 'INITIALIZING...' : 'INITIALIZE BIONODE ⚡',
                    icon: null,
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
                          text: 'Already have an active node? ',
                          style: GoogleFonts.inter(
                            color: Colors.white54,
                            fontSize: 14,
                          ),
                          children: [
                            TextSpan(
                              text: 'Login',
                              style: GoogleFonts.inter(
                                color: const Color(0xFFA855F7),
                                fontWeight: FontWeight.bold,
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
          if (_isLoading) const QuantumLoader(message: 'INITIALIZING NODE...'),
        ],
      ),
    );
  }"""
u_b_reg = r'  @override\n  Widget build\(BuildContext context\) \{\n    return Scaffold\(\n      body: Stack\(\n        children: \[\n          const AnimatedMeshBackground\(\),\n          SafeArea\(\n            child: SingleChildScrollView\(\n              padding: const EdgeInsets\.symmetric\([\s\S]*?if \(_isLoading\) const QuantumLoader\(message: \'INITIALIZING NODE...\'\),\n        \],\n      \),\n    \);\n  \}'
code = re.sub(u_b_reg, new_auth_build, code)

# 4. Replace LoginScreen build
new_login_build = """  @override
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
                    Center(
                      child: Column(
                        children: [
                          Hero(
                            tag: 'core_logo',
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFFA855F7).withOpacity(0.1),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.fingerprint,
                                  color: Color(0xFFA855F7),
                                  size: 40,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'BioNode AI',
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.verified_user, color: Color(0xFF00FFCC), size: 14),
                              const SizedBox(width: 6),
                              Text(
                                'QUANTUM SECURE',
                                style: GoogleFonts.jetBrainsMono(
                                  color: const Color(0xFF00FFCC),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 48),
                    EliteTextField(
                      controller: _aliasCtrl,
                      overline: 'NEURAL IDENTITY',
                      labelText: '',
                      icon: Icons.alternate_email,
                      hint: 'Enter your bio-node alias',
                    ),
                    const SizedBox(height: 24),
                    EliteTextField(
                      controller: _passCtrl,
                      overline: 'QUANTUM KEY',
                      labelText: '',
                      icon: Icons.security_outlined,
                      hint: 'Enter security password',
                      isPassword: true,
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'Forgot Quantum Key?',
                        style: GoogleFonts.inter(
                          color: Colors.white54,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 48),
                    SpringButton(
                      text: _isLoading ? 'DECRYPTING KEY...' : 'Access BioNode',
                      icon: _isLoading ? Icons.sync : Icons.arrow_forward_ios,
                      onTap: _isLoading ? () {} : _loginNode,
                    ),
                    const SizedBox(height: 32),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFA855F7).withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFA855F7).withOpacity(0.2)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.shield_outlined, color: Color(0xFFA855F7), size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'IN PRODUCTION',
                                  style: GoogleFonts.outfit(
                                    color: const Color(0xFFA855F7),
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Multi-factor biometric sync is active. Your session will be monitored for anomalous behavior patterns.',
                                  style: GoogleFonts.inter(
                                    color: Colors.white70,
                                    fontSize: 12,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_isLoading) const QuantumLoader(message: 'DECRYPTING NODE...'),
        ],
      ),
    );
  }"""
l_b_reg = r'  @override\n  Widget build\(BuildContext context\) \{\n    return Scaffold\(\n      body: Stack\(\n        children: \[\n          const AnimatedMeshBackground\(\),\n          SafeArea\(\n            child: Positioned\([\s\S]*?if \(_isLoading\) const QuantumLoader\(message: \'DECRYPTING NODE...\'\),\n        \],\n      \),\n    \);\n  \}'
code = re.sub(l_b_reg, new_login_build, code)

with open('lib/main.dart', 'w', encoding='utf-8') as f:
    f.write(code)

print("Rewritten successfully")
