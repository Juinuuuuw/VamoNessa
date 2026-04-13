import 'package:flutter/material.dart';

// Model classes
class Activity {
  String name;
  String? time;

  Activity({required this.name, this.time});
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
  List<Activity> activities;
  String scheduleName;
  List<Activity> scheduleActivities;
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

class EventDetailsScreen extends StatefulWidget {
  const EventDetailsScreen({super.key});

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  List<VenueOption> venueOptions = [];
  List<DateRangeOption> dateOptions = [];
  String selectedEventType = 'Weekend Stay';
  String? eventImageUrl;
  String eventName = '';
  final TextEditingController eventNameController = TextEditingController();

  final List<String> defaultImages = [
    'https://images.unsplash.com/photo-1571896349842-33c89424de2d?q=80&w=200&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?q=80&w=200&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1566073771259-6a8506099945?q=80&w=200&auto=format&fit=crop',
  ];

  @override
  void initState() {
    super.initState();
    _initializeSampleData();
  }

  void _initializeSampleData() {
    // Sample date options
    dateOptions = [
      DateRangeOption(
        startDate: DateTime(2024, 12, 15),
        endDate: DateTime(2024, 12, 17),
      ),
      DateRangeOption(
        startDate: DateTime(2024, 12, 20),
        endDate: DateTime(2024, 12, 22),
      ),
    ];

    // Sample venue options
    venueOptions = [
      VenueOption(
        id: '1',
        title: 'Chácara Recanto',
        venueName: 'Vila das Dunas Resort',
        venueLink: 'airbnb.com/h/dunas-resort',
        price: 1240,
        priceDetail: '/ fim de semana',
        imageUrl: defaultImages[0],
        activities: [
          Activity(name: 'Festa na Piscina'),
          Activity(name: 'Churrasco'),
        ],
        scheduleName: 'Cronograma Chácara',
        scheduleActivities: [
          Activity(name: 'Chegada & Drinks', time: '16:00'),
          Activity(name: 'Jantar', time: '20:00'),
          Activity(name: 'Festa', time: '22:00'),
        ],
        total: 1850,
      ),
      VenueOption(
        id: '2',
        title: 'Salão Alpha',
        venueName: 'Alpha Rooftop Lounge',
        venueLink: 'booking.com/alpha-lounge',
        price: 980,
        priceDetail: '/ 6 horas',
        imageUrl: defaultImages[1],
        activities: [
          Activity(name: 'Banda ao vivo'),
          Activity(name: 'Serviço de Buffet'),
        ],
        scheduleName: 'Cronograma Salão',
        scheduleActivities: [
          Activity(name: 'Welcome Drinks', time: '19:00'),
          Activity(name: 'Show', time: '21:00'),
          Activity(name: 'After Party', time: '23:00'),
        ],
        total: 1420,
      ),
    ];
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
            colors: [
              Color(0xFFF7DFCA),
              Color(0xFFE8E2FF),
              Color(0xFFD4C8FF),
            ],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildEventImageSection(),
                const SizedBox(height: 16),
                _buildEventNameSection(),
                const SizedBox(height: 24),

                _buildEventTypeSection(),
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
                const SizedBox(height: 20),
                
                _buildLaunchEventButton(),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const _CustomBottomNav(),
    );
  }

