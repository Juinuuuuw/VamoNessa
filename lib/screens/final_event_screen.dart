// lib/screens/final_event_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vamonessa/services/participant_service.dart';
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
  final ParticipantService _participantService = ParticipantService();
  late Future<Event?> _eventFuture;
  final int _currentNavIndex = 0;

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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Botão de voltar simplificado
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, top: 8.0, right: 24.0),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(
                        left: 24.0, 
                        right: 24.0, 
                        bottom: 140.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Cabeçalho com Título e Ano em tons pasteis
                          _buildScreenHeader(event),
                          const SizedBox(height: 32),

                          _buildMainCard(event, winningVenue, winningDate),

                          if (winningVenue != null &&
                              winningVenue.scheduleActivities.isNotEmpty) ...[
                            const SizedBox(height: 24),
                            _buildScheduleSection(winningVenue),
                          ],

                          const SizedBox(height: 32),
                          _buildPlanningHeader(event.id),
                          const SizedBox(height: 16),
                          _buildTasksList(event.id),
                          const SizedBox(height: 32),
                          _buildParticipantsSection(event),
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

  // ========== HEADER (TÍTULO E ANO) ==========
  Widget _buildScreenHeader(Event event) {
    String statusText;
    Color badgeColor;

    switch (event.status) {
      case 'voting':
        statusText = 'EM VOTAÇÃO';
        badgeColor = const Color(0xFF8B80F9);
        break;
      case 'confirmed':
        statusText = 'CONFIRMADO';
        badgeColor = const Color(0xFF8B80F9);
        break;
      default:
        statusText = 'PLANEJANDO';
        badgeColor = const Color(0xFF8B80F9);
    }

    final year = event.startDate.year.toString();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: badgeColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            statusText,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          event.title,
          style: const TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w900,
            color: Color(0xFF2D2D2D),
            height: 1.1,
            letterSpacing: -0.5,
          ),
        ),
        Text(
          year,
          style: const TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w900,
            color: Color(0xFF8B80F9),
            height: 1.1,
            letterSpacing: -0.5,
          ),
        ),
      ],
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

    final List<String> eventTags = (venue != null && venue.activities.isNotEmpty)
        ? venue.activities.map((a) => a.name).toList()
        : ['Premium', 'Ao ar livre'];

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
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildInfoColumn('DATA & PERÍODO', dateRange),
                    _buildPriceColumn('INVESTIMENTO', totalPrice),
                  ],
                ),
                const SizedBox(height: 16),
                
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: eventTags.map((tag) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6F3FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      tag,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF8B80F9),
                      ),
                    ),
                  )).toList(),
                ),
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
                color: Color(0xFF8B80F9),
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
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF8B80F9).withOpacity(0.08), 
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF8B80F9).withOpacity(0.2), 
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _showAddTaskDialog(),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B80F9).withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add, size: 18, color: Color(0xFF8B80F9)),
                ),
                const SizedBox(width: 12),
                const Text(
                  'ADICIONAR NOVA ATIVIDADE',
                  style: TextStyle(
                    color: Color(0xFF8B80F9),
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ========== MODAL DE ADICIONAR TAREFA MODERNIZADO ==========
  void _showAddTaskDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    String? selectedUserId;
    String? selectedUserName;
    DateTime? dueDate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // Permite as bordas arredondadas sem fundo quadrado
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                left: 24,
                right: 24,
                top: 12,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle de arrastar (Pill Minimalista)
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  const Text(
                    'Nova Tarefa',
                    style: TextStyle(
                      fontSize: 24, 
                      fontWeight: FontWeight.w900, 
                      color: Color(0xFF2D2D2D),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Campo Título
                  TextField(
                    controller: titleController,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      labelText: 'O que precisa ser feito?',
                      labelStyle: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.w600),
                      filled: true,
                      fillColor: const Color(0xFFF8F7FF),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Campo Descrição
                  TextField(
                    controller: descriptionController,
                    style: const TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      labelText: 'Detalhes (opcional)',
                      labelStyle: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.w600),
                      filled: true,
                      fillColor: const Color(0xFFF8F7FF),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  
                  // ----- DROPDOWN DE RESPONSÁVEL -----
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: _participantService.getParticipants(widget.eventId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Container(
                          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                          decoration: BoxDecoration(color: const Color(0xFFF8F7FF), borderRadius: BorderRadius.circular(20)),
                          child: const Row(
                            children: [
                              SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                              SizedBox(width: 12),
                              Text('Carregando equipe...', style: TextStyle(fontWeight: FontWeight.w600)),
                            ],
                          ),
                        );
                      }
                      if (snapshot.hasError) {
                        return Text('Erro ao carregar participantes', style: TextStyle(color: Colors.red.shade700));
                      }
                      final participants = snapshot.data ?? [];
                      
                      return DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Responsável',
                          labelStyle: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.w600),
                          filled: true,
                          fillColor: const Color(0xFFF8F7FF),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        ),
                        icon: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey.shade500),
                        style: const TextStyle(color: Color(0xFF2D2D2D), fontWeight: FontWeight.w600, fontSize: 14),
                        value: selectedUserId,
                        items: [
                          const DropdownMenuItem<String>(
                            value: null,
                            child: Text('Tarefa compartilhada (Todos)'),
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
                              final selected = participants.firstWhere((p) => p['uid'] == value);
                              selectedUserName = selected['name'] as String;
                            } else {
                              selectedUserName = null;
                            }
                          });
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Date Picker Botão Modernizado
                  InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: const ColorScheme.light(
                                primary: Color(0xFF8B80F9), 
                                onPrimary: Colors.white, 
                                onSurface: Color(0xFF2D2D2D),
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (date != null) setState(() => dueDate = date);
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                      decoration: BoxDecoration(
                        color: dueDate == null ? const Color(0xFFF8F7FF) : const Color(0xFF8B80F9).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: dueDate != null ? Border.all(color: const Color(0xFF8B80F9).withOpacity(0.3), width: 1.5) : null,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            dueDate == null ? Icons.calendar_today_rounded : Icons.event_available_rounded, 
                            color: dueDate == null ? Colors.grey.shade500 : const Color(0xFF8B80F9),
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              dueDate == null
                                  ? 'Definir data limite'
                                  : 'Prazo: ${dueDate!.day.toString().padLeft(2,'0')}/${dueDate!.month.toString().padLeft(2,'0')}/${dueDate!.year}',
                              style: TextStyle(
                                color: dueDate == null ? Colors.grey.shade600 : const Color(0xFF8B80F9),
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          if (dueDate != null)
                            GestureDetector(
                              onTap: () => setState(() => dueDate = null),
                              child: Icon(Icons.close_rounded, color: Colors.grey.shade400, size: 20),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Botão Salvar
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
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e')));
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B80F9),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        'CRIAR TAREFA',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 1.0),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ========== MODAL DE CONVITE ==========
  void _showInviteModal(Event event) async {
    final inviteCode = await _eventService.getOrCreateInviteCode(event.id);

    if (mounted) {
      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
        builder: (context) => Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Convidar Participantes', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              Text('Compartilhe o código abaixo para que outras pessoas possam entrar.', style: TextStyle(color: Colors.grey.shade600)),
              const SizedBox(height: 24),
              const Text('Código de convite:', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(16)),
                      child: Text(inviteCode, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 4, color: Color(0xFF8B80F9)), textAlign: TextAlign.center),
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: inviteCode));
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Código copiado!')));
                    },
                    icon: const Icon(Icons.copy, color: Color(0xFF8B80F9)),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B80F9),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text('OK', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      );
    }
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
              _buildAddParticipantButton(event),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildParticipantCircle(String uid) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
      builder: (context, snapshot) {
        String name = 'Usuário';
        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          name = data['first_name'] ?? 'Usuário';
        }
        return Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Column(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: const Color(0xFF8B80F9),
                child: CircleAvatar(
                  radius: 28,
                  backgroundImage: NetworkImage(
                    'https://ui-avatars.com/api/?name=$name&background=8B80F9&color=fff&size=56',
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                name.toUpperCase(),
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAddParticipantButton(Event event) {
    return GestureDetector(
      onTap: () => _showInviteModal(event),
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

  // ========== BOTTOM NAVIGATION ==========
  Widget _buildCustomBottomNav() {
    return Container(
      padding: const EdgeInsets.only(top: 16, bottom: 32, left: 32, right: 32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFDFBFF), Color(0xFFF6F3FF)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40)),
        boxShadow: [
          BoxShadow(color: const Color(0xFF8B80F9).withOpacity(0.08), blurRadius: 24, offset: const Offset(0, -5)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(Icons.calendar_month, 'EVENTOS', 0),
          _buildNavItem(Icons.add_circle_outline, 'CRIAR', 1),
          _buildNavItem(Icons.person_outline, 'PERFIL', 2),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    bool isActive = _currentNavIndex == index;
    return GestureDetector(
      onTap: () {
        if (index == 0) {
          Navigator.popUntil(context, (route) => route.isFirst);
        } else if (index == 1) {
          Navigator.pushNamed(context, '/create_event');
        } else if (index == 2) {
          Navigator.pushNamed(context, '/profile');
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isActive ? const Color(0xFF8B80F9) : Colors.grey.shade400, size: 26),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: isActive ? const Color(0xFF8B80F9) : Colors.grey.shade400, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}