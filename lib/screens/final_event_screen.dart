// lib/screens/final_event_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/event.dart';
import '../models/task.dart';
import '../services/event_service.dart';
import '../services/task_service.dart';

class FinalEventScreen extends StatefulWidget {
  final String eventId;

  const FinalEventScreen({super.key, required this.eventId});

  @override
  State<FinalEventScreen> createState() => _FinalEventScreenState();
}

class _FinalEventScreenState extends State<FinalEventScreen> {
  final EventService _eventService = EventService();
  final TaskService _taskService = TaskService();
  late Future<Event?> _eventFuture;
  int _currentNavIndex = 0;

  @override
  void initState() {
    super.initState();
    _eventFuture = _eventService.getEventById(widget.eventId);
  }

  VenueOptionModel? _getWinningVenue(Event event) {
    final venues = event.venueOptions ?? [];
    if (venues.isEmpty) return null;
    venues.sort((a, b) => b.votes.length.compareTo(a.votes.length));
    return venues.first;
  }

  DateOption? _getWinningDate(Event event) {
    final dates = event.dateOptions ?? [];
    if (dates.isEmpty) return null;
    dates.sort((a, b) => b.votes.length.compareTo(a.votes.length));
    return dates.first;
  }

  String _formatDateRange(DateOption date) {
    final start = date.startDate;
    final end = date.endDate;
    if (start.year == end.year &&
        start.month == end.month &&
        start.day == end.day) {
      return '${start.day} de ${_getMonthName(start.month)}';
    }
    return '${start.day} - ${end.day} de ${_getMonthName(end.month)}';
  }

  String _getMonthName(int month) {
    const months = [
      'Janeiro',
      'Fevereiro',
      'Março',
      'Abril',
      'Maio',
      'Junho',
      'Julho',
      'Agosto',
      'Setembro',
      'Outubro',
      'Novembro',
      'Dezembro',
    ];
    return months[month - 1];
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
            future: _eventFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError || !snapshot.hasData) {
                return const Center(child: Text('Evento não encontrado'));
              }

              final event = snapshot.data!;
              final winningVenue = _getWinningVenue(event);
              final winningDate = _getWinningDate(event);