  Widget _buildEventImageSection() {
    return GestureDetector(
      onTap: _showImagePickerModal,
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(30),
          image: eventImageUrl != null
              ? DecorationImage(
                  image: NetworkImage(eventImageUrl!),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: eventImageUrl == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_photo_alternate, size: 50, color: Colors.grey.shade400),
                  const SizedBox(height: 12),
                  Text(
                    'Adicionar imagem do evento',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                  ),
                ],
              )
            : Stack(
                children: [
                  Positioned(
                    top: 12,
                    right: 12,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          eventImageUrl = null;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, color: Colors.white, size: 18),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildEventNameSection() {
    return TextField(
      controller: eventNameController,
      onChanged: (value) {
        setState(() {
          eventName = value;
        });
      },
      decoration: InputDecoration(
        hintText: 'Nome do evento *',
        filled: true,
        fillColor: Colors.white.withOpacity(0.9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: const BorderSide(color: Color(0xFF8B80F9)),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            GestureDetector(
              onTap: () => _showAddDateModal(),
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
                      'Adicionar Período',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF8B80F9),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
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
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
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
                  color: const Color(0xFF8B80F9).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(Icons.date_range, color: Color(0xFF8B80F9)),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${dateOption.startDate.day}/${dateOption.startDate.month}/${dateOption.startDate.year} - ${dateOption.endDate.day}/${dateOption.endDate.month}/${dateOption.endDate.year}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getDateRangeDuration(dateOption),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
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
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.edit, size: 18, color: Colors.grey),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  setState(() {
                    dateOptions.remove(dateOption);
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Período removido!')),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(Icons.delete, size: 18, color: Colors.red.shade400),
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
    if (difference == 0) {
      return '1 dia';
    }
    return '$difference dias';
  }

  void _showAddDateModal() {
    DateTime? startDate;
    DateTime? endDate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Adicionar Período',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              
              // Data de Início
              const Text(
                'Data de Início',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: startDate ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    setState(() {
                      startDate = date;
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        startDate != null
                            ? '${startDate!.day}/${startDate!.month}/${startDate!.year}'
                            : 'Selecione a data de início',
                        style: TextStyle(
                          color: startDate != null ? Colors.black87 : Colors.grey.shade500,
                        ),
                      ),
                      const Icon(Icons.calendar_today, color: Color(0xFF8B80F9)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Data de Fim
              const Text(
                'Data de Fim',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: endDate ?? (startDate ?? DateTime.now()),
                    firstDate: startDate ?? DateTime.now(),
                    lastDate: (startDate ?? DateTime.now()).add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    setState(() {
                      endDate = date;
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        endDate != null
                            ? '${endDate!.day}/${endDate!.month}/${endDate!.year}'
                            : 'Selecione a data de fim',
                        style: TextStyle(
                          color: endDate != null ? Colors.black87 : Colors.grey.shade500,
                        ),
                      ),
                      const Icon(Icons.calendar_today, color: Color(0xFF8B80F9)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (startDate != null && endDate != null) {
                      if (endDate!.isAfter(startDate!) || endDate!.isAtSameMomentAs(startDate!)) {
                        setState(() {
                          dateOptions.add(DateRangeOption(
                            startDate: startDate!,
                            endDate: endDate!,
                          ));
                        });
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Período adicionado!')),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('A data de fim deve ser após a data de início')),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B80F9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text('Adicionar Período'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditDateModal(DateRangeOption dateOption) {
    DateTime startDate = dateOption.startDate;
    DateTime endDate = dateOption.endDate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Editar Período',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              
              // Data de Início
              const Text(
                'Data de Início',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: startDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    setState(() {
                      startDate = date;
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${startDate.day}/${startDate.month}/${startDate.year}',
                        style: const TextStyle(color: Colors.black87),
                      ),
                      const Icon(Icons.calendar_today, color: Color(0xFF8B80F9)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Data de Fim
              const Text(
                'Data de Fim',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: endDate,
                    firstDate: startDate,
                    lastDate: startDate.add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    setState(() {
                      endDate = date;
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${endDate.day}/${endDate.month}/${endDate.year}',
                        style: const TextStyle(color: Colors.black87),
                      ),
                      const Icon(Icons.calendar_today, color: Color(0xFF8B80F9)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (endDate.isAfter(startDate) || endDate.isAtSameMomentAs(startDate)) {
                      setState(() {
                        dateOption.startDate = startDate;
                        dateOption.endDate = endDate;
                      });
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Período atualizado!')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('A data de fim deve ser após a data de início')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B80F9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text('Salvar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showImagePickerModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Adicionar Imagem',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildShareOption(Icons.link, 'Inserir URL da imagem', () {
              Navigator.pop(context);
              _showImageUrlDialog();
            }),
            const SizedBox(height: 12),
            _buildShareOption(Icons.photo_library, 'Escolher da galeria', () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Funcionalidade em desenvolvimento')),
              );
            }),
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
        title: const Text('URL da Imagem'),
        content: TextField(
          controller: urlController,
          decoration: const InputDecoration(
            hintText: 'https://exemplo.com/imagem.jpg',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (urlController.text.isNotEmpty) {
                setState(() {
                  eventImageUrl = urlController.text;
                });
              }
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B80F9),
            ),
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
  }

  Widget _buildLaunchEventButton() {
    return Container(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _launchEvent,
        icon: const Icon(Icons.rocket_launch, size: 24),
        label: const Text(
          'Lançar Evento',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF8B80F9),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 3,
        ),
      ),
    );
  }

  void _launchEvent() {
    if (eventNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, insira o nome do evento')),
      );
      return;
    }

    // Navegar para tela de votação
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VotingScreen(
          eventName: eventNameController.text,
          eventType: _getEventTypeText(selectedEventType),
          dateOptions: dateOptions,
          venueOptions: venueOptions,
          eventImageUrl: eventImageUrl,
        ),
      ),
    );
  }

  String _getEventTypeText(String type) {
    switch (type) {
      case 'Weekend Stay':
        return 'Fim de Semana';
      case 'Dinner Party':
        return 'Jantar';
      case 'Birthday':
        return 'Aniversário';
      default:
        return type;
    }
  }

  Widget _buildShareOption(IconData icon, String label, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF8B80F9).withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: const Color(0xFF8B80F9)),
      ),
      title: Text(label),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget _buildEventTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tipo de Evento',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildChip('Fim de Semana', isActive: selectedEventType == 'Weekend Stay', onTap: () {
                setState(() => selectedEventType = 'Weekend Stay');
              }),
              const SizedBox(width: 8),
              _buildChip('Jantar', isActive: selectedEventType == 'Dinner Party', onTap: () {
                setState(() => selectedEventType = 'Dinner Party');
              }),
              const SizedBox(width: 8),
              _buildChip('Aniversário', isActive: selectedEventType == 'Birthday', onTap: () {
                setState(() => selectedEventType = 'Birthday');
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProposedOptionsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Expanded(
          child: Text(
            'Opções de Local',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              height: 1.2,
              color: Colors.black87,
            ),
          ),
        ),
        GestureDetector(
          onTap: () => _showAddOptionModal(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF8B80F9).withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              children: [
                Icon(Icons.add, size: 18, color: Color(0xFF8B80F9)),
                SizedBox(width: 4),
                Text(
                  'Adicionar\nOpção',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF8B80F9),
                    fontWeight: FontWeight.w600,
                    height: 1.1,
                  ),
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
      onTap: () => _showAddOptionModal(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFF8B80F9),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add_location_alt, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Adicionar Nova Opção de Local',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  'Compare custos e locais para a equipe',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  void _showAddOptionModal() {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController venueNameController = TextEditingController();
    final TextEditingController venueLinkController = TextEditingController();
    final TextEditingController priceController = TextEditingController();
    final TextEditingController priceDetailController = TextEditingController();
    List<Activity> activities = [];
    String scheduleName = '';
    List<Activity> scheduleActivities = [];
    String? imageUrl;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 24,
              right: 24,
              top: 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Adicionar Nova Opção de Local',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 24),
                
                _buildModalTextField(titleController, 'Título da Opção *', 'Ex: Chácara Recanto'),
                const SizedBox(height: 16),
                _buildModalTextField(venueNameController, 'Nome do Local *', 'Ex: Vila das Dunas Resort'),
                const SizedBox(height: 16),
                _buildModalTextField(venueLinkController, 'Link do Local (Opcional)', 'https://...', isOptional: true),
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(
                      child: _buildModalTextField(priceController, 'Preço *', 'Ex: 1240', isPrice: true),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildModalTextField(priceDetailController, 'Detalhe do Preço', 'Ex: / fim de semana'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                _buildModalTextField(TextEditingController(text: imageUrl), 'URL da Imagem', 'URL da imagem (opcional)', isOptional: true,
                  onChanged: (value) {
                    setState(() => imageUrl = value);
                  },
                ),
                const SizedBox(height: 16),
                
                // Seção do Cronograma
                const Text(
                  'Cronograma do Local',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                _buildModalTextField(TextEditingController(), 'Nome do Cronograma', 'Ex: Cronograma Principal',
                  onChanged: (value) {
                    setState(() => scheduleName = value);
                  },
                ),
                const SizedBox(height: 12),
                
                const Text(
                  'Atividades do Cronograma',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                ...scheduleActivities.asMap().entries.map((entry) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: _buildActivityWithTimeItem(scheduleActivities, entry.key, setState),
                )),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      scheduleActivities.add(Activity(name: ''));
                    });
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Adicionar Atividade ao Cronograma'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF8B80F9),
                  ),
                ),
                const SizedBox(height: 16),
                
                const Text(
                  'Atividades do Local',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                ...activities.asMap().entries.map((entry) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: _buildActivityItem(activities, entry.key, setState),
                )),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      activities.add(Activity(name: ''));
                    });
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Adicionar Atividade ao Local'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF8B80F9),
                  ),
                ),
                const SizedBox(height: 24),
                
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_validateVenueForm(titleController, venueNameController, priceController)) {
                        final newOption = VenueOption(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          title: titleController.text,
                          venueName: venueNameController.text,
                          venueLink: venueLinkController.text.isNotEmpty ? venueLinkController.text : null,
                          price: double.parse(priceController.text),
                          priceDetail: priceDetailController.text,
                          imageUrl: imageUrl ?? defaultImages[venueOptions.length % defaultImages.length],
                          activities: activities.where((a) => a.name.isNotEmpty).toList(),
                          scheduleName: scheduleName.isNotEmpty ? scheduleName : 'Cronograma Padrão',
                          scheduleActivities: scheduleActivities.where((a) => a.name.isNotEmpty).toList(),
                          total: double.parse(priceController.text) * 1.5,
                        );
                        
                        setState(() {
                          venueOptions.add(newOption);
                        });
                        
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Opção adicionada com sucesso!')),
                        );
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B80F9),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text(
                      'Adicionar Opção',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActivityItem(List<Activity> activities, int index, StateSetter setState) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            onChanged: (value) {
              setState(() {
                activities[index].name = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Nome da atividade',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: () {
            setState(() {
              activities.removeAt(index);
            });
          },
          icon: const Icon(Icons.delete, color: Colors.red),
        ),
      ],
    );
  }

  Widget _buildActivityWithTimeItem(List<Activity> activities, int index, StateSetter setState) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: TextField(
            onChanged: (value) {
              setState(() {
                activities[index].name = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Nome da atividade',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            onChanged: (value) {
              setState(() {
                activities[index].time = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Horário',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: () {
            setState(() {
              activities.removeAt(index);
            });
          },
          icon: const Icon(Icons.delete, color: Colors.red),
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
    return true;
  }

  Widget _buildModalTextField(TextEditingController controller, String label, String hint, 
      {bool isPrice = false, bool isOptional = false, Function(String)? onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          onChanged: onChanged,
          keyboardType: isPrice ? TextInputType.number : TextInputType.text,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Color(0xFF8B80F9)),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildChip(String label, {required bool isActive, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF8B80F9) : Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.grey.shade700,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard(VenueOption option) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
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
                    style: const TextStyle(
                      color: Color(0xFF8B80F9),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    option.title,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B80F9).withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.location_on, color: Color(0xFF8B80F9)),
              ),
            ],
          ),
          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Detalhes do Local',
                style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => _showEditScheduleModal(option),
                    child: Text(
                      'Editar Cronograma',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFF9A866),
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => _showEditVenueModal(option),
                    child: Text(
                      'Alterar Local',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF8B80F9),
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    option.imageUrl,
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 70,
                        height: 70,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.broken_image),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        option.venueName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      if (option.venueLink != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                option.venueLink!,
                                style: const TextStyle(color: Color(0xFF8B80F9), fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const Icon(Icons.open_in_new, size: 12, color: Color(0xFF8B80F9)),
                          ],
                        ),
                      ],
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            'R\$ ${option.price.toStringAsFixed(0)}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Text(
                            option.priceDetail,
                            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Cronograma do Local
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF9A866).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.schedule, size: 16, color: Color(0xFFF9A866)),
                    const SizedBox(width: 8),
                    Text(
                      option.scheduleName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFFF9A866),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...option.scheduleActivities.map((activity) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Icon(Icons.circle, size: 6, color: Colors.grey.shade400),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          activity.name,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      if (activity.time != null)
                        Text(
                          activity.time!,
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                        ),
                    ],
                  ),
                )).toList(),
              ],
            ),
          ),
          const SizedBox(height: 16),

          const Text(
            'Atividades do Local',
            style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: option.activities.map((activity) => Container(
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
                  Text(activity.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                ],
              ),
            )).toList(),
          ),
          const SizedBox(height: 16),

          GestureDetector(
            onTap: () => _showVoteModal(option.title),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TOTAL ESTIMADO',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade500,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        'R\$ ${option.total.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF8B80F9),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: const BoxDecoration(
                      color: Color(0xFF8B80F9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.how_to_vote, color: Colors.white, size: 20),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditScheduleModal(VenueOption option) {
    final TextEditingController scheduleNameController = TextEditingController(text: option.scheduleName);
    List<Activity> scheduleActivities = List.from(option.scheduleActivities);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 24,
              right: 24,
              top: 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Editar Cronograma',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 24),
                
                _buildModalTextField(scheduleNameController, 'Nome do Cronograma', 'Ex: Cronograma Principal'),
                const SizedBox(height: 16),
                
                const Text(
                  'Atividades do Cronograma',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                ...scheduleActivities.asMap().entries.map((entry) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: _buildActivityWithTimeItem(scheduleActivities, entry.key, setState),
                )),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      scheduleActivities.add(Activity(name: ''));
                    });
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Adicionar Atividade'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFF9A866),
                  ),
                ),
                const SizedBox(height: 24),
                
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        option.scheduleName = scheduleNameController.text;
                        option.scheduleActivities = scheduleActivities.where((a) => a.name.isNotEmpty).toList();
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Cronograma atualizado!')),
                      );
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF9A866),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text(
                      'Salvar Cronograma',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEditVenueModal(VenueOption option) {
    final TextEditingController venueController = TextEditingController(text: option.venueName);
    final TextEditingController linkController = TextEditingController(text: option.venueLink ?? '');
    final TextEditingController priceController = TextEditingController(text: option.price.toString());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Padding(
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
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Editar Detalhes do Local',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              _buildModalTextField(venueController, 'Nome do Local', 'Digite o nome do local'),
              const SizedBox(height: 16),
              _buildModalTextField(linkController, 'Link do Local', 'Digite o link', isOptional: true),
              const SizedBox(height: 16),
              _buildModalTextField(priceController, 'Preço', 'Digite o preço', isPrice: true),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      option.venueName = venueController.text;
                      option.venueLink = linkController.text.isNotEmpty ? linkController.text : null;
                      option.price = double.parse(priceController.text);
                      option.total = option.price * 1.5;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Detalhes do local atualizados!')),
                    );
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B80F9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text('Salvar Alterações'),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _showVoteModal(String optionTitle) {
    // Simula navegação para tela de votação
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Votação para $optionTitle será em outra tela!')),
    );
  }
}

