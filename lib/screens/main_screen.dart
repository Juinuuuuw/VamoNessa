// lib/screens/main_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/event.dart';
import '../services/auth_service.dart';
import '../services/event_service.dart';
import '../services/participant_service.dart';
import '../services/accessibility_settings.dart';
import 'event_details_screen.dart';
import 'final_event_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentNavIndex = 0;
  String _userName = '';
  final AuthService _authService = AuthService();
  final EventService _eventService = EventService();
  
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null && mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists && mounted) {
        final data = doc.data();
        setState(() {
          _userName = data?['first_name'] ?? user.email?.split('@').first ?? 'Usuário';
        });
      } else {
        setState(() {
          _userName = user.email?.split('@').first ?? 'Usuário';
        });
      }
    } catch (e) {
      setState(() {
        _userName = user.email?.split('@').first ?? 'Usuário';
      });
    }
  }

  String _getDaysLeftText(DateTime targetDate) {
    final now = DateTime.now();
    final difference = targetDate.difference(now).inDays;
    if (difference > 1) return 'Faltam $difference dias';
    if (difference == 1) return 'Falta 1 dia';
    if (difference == 0) return 'É hoje!';
    return 'Encerrado';
  }

  @override
  Widget build(BuildContext context) {
    final isHighContrast = AccessibilitySettings.isHighContrast(context);
    return Container(
      decoration: BoxDecoration(
        gradient: isHighContrast ? null : const LinearGradient(
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
            padding: const EdgeInsets.all(20.0),
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
                          Text(
                            'Olá, $_userName 👋',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: isHighContrast ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Pronto(a) para o próximo evento?",
                            style: TextStyle(
                              fontSize: 13,
                              color: isHighContrast ? Colors.white70 : Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: isHighContrast ? Colors.yellow : null,
                      backgroundImage: const NetworkImage(
                        'https://images.unsplash.com/photo-1534528741775-53994a69daEB?ixlib=rb-1.2.1&auto=format&fit=crop&w=256&q=80',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  decoration: BoxDecoration(
                    color: isHighContrast ? Colors.grey.shade900 : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: TextStyle(color: isHighContrast ? Colors.white : Colors.black87),
                    decoration: InputDecoration(
                      hintText: 'Buscar eventos...',
                      hintStyle: TextStyle(color: isHighContrast ? Colors.white70 : Colors.grey.shade400),
                      prefixIcon: Icon(Icons.search, color: isHighContrast ? Colors.yellow : Colors.grey.shade400),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear, color: isHighContrast ? Colors.yellow : Colors.grey.shade400),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: _PillActionButton(
                        icon: Icons.add,
                        label: 'Criar Evento',
                        backgroundColor: isHighContrast ? Colors.yellow : const Color(0xFFE8E2FF),
                        contentColor: isHighContrast ? Colors.black : const Color(0xFF6B5DE8),
                        onTap: () => Navigator.pushNamed(context, '/create_event'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _PillActionButton(
                        icon: Icons.group_add_outlined,
                        label: 'Participar',
                        backgroundColor: isHighContrast ? Colors.cyan : const Color(0xFFFFF0E3),
                        contentColor: isHighContrast ? Colors.black : const Color(0xFFE58A3E),
                        onTap: () => Navigator.pushNamed(context, '/join'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Text(
                  'Seus Eventos',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isHighContrast ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                StreamBuilder<List<Event>>(
                  stream: _eventService.getUserEvents(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: Padding(padding: EdgeInsets.all(32.0), child: CircularProgressIndicator()));
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Erro ao carregar eventos.', style: TextStyle(color: isHighContrast ? Colors.white : Colors.black87)));
                    }
                    final allEvents = snapshot.data ?? [];
                    final filteredEvents = _searchQuery.isEmpty
                        ? allEvents
                        : allEvents.where((event) => event.title.toLowerCase().contains(_searchQuery)).toList();
                    if (filteredEvents.isEmpty) {
                      return _buildEmptyState(_searchQuery.isNotEmpty, isHighContrast);
                    }
                    return Column(
                      children: filteredEvents.map((event) => _buildEventCard(event, isHighContrast)).toList(),
                    );
                  },
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

  Widget _buildEmptyState(bool isSearch, bool isHighContrast) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isHighContrast ? Colors.grey.shade900 : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(isSearch ? Icons.search_off : Icons.event_busy, size: 64, color: isHighContrast ? Colors.white70 : Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              isSearch ? 'Nenhum evento encontrado.' : 'Você ainda não tem eventos.',
              style: TextStyle(fontSize: 16, color: isHighContrast ? Colors.white70 : Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventCard(Event event, bool isHighContrast) {
    Color badgeColor;
    Color badgeTextColor;
    String badgeText;
    switch (event.status) {
      case 'voting':
        badgeColor = isHighContrast ? Colors.yellow : Colors.white.withOpacity(0.95);
        badgeTextColor = isHighContrast ? Colors.black : const Color(0xFF1976D2);
        badgeText = 'EM VOTAÇÃO';
        break;
      case 'confirmed':
        badgeColor = isHighContrast ? Colors.lightGreen : const Color(0xFF2DCC70);
        badgeTextColor = isHighContrast ? Colors.black : Colors.white;
        badgeText = 'CONFIRMADO';
        break;
      default:
        badgeColor = isHighContrast ? Colors.cyan : Colors.white.withOpacity(0.95);
        badgeTextColor = isHighContrast ? Colors.black : const Color(0xFF8B80F9);
        badgeText = 'PLANEJANDO';
    }
    final daysLeftText = _getDaysLeftText(event.startDate);
    return _EventCard(
      eventId: event.id,
      imageUrl: event.imageUrl.isNotEmpty ? event.imageUrl : 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?ixlib=rb-1.2.1&auto=format&fit=crop&w=600&q=80',
      title: event.title,
      timeText: daysLeftText,
      badgeText: badgeText,
      badgeColor: badgeColor,
      badgeTextColor: badgeTextColor,
      isHighContrast: isHighContrast,
      onTap: () {
        if (event.status == 'confirmed') {
          Navigator.push(context, MaterialPageRoute(builder: (context) => FinalEventScreen(eventId: event.id)));
        } else {
          Navigator.pushNamed(context, '/inside_event', arguments: event.id);
        }
      },
    );
  }

  Widget _buildCustomBottomNav(bool isHighContrast) {
    return Container(
      padding: const EdgeInsets.only(top: 16, bottom: 32, left: 32, right: 32),
      decoration: BoxDecoration(
        gradient: isHighContrast ? null : const LinearGradient(colors: [Color(0xFFFDFBFF), Color(0xFFF6F3FF)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
        color: isHighContrast ? Colors.black : null,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40)),
        boxShadow: isHighContrast ? [] : [BoxShadow(color: const Color(0xFF8B80F9).withOpacity(0.08), blurRadius: 24, offset: const Offset(0, -5))],
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
          setState(() => _currentNavIndex = index);
        } else if (index == 1) {
          Navigator.pushNamed(context, '/create_event');
        } else if (index == 2) {
          Navigator.pushNamed(context, '/profile');
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isActive ? (isHighContrast ? Colors.yellow : const Color(0xFF8B80F9)) : (isHighContrast ? Colors.white70 : Colors.grey.shade400), size: 26),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: isActive ? (isHighContrast ? Colors.yellow : const Color(0xFF8B80F9)) : (isHighContrast ? Colors.white70 : Colors.grey.shade400), fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _PillActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color contentColor;
  final VoidCallback onTap;
  const _PillActionButton({required this.icon, required this.label, required this.backgroundColor, required this.contentColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [BoxShadow(color: backgroundColor.withOpacity(0.5), blurRadius: 16, offset: const Offset(0, 6))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: contentColor),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: contentColor)),
          ],
        ),
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final String eventId;
  final String imageUrl;
  final String title;
  final String timeText;
  final String badgeText;
  final Color badgeColor;
  final Color badgeTextColor;
  final bool isHighContrast;
  final VoidCallback onTap;
  const _EventCard({required this.eventId, required this.imageUrl, required this.title, required this.timeText, required this.badgeText, required this.badgeColor, required this.badgeTextColor, required this.isHighContrast, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        decoration: BoxDecoration(
          color: isHighContrast ? Colors.black : const Color(0xFFFBF8F5),
          borderRadius: BorderRadius.circular(32),
          boxShadow: isHighContrast ? [] : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 8))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                  child: Image.network(
                    imageUrl,
                    height: 140,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(height: 140, color: Colors.grey.shade300, width: double.infinity, child: const Icon(Icons.image, size: 40, color: Colors.grey)),
                  ),
                ),
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(color: badgeColor, borderRadius: BorderRadius.circular(20)),
                    child: Text(badgeText, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.5, color: badgeTextColor)),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: isHighContrast ? Colors.white : const Color(0xFF2D2D2D)), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.calendar_month, size: 16, color: isHighContrast ? Colors.yellow : Colors.grey.shade600),
                      const SizedBox(width: 6),
                      Text(timeText, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isHighContrast ? Colors.white70 : Colors.grey.shade600)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: ParticipantService().getParticipants(eventId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(width: 60, height: 32, child: CircularProgressIndicator(strokeWidth: 2, color: isHighContrast ? Colors.yellow : null)),
                            Text('CARREGANDO...', style: TextStyle(color: isHighContrast ? Colors.white70 : Colors.grey.shade600)),
                          ],
                        );
                      }
                      if (snapshot.hasError || !snapshot.hasData) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Erro ao carregar participantes', style: TextStyle(color: isHighContrast ? Colors.white70 : Colors.grey.shade600)),
                            Text('0 CONVIDADOS', style: TextStyle(color: isHighContrast ? Colors.white70 : Colors.grey.shade600)),
                          ],
                        );
                      }
                      final participants = snapshot.data!;
                      final totalCount = participants.length;
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _buildAvatarStack(participants),
                          Text('$totalCount CONVIDADOS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: isHighContrast ? Colors.white70 : const Color(0xFF9E9E9E), letterSpacing: 0.5)),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarStack(List<Map<String, dynamic>> participants) {
    final displayCount = participants.length > 2 ? 2 : participants.length;
    final extraCount = participants.length - displayCount;
    List<Widget> stackChildren = [];
    for (int i = 0; i < displayCount; i++) {
      final name = participants[i]['name'] as String? ?? 'Usuário';
      final initials = _getInitials(name);
      stackChildren.add(
        Positioned(
          left: i * 22.0,
          child: CircleAvatar(
            radius: 16,
            backgroundColor: isHighContrast ? Colors.black : const Color(0xFFFBF8F5),
            child: CircleAvatar(
              radius: 14,
              backgroundColor: isHighContrast ? Colors.yellow : const Color(0xFF8B80F9),
              child: Text(initials, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isHighContrast ? Colors.black : Colors.white)),
            ),
          ),
        ),
      );
    }
    if (extraCount > 0) {
      stackChildren.add(
        Positioned(
          left: displayCount * 22.0,
          child: CircleAvatar(
            radius: 16,
            backgroundColor: isHighContrast ? Colors.black : const Color(0xFFFBF8F5),
            child: CircleAvatar(
              radius: 14,
              backgroundColor: isHighContrast ? Colors.cyan : const Color(0xFFA5B4FC),
              child: Text('+$extraCount', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isHighContrast ? Colors.black : const Color(0xFF4338CA))),
            ),
          ),
        ),
      );
    }
    final totalWidth = (displayCount * 22.0) + (extraCount > 0 ? 32.0 : 16.0);
    return SizedBox(width: totalWidth, height: 32, child: Stack(children: stackChildren));
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0].substring(0, 1).toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }
}