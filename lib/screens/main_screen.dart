// lib/screens/main_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/event.dart';
import '../services/auth_service.dart';
import '../services/event_service.dart';
import 'event_details_screen.dart';
import 'final_event_screen.dart'; // ← NOVO IMPORT

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

  @override
  void initState() {
    super.initState();
    _loadUserName();

    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null && mounted) {
        setState(() {});
      }
    });
  }

  Future<void> _loadUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists && mounted) {
        final data = doc.data();
        setState(() {
          _userName =
              data?['first_name'] ?? user.email?.split('@').first ?? 'Usuário';
        });
      } else {
        setState(() {
          _userName = user.email?.split('@').first ?? 'Usuário';
        });
      }
    } catch (e) {
      print('DEBUG MainScreen: Erro ao carregar nome do usuário: $e');
      setState(() {
        _userName = user.email?.split('@').first ?? 'Usuário';
      });
    }
  }

  void _debugPrintEvents(List<Event> events) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('=== DEBUG MainScreen: Usuário deslogado, ignorando eventos ===');
      return;
    }
    print('=== DEBUG MainScreen: Eventos para o usuário ${user.uid} ===');
    for (var event in events) {
      print('Evento: ${event.title}');
      print('Participantes UIDs: ${event.participants}');
      print('Status: ${event.status}');
      print('---');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF7DFCA), Color(0xFFE8E2FF), Color(0xFFD4C8FF)],
        ),
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
                            'Hello, $_userName 👋',
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Let's create amazing experiences\ntogether!",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade700,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 24,
                          backgroundImage: NetworkImage(
                            'https://images.unsplash.com/photo-1534528741775-53994a69daEB?ixlib=rb-1.2.1&auto=format&fit=crop&w=256&q=80',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Campo de busca
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search events...',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 14,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.grey.shade400,
                        size: 20,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Botões de ação
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _ActionButton(
                        icon: Icons.add,
                        label: 'Add Events',
                        backgroundColor: const Color(0xFFE2E0FF),
                        iconColor: const Color(0xFF8B80F9),
                        onTap: () =>
                            Navigator.pushNamed(context, '/create_event'),
                      ),
                      const SizedBox(width: 12),
                      _ActionButton(
                        icon: Icons.groups_outlined,
                        label: 'Invite',
                        backgroundColor: const Color(0xFFFFF0E3),
                        iconColor: const Color(0xFFF9A866),
                        onTap: () => Navigator.pushNamed(context, '/join'),
                      ),
                      const SizedBox(width: 12),
                      _ActionButton(
                        icon: Icons.check_circle_outline,
                        label: 'My Tasks',
                        backgroundColor: const Color(0xFFE0F9ED),
                        iconColor: const Color(0xFF4AC48B),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Funcionalidade em desenvolvimento',
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 12),
                      _ActionButton(
                        icon: Icons.notifications_none,
                        label: 'Notifications',
                        backgroundColor: const Color(0xFFFFEAE9),
                        iconColor: const Color(0xFFF28B82),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Funcionalidade em desenvolvimento',
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Título "Your Events"
                const Text(
                  'Your Events',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),

                // Lista dinâmica de eventos
                StreamBuilder<List<Event>>(
                  stream: _eventService.getUserEvents(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      print(
                        'DEBUG MainScreen: Erro no StreamBuilder: ${snapshot.error}',
                      );
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Colors.red,
                              size: 48,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Erro ao carregar eventos: ${snapshot.error}',
                              style: const TextStyle(color: Colors.red),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }

                    final events = snapshot.data ?? [];

                    _debugPrintEvents(events);

                    if (events.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.event_busy,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Você ainda não tem eventos.',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Toque em "Add Events" para criar um!',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return Column(
                      children: events
                          .map((event) => _buildEventCard(event))
                          .toList(),
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Título "Recent Activities"
                const Text(
                  'Recent Activities',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),

                // Container de atividades recentes (estático por enquanto)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Column(
                    children: [
                      _ActivityItem(
                        text:
                            'The creature voted for the beach for the Trip to Natal event.',
                        time: '5 hours ago',
                      ),
                      _ActivityItem(
                        text:
                            'Ana suggested "July 20th" for Aniversário da Ana event.',
                        time: '3 hours ago',
                      ),
                      _ActivityItem(
                        text: 'João completed "Buy decorations" task',
                        time: '2 hours ago',
                      ),
                      _ActivityItem(
                        text:
                            'Maria invited 3 new participants to Projeto Integrador',
                        time: '1 hour ago',
                        isLast: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 120),
              ],
            ),
          ),
        ),
        bottomNavigationBar: _buildCustomBottomNav(),
      ),
    );
  }

  Widget _buildEventCard(Event event) {
    Color badgeColor;
    Color badgeTextColor;
    IconData badgeIcon;
    String badgeText;

    switch (event.status) {
      case 'voting':
        badgeColor = const Color(0xFFFFD48F);
        badgeTextColor = const Color(0xFFD6942C);
        badgeIcon = Icons.how_to_vote;
        badgeText = 'Em votação';
        break;
      case 'confirmed':
        badgeColor = const Color(0xFFB1FFC8);
        badgeTextColor = const Color(0xFF34A853);
        badgeIcon = Icons.check_circle;
        badgeText = 'Confirmado';
        break;
      default:
        badgeColor = const Color(0xFFBBE5FF);
        badgeTextColor = const Color(0xFF4A90E2);
        badgeIcon = Icons.edit_calendar;
        badgeText = 'Planejando';
    }

    return _EventCard(
      imageUrl: event.imageUrl.isNotEmpty
          ? event.imageUrl
          : 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
      title: event.title,
      date:
          '${event.startDate.day}/${event.startDate.month} - ${event.endDate.day}/${event.endDate.month}',
      participants: event.participants.length,
      badgeText: badgeText,
      badgeColor: badgeColor,
      badgeTextColor: badgeTextColor,
      badgeIcon: badgeIcon,
      onTap: () {
        // Navegação condicional conforme o status do evento
        if (event.status == 'confirmed') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FinalEventScreen(eventId: event.id),
            ),
          );
        } else {
          Navigator.pushNamed(context, '/inside_event', arguments: event.id);
        }
      },
    );
  }

  Widget _buildCustomBottomNav() {
    return Container(
      padding: const EdgeInsets.only(top: 16, bottom: 32, left: 24, right: 24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home_filled, 'HOME', 0),
          _buildCreateNavItem(),
          _buildNavItem(Icons.people_alt, 'SOCIAL', 2),
          _buildNavItem(Icons.person, 'PROFILE', 3),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    bool isActive = _currentNavIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() => _currentNavIndex = index);
        if (index == 0) {
          // Já está na home
        } else if (index == 3) {
          Navigator.pushNamed(context, '/profile');
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? const Color(0xFF8B80F9) : Colors.grey.shade400,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? const Color(0xFF8B80F9) : Colors.grey.shade400,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateNavItem() {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/create_event'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF8B80F9),
          borderRadius: BorderRadius.circular(30),
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_circle, color: Colors.white),
            SizedBox(height: 4),
            Text(
              'CREATE',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------ Widgets Auxiliares ------------------

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color iconColor;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, size: 28, color: iconColor),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String date;
  final int participants;
  final String badgeText;
  final Color badgeColor;
  final Color badgeTextColor;
  final IconData badgeIcon;
  final VoidCallback onTap;

  const _EventCard({
    required this.imageUrl,
    required this.title,
    required this.date,
    required this.participants,
    required this.badgeText,
    required this.badgeColor,
    required this.badgeTextColor,
    required this.badgeIcon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                imageUrl,
                width: 85,
                height: 85,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 85,
                    height: 85,
                    color: Colors.grey.shade200,
                    child: Icon(
                      Icons.event,
                      color: Colors.grey.shade400,
                      size: 32,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 14,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        date,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Text(
                          '|',
                          style: TextStyle(color: Colors.grey.shade400),
                        ),
                      ),
                      Icon(
                        Icons.people_alt_outlined,
                        size: 14,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$participants',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: badgeColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(badgeIcon, size: 14, color: badgeTextColor),
                        const SizedBox(width: 4),
                        Text(
                          badgeText,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: badgeTextColor,
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
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final String text;
  final String time;
  final bool isLast;

  const _ActivityItem({
    required this.text,
    required this.time,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 12,
            backgroundImage: NetworkImage(
              'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?ixlib=rb-1.2.1&auto=format&fit=crop&w=256&q=80',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    text,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                      height: 1.3,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  time,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}