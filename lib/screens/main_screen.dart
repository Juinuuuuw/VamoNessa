import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // Controle da aba selecionada (0 = HOME)
  int _currentNavIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      // Gradiente de fundo da tela inteira
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF7DFCA), // Tom pêssego/laranja claro
            Color(0xFFE8E2FF), // Tom roxo/azul claro
            Color(0xFFD4C8FF), // Tom roxo mais escuro na ponta inferior
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent, // Transparente para mostrar o gradiente
        extendBody: true, // Permite que o corpo passe por baixo da navbar transparente
        body: SafeArea(
          bottom: false, // Desativa a safe area em baixo para a navbar flutuante
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header (Saudação e Avatar)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Hello, Ebony 👋',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Let's create amazings experiences\ntogether!",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade700,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const CircleAvatar(
                      radius: 24,
                      backgroundImage: NetworkImage(
                        'https://images.unsplash.com/photo-1534528741775-53994a69daEB?ixlib=rb-1.2.1&auto=format&fit=crop&w=256&q=80',
                      ),
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
                      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                      prefixIcon: Icon(Icons.search, color: Colors.grey.shade400, size: 20),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Botões de ação com FittedBox para evitar erro de overflow (tela pequena)
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
                      ),
                      const SizedBox(width: 12),
                      _ActionButton(
                        icon: Icons.groups_outlined,
                        label: 'Invite',
                        backgroundColor: const Color(0xFFFFF0E3),
                        iconColor: const Color(0xFFF9A866),
                      ),
                      const SizedBox(width: 12),
                      _ActionButton(
                        icon: Icons.check_circle_outline,
                        label: 'My Tasks',
                        backgroundColor: const Color(0xFFE0F9ED),
                        iconColor: const Color(0xFF4AC48B),
                      ),
                      const SizedBox(width: 12),
                      _ActionButton(
                        icon: Icons.notifications_none,
                        label: 'Notifications',
                        backgroundColor: const Color(0xFFFFEAE9),
                        iconColor: const Color(0xFFF28B82),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Título Your Events
                const Text(
                  'Your Events',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),

                // Lista de eventos
                _EventCard(
                  imageUrl: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
                  title: 'Viagem Para Natal',
                  date: '12 - 15 Dezembro',
                  participants: 5,
                  badgeText: 'Em votação',
                  badgeColor: const Color(0xFFFFD48F),
                  badgeTextColor: const Color(0xFFD6942C),
                  badgeIcon: Icons.access_time,
                  onTap: () => Navigator.pushNamed(context, '/inside_event'), // Navegação adicionada
                ),
                _EventCard(
                  imageUrl: 'https://images.unsplash.com/photo-1558961363-fa8fdf82db35?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
                  title: 'Aniversário da Ana',
                  date: '20 de Julho',
                  participants: 6,
                  badgeText: 'Confirmado',
                  badgeColor: const Color(0xFFB1FFC8),
                  badgeTextColor: const Color(0xFF34A853),
                  badgeIcon: Icons.check,
                  onTap: () => Navigator.pushNamed(context, '/inside_event'), // Navegação adicionada
                ),
                _EventCard(
                  imageUrl: 'https://images.unsplash.com/photo-1558961363-fa8fdf82db35?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
                  title: 'Projeto Integrador',
                  date: 'Até 30 de Agosto',
                  participants: 4,
                  badgeText: 'Planejando',
                  badgeColor: const Color(0xFFBBE5FF),
                  badgeTextColor: const Color(0xFF4A90E2),
                  badgeIcon: Icons.edit_calendar_outlined,
                  onTap: () => Navigator.pushNamed(context, '/inside_event'), // Navegação adicionada
                ),
                const SizedBox(height: 24),

                // Título Recent Activities
                const Text(
                  'Recent Activities',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),

                // Container Branco para Atividades Recentes
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const _ActivityItem(
                        text: 'The creature voted for the beach for the Trip to Natal event.',
                        time: '5 hours ago',
                      ),
                      const _ActivityItem(
                        text: 'Ana suggested "July 20th" for Aniversário da Ana event.',
                        time: '3 hours ago',
                      ),
                      const _ActivityItem(
                        text: 'João completed "Buy decorations" task',
                        time: '2 hours ago',
                      ),
                      const _ActivityItem(
                        text: 'Maria invited 3 new participants to Projeto Integrador',
                        time: '1 hour ago',
                        isLast: true,
                      ),
                    ],
                  ),
                ),
                // Espaço extra no final para a lista não ficar escondida atrás do footer flutuante
                const SizedBox(height: 120), 
              ],
            ),
          ),
        ),
        // Novo Footer Padronizado
        bottomNavigationBar: _buildCustomBottomNav(),
      ),
    );
  }

  // --- Widgets do Footer integrados ---

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
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5)),
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
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isActive ? const Color(0xFF8B80F9) : Colors.grey.shade400, size: 24),
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
            Text('CREATE', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

// Botão de ação (quadrados arredondados)
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color iconColor;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
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
    );
  }
}

// Card de evento remodelado
class _EventCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String date;
  final int participants;
  final String badgeText;
  final Color badgeColor;
  final Color badgeTextColor;
  final IconData badgeIcon;
  final VoidCallback onTap; // Parâmetro novo para permitir clique

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
    return GestureDetector( // Envolvendo com GestureDetector para o clique funcionar
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
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
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Text(
                        date,
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Text('|', style: TextStyle(color: Colors.grey.shade400)),
                      ),
                      Icon(Icons.people_alt_outlined, size: 14, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Text(
                        '$participants',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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

// Item de atividade recente
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
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}