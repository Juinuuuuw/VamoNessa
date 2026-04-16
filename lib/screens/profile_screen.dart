// lib/screens/profile_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/user_service.dart';
import '../services/event_service.dart';
import '../services/accessibility_settings.dart';
import '../models/user.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserService _userService = UserService();
  final EventService _eventService = EventService();
  final ImagePicker _picker = ImagePicker();

  int _currentNavIndex = 2; // Aba "PERFIL"
  bool _isLoading = false;
  bool _isUploading = false;

  UserModel? _user;
  int _eventCount = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _loadUser();
    await _loadEventCount();
  }

  Future<void> _loadUser() async {
    final user = await _userService.getCurrentUser();
    if (mounted) setState(() => _user = user);
  }

  Future<void> _loadEventCount() async {
    try {
      final events = await _eventService.getUserEvents().first;
      if (mounted) setState(() => _eventCount = events.length);
    } catch (e) {
      print('Erro ao carregar contagem de eventos: $e');
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    setState(() => _isUploading = true);
    try {
      final newUrl = await _userService.uploadProfilePicture(image);
      setState(() {
        _user = UserModel(
          uid: _user!.uid,
          email: _user!.email,
          firstName: _user!.firstName,
          lastName: _user!.lastName,
          photoUrl: newUrl,
        );
        _isUploading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto atualizada!')),
      );
    } catch (e) {
      setState(() => _isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao enviar foto: $e')),
      );
    }
  }

  void _showEditProfileModal() {
    final firstNameController = TextEditingController(text: _user?.firstName);
    final lastNameController = TextEditingController(text: _user?.lastName);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 24,
          right: 24,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Editar Perfil', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            TextField(
              controller: firstNameController,
              decoration: const InputDecoration(labelText: 'Nome', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: lastNameController,
              decoration: const InputDecoration(labelText: 'Sobrenome', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final firstName = firstNameController.text.trim();
                  final lastName = lastNameController.text.trim();
                  if (firstName.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Nome obrigatório')),
                    );
                    return;
                  }
                  Navigator.pop(context);
                  setState(() => _isLoading = true);
                  try {
                    await _userService.updateName(firstName, lastName);
                    await _loadUser();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Perfil atualizado!')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erro: $e')),
                    );
                  } finally {
                    setState(() => _isLoading = false);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B80F9),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Salvar'),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ========== MODAL DE ACESSIBILIDADE (TEXT SCALING + HIGH CONTRAST) ==========
  void _showAccessibilityModal() {
    double tempScale = AccessibilitySettings.textScaleNotifier.value;
    bool tempHighContrast = AccessibilitySettings.highContrastNotifier.value;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final isHighContrast = tempHighContrast;
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isHighContrast ? Colors.black : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: isHighContrast ? Colors.yellow : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Acessibilidade',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: isHighContrast ? Colors.yellow : const Color(0xFF2D2D2D),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ajuste o tamanho da fonte e ative o alto contraste.',
                    style: TextStyle(
                      color: isHighContrast ? Colors.white70 : Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ---- Slider para tamanho da fonte ----
                  Text(
                    'Tamanho da Fonte',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: isHighContrast ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.text_fields,
                        color: isHighContrast ? Colors.yellow : const Color(0xFF8B80F9),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Slider(
                          value: tempScale,
                          min: 0.8,
                          max: 1.5,
                          divisions: 7,
                          label: '${tempScale.toStringAsFixed(1)}x',
                          onChanged: (value) => setState(() => tempScale = value),
                          activeColor: const Color(0xFF8B80F9),
                          inactiveColor: isHighContrast ? Colors.grey.shade700 : Colors.grey.shade300,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isHighContrast ? Colors.yellow : const Color(0xFFF0F4FF),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${tempScale.toStringAsFixed(1)}x',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isHighContrast ? Colors.black : const Color(0xFF8B80F9),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ---- Switch para Alto Contraste ----
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Alto Contraste',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: isHighContrast ? Colors.white : Colors.black87,
                      ),
                    ),
                    subtitle: Text(
                      'Fundo escuro com cores de alto contraste',
                      style: TextStyle(
                        color: isHighContrast ? Colors.white70 : Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                    value: tempHighContrast,
                    onChanged: (value) => setState(() => tempHighContrast = value),
                    activeColor: const Color(0xFF8B80F9),
                    activeTrackColor: const Color(0xFF8B80F9).withOpacity(0.5),
                  ),
                  const SizedBox(height: 32),

                  // ---- Botões ----
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              tempScale = 1.0;
                              tempHighContrast = false;
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: isHighContrast ? Colors.yellow : Colors.grey.shade400),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Text(
                            'Resetar',
                            style: TextStyle(
                              color: isHighContrast ? Colors.yellow : Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            await AccessibilitySettings.setTextScale(tempScale);
                            await AccessibilitySettings.setHighContrast(tempHighContrast);
                            if (mounted) Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8B80F9),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text(
                            'Aplicar',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _logout() async {
    await _userService.signOut();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isHighContrast = AccessibilitySettings.isHighContrast(context);
    return Container(
      decoration: BoxDecoration(
        gradient: isHighContrast
            ? null
            : const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFF7DFCA), Color(0xFFE8E2FF), Color(0xFFD4C8FF)],
              ),
        color: isHighContrast ? Colors.black : null,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBody: true,
        body: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Avatar
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: isHighContrast ? Colors.yellow : Colors.white, width: 4),
                          boxShadow: isHighContrast
                              ? []
                              : [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 15,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                        ),
                        child: CircleAvatar(
                          radius: 56,
                          backgroundColor: isHighContrast ? Colors.grey.shade800 : Colors.grey.shade200,
                          backgroundImage: _user?.photoUrl != null && _user!.photoUrl!.isNotEmpty
                              ? NetworkImage(_user!.photoUrl!)
                              : const NetworkImage('https://www.gravatar.com/avatar/00000000000000000000000000000000?d=mp&f=y')
                                  as ImageProvider,
                          child: _isUploading
                              ? Container(
                                  color: Colors.black26,
                                  child: const CircularProgressIndicator(color: Colors.white),
                                )
                              : null,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: isHighContrast ? Colors.yellow : const Color(0xFF8B80F9),
                          shape: BoxShape.circle,
                          border: Border.all(color: isHighContrast ? Colors.black : Colors.white, width: 2),
                        ),
                        child: Icon(
                          Icons.camera_alt,
                          color: isHighContrast ? Colors.black : Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  _user?.displayName ?? 'Carregando...',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: isHighContrast ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _user?.email ?? '',
                  style: TextStyle(
                    fontSize: 14,
                    color: isHighContrast ? Colors.white70 : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _showEditProfileModal,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isHighContrast ? Colors.yellow : const Color(0xFF8B80F9),
                    foregroundColor: isHighContrast ? Colors.black : Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  child: const Text(
                    'Edit Profile',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 32),

                // Card de eventos (contagem real)
                Container(
                  width: 160,
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  decoration: BoxDecoration(
                    color: isHighContrast ? Colors.grey.shade900 : Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: isHighContrast
                        ? []
                        : [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isHighContrast ? Colors.yellow : const Color(0xFFE8E2FF),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.calendar_month,
                          color: isHighContrast ? Colors.black : const Color(0xFF8B80F9),
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '$_eventCount',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: isHighContrast ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'EVENTOS',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isHighContrast ? Colors.white70 : Colors.grey.shade500,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // Preferências
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'PREFERÊNCIAS',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isHighContrast ? Colors.yellow : Colors.grey.shade600,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Container(
                  decoration: BoxDecoration(
                    color: isHighContrast ? Colors.grey.shade900 : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: isHighContrast
                        ? []
                        : [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                  ),
                  child: Column(
                    children: [
                      _buildPreferenceItem(
                        icon: Icons.accessibility_new_rounded,
                        title: 'Acessibilidade',
                        isHighContrast: isHighContrast,
                        onTap: _showAccessibilityModal,
                      ),
                      Divider(
                        height: 1,
                        color: isHighContrast ? Colors.grey.shade700 : Colors.grey.shade100,
                        indent: 64,
                      ),
                      _buildPreferenceItem(
                        icon: Icons.help_outline_rounded,
                        title: 'Ajuda',
                        isHighContrast: isHighContrast,
                        onTap: () {},
                      ),
                      Divider(
                        height: 1,
                        color: isHighContrast ? Colors.grey.shade700 : Colors.grey.shade100,
                        indent: 64,
                      ),
                      _buildPreferenceItem(
                        icon: Icons.logout_rounded,
                        title: 'Sair',
                        isDestructive: true,
                        isHighContrast: isHighContrast,
                        onTap: _logout,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 120),
              ],
            ),
          ),
        ),
        bottomNavigationBar: _buildCustomBottomNav(isHighContrast),
      ),
    );
  }

  Widget _buildPreferenceItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
    required bool isHighContrast,
  }) {
    final Color itemColor = isDestructive
        ? (isHighContrast ? Colors.redAccent : Colors.red.shade400)
        : (isHighContrast ? Colors.white : Colors.black87);
    final Color iconBgColor = isDestructive
        ? (isHighContrast ? Colors.red.shade900 : Colors.red.shade50)
        : (isHighContrast ? Colors.grey.shade800 : Colors.grey.shade100);
    final Color iconColor = isDestructive
        ? (isHighContrast ? Colors.redAccent : Colors.red.shade400)
        : (isHighContrast ? Colors.yellow : Colors.grey.shade600);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: iconBgColor, shape: BoxShape.circle),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(
        title,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: itemColor),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios_rounded,
        size: 16,
        color: isDestructive
            ? (isHighContrast ? Colors.redAccent : Colors.red.shade300)
            : (isHighContrast ? Colors.white70 : Colors.grey.shade400),
      ),
      onTap: onTap,
    );
  }

  Widget _buildCustomBottomNav(bool isHighContrast) {
    return Container(
      padding: const EdgeInsets.only(top: 16, bottom: 32, left: 32, right: 32),
      decoration: BoxDecoration(
        gradient: isHighContrast
            ? null
            : const LinearGradient(
                colors: [Color(0xFFFDFBFF), Color(0xFFF6F3FF)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
        color: isHighContrast ? Colors.black : null,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40)),
        boxShadow: isHighContrast
            ? []
            : [
                BoxShadow(
                  color: const Color(0xFF8B80F9).withOpacity(0.08),
                  blurRadius: 24,
                  offset: const Offset(0, -5),
                ),
              ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(Icons.calendar_month, 'EVENTOS', 0, isHighContrast),
          _buildNavItem(Icons.add_circle_outline, 'CRIAR', 1, isHighContrast),
          _buildNavItem(Icons.person_outline, 'PERFIL', 2, isHighContrast),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index, bool isHighContrast) {
    bool isActive = _currentNavIndex == index;
    return GestureDetector(
      onTap: () {
        if (index == 0) {
          Navigator.pushReplacementNamed(context, '/main');
        } else if (index == 1) {
          Navigator.pushNamed(context, '/create_event');
        } else if (index == 2) {
          // já está na tela de perfil
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive
                ? (isHighContrast ? Colors.yellow : const Color(0xFF8B80F9))
                : (isHighContrast ? Colors.white70 : Colors.grey.shade400),
            size: 26,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive
                  ? (isHighContrast ? Colors.yellow : const Color(0xFF8B80F9))
                  : (isHighContrast ? Colors.white70 : Colors.grey.shade400),
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}