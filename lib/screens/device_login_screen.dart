import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kpos/main.dart';

// IMPORTANT: Keep your actual service import here
// import '../services/device_auth_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Device Auth UI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(brightness: Brightness.dark),

      // 1. Define the initial screen
      home: const DeviceLoginScreen(),

      // 2. REGISTER YOUR ROUTES HERE
      // This is what fixes the "Could not find a generator" error
      routes: {'/Home': (context) => const MainLayout()},
    );
  }
}

// ─── Placeholder Home Screen ────────────────────────────────────────────────
// This is where the app goes after a successful login or bypass.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F13),
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: const Color(0xFF18181F),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.verified_user_rounded,
              color: Color(0xFF4ECDC4),
              size: 80,
            ),
            const SizedBox(height: 20),
            const Text(
              'Welcome to the Secure Area',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
            const SizedBox(height: 40),
            TextButton(
              onPressed: () => Navigator.of(context).pushReplacementNamed('/'),
              child: const Text('Sign Out'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Your Device Login Screen ───────────────────────────────────────────────
class DeviceLoginScreen extends StatefulWidget {
  const DeviceLoginScreen({super.key});

  @override
  State<DeviceLoginScreen> createState() => _DeviceLoginScreenState();
}

class _DeviceLoginScreenState extends State<DeviceLoginScreen>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Note: I've commented out the service call so the code compiles
  // without your external service file, but left the logic intact.
  // final _service = DeviceAuthService();

  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  late AnimationController _animController;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;

  // Palette
  static const _bg = Color(0xFF0F0F13);
  static const _surface = Color(0xFF18181F);
  static const _border = Color(0xFF252530);
  static const _primary = Color(0xFF6C63FF);
  static const _accent = Color(0xFF4ECDC4);
  static const _textHigh = Color(0xFFF0EEFF);
  static const _textMid = Color(0xFF9090B0);
  static const _textLow = Color(0xFF4A4A72);
  static const _devBg = Color(0xFF13131A);
  static const _devBorder = Color(0xFF2A2A3E);

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeIn = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideUp = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
        );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    _setLoading(true);
    try {
      // await _service.signIn(...)
      Navigator.of(context).pushReplacementNamed('/login');
    } catch (e) {
      _setError('An error occurred: $e');
    } finally {
      _setLoading(false);
    }
  }

  void _devBypass() {
    Navigator.of(context).pushReplacementNamed('/home');
  }

  void _setLoading(bool v) => setState(() => _isLoading = v);
  void _setError(String? msg) => setState(() => _errorMessage = msg);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          _blob(top: -80, right: -60, color: _primary, size: 260),
          _blob(bottom: 60, left: -80, color: _accent, size: 220),
          Center(
            child: FadeTransition(
              opacity: _fadeIn,
              child: SlideTransition(
                position: _slideUp,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 40,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 380),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 36),
                        if (_errorMessage != null) ...[
                          _buildError(),
                          const SizedBox(height: 16),
                        ],
                        _buildField(
                          controller: _emailController,
                          hint: 'Email address',
                          icon: Icons.mail_outline_rounded,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 10),
                        _buildPasswordField(),
                        const SizedBox(height: 22),
                        _buildLoginButton(),
                        const SizedBox(height: 10),
                        _buildRegisterButton(),
                        const SizedBox(height: 22),
                        _buildDivider(),
                        const SizedBox(height: 14),
                        _buildDevButton(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Widget Builders ---

  Widget _blob({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required Color color,
    required double size,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: IgnorePointer(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.12),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(colors: [_primary, _accent]),
            boxShadow: [
              BoxShadow(
                color: _primary.withOpacity(0.35),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.devices_rounded,
            color: Colors.white,
            size: 28,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Device Auth',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: _textHigh,
          ),
        ),
        const Text(
          'SECURE ACCESS PORTAL',
          style: TextStyle(fontSize: 10, letterSpacing: 2.5, color: _textLow),
        ),
      ],
    );
  }

  Widget _buildError() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E0F0F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF5A2020)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Color(0xFFE24B4A),
            size: 16,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _errorMessage!,
              style: const TextStyle(color: Color(0xFFE24B4A), fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: _textHigh, fontSize: 13),
      decoration: _inputDecoration(hint, icon),
    );
  }

  Widget _buildPasswordField() {
    return TextField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      style: const TextStyle(color: _textHigh, fontSize: 13),
      decoration: _inputDecoration('Password', Icons.lock_outline_rounded)
          .copyWith(
            suffixIcon: IconButton(
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: _textLow,
                size: 18,
              ),
            ),
          ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: _textLow, fontSize: 13),
      prefixIcon: Icon(icon, color: _textLow, size: 18),
      filled: true,
      fillColor: _surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _primary, width: 1.5),
      ),
    );
  }

  Widget _buildLoginButton() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [_primary, _accent]),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: _primary.withOpacity(0.3),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _login,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          _isLoading ? 'Signing in...' : 'Sign In',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterButton() {
    return OutlinedButton(
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: _border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        foregroundColor: _textMid,
      ),
      child: const Text('Create account'),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(child: Divider(color: Color(0xFF1E1E28))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            'DEV ACCESS',
            style: TextStyle(fontSize: 9, color: _textLow.withOpacity(0.6)),
          ),
        ),
        const Expanded(child: Divider(color: Color(0xFF1E1E28))),
      ],
    );
  }

  Widget _buildDevButton() {
    return OutlinedButton.icon(
      onPressed: _devBypass,
      icon: const Icon(Icons.bug_report_outlined, size: 16),
      label: const Text(
        'Developer bypass — skip auth',
        style: TextStyle(fontSize: 11),
      ),
      style: OutlinedButton.styleFrom(
        backgroundColor: _devBg,
        foregroundColor: _textLow,
        side: const BorderSide(color: _devBorder),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
