// lib/screens/event_details_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/event.dart';
import '../models/poll.dart';
import '../models/task.dart';
import '../services/event_service.dart';
import '../services/poll_service.dart';
import '../services/task_service.dart';

class EventDetailsScreen extends StatefulWidget {
  final String eventId;

  const EventDetailsScreen({super.key, required this.eventId});

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  final EventService _eventService = EventService();
  final PollService _pollService = PollService();
  final TaskService _taskService = TaskService();
  int _currentNavIndex = 0;

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
                        bottom: 100.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Banner do evento (dinâmico)
                          _buildEventBanner(event),
                          const SizedBox(height: 32),

                          // Votação de Locais
                          _buildSectionHeader(
                            'Votação de Locais',
                            trailingText: _calculateDaysLeft(event.endDate),
                          ),
                          const SizedBox(height: 16),
                          _buildLocationPollsSection(event.id),
                          const SizedBox(height: 32),

                          // Votação de Datas
                          _buildSectionHeader('Datas'),
                          const SizedBox(height: 16),
                          _buildDatePollsSection(event.id),
                          const SizedBox(height: 32),

                          // Tendência do Grupo (simplificado)
                          _buildTrendCard(event),
                          const SizedBox(height: 32),

                          // Participantes
                          _buildSectionHeader(
                            'Participantes',
                            trailingAction: 'Convidar +',
                          ),
                          const SizedBox(height: 16),
                          _buildParticipantsList(event.participants),

                          // ========== SEÇÃO DE TAREFAS (NOVO) ==========
                          const SizedBox(height: 32),
                          _buildTasksSection(event.id),
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

