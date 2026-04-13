import 'package:flutter/material.dart';

class InsideEventScreen extends StatefulWidget {
  const InsideEventScreen({super.key});

  @override
  State<InsideEventScreen> createState() => _InsideEventScreenState();
}

class _InsideEventScreenState extends State<InsideEventScreen> {
  int _currentNavIndex = 0;
  
  // Estado para simular os votos
  int _rooftopVotes = 8;
  int _bistroVotes = 5;
  bool _votedRooftop = true; // Simula que o usuário atual já votou nesta opção

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Para o fundo passar por baixo da nav bar
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF7DFCA), // Pêssego/laranja claro
              Color(0xFFE8E2FF), // Roxo/azul claro
              Color(0xFFD4C8FF), // Roxo mais escuro
            ],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // AppBar Transparente Simples
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              
              // Conteúdo Rolável
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(left: 24.0, right: 24.0, bottom: 100.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Banner Principal do Evento (COM A COR ATUALIZADA)
                      _buildEventBanner(),
                      const SizedBox(height: 32),

                      // 2. Votação de Locais
                      _buildSectionHeader('Votação de Locais', trailingText: 'Faltam 2 dias'),
                      const SizedBox(height: 16),
                      
                      // Opção 1: Rooftop
                      _buildVoteCard(
                        title: 'Club House Rooftop',
                        subtitle: 'Vila Madalena, SP',
                        imageUrl: 'https://images.unsplash.com/photo-1572369889240-4f81fb80d196?q=80&w=400&auto=format&fit=crop', // Imagem elegante
                        votes: _rooftopVotes,
                        isVotedByMe: _votedRooftop,
                        onVote: () {
                          setState(() {
                            _votedRooftop = !_votedRooftop;
                            _votedRooftop ? _rooftopVotes++ : _rooftopVotes--;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      
                      // Opção 2: Bistro
                      _buildVoteCard(
                        title: 'Garden Bistro',
                        subtitle: 'Pinheiros, SP',
                        imageUrl: 'https://images.unsplash.com/photo-1550966871-3ed3cdb5ed0c?q=80&w=400&auto=format&fit=crop', // Imagem de restaurante com plantas
                        votes: _bistroVotes,
                        isVotedByMe: false,
                        onVote: () {
                          setState(() => _bistroVotes++);
                        },
                      ),
                      const SizedBox(height: 32),

                      // 3. Votação de Datas
                      _buildSectionHeader('Datas'),
                      const SizedBox(height: 16),
                      _buildDateTile(month: 'SET', day: '15', weekday: 'Sábado', time: '19:00 - 02:00', votes: 9, isWinner: true),
                      const SizedBox(height: 12),
                      _buildDateTile(month: 'SET', day: '16', weekday: 'Domingo', time: '14:00 - 21:00', votes: 3, isWinner: false),
                      const SizedBox(height: 32),

                      // 4. Tendência do Grupo (Insight Card)
                      _buildTrendCard(),
                      const SizedBox(height: 32),

                      // 5. Participantes
                      _buildSectionHeader('Participantes', trailingAction: 'Convidar +'),
                      const SizedBox(height: 16),
                      _buildParticipantsList(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildCustomBottomNav(),
    );
  }

  // --- Widgets Internos ---

  Widget _buildEventBanner() {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        image: const DecorationImage(
          image: NetworkImage('https://images.unsplash.com/photo-1533174000220-db6fbc4b2da0?q=80&w=600&auto=format&fit=crop'), // Festa/Aniversário
          fit: BoxFit.cover,
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              // ALTERADO: De verde para o roxo pastel que estamos usando
              const Color(0xFF8B80F9).withOpacity(0.8), 
            ],
          ),
        ),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF8B80F9), // Roxo pastel sólido no badge
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'PLANEJANDO',
                style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Aniversário do Rodrigo',
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, height: 1.1),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.people_alt, color: Colors.white, size: 14),
                const SizedBox(width: 6),
                Text(
                  '12 Confirmados',
                  style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {String? trailingText, String? trailingAction}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        if (trailingText != null)
          Text(
            trailingText,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF8B80F9)),
          ),
        if (trailingAction != null)
          GestureDetector(
            onTap: () {},
            child: Text(
              trailingAction,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF8B80F9)),
            ),
          ),
      ],
    );
  }

  Widget _buildVoteCard({
    required String title,
    required String subtitle,
    required String imageUrl,
    required int votes,
    required bool isVotedByMe,
    required VoidCallback onVote,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        children: [
          // Imagem com Badge de Votos
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
                child: Image.network(
                  imageUrl,
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.thumb_up, size: 12, color: Color(0xFF8B80F9)),
                      const SizedBox(width: 4),
                      Text('$votes', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF8B80F9))),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          // Infos e Botão
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                const SizedBox(height: 16),
                
                // Botão de Votar
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: onVote,
                    icon: Icon(isVotedByMe ? Icons.check_circle : Icons.add_circle, size: 18),
                    label: Text(isVotedByMe ? 'Votado' : 'Votar +1', style: const TextStyle(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isVotedByMe ? const Color(0xFF8B80F9) : const Color(0xFFF0F4FF),
                      foregroundColor: isVotedByMe ? Colors.white : const Color(0xFF8B80F9),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateTile({
    required String month,
    required String day,
    required String weekday,
    required String time,
    required int votes,
    required bool isWinner,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          // Caixinha da Data
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isWinner ? const Color(0xFFE2E0FF) : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(month, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isWinner ? const Color(0xFF8B80F9) : Colors.grey.shade500)),
                Text(day, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isWinner ? const Color(0xFF8B80F9) : Colors.black87)),
              ],
            ),
          ),
          const SizedBox(width: 16),
          
          // Dia e Horário
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(weekday, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                const SizedBox(height: 4),
                Text(time, style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
              ],
            ),
          ),
          
          // Status de Votos
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('$votes votos', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isWinner ? const Color(0xFF8B80F9) : Colors.grey.shade600)),
              const SizedBox(height: 4),
              Icon(
                isWinner ? Icons.check_circle : Icons.add_circle,
                color: isWinner ? const Color(0xFF8B80F9) : Colors.grey.shade300,
                size: 20,
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildTrendCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF8B80F9), // Roxo pastel
            Color(0xFF7A6EE6), // Levemente mais escuro
          ],
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(color: const Color(0xFF8B80F9).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.trending_up, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text(
                'TENDÊNCIA DO GRUPO',
                style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Sábado no Rooftop',
            style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold, height: 1.1),
          ),
          const SizedBox(height: 12),
          Text(
            'Esta combinação tem o maior engajamento até agora. Rodrigo vai adorar a vista!',
            style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14, height: 1.4),
          ),
          const SizedBox(height: 24),
          
          // Stack de Avatares (Simulando quem votou)
          SizedBox(
            height: 40,
            child: Stack(
              children: [
                _buildAvatarStack(0, 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=150&auto=format&fit=crop'),
                _buildAvatarStack(25, 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=150&auto=format&fit=crop'),
                _buildAvatarStack(50, 'https://images.unsplash.com/photo-1599566150163-29194dcaad36?q=80&w=150&auto=format&fit=crop'),
                Positioned(
                  left: 75,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF7A6EE6), width: 2),
                    ),
                    child: const Center(
                      child: Text('+6', style: TextStyle(color: Color(0xFF8B80F9), fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarStack(double leftPosition, String imageUrl) {
    return Positioned(
      left: leftPosition,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFF7A6EE6), width: 2),
        ),
        child: CircleAvatar(
          radius: 18,
          backgroundImage: NetworkImage(imageUrl),
        ),
      ),
    );
  }

  Widget _buildParticipantsList() {
    return Wrap(
      spacing: 24,
      runSpacing: 24,
      children: [
        _buildParticipantAvatar('Rodrigo', 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=150&auto=format&fit=crop', isOrganizer: true),
        _buildParticipantAvatar('Ana Julia', 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?q=80&w=150&auto=format&fit=crop'),
        _buildParticipantAvatar('Lucas M.', 'https://images.unsplash.com/photo-1527980965255-d3b416303d12?q=80&w=150&auto=format&fit=crop'),
        _buildParticipantAvatar('Carla Dias', 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?q=80&w=150&auto=format&fit=crop'),
        
        // Botão Ver Mais
        Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Icon(Icons.more_horiz, color: Colors.grey.shade400),
            ),
            const SizedBox(height: 8),
            Text('Ver mais', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
          ],
        )
      ],
    );
  }

  Widget _buildParticipantAvatar(String name, String imageUrl, {bool isOrganizer = false}) {
    return Column(
      children: [
        Container(
          padding: isOrganizer ? const EdgeInsets.all(2) : EdgeInsets.zero,
          decoration: isOrganizer 
              ? const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF8B80F9), // Borda roxa pro organizador
                ) 
              : null,
          child: CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white,
            backgroundImage: NetworkImage(imageUrl),
          ),
        ),
        const SizedBox(height: 8),
        Text(name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
        if (isOrganizer)
          const Padding(
            padding: EdgeInsets.only(top: 2.0),
            child: Text('ORGANIZADOR', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Color(0xFF8B80F9))),
          )
      ],
    );
  }

  Widget _buildCustomBottomNav() {
    return Container(
      padding: const EdgeInsets.only(top: 16, bottom: 32, left: 24, right: 24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home_filled, 'HOME', 0),
          _buildCreateNavItem(1),
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
          Text(label, style: TextStyle(color: isActive ? const Color(0xFF8B80F9) : Colors.grey.shade400, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildCreateNavItem(int index) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/create_event'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(color: const Color(0xFF8B80F9), borderRadius: BorderRadius.circular(30)), // Botão Create principal sólido
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