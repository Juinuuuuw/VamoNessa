// lib/screens/create_event_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/event_service.dart';
import '../models/event.dart';

// ================== CLASSES AUXILIARES DE UI ==================
class ActivityUI {
  String name;
  String? time;

  ActivityUI({required this.name, this.time});
}

class DateRangeOption {
  DateTime startDate;
  DateTime endDate;

  DateRangeOption({required this.startDate, required this.endDate});
}

class VenueOption {
  String id;
  String title;
  String venueName;
  String? venueLink;
  double price;
  String priceDetail;
  String imageUrl;
  List<ActivityUI> activities;
  String scheduleName;
  List<ActivityUI> scheduleActivities;
  double total;

  VenueOption({
    required this.id,
    required this.title,
    required this.venueName,
    this.venueLink,
    required this.price,
    required this.priceDetail,
    required this.imageUrl,
    required this.activities,
    required this.scheduleName,
    required this.scheduleActivities,
    required this.total,
  });
}

// ================== TELA PRINCIPAL ==================
class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final EventService _eventService = EventService();
  final int _currentNavIndex = 1; // Aba "Criar" ativa
  bool _isLoading = false;

  List<VenueOption> venueOptions = [];
  List<DateRangeOption> dateOptions = [];
  String? eventImageUrl;
  final TextEditingController eventNameController = TextEditingController();

  final List<String> defaultImages = [
    'https://images.unsplash.com/photo-1571896349842-33c89424de2d?q=80&w=200&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?q=80&w=200&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1566073771259-6a8506099945?q=80&w=200&auto=format&fit=crop',
  ];

  @override
  void dispose() {
    eventNameController.dispose();
    super.dispose();
  }

  // ================== MÉTODO DE CRIAÇÃO DO EVENTO ==================
  Future<void> _launchEvent() async {
    if (eventNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, insira o nome do evento')),
      );
      return;
    }

    if (dateOptions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Adicione pelo menos uma opção de data')),
      );
      return;
    }

    if (venueOptions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Adicione pelo menos uma opção de local')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Usuário não autenticado');

      final dateOptionsForFirestore = dateOptions.map((d) => DateOption(
            id: '',
            startDate: d.startDate,
            endDate: d.endDate,
          )).toList();

      final venueOptionsForFirestore = venueOptions.map((v) => VenueOptionModel(
            id: '',
            title: v.title,
            venueName: v.venueName,
            venueLink: v.venueLink,
            price: v.price,
            priceDetail: v.priceDetail,
            imageUrl: v.imageUrl,
            activities: v.activities.map((a) => Activity(name: a.name, time: a.time)).toList(),
            scheduleName: v.scheduleName,
            scheduleActivities: v.scheduleActivities.map((a) => Activity(name: a.name, time: a.time)).toList(),
            total: v.total,
          )).toList();

      final eventId = await _eventService.createAdvancedEvent(
        title: eventNameController.text,
        description: '',
        imageUrl: eventImageUrl,
        dateOptions: dateOptionsForFirestore,
        venueOptions: venueOptionsForFirestore,
        createdBy: user.uid,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Evento criado com sucesso!')),
        );
        Navigator.pushReplacementNamed(context, '/inside_event', arguments: eventId);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao criar evento: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ================== BUILD PRINCIPAL ==================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF7DFCA),
              Color(0xFFE8E2FF),
              Color(0xFFD4C8FF),
            ],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Seta de Retorno
              Padding(
                padding: const EdgeInsets.only(left: 8.0, top: 8.0, right: 24.0),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
                  onPressed: () => Navigator.pushReplacementNamed(context, '/main'),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Criar Novo Evento',
                        style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF2D2D2D), letterSpacing: -0.5),
                      ),
                      const SizedBox(height: 24),
                      _buildEventImageSection(),
                      const SizedBox(height: 24),
                      _buildEventNameSection(),
                      const SizedBox(height: 32),
                      _buildDateOptionsSection(),
                      const SizedBox(height: 32),
                      _buildProposedOptionsHeader(),
                      const SizedBox(height: 24),
                      ...venueOptions.map((option) => Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: _buildOptionCard(option),
                          )),
                      _buildAddNewOptionButton(),
                      const SizedBox(height: 32),
                      _buildLaunchEventButton(),
                      const SizedBox(height: 120), // Espaço para o BottomNav
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

  // ================== COMPONENTES DE UI ==================
  Widget _buildEventImageSection() {
    return GestureDetector(
      onTap: _showImagePickerModal,
      child: Container(
        width: double.infinity,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.6),
          borderRadius: BorderRadius.circular(24),
          image: eventImageUrl != null
              ? DecorationImage(image: NetworkImage(eventImageUrl!), fit: BoxFit.cover)
              : null,
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: eventImageUrl == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_photo_alternate_rounded, size: 32, color: const Color(0xFF8B80F9).withOpacity(0.7)),
                  const SizedBox(height: 8),
                  Text(
                    'Capa do Evento',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ],
              )
            : Stack(
                children: [
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => setState(() => eventImageUrl = null),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, color: Colors.white, size: 16),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // CORRIGIDO: boxShadow movido para Container externo
  Widget _buildEventNameSection() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: eventNameController,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: Color(0xFF2D2D2D)),
        decoration: InputDecoration(
          hintText: 'Nome do evento *',
          hintStyle: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.w600),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        ),
      ),
    );
  }

  Widget _buildDateOptionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Opções de Data',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF2D2D2D)),
            ),
            GestureDetector(
              onTap: _showAddDateModal,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B80F9).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.add, size: 16, color: Color(0xFF8B80F9)),
                    SizedBox(width: 4),
                    Text(
                      'Adicionar',
                      style: TextStyle(fontSize: 12, color: Color(0xFF8B80F9), fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (dateOptions.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(
              child: Text(
                'Nenhuma data adicionada. Toque em "Adicionar".',
                style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w500),
              ),
            ),
          )
        else
          ...dateOptions.map((dateOption) => _buildDateCard(dateOption)),
      ],
    );
  }

  Widget _buildDateCard(DateRangeOption dateOption) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F7FF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.date_range_rounded, color: Color(0xFF8B80F9)),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${dateOption.startDate.day}/${dateOption.startDate.month}/${dateOption.startDate.year} - ${dateOption.endDate.day}/${dateOption.endDate.month}/${dateOption.endDate.year}',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF2D2D2D)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getDateRangeDuration(dateOption),
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () => _showEditDateModal(dateOption),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.edit_rounded, size: 16, color: Colors.grey),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  setState(() => dateOptions.remove(dateOption));
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.delete_outline_rounded, size: 16, color: Colors.red.shade400),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getDateRangeDuration(DateRangeOption dateOption) {
    final difference = dateOption.endDate.difference(dateOption.startDate).inDays;
    return difference == 0 ? '1 dia' : '$difference dias';
  }

  void _showAddDateModal() {
    DateTime? startDate;
    DateTime? endDate;

    showModalBottomSheet<DateRangeOption?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 24),
              const Text('Adicionar Período', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF2D2D2D))),
              const SizedBox(height: 24),
              const Text('Data de Início', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black87)),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: startDate ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) setState(() => startDate = date);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F7FF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        startDate != null
                            ? '${startDate!.day.toString().padLeft(2,'0')}/${startDate!.month.toString().padLeft(2,'0')}/${startDate!.year}'
                            : 'Selecione a data de início',
                        style: TextStyle(color: startDate != null ? Colors.black87 : Colors.grey.shade500, fontWeight: FontWeight.w600),
                      ),
                      const Icon(Icons.calendar_today_rounded, color: Color(0xFF8B80F9), size: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Data de Fim', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black87)),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: endDate ?? (startDate ?? DateTime.now()),
                    firstDate: startDate ?? DateTime.now(),
                    lastDate: (startDate ?? DateTime.now()).add(const Duration(days: 365)),
                  );
                  if (date != null) setState(() => endDate = date);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F7FF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        endDate != null
                            ? '${endDate!.day.toString().padLeft(2,'0')}/${endDate!.month.toString().padLeft(2,'0')}/${endDate!.year}'
                            : 'Selecione a data de fim',
                        style: TextStyle(color: endDate != null ? Colors.black87 : Colors.grey.shade500, fontWeight: FontWeight.w600),
                      ),
                      const Icon(Icons.calendar_today_rounded, color: Color(0xFF8B80F9), size: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (startDate != null && endDate != null) {
                      if (endDate!.isAfter(startDate!) || endDate!.isAtSameMomentAs(startDate!)) {
                        Navigator.pop(context, DateRangeOption(startDate: startDate!, endDate: endDate!));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('A data de fim deve ser após a data de início')),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B80F9),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text('ADICIONAR PERÍODO', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: 1.0)),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    ).then((newDateRange) {
      if (newDateRange != null) {
        setState(() => dateOptions.add(newDateRange));
      }
    });
  }

  void _showEditDateModal(DateRangeOption dateOption) {
    DateTime startDate = dateOption.startDate;
    DateTime endDate = dateOption.endDate;

    showModalBottomSheet<DateRangeOption?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 24),
              const Text('Editar Período', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF2D2D2D))),
              const SizedBox(height: 24),
              const Text('Data de Início', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black87)),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: startDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) setState(() => startDate = date);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F7FF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${startDate.day.toString().padLeft(2,'0')}/${startDate.month.toString().padLeft(2,'0')}/${startDate.year}',
                        style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
                      ),
                      const Icon(Icons.calendar_today_rounded, color: Color(0xFF8B80F9), size: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Data de Fim', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black87)),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: endDate,
                    firstDate: startDate,
                    lastDate: startDate.add(const Duration(days: 365)),
                  );
                  if (date != null) setState(() => endDate = date);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F7FF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${endDate.day.toString().padLeft(2,'0')}/${endDate.month.toString().padLeft(2,'0')}/${endDate.year}',
                        style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
                      ),
                      const Icon(Icons.calendar_today_rounded, color: Color(0xFF8B80F9), size: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (endDate.isAfter(startDate) || endDate.isAtSameMomentAs(startDate)) {
                      Navigator.pop(context, DateRangeOption(startDate: startDate, endDate: endDate));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('A data de fim deve ser após a data de início')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B80F9),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text('SALVAR ALTERAÇÕES', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: 1.0)),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    ).then((updatedDateRange) {
      if (updatedDateRange != null) {
        setState(() {
          final index = dateOptions.indexOf(dateOption);
          if (index != -1) dateOptions[index] = updatedDateRange;
        });
      }
    });
  }

  void _showImagePickerModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Adicionar Imagem', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
            const SizedBox(height: 20),
            _buildShareOption(Icons.link_rounded, 'Inserir URL da imagem', () {
              Navigator.pop(context);
              _showImageUrlDialog();
            }),
            const SizedBox(height: 12),
            _buildShareOption(Icons.photo_library_rounded, 'Escolher da galeria', () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Funcionalidade em desenvolvimento')),
              );
            }),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void _showImageUrlDialog() {
    final TextEditingController urlController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('URL da Imagem', style: TextStyle(fontWeight: FontWeight.w800)),
        content: TextField(
          controller: urlController,
          decoration: InputDecoration(
            hintText: 'https://exemplo.com/imagem.jpg',
            filled: true,
            fillColor: const Color(0xFFF8F7FF),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () {
              if (urlController.text.isNotEmpty) {
                setState(() => eventImageUrl = urlController.text);
              }
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B80F9),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('Adicionar', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildShareOption(IconData icon, String label, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F7FF),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: const Color(0xFF8B80F9)),
      ),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildProposedOptionsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'Locais Sugeridos',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF2D2D2D)),
        ),
        GestureDetector(
          onTap: _showAddOptionModal,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF8B80F9).withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              children: [
                Icon(Icons.add, size: 16, color: Color(0xFF8B80F9)),
                SizedBox(width: 4),
                Text(
                  'Adicionar',
                  style: TextStyle(fontSize: 12, color: Color(0xFF8B80F9), fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddNewOptionButton() {
    return GestureDetector(
      onTap: _showAddOptionModal,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(color: Color(0xFFF8F7FF), shape: BoxShape.circle),
              child: const Icon(Icons.add_location_alt_rounded, color: Color(0xFF8B80F9), size: 22),
            ),
            const SizedBox(width: 16),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Adicionar Novo Local', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF2D2D2D))),
                SizedBox(height: 2),
                Text('Detalhes, custos e cronogramas', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w600)),
              ],
            )
          ],
        ),
      ),
    );
  }

  // ========== MODAL DE ADICIONAR NOVO LOCAL ==========
  void _showAddOptionModal() {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController venueNameController = TextEditingController();
    final TextEditingController priceController = TextEditingController();
    final TextEditingController priceDetailController = TextEditingController();
    final TextEditingController imageUrlController = TextEditingController();
    List<ActivityUI> activities = [];
    String scheduleName = '';
    List<ActivityUI> scheduleActivities = [];

    showModalBottomSheet<VenueOption?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              left: 24,
              right: 24,
              top: 12,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag Handle
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
                  'Novo Local',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF2D2D2D), letterSpacing: -0.5),
                ),
                const SizedBox(height: 24),
                
                // Imagem do Local (Pequeno)
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(color: const Color(0xFFF8F7FF), borderRadius: BorderRadius.circular(16)),
                      child: const Icon(Icons.image_rounded, color: Color(0xFF8B80F9)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildModalTextFieldSoft(imageUrlController, 'URL da Imagem (Opcional)', 'https://...', isOptional: true),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                _buildModalTextFieldSoft(titleController, 'Título da Opção *', 'Ex: Opção Luxo'),
                const SizedBox(height: 16),
                _buildModalTextFieldSoft(venueNameController, 'Nome do Local *', 'Ex: Vila das Dunas Resort'),
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(child: _buildModalTextFieldSoft(priceController, 'Preço Total *', 'Ex: 1500', isPrice: true)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildModalTextFieldSoft(priceDetailController, 'Detalhe (Opcional)', 'Ex: / pessoa')),
                  ],
                ),
                const SizedBox(height: 24),
                
                const Text('Cronograma do Local', style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF2D2D2D), fontSize: 16)),
                const SizedBox(height: 12),
                _buildModalTextFieldSoft(
                  TextEditingController(),
                  'Nome do Cronograma',
                  'Ex: Sábado à tarde',
                  onChanged: (value) => setState(() => scheduleName = value),
                ),
                const SizedBox(height: 12),
                
                ...scheduleActivities.asMap().entries.map((entry) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: _buildActivityWithTimeItemSoft(scheduleActivities, entry.key, setState),
                    )),
                
                TextButton.icon(
                  onPressed: () => setState(() => scheduleActivities.add(ActivityUI(name: ''))),
                  icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
                  label: const Text('Adicionar Atividade ao Cronograma', style: TextStyle(fontWeight: FontWeight.w700)),
                  style: TextButton.styleFrom(foregroundColor: const Color(0xFF8B80F9)),
                ),
                const SizedBox(height: 24),
                
                const Text('Atividades Gerais do Local', style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF2D2D2D), fontSize: 16)),
                const SizedBox(height: 12),
                ...activities.asMap().entries.map((entry) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: _buildActivityItemSoft(activities, entry.key, setState),
                    )),
                
                TextButton.icon(
                  onPressed: () => setState(() => activities.add(ActivityUI(name: ''))),
                  icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
                  label: const Text('Adicionar Atividade Geral', style: TextStyle(fontWeight: FontWeight.w700)),
                  style: TextButton.styleFrom(foregroundColor: const Color(0xFF8B80F9)),
                ),
                
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_validateVenueForm(titleController, venueNameController, priceController)) {
                        final priceValue = double.tryParse(priceController.text.replaceAll(',', '.')) ?? 0.0;
                        final newOption = VenueOption(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          title: titleController.text,
                          venueName: venueNameController.text,
                          venueLink: null,
                          price: priceValue,
                          priceDetail: priceDetailController.text,
                          imageUrl: imageUrlController.text.isNotEmpty ? imageUrlController.text : defaultImages[venueOptions.length % defaultImages.length],
                          activities: activities.where((a) => a.name.isNotEmpty).toList(),
                          scheduleName: scheduleName.isNotEmpty ? scheduleName : 'Cronograma Padrão',
                          scheduleActivities: scheduleActivities.where((a) => a.name.isNotEmpty).toList(),
                          total: priceValue * 1.5,
                        );
                        Navigator.pop(context, newOption);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B80F9),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: const Text('ADICIONAR OPÇÃO DE LOCAL', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1.0)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).then((newOption) {
      if (newOption != null) {
        setState(() => venueOptions.add(newOption));
      }
    });
  }

  // Elementos de Texto com o Design Soft Minimalista
  Widget _buildModalTextFieldSoft(
    TextEditingController controller,
    String label,
    String hint, {
    bool isPrice = false,
    bool isOptional = false,
    Function(String)? onChanged,
  }) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      keyboardType: isPrice ? TextInputType.number : TextInputType.text,
      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.w600),
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400),
        filled: true,
        fillColor: const Color(0xFFF8F7FF),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    );
  }

  Widget _buildActivityItemSoft(List<ActivityUI> activities, int index, StateSetter setState) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            onChanged: (value) => setState(() => activities[index].name = value),
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Ex: Piscina liberada',
              filled: true,
              fillColor: const Color(0xFFF8F7FF),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: () => setState(() => activities.removeAt(index)),
          icon: Icon(Icons.remove_circle_outline_rounded, color: Colors.red.shade300),
        ),
      ],
    );
  }

  Widget _buildActivityWithTimeItemSoft(List<ActivityUI> activities, int index, StateSetter setState) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: TextField(
            onChanged: (value) => setState(() => activities[index].name = value),
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Ex: Check-in',
              filled: true,
              fillColor: const Color(0xFFF8F7FF),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            onChanged: (value) => setState(() => activities[index].time = value),
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            decoration: InputDecoration(
              hintText: '14:00',
              filled: true,
              fillColor: const Color(0xFFF8F7FF),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
        const SizedBox(width: 4),
        IconButton(
          onPressed: () => setState(() => activities.removeAt(index)),
          icon: Icon(Icons.remove_circle_outline_rounded, color: Colors.red.shade300),
        ),
      ],
    );
  }

  bool _validateVenueForm(TextEditingController title, TextEditingController venue, TextEditingController price) {
    if (title.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor, insira um título')));
      return false;
    }
    if (venue.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor, insira o nome do local')));
      return false;
    }
    if (price.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor, insira o preço')));
      return false;
    }
    final priceValue = double.tryParse(price.text.replaceAll(',', '.'));
    if (priceValue == null || priceValue < 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Preço inválido. Use apenas números.')));
      return false;
    }
    return true;
  }

  Widget _buildOptionCard(VenueOption option) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'OPÇÃO ${venueOptions.indexOf(option) + 1}',
                    style: const TextStyle(color: Color(0xFF8B80F9), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.2),
                  ),
                  const SizedBox(height: 4),
                  Text(option.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF2D2D2D))),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(color: Color(0xFFF8F7FF), shape: BoxShape.circle),
                child: const Icon(Icons.location_on_rounded, color: Color(0xFF8B80F9)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Detalhes do Local', style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF2D2D2D))),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => _showEditScheduleModal(option),
                    child: Text(
                      'Editar Cronograma',
                      style: TextStyle(fontWeight: FontWeight.w700, color: const Color(0xFFF9A866), fontSize: 12),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => _showEditVenueModal(option),
                    child: const Text(
                      'Alterar Local',
                      style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF8B80F9), fontSize: 12),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFFF8F7FF), borderRadius: BorderRadius.circular(20)),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    option.imageUrl,
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(width: 70, height: 70, color: Colors.white, child: const Icon(Icons.broken_image, color: Colors.grey));
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(option.venueName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                      const SizedBox(height: 6),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text('R\$ ${option.price.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF8B80F9))),
                          const SizedBox(width: 4),
                          Text(option.priceDetail, style: TextStyle(color: Colors.grey.shade500, fontSize: 12, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          if (option.scheduleActivities.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFFFFF7F0), borderRadius: BorderRadius.circular(20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.schedule_rounded, size: 18, color: Color(0xFFF9A866)),
                      const SizedBox(width: 8),
                      Text(
                        option.scheduleName,
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFFF9A866)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...option.scheduleActivities.map((activity) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            Icon(Icons.circle, size: 6, color: Colors.grey.shade400),
                            const SizedBox(width: 8),
                            Expanded(child: Text(activity.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
                            if (activity.time != null)
                              Text(activity.time!, style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          ],
          if (option.activities.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text('Atividades do Local', style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF2D2D2D))),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: option.activities.map((activity) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(color: const Color(0xFFF8F7FF), borderRadius: BorderRadius.circular(16)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.celebration_rounded, size: 14, color: Color(0xFF8B80F9)),
                        const SizedBox(width: 6),
                        Text(activity.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF8B80F9))),
                      ],
                    ),
                  )).toList(),
            ),
          ]
        ],
      ),
    );
  }

  void _showEditScheduleModal(VenueOption option) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Edição em breve!')));
  }

  void _showEditVenueModal(VenueOption option) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Edição em breve!')));
  }

  Widget _buildLaunchEventButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : _launchEvent,
        icon: _isLoading
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Icon(Icons.rocket_launch_rounded, size: 20),
        label: Text(
          _isLoading ? 'CRIANDO...' : 'LANÇAR EVENTO',
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1.0),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF8B80F9),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 20),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ),
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
          Navigator.pushReplacementNamed(context, '/main');
        } else if (index == 1) {
          // Já está na tela de criar
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