  // ========== SEÇÃO DE LOCAIS (STREAM) ==========
  Widget _buildLocationPollsSection(String eventId) {
    return StreamBuilder<List<Poll>>(
      stream: _pollService.getPollsByType(eventId, 'location'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Text('Erro: ${snapshot.error}');
        }

        final polls = snapshot.data ?? [];

        if (polls.isEmpty) {
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
          children: polls.map((poll) {
            final hasVoted = _pollService.hasUserVoted(poll);
            return Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: _buildVoteCard(
                title: poll.title,
                subtitle: poll.subtitle ?? '',
                imageUrl: poll.imageUrl ?? '',
                votes: poll.votes,
                isVotedByMe: hasVoted,
                onVote: () => _pollService.vote(eventId, poll.id),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  // ========== SEÇÃO DE DATAS (STREAM) ==========
  Widget _buildDatePollsSection(String eventId) {
    return StreamBuilder<List<Poll>>(
      stream: _pollService.getPollsByType(eventId, 'date'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Text('Erro: ${snapshot.error}');
        }

        final polls = snapshot.data ?? [];
        if (polls.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(child: Text('Nenhuma data proposta.')),
          );
        }

        // Ordenar por data
        polls.sort((a, b) => a.date!.compareTo(b.date!));

        // Determinar vencedor (mais votos)
        int maxVotes = polls.fold(0, (max, p) => p.votes > max ? p.votes : max);

        return Column(
          children: polls.map((poll) {
            final hasVoted = _pollService.hasUserVoted(poll);
            final isWinner = poll.votes == maxVotes && maxVotes > 0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildDateTile(
                month: _getMonthAbbr(poll.date!),
                day: poll.date!.day.toString(),
                weekday: _getWeekday(poll.date!),
                time:
                    '${poll.date!.hour}:${poll.date!.minute.toString().padLeft(2, '0')}',
                votes: poll.votes,
                isWinner: isWinner,
                isVotedByMe: hasVoted,
                onVote: () => _pollService.vote(eventId, poll.id),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  // ========== PARTICIPANTES ==========
  Widget _buildParticipantsList(List<String> participantUids) {
    // Limitar a exibição aos primeiros 5 e depois um botão "Ver mais"
    final displayUids = participantUids.take(5).toList();

    return Wrap(
      spacing: 24,
      runSpacing: 24,
      children: [
        ...displayUids.map((uid) => _buildParticipantAvatar(uid)),
        if (participantUids.length > 5)
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
                'Ver +${participantUids.length - 5}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildParticipantAvatar(String uid) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
      builder: (context, snapshot) {
        String name = 'Usuário';
        String? photoUrl;
        bool isOrganizer = false; // Simplificado

        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          name =
              data['first_name'] ?? data['email']?.split('@')[0] ?? 'Usuário';
          photoUrl = data['photo_url'];
        }

        return Column(
          children: [
            Container(
              padding: isOrganizer ? const EdgeInsets.all(2) : EdgeInsets.zero,
              decoration: isOrganizer
                  ? const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF8B80F9),
                    )
                  : null,
              child: CircleAvatar(
                radius: 28,
                backgroundColor: Colors.white,
                backgroundImage: photoUrl != null && photoUrl.isNotEmpty
                    ? NetworkImage(photoUrl)
                    : const NetworkImage(
                        'https://www.gravatar.com/avatar/00000000000000000000000000000000?d=mp&f=y',
                      ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            if (isOrganizer)
              const Padding(
                padding: EdgeInsets.only(top: 2.0),
                child: Text(
                  'ORGANIZADOR',
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8B80F9),
                  ),
                ),
              ),
          ],
        );
      },
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

  // ========== SEÇÃO DE TAREFAS ==========
  Widget _buildTasksSection(String eventId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Tarefas',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            TextButton.icon(
              onPressed: () => _showAddTaskDialog(eventId),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Nova'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF8B80F9),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        StreamBuilder<List<Task>>(
          stream: _taskService.getTasks(eventId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Text('Erro: ${snapshot.error}');
            }
            final tasks = snapshot.data ?? [];
            if (tasks.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Text('Nenhuma tarefa criada ainda.'),
                ),
              );
            }
            return Column(
              children: tasks
                  .map((task) => _buildTaskTile(eventId, task))
                  .toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTaskTile(String eventId, Task task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Checkbox(
          value: task.status == 'done',
          onChanged: (val) {
            _taskService.updateTaskStatus(
              eventId,
              task.id,
              val! ? 'done' : 'pending',
            );
          },
          activeColor: const Color(0xFF8B80F9),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.status == 'done'
                ? TextDecoration.lineThrough
                : null,
            color: task.status == 'done' ? Colors.grey : Colors.black87,
          ),
        ),
        subtitle: task.assignedToName != null
            ? Text('Responsável: ${task.assignedToName}')
            : const Text('Não atribuída'),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.grey, size: 20),
          onPressed: () => _taskService.deleteTask(eventId, task.id),
        ),
        onTap: () {
          // Opcional: abrir edição da tarefa
        },
      ),
    );
  }

  void _showAddTaskDialog(String eventId) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    String? selectedUserId;
    String? selectedUserName;
    DateTime? dueDate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
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
                  const Text(
                    'Nova Tarefa',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Título',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Descrição (opcional)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: _getEventParticipants(eventId),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const SizedBox.shrink();
                      final participants = snapshot.data!;
                      return DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Responsável',
                          border: OutlineInputBorder(),
                        ),
                        value: selectedUserId,
                        items: [
                          const DropdownMenuItem<String>(
                            value: null,
                            child: Text('Nenhum (tarefa compartilhada)'),
                          ),
                          ...participants.map(
                            (p) => DropdownMenuItem<String>(
                              value: p['uid'] as String,
                              child: Text(p['name'] as String),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedUserId = value;
                            if (value != null) {
                              final selected = participants.firstWhere(
                                (p) => p['uid'] == value,
                              );
                              selectedUserName = selected['name'] as String;
                            } else {
                              selectedUserName = null;
                            }
                          });
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          dueDate == null
                              ? 'Sem data limite'
                              : 'Prazo: ${dueDate!.day}/${dueDate!.month}/${dueDate!.year}',
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(
                              const Duration(days: 365),
                            ),
                          );
                          if (date != null) {
                            setState(() => dueDate = date);
                          }
                        },
                        child: const Text('Selecionar data'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (titleController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('O título é obrigatório'),
                            ),
                          );
                          return;
                        }
                        Navigator.pop(context);
                        try {
                          await _taskService.createTask(
                            eventId: eventId,
                            title: titleController.text.trim(),
                            description: descriptionController.text.trim(),
                            assignedTo: selectedUserId,
                            assignedToName: selectedUserName,
                            dueDate: dueDate,
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text('Erro: $e')));
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B80F9),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Criar Tarefa'),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> _getEventParticipants(
    String eventId,
  ) async {
    final eventDoc = await FirebaseFirestore.instance
        .collection('events')
        .doc(eventId)
        .get();
    final participants = List<String>.from(
      eventDoc.data()?['participants'] ?? [],
    );
    final List<Map<String, dynamic>> result = [];
    for (var uid in participants) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      if (userDoc.exists) {
        final data = userDoc.data()!;
        final name = '${data['first_name'] ?? ''} ${data['last_name'] ?? ''}'
            .trim();
        result.add({'uid': uid, 'name': name.isNotEmpty ? name : uid});
      } else {
        result.add({'uid': uid, 'name': uid});
      }
    }
    return result;
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

  // ========== BOTTOM NAVIGATION ==========
  Widget _buildSectionHeader(
    String title, {
    String? trailingText,
    String? trailingAction,
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
            onTap: () {
              // TODO: Implementar convite
            },
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