              return Column(
                children: [
                  _buildAppBar(),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildMainCard(event, winningVenue, winningDate),

                          if (winningVenue != null &&
                              winningVenue.scheduleActivities.isNotEmpty) ...[
                            const SizedBox(height: 24),
                            _buildScheduleSection(winningVenue),
                          ],
                          if (winningVenue != null &&
                              winningVenue.activities.isNotEmpty) ...[
                            const SizedBox(height: 24),
                            _buildActivitiesSection(winningVenue),
                          ],

                          const SizedBox(height: 32),
                          _buildPlanningHeader(event.id),
                          const SizedBox(height: 16),
                          _buildTasksList(event.id),
                          const SizedBox(height: 32),
                          _buildParticipantsSection(event),
                          const SizedBox(height: 120),
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

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
            onPressed: () => Navigator.pop(context),
          ),
          const Text(
            'VamoNessa',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF8B80F9),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.black87),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  // ==================== CARD PRINCIPAL ====================
  Widget _buildMainCard(
    Event event,
    VenueOptionModel? venue,
    DateOption? date,
  ) {
    final imageUrl = venue?.imageUrl.isNotEmpty == true
        ? venue!.imageUrl
        : (event.imageUrl.isNotEmpty
              ? event.imageUrl
              : 'https://images.unsplash.com/photo-1517457373958-b7bdd4587205');

    final venueName = venue?.venueName ?? event.title;
    final totalPrice = venue?.total ?? venue?.price ?? 0.0;
    final dateRange = date != null ? _formatDateRange(date) : 'A definir';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // PARTE SUPERIOR: Imagem com Textos sobrepostos
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(32),
                ),
                child: Image.network(
                  imageUrl,
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 220,
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.broken_image, size: 50),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 24,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.85),
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'LOCALIZAÇÃO PREMIUM',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        venueName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // PARTE INFERIOR: Detalhes brancos (Data e Investimento)
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoColumn('DATA & PERÍODO', dateRange),
                _buildPriceColumn('INVESTIMENTO', totalPrice),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildPriceColumn(String label, double price) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              'R\$ ${price.toStringAsFixed(2).replaceAll('.', ',')}',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Color(0xFF2954D1), // Azul similar ao da imagem
              ),
            ),
            Text(
              ' /pessoa',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ],
    );
  }
  // ==========================================================

  Widget _buildScheduleSection(VenueOptionModel venue) {
    return Container(
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.schedule, size: 18, color: Color(0xFF8B80F9)),
              const SizedBox(width: 8),
              Text(
                venue.scheduleName.isNotEmpty
                    ? venue.scheduleName
                    : 'Cronograma',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8B80F9),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...venue.scheduleActivities.map(
            (activity) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(Icons.circle, size: 6, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(child: Text(activity.name)),
                  if (activity.time != null)
                    Text(
                      activity.time!,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivitiesSection(VenueOptionModel venue) {
    return Container(
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Atividades do Local',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: venue.activities
                .map(
                  (activity) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.celebration_outlined,
                          size: 14,
                          color: Color(0xFF8B80F9),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          activity.name,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanningHeader(String eventId) {
    return StreamBuilder<List<Task>>(
      stream: _taskService.getTasks(eventId),
      builder: (context, snapshot) {
        final tasks = snapshot.data ?? [];
        final done = tasks.where((t) => t.status == 'done').length;
        final percent = tasks.isEmpty
            ? 0
            : ((done / tasks.length) * 100).round();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Planejamento',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              '$percent% completo',
              style: const TextStyle(
                color: Color(0xFF8B80F9),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTasksList(String eventId) {
    return StreamBuilder<List<Task>>(
      stream: _taskService.getTasks(eventId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Text('Erro: ${snapshot.error}');
        }
        final tasks = snapshot.data ?? [];
        return Column(
          children: [
            ...tasks.map((task) => _buildTaskItem(task)),
            const SizedBox(height: 8),
            _buildAddActivityButton(),
          ],
        );
      },
    );
  }

  Widget _buildTaskItem(Task task) {
    bool isDone = task.status == 'done';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Checkbox de conclusão
          GestureDetector(
            onTap: () {
              _taskService.updateTaskStatus(
                widget.eventId,
                task.id,
                isDone ? 'pending' : 'done',
              );
            },
            child: Icon(
              isDone ? Icons.check_box : Icons.check_box_outline_blank,
              color: isDone ? const Color(0xFF8B80F9) : Colors.grey,
            ),
          ),
          const SizedBox(width: 12),
          // Título e responsável
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    decoration: isDone ? TextDecoration.lineThrough : null,
                    color: isDone ? Colors.grey : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Responsável: ${task.assignedToName ?? "Todos"}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          // Botão de excluir
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: () => _confirmDeleteTask(task),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteTask(Task task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir tarefa'),
        content: Text('Deseja realmente excluir a tarefa "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _taskService.deleteTask(widget.eventId, task.id);
    }
  }

  Widget _buildAddActivityButton() {
    return GestureDetector(
      onTap: () => _showAddTaskDialog(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: const Color(0xFF8B80F9).withOpacity(0.5),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle, size: 20, color: Color(0xFF8B80F9)),
            SizedBox(width: 8),
            Text(
              'Adicionar Nova Atividade',
              style: TextStyle(
                color: Color(0xFF8B80F9),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddTaskDialog() {
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
                  // ----- DROPDOWN DE RESPONSÁVEL (COM CARREGAMENTO VISÍVEL) -----
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: _getEventParticipants(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                              SizedBox(width: 12),
                              Text('Carregando participantes...'),
                            ],
                          ),
                        );
                      }
                      if (snapshot.hasError) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            'Erro ao carregar participantes',
                            style: TextStyle(color: Colors.red.shade700),
                          ),
                        );
                      }
                      final participants = snapshot.data ?? [];
                      if (participants.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Text('Nenhum participante disponível.'),
                        );
                      }
                      // Dropdown exibido quando há participantes
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
                  // Data limite (mantido como está)
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
                          if (date != null) setState(() => dueDate = date);
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
                            eventId: widget.eventId,
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

  Future<List<Map<String, dynamic>>> _getEventParticipants() async {
    print('=== Buscando participantes do evento ${widget.eventId} ===');
    final eventDoc = await FirebaseFirestore.instance
        .collection('events')
        .doc(widget.eventId)
        .get();
    final participants = List<String>.from(
      eventDoc.data()?['participants'] ?? [],
    );
    print('Participantes UIDs: $participants');

    final List<Map<String, dynamic>> result = [];
    for (var uid in participants) {
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .get();
        if (userDoc.exists) {
          final data = userDoc.data()!;
          final name = '${data['first_name'] ?? ''} ${data['last_name'] ?? ''}'
              .trim();
          print('Usuário $uid: nome="$name"');
          result.add({'uid': uid, 'name': name.isNotEmpty ? name : uid});
        } else {
          print('Usuário $uid não encontrado na coleção users');
          result.add({'uid': uid, 'name': uid}); // fallback para UID
        }
      } catch (e) {
        print('Erro ao buscar usuário $uid: $e');
        result.add({'uid': uid, 'name': uid}); // fallback para UID
      }
    }
    print('Resultado final: $result');
    return result;
  }

  Widget _buildParticipantsSection(Event event) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Participantes Confirmados',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ...event.participants.map((uid) => _buildParticipantCircle(uid)),
              _buildAddParticipantButton(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildParticipantCircle(String uid) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: const Color(0xFF8B80F9),
            child: CircleAvatar(
              radius: 28,
              backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=$uid'),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'USER',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildAddParticipantButton() {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(Icons.add, color: Colors.grey.shade400),
      ),
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
        if (index == 0) Navigator.popUntil(context, (route) => route.isFirst);
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