// Tela de Votação (simulada)
class VotingScreen extends StatelessWidget {
  final String eventName;
  final String eventType;
  final List<DateRangeOption> dateOptions;
  final List<VenueOption> venueOptions;
  final String? eventImageUrl;

  const VotingScreen({
    super.key,
    required this.eventName,
    required this.eventType,
    required this.dateOptions,
    required this.venueOptions,
    this.eventImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(eventName),
        backgroundColor: const Color(0xFF8B80F9),
        foregroundColor: Colors.white,
      ),
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (eventImageUrl != null)
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    image: DecorationImage(
                      image: NetworkImage(eventImageUrl!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              Text(
                'Vote nas opções abaixo:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              
              // Datas para votação
              const Text(
                'Datas Disponíveis',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...dateOptions.map((date) => _buildVotingCard(
                title: 'Período',
                subtitle: '${date.startDate.day}/${date.startDate.month}/${date.startDate.year} - ${date.endDate.day}/${date.endDate.month}/${date.endDate.year}',
                onVote: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Voto registrado para este período!')),
                  );
                },
              )),
              
              const SizedBox(height: 24),
              
              // Locais para votação
              const Text(
                'Locais Disponíveis',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...venueOptions.map((venue) => _buildVotingCard(
                title: venue.title,
                subtitle: venue.venueName,
                price: 'R\$ ${venue.total.toStringAsFixed(2)}',
                onVote: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Voto registrado para ${venue.title}!')),
                  );
                },
              )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVotingCard({
    required String title,
    required String subtitle,
    String? price,
    required VoidCallback onVote,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
                if (price != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    price,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF8B80F9),
                    ),
                  ),
                ],
              ],
            ),
          ),
          ElevatedButton(
            onPressed: onVote,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B80F9),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text('Votar'),
          ),
        ],
      ),
    );
  }
}

class _CustomBottomNav extends StatelessWidget {
  const _CustomBottomNav();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 16, bottom: 32, left: 24, right: 24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
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
          _buildNavItem(Icons.home_filled, 'INÍCIO', false),
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Criar novo evento')),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFE2E0FF),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add_circle, color: Color(0xFF8B80F9)),
                  SizedBox(height: 4),
                  Text('CRIAR', style: TextStyle(color: Color(0xFF8B80F9), fontSize: 10, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          _buildNavItem(Icons.people_alt, 'SOCIAL', false),
          _buildNavItem(Icons.person, 'PERFIL', false),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    return GestureDetector(
      onTap: () {},
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
}