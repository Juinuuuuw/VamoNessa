import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _birthDateController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final user = User(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: _emailController.text.trim(),
      birthDate: _birthDateController.text.trim(),
      phone: _phoneController.text.trim(),
    );

    final result = await _authService.register(user, _passwordController.text);

    setState(() => _isLoading = false);

    if (result['success']) {
      // Cadastro bem-sucedido – navegue para Login ou Home
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Conta criada com sucesso!')),
      );
      Navigator.pop(context); // volta para a tela de login
    } else {
      setState(() => _errorMessage = result['message']);
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'E-mail obrigatório';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) return 'E-mail inválido';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Senha obrigatória';
    if (value.length < 6) return 'A senha deve ter pelo menos 6 caracteres';
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) return 'Telefone obrigatório';
    // Aceita formatos como (99) 99999-9999 ou 999999999
    final phoneRegex = RegExp(r'^\(?\d{2}\)?\s?\d{4,5}-?\d{4}$');
    if (!phoneRegex.hasMatch(value)) return 'Telefone inválido';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                const Text(
                  'Sign Up',
                  style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Create an account to continue!',
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 40),

                // First Name
                TextFormField(
                  controller: _firstNameController,
                  decoration: _inputDecoration('First Name'),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Nome obrigatório' : null,
                ),
                const SizedBox(height: 16),

                // Last Name
                TextFormField(
                  controller: _lastNameController,
                  decoration: _inputDecoration('Last Name'),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Sobrenome obrigatório' : null,
                ),
                const SizedBox(height: 16),

                // E-mail
                TextFormField(
                  controller: _emailController,
                  decoration: _inputDecoration('E-mail'),
                  keyboardType: TextInputType.emailAddress,
                  validator: _validateEmail,
                ),
                const SizedBox(height: 16),

                // Birth Date
                TextFormField(
                  controller: _birthDateController,
                  decoration: _inputDecoration(
                    'Birth Date',
                    hint: 'DD/MM/YYYY',
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Data obrigatória' : null,
                ),
                const SizedBox(height: 16),

                // Phone Number
                TextFormField(
                  controller: _phoneController,
                  decoration: _inputDecoration('Phone Number'),
                  keyboardType: TextInputType.phone,
                  validator: _validatePhone,
                ),
                const SizedBox(height: 16),

                // Password
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: _inputDecoration('Password'),
                  validator: _validatePassword,
                ),
                const SizedBox(height: 8),

                // Mensagem de erro
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),

                const SizedBox(height: 32),

                // Botão Register
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _register,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Register',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 24),

                // Login link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account? ",
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Login',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
