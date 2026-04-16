// lib/screens/event_details_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vamonessa/services/participant_service.dart';
import '../models/event.dart';
import '../services/event_service.dart';
import '../services/poll_service.dart';
import 'final_event_screen.dart';

class EventDetailsScreen extends StatefulWidget {
  final String eventId;

  const EventDetailsScreen({super.key, required this.eventId});

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  final EventService _eventService = EventService();
  final PollService _pollService = PollService();
  final ParticipantService _participantService = ParticipantService();
  int _currentNavIndex = 0;
  bool _isConfirming = false;

  bool _isEventCreator(Event event) {
    final user = FirebaseAuth.instance.currentUser;
    return user != null && event.createdBy == user.uid;
  }

  Future<void> _confirmEvent(Event event) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar evento'),
        content: const Text(
          'Ao confirmar, o evento sairá do modo de votação e será definitivo. '
          'Os participantes não poderão mais votar. Deseja continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF34A853),
            ),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isConfirming = true);
    try {
      await _eventService.confirmEvent(event.id);
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => FinalEventScreen(eventId: event.id),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao confirmar evento: $e')));
      }
    } finally {
      if (mounted) setState(() => _isConfirming = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF7DFCA), Color(0xFFE8E2FF), Color(0xFFD4C8FF)],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: FutureBuilder<Event?>(
            future: _eventService.getEventById(widget.eventId),
            builder: (context, eventSnapshot) {
              if (eventSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (eventSnapshot.hasError || !eventSnapshot.hasData) {
                return const Center(child: Text('Erro ao carregar evento'));
              }

              final event = eventSnapshot.data!;
              final currentUser = FirebaseAuth.instance.currentUser;

              // Verificação de participante
              if (currentUser == null ||
                  !event.participants.contains(currentUser.uid)) {
                return _buildNotParticipantView(event);
              }

              return Column(
                children: [
                  // AppBar
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 8.0,
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios_new,
                            color: Colors.black87,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),

                  // Conteúdo Rolável
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(
                        left: 24.0,
                        right: 24.0,
                        bottom: 140.0, // era 100.0
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Banner do evento
                          _buildEventBanner(event),
                          const SizedBox(height: 32),

                          // Votação de Locais
                          _buildSectionHeader(
                            'Votação de Locais',
                            trailingText: _calculateDaysLeft(event.endDate),
                          ),
                          const SizedBox(height: 16),
                          _buildVenueOptionsSection(event),
                          const SizedBox(height: 32),

                          // Votação de Datas
                          _buildSectionHeader('Datas'),
                          const SizedBox(height: 16),
                          _buildDateOptionsSection(event),
                          const SizedBox(height: 32),

                          // Tendência do Grupo
                          _buildTrendCard(event),
                          const SizedBox(height: 24),

                          // Botão Confirmar (somente criador e se estiver em votação)
                          if (_isEventCreator(event) &&
                              event.status == 'voting')
                            _buildConfirmButton(event),

                          const SizedBox(height: 32),

                          // Participantes
                          _buildSectionHeader(
                            'Participantes',
                            trailingAction: 'Convidar +',
                            onTrailingActionTap: () => _showInviteModal(event),
                          ),
                          const SizedBox(height: 16),
                          _buildParticipantsList(event.participants),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: _buildCustomBottomNav(),
    );
  }

  Widget _buildConfirmButton(Event event) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isConfirming ? null : () => _confirmEvent(event),
        icon: _isConfirming
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.check_circle_outline, size: 20),
        label: Text(
          _isConfirming ? 'CONFIRMANDO...' : 'CONFIRMAR EVENTO',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF34A853),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }

  // ---------- VIEW PARA NÃO PARTICIPANTE ----------
  Widget _buildNotParticipantView(Event event) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 24),
            Text(
              'Você não está participando deste evento.',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Peça ao organizador para adicionar você à lista de participantes.',
              style: TextStyle(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Voltar'),
            ),
          ],
        ),
      ),
    );
  }

  // ========== BANNER ==========
  Widget _buildEventBanner(Event event) {
    String statusText;
    switch (event.status) {
      case 'voting':
        statusText = 'EM VOTAÇÃO';
        break;
      case 'confirmed':
        statusText = 'CONFIRMADO';
        break;
      default:
        statusText = 'PLANEJANDO';
    }

    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        image: DecorationImage(
          image: NetworkImage(
            event.imageUrl.isNotEmpty
                ? event.imageUrl
                : 'https://images.unsplash.com/photo-1533174000220-db6fbc4b2da0?q=80&w=600&auto=format&fit=crop',
          ),
          fit: BoxFit.cover,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
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
                color: const Color(0xFF8B80F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                statusText,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              event.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.people_alt, color: Colors.white, size: 14),
                const SizedBox(width: 6),
                Text(
                  '${event.participants.length} Participante(s)',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ---------- SEÇÃO DE LOCAIS ----------
  Widget _buildVenueOptionsSection(Event event) {
    final venues = event.venueOptions ?? [];
    if (venues.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(child: Text('Nenhum local para votar ainda.')),
      );
    }
    return Column(
      children: venues.map((venue) {
        final hasVoted = _pollService.hasUserVoted(venue.votes);
        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: _buildVoteCard(
            title: venue.title,
            subtitle: venue.venueName,
            imageUrl: venue.imageUrl,
            votes: venue.votes.length,
            isVotedByMe: hasVoted,
            onVote: () => _pollService
                .voteVenue(event.id, venue.id)
                .then((_) => setState(() {})),
          ),
        );
      }).toList(),
    );
  }

  // ---------- SEÇÃO DE DATAS ----------
  Widget _buildDateOptionsSection(Event event) {
    final dates = event.dateOptions ?? [];
    if (dates.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(child: Text('Nenhuma data proposta.')),
      );
    }
    dates.sort((a, b) => a.startDate.compareTo(b.startDate));
    final maxVotes = dates.fold<int>(
      0,
      (max, d) => d.votes.length > max ? d.votes.length : max,
    );

    return Column(
      children: dates.map((date) {
        final hasVoted = _pollService.hasUserVoted(date.votes);
        final isWinner = date.votes.length == maxVotes && maxVotes > 0;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildDateTile(
            month: _getMonthAbbr(date.startDate),
            day: date.startDate.day.toString(),
            weekday: _getWeekday(date.startDate),
            time:
                '${date.startDate.hour}:${date.startDate.minute.toString().padLeft(2, '0')}',
            votes: date.votes.length,
            isWinner: isWinner,
            isVotedByMe: hasVoted,
            onVote: () => _pollService
                .voteDate(event.id, date.id)
                .then((_) => setState(() {})),
          ),
        );
      }).toList(),
    );
  }

  // ========== WIDGETS DE VOTAÇÃO ==========
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
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                child: Image.network(
                  imageUrl,
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 140,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.image_not_supported, size: 40),
                  ),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.thumb_up,
                        size: 12,
                        color: Color(0xFF8B80F9),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$votes',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF8B80F9),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: onVote,
                    icon: Icon(
                      isVotedByMe ? Icons.check_circle : Icons.add_circle,
                      size: 18,
                    ),
                    label: Text(
                      isVotedByMe ? 'Votado' : 'Votar +1',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isVotedByMe
                          ? const Color(0xFF8B80F9)
                          : const Color(0xFFF0F4FF),
                      foregroundColor: isVotedByMe
                          ? Colors.white
                          : const Color(0xFF8B80F9),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
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
    required bool isVotedByMe,
    required VoidCallback onVote,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isWinner ? const Color(0xFFE2E0FF) : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  month,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isWinner
                        ? const Color(0xFF8B80F9)
                        : Colors.grey.shade500,
                  ),
                ),
                Text(
                  day,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isWinner ? const Color(0xFF8B80F9) : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  weekday,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$votes votos',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isWinner
                      ? const Color(0xFF8B80F9)
                      : Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: onVote,
                child: Icon(
                  isVotedByMe ? Icons.check_circle : Icons.add_circle,
                  color: isVotedByMe
                      ? const Color(0xFF8B80F9)
                      : Colors.grey.shade400,
                  size: 20,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ========== PARTICIPANTES ==========
  Widget _buildParticipantsList(List<String> participantUids) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _participantService.getParticipants(widget.eventId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Text('Erro: ${snapshot.error}');
        }
        final participants = snapshot.data ?? [];
        final displayParticipants = participants.take(5).toList();

        return Wrap(
          spacing: 24,
          runSpacing: 24,
          children: [
            ...displayParticipants.map((p) => _buildParticipantAvatar(p)),
            if (participants.length > 5)
              Column(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(Icons.more_horiz, color: Colors.grey.shade400),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ver +${participants.length - 5}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                ],
              ),
          ],
        );
      },
    );
  }

  Widget _buildParticipantAvatar(Map<String, dynamic> participant) {
    final uid = participant['uid'] as String;
    final name = participant['name'] as String? ?? 'Usuário';

    return Column(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: Colors.white,
          backgroundImage: NetworkImage(
            'https://ui-avatars.com/api/?name=$name&background=8B80F9&color=fff&size=56',
          ),
        ),
        const SizedBox(height: 8),
        Text(
          name.length > 10 ? '${name.substring(0, 10)}...' : name,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  // ========== TENDÊNCIA ==========
  Widget _buildTrendCard(Event event) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF8B80F9), Color(0xFF7A6EE6)],
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B80F9).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
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
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Em breve: ${event.title}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'As votações estão aquecidas! Convide mais amigos para decidir.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ========== MODAL DE CONVITE ==========
  void _showInviteModal(Event event) async {
    final inviteCode = await _eventService.getOrCreateInviteCode(event.id);
    final inviteLink = 'vamonessa://invite?code=$inviteCode';

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Convidar Participantes',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Compartilhe o código ou link abaixo para que outras pessoas possam entrar no evento.',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            // Código de convite
            const Text(
              'Código de convite:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      inviteCode,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 4,
                        color: Color(0xFF8B80F9),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: inviteCode));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Código copiado!')),
                    );
                  },
                  icon: const Icon(Icons.copy, color: Color(0xFF8B80F9)),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Link de convite
            const Text(
              'Link de convite:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      inviteLink,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade800,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: inviteLink));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Link copiado!')),
                    );
                  },
                  icon: const Icon(Icons.copy, color: Color(0xFF8B80F9)),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Botão de fechar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B80F9),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('OK'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ========== HELPERS ==========
  String _calculateDaysLeft(DateTime endDate) {
    final now = DateTime.now();
    final diff = endDate.difference(now).inDays;
    if (diff <= 0) return 'Encerrado';
    return 'Faltam $diff dia${diff > 1 ? 's' : ''}';
  }

  String _getMonthAbbr(DateTime date) {
    const months = [
      'JAN',
      'FEV',
      'MAR',
      'ABR',
      'MAI',
      'JUN',
      'JUL',
      'AGO',
      'SET',
      'OUT',
      'NOV',
      'DEZ',
    ];
    return months[date.month - 1];
  }

  String _getWeekday(DateTime date) {
    const weekdays = [
      'Segunda',
      'Terça',
      'Quarta',
      'Quinta',
      'Sexta',
      'Sábado',
      'Domingo',
    ];
    return weekdays[date.weekday - 1];
  }

  Widget _buildSectionHeader(
    String title, {
    String? trailingText,
    String? trailingAction,
    VoidCallback? onTrailingActionTap,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        if (trailingText != null)
          Text(
            trailingText,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF8B80F9),
            ),
          ),
        if (trailingAction != null)
          GestureDetector(
            onTap: onTrailingActionTap,
            child: Text(
              trailingAction,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF8B80F9),
              ),
            ),
          ),
      ],
    );
  }

  // ========== BOTTOM NAVIGATION ==========
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
          Navigator.popUntil(context, (route) => route.isFirst);
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
