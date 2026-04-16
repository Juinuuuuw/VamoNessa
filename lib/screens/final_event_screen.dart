// lib/screens/final_event_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/event.dart';
import '../services/event_service.dart';
import '../services/task_service.dart';
import '../models/task.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  @override
  void initState() {
    super.initState();
    _eventFuture = _eventService.getEventById(widget.eventId);
  }

  // Retorna o local mais votado (desempate: primeiro)
  VenueOptionModel? _getWinningVenue(Event event) {
    final venues = event.venueOptions ?? [];
    if (venues.isEmpty) return null;
    // Ordena por número de votos decrescente
    venues.sort((a, b) => b.votes.length.compareTo(a.votes.length));
    return venues.first;
  }

  // Retorna a data mais votada (desempate: primeiro)
  DateOption? _getWinningDate(Event event) {
    final dates = event.dateOptions ?? [];
    if (dates.isEmpty) return null;
    dates.sort((a, b) => b.votes.length.compareTo(a.votes.length));
    return dates.first;
  }

  String _formatDateRange(DateOption date) {
    final start = date.startDate;
    final end = date.endDate;
    if (start.year == end.year && start.month == end.month && start.day == end.day) {
      return '${start.day}/${start.month}/${start.year}';
    }
    return '${start.day}/${start.month} - ${end.day}/${end.month}/${end.year}';
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
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
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
            onPressed: () {
              // TODO: compartilhar evento
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMainCard(Event event, VenueOptionModel? venue, DateOption? date) {
    final imageUrl = venue?.imageUrl.isNotEmpty == true
        ? venue!.imageUrl
        : (event.imageUrl.isNotEmpty ? event.imageUrl : 'https://images.unsplash.com/photo-1517457373958-b7bdd4587205');

    final venueName = venue?.venueName ?? 'Local a definir';
    final totalPrice = venue?.total ?? venue?.price ?? 0.0;
    final dateRange = date != null ? _formatDateRange(date) : 'Data a definir';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF0056D2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'CONFIRMADO',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          event.title,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 24),
        ClipRRect(
          borderRadius: BorderRadius.circular(40),
          child: Stack(
            children: [
              Image.network(
                imageUrl,
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 250,
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.broken_image, size: 50),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'LOCAL CONFIRMADO',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        venueName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildInfoColumn('DATA & PERÍODO', dateRange),
            _buildInfoColumn('INVESTIMENTO', 'R\$ ${totalPrice.toStringAsFixed(2)}', isPrice: true),
          ],
        ),
        if (venue != null && venue.scheduleActivities.isNotEmpty) ...[
          const SizedBox(height: 24),
          _buildScheduleSection(venue),
        ],
        if (venue != null && venue.activities.isNotEmpty) ...[
          const SizedBox(height: 24),
          _buildActivitiesSection(venue),
        ],
      ],
    );
  }

  Widget _buildScheduleSection(VenueOptionModel venue) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.schedule, size: 18, color: Color(0xFFF9A866)),
              const SizedBox(width: 8),
              Text(
                venue.scheduleName.isNotEmpty ? venue.scheduleName : 'Cronograma',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFF9A866),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...venue.scheduleActivities.map((activity) => Padding(
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
              )),
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
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10),
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
            children: venue.activities.map((activity) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.celebration_outlined, size: 14, color: Colors.deepOrange),
                      const SizedBox(width: 6),
                      Text(activity.name, style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value, {bool isPrice = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 10, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isPrice ? const Color(0xFF0056D2) : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildPlanningHeader(String eventId) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Planejamento',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        // Aqui poderia calcular o percentual real de tarefas concluídas
        Text(
          '80% completo',
          style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.bold, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildTasksList(String eventId) {
    return StreamBuilder<List<Task>>(
      stream: _taskService.getTasks(eventId),
      builder: (context, snapshot) {
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
      ),
      child: Row(
        children: [
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
              color: isDone ? const Color(0xFF0056D2) : Colors.grey,
            ),
          ),
          const SizedBox(width: 12),
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
                Text(
                  'ATRIBUÍDO A: ${task.assignedToName?.toUpperCase() ?? "TODOS"}',
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddActivityButton() {
    return GestureDetector(
      onTap: () => _showAddTaskDialog(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.withOpacity(0.3), width: 1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle, size: 20, color: Colors.grey),
            SizedBox(width: 8),
            Text('Adicionar Nova Atividade', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
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
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: _getEventParticipants(),
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
                            lastDate: DateTime.now().add(const Duration(days: 365)),
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
                            const SnackBar(content: Text('O título é obrigatório')),
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
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Erro: $e')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B80F9),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
    final eventDoc = await FirebaseFirestore.instance
        .collection('events')
        .doc(widget.eventId)
        .get();
    final participants = List<String>.from(eventDoc.data()?['participants'] ?? []);
    final List<Map<String, dynamic>> result = [];
    for (var uid in participants) {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (userDoc.exists) {
        final data = userDoc.data()!;
        final name = '${data['first_name'] ?? ''} ${data['last_name'] ?? ''}'.trim();
        result.add({'uid': uid, 'name': name.isNotEmpty ? name : uid});
      } else {
        result.add({'uid': uid, 'name': uid});
      }
    }
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
          const Text('USER', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildAddParticipantButton() {
    return GestureDetector(
      onTap: () {
        // Abrir modal de convite
      },
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.withOpacity(0.5), width: 1),
        ),
        child: const Icon(Icons.add, color: Colors.grey),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      height: 90,
      margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.explore_outlined, 'EXPLORE', false),
          _buildNavItem(Icons.calendar_month, 'EVENTS', true),
          _buildNavItem(Icons.check_circle_outline, 'PLANNING', false),
          _buildNavItem(Icons.person_outline, 'PROFILE', false),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: isActive ? const Color(0xFF0056D2) : Colors.grey),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            color: isActive ? const Color(0xFF0056D2) : Colors.grey,
          ),
        ),
      ],
    );
  }
}