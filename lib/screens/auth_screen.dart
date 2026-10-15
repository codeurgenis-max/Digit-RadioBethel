import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';
import '../providers/church_provider.dart';
import '../utils/app_colors.dart';
import 'home_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true;
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('remember_email');
    final savedPassword = prefs.getString('remember_password');
    if (savedEmail != null && savedPassword != null) {
      setState(() {
        _emailController.text = savedEmail;
        _passwordController.text = savedPassword;
        _rememberMe = true;
      });
    }
  }

  Future<void> _saveCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      await prefs.setString('remember_email', _emailController.text.trim());
      await prefs.setString('remember_password', _passwordController.text.trim());
    } else {
      await prefs.remove('remember_email');
      await prefs.remove('remember_password');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<ChurchProvider>();
    bool success;

    if (_isLogin) {
      success = await provider.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
    } else {
      success = await provider.register(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
    }

    if (success && mounted) {
      await _saveCredentials();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isLogin ? 'Échec de la connexion' : "Échec de l'inscription"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image with Gradient Overlay
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(
                  'https://images.unsplash.com/photo-1438232992991-995b7058bbb3?ixlib=rb-4.0.3&auto=format&fit=crop&w=1200&q=80',
                ),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    const Color(0xFF0F172A).withOpacity(0.9), // Slate-900
                  ],
                ),
              ),
            ),
          ),
          // Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  // Logo & Motto
                  AnimationConfiguration.synchronized(
                    duration: const Duration(seconds: 1),
                    child: FadeInAnimation(
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                                width: 2,
                              ),
                            ),
                            child: Image.asset(
                              'assets/logo_new.png',
                              height: 120,
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Votre communauté, partout, tout le temps.',
                            style: GoogleFonts.inter(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 60),
                  // Glassmorphism Form Container
                  AnimationConfiguration.synchronized(
                    duration: const Duration(milliseconds: 800),
                    child: FadeInAnimation(
                      child: Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.12),
                            width: 1.5,
                          ),
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                _isLogin ? 'Connexion' : 'Inscription',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 32),
                              if (!_isLogin) ...[
                                _buildTextField(
                                  label: 'Nom complet',
                                  icon: Icons.person_outline_rounded,
                                  controller: _nameController,
                                  validator: (v) => (v == null || v.isEmpty) ? 'Entrez votre nom' : null,
                                ),
                                const SizedBox(height: 20),
                              ],
                              _buildTextField(
                                label: 'Email',
                                icon: Icons.alternate_email_rounded,
                                keyboardType: TextInputType.emailAddress,
                                controller: _emailController,
                                validator: (v) => (v == null || v.isEmpty || !v.contains('@')) ? 'Email invalide' : null,
                              ),
                              const SizedBox(height: 20),
                                _buildTextField(
                                  label: 'Mot de passe',
                                  icon: Icons.lock_outline_rounded,
                                  isPassword: true,
                                  controller: _passwordController,
                                  validator: (v) => (v == null || v.length < 6) ? 'Minimum 6 caractères' : null,
                                ),
                                const SizedBox(height: 12),
                                // Remember Me Checkbox
                                Theme(
                                  data: ThemeData(unselectedWidgetColor: Colors.white70),
                                  child: CheckboxListTile(
                                    contentPadding: EdgeInsets.zero,
                                    title: Text(
                                      'Se souvenir de moi',
                                      style: GoogleFonts.inter(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                    value: _rememberMe,
                                    activeColor: AppColors.orange500,
                                    checkColor: Colors.white,
                                    onChanged: (v) => setState(() => _rememberMe = v ?? false),
                                    controlAffinity: ListTileControlAffinity.leading,
                                  ),
                                ),
                                const SizedBox(height: 20),
                              Consumer<ChurchProvider>(
                                builder: (context, provider, _) {
                                  return ElevatedButton(
                                    onPressed: provider.isLoading ? null : _submit,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF000000),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 18),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: provider.isLoading
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : Text(
                                            _isLogin ? 'Se connecter' : 'Créer un compte',
                                            style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Toggle Login/Signup
                  TextButton(
                    onPressed: () => setState(() => _isLogin = !_isLogin),
                    child: RichText(
                      text: TextSpan(
                        text: _isLogin
                            ? "Vous n'avez pas de compte ? "
                            : "Vous avez déjà un compte ? ",
                        style: GoogleFonts.inter(color: Colors.white70),
                        children: [
                          TextSpan(
                            text: _isLogin ? "S'inscrire" : "Se connecter",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    bool isPassword = false,
    TextInputType? keyboardType,
    TextEditingController? controller,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          obscureText: isPassword && _obscurePassword,
          keyboardType: keyboardType,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.white54, size: 20),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: Colors.white54,
                      size: 20,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  )
                : null,
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.orange500, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
