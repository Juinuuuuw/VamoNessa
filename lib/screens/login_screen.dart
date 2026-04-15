import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'signup_screen.dart';
import 'main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  String? _errorMessage;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final User? user = await _authService.signIn(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (user != null && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Erro ao fazer login.';
      if (e.code == 'user-not-found') {
        message = 'Nenhum usuário encontrado com este e-mail.';
      } else if (e.code == 'wrong-password') {
        message = 'Senha incorreta.';
      } else if (e.code == 'invalid-email') {
        message = 'E-mail inválido.';
      } else if (e.code == 'user-disabled') {
        message = 'Este usuário foi desativado.';
      }
      setState(() => _errorMessage = message);
    } catch (e) {
      setState(() => _errorMessage = 'Ocorreu um erro inesperado.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        // Gradiente de fundo suave já padronizado
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF7DFCA), // Bege claro
              Color(0xFFE8E2FF), // Lilás médio
              Color(0xFFD4C8FF), // Roxo suave
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Ícone com a cor pastel do sistema (mesmo do SignUp)
                    const Icon(Icons.auto_awesome_outlined, size: 44, color: Color(0xFF9575CD)),
                    const SizedBox(height: 16),
                    const Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 28, 
                        fontWeight: FontWeight.bold, 
                        color: Color(0xFF2D2D2D),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Enter your email and password to log in',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 32),
                    _buildTextField(
                      controller: _emailController,
                      label: 'E-mail',
                      validator: (v) => v!.isEmpty ? 'E-mail obrigatório' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _passwordController,
                      label: 'Password',
                      obscureText: true,
                      suffixIcon: const Icon(Icons.visibility_off_outlined, size: 20, color: Colors.grey),
                      validator: (v) => v!.isEmpty ? 'Senha obrigatória' : null,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: Checkbox(
                                value: _rememberMe,
                                activeColor: const Color(0xFF8B80F9), // Checkbox na cor do sistema
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                onChanged: (value) => setState(() => _rememberMe = value ?? false),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text('Remember me', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text(
                            'Forgot Password?', 
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF8B80F9)) // Cor pastel
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8B80F9), // Botão na cor roxo pastel principal
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: _isLoading 
                          ? const CircularProgressIndicator(color: Colors.white) 
                          : const Text('Log In', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text('Or login with', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _SocialIcon(icon: Icons.g_mobiledata, color: Colors.red.shade400),
                        _SocialIcon(icon: Icons.facebook, color: Colors.blue.shade400),
                        _SocialIcon(icon: Icons.apple, color: Colors.black87),
                        _SocialIcon(icon: Icons.phone_android, color: Colors.grey.shade600),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don't have an account? ", style: TextStyle(fontSize: 13, color: Colors.grey)),
                        GestureDetector(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUpScreen())),
                          child: const Text(
                            "Sign Up", 
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF8B80F9)) // Cor pastel
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        hintText: label,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        filled: true,
        fillColor: Colors.white.withOpacity(0.5), // Fundo suavizado como no signup
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade100),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade100),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFD4C8FF)), // Borda focada na cor pastel
        ),
      ),
    );
  }
}

class _SocialIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  const _SocialIcon({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Icon(icon, color: color, size: 28),
    );
  }
}
