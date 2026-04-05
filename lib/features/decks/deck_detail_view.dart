import 'package:flutter/material.dart';
import '../../services/database_service.dart';
import '../../services/scryfall_service.dart';
import '../../core/utils/legality_helper.dart';
import '../scanner/scanner_view.dart';

class DeckDetailView extends StatefulWidget {
  final Map<String, dynamic> deck;

  const DeckDetailView({super.key, required this.deck});

  @override
  State<DeckDetailView> createState() => _DeckDetailViewState();
}

class _DeckDetailViewState extends State<DeckDetailView> {
  late Map<String, dynamic> _currentDeck;

  Map<String, List<Map<String, dynamic>>> _groupedCards = {};
  int _mainDeckCount = 0;
  int _sideboardCount = 0;

  bool _isLoading = true;
  bool _isSearchingCard = false;

  @override
  void initState() {
    super.initState();
    _currentDeck = widget.deck;
    _loadCards();
  }

  Future<void> _loadCards() async {
    setState(() => _isLoading = true);
    final cards = await DatabaseService.instance.getDeckCards(
      _currentDeck['id'],
    );

    final Map<String, List<Map<String, dynamic>>> grouped = {
      'Comandante': [],
      'Criaturas': [],
      'Planeswalkers': [],
      'Mágicas Instantâneas': [],
      'Feitiços': [],
      'Artefatos': [],
      'Encantamentos': [],
      'Terrenos': [],
      'Outros': [],
      'Sideboard': [], // Categoria Especial
    };

    int mainCount = 0;
    int sideCount = 0;

    for (var card in cards) {
      final boardType = card['board_type'] as String? ?? 'main';
      final qty = card['quantity'] as int;

      if (boardType == 'sideboard') {
        grouped['Sideboard']!.add(card);
        sideCount += qty;
      } else {
        mainCount += qty;
        final type = (card['type_line'] as String?)?.toLowerCase() ?? '';

        if (type.contains('creature')) {
          grouped['Criaturas']!.add(card);
        } else if (type.contains('land')) {
          grouped['Terrenos']!.add(card);
        } else if (type.contains('instant')) {
          grouped['Mágicas Instantâneas']!.add(card);
        } else if (type.contains('sorcery')) {
          grouped['Feitiços']!.add(card);
        } else if (type.contains('artifact')) {
          grouped['Artefatos']!.add(card);
        } else if (type.contains('enchantment')) {
          grouped['Encantamentos']!.add(card);
        } else if (type.contains('planeswalker')) {
          grouped['Planeswalkers']!.add(card);
        } else {
          grouped['Outros']!.add(card);
        }
      }
    }

    // Remove as categorias que ficaram vazias
    grouped.removeWhere((key, value) => value.isEmpty);

    if (mounted) {
      setState(() {
        _groupedCards = grouped;
        _mainDeckCount = mainCount;
        _sideboardCount = sideCount;
        _isLoading = false;
      });
    }
  }

  Future<void> _changeQuantity(Map<String, dynamic> card, int delta) async {
    final format = _currentDeck['format'].toString().toLowerCase();
    int limit = format == 'commander'
        ? 1
        : (format == 'mesa de cozinha' ? 999 : 4);

    // Terrenos básicos não têm limite
    if ((card['type_line'] as String).toLowerCase().contains('basic land')) {
      limit = 999;
    }

    await DatabaseService.instance.updateCardQuantity(
      card['id'] as int,
      card['quantity'] as int,
      delta,
      limit,
    );
    _loadCards();
  }

  // --- MODAL DE EDITAR ---
  void _showEditDialog() {
    final TextEditingController nameController = TextEditingController(
      text: _currentDeck['name'],
    );
    String selectedFormat = _currentDeck['format'];
    final List<String> formats = [
      'Standard',
      'Pioneer',
      'Modern',
      'Legacy',
      'Commander',
      'Pauper',
      'Mesa de Cozinha',
    ];

    if (!formats
        .map((e) => e.toLowerCase())
        .contains(selectedFormat.toLowerCase())) {
      selectedFormat = 'pioneer';
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              backgroundColor: Colors.grey[900],
              title: const Text(
                'Editar Deck',
                style: TextStyle(color: Colors.white),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Nome do Deck',
                      labelStyle: TextStyle(color: Colors.orange),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.orange),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: selectedFormat.toLowerCase(),
                    dropdownColor: Colors.grey[850],
                    style: const TextStyle(color: Colors.white),
                    items: formats
                        .map(
                          (format) => DropdownMenuItem(
                            value: format.toLowerCase(),
                            child: Text(format),
                          ),
                        )
                        .toList(),
                    onChanged: (val) =>
                        setModalState(() => selectedFormat = val!),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                  onPressed: () async {
                    if (nameController.text.isNotEmpty) {
                      await DatabaseService.instance.updateDeck(
                        _currentDeck['id'],
                        nameController.text,
                        selectedFormat,
                      );
                      setState(() {
                        _currentDeck = {
                          ..._currentDeck,
                          'name': nameController.text,
                          'format': selectedFormat,
                        };
                      });
                      if (context.mounted) Navigator.pop(context);
                    }
                  },
                  child: const Text(
                    'Salvar',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // --- DELETAR DECK ---
  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Destruir Deck?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Tem certeza? Isso apagará todas as cartas dentro dele.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              await DatabaseService.instance.deleteDeck(_currentDeck['id']);
              if (context.mounted) {
                Navigator.pop(context);
                Navigator.pop(context, true);
              }
            },
            child: const Text(
              'Destruir',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }

  // --- GAVETA DE ADICIONAR CARTA ---
  void _showAddCardBottomSheet() {
    final TextEditingController searchController = TextEditingController();
    String targetBoard = 'main'; // Controla o destino dentro do modal

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[700],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Forjar Carta',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // TOGGLE: MAIN VS SIDEBOARD
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ChoiceChip(
                        label: const Text(
                          'Main Deck',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        selected: targetBoard == 'main',
                        onSelected: (val) =>
                            setSheetState(() => targetBoard = 'main'),
                        selectedColor: Colors.orange,
                        backgroundColor: Colors.grey[800],
                        labelStyle: TextStyle(
                          color: targetBoard == 'main'
                              ? Colors.black
                              : Colors.white,
                        ),
                      ),
                      const SizedBox(width: 16),
                      ChoiceChip(
                        label: const Text(
                          'Sideboard',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        selected: targetBoard == 'sideboard',
                        onSelected: (val) =>
                            setSheetState(() => targetBoard = 'sideboard'),
                        selectedColor: Colors.orange,
                        backgroundColor: Colors.grey[800],
                        labelStyle: TextStyle(
                          color: targetBoard == 'sideboard'
                              ? Colors.black
                              : Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: searchController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Nome exato da carta (Inglês)...',
                      hintStyle: const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: Colors.grey[800],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: _isSearchingCard
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: CircularProgressIndicator(
                                color: Colors.orange,
                                strokeWidth: 2,
                              ),
                            )
                          : IconButton(
                              icon: const Icon(
                                Icons.search,
                                color: Colors.orange,
                              ),
                              onPressed: () => _searchAndAddCard(
                                searchController.text,
                                setSheetState,
                                searchController,
                                targetBoard,
                              ),
                            ),
                    ),
                    onSubmitted: (val) => _searchAndAddCard(
                      val,
                      setSheetState,
                      searchController,
                      targetBoard,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Row(
                    children: [
                      Expanded(child: Divider(color: Colors.white24)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          'OU',
                          style: TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.white24)),
                    ],
                  ),
                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(Icons.camera_alt, color: Colors.black),
                      label: Text(
                        'Escanear para o ${targetBoard == "main" ? "Main" : "Side"}',
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () async {
                        Navigator.pop(context);
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ScannerView(
                              targetDeckId: _currentDeck['id'],
                              deckFormat: _currentDeck['format'],
                              targetBoard: targetBoard,
                            ),
                          ),
                        );
                        _loadCards();
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _searchAndAddCard(
    String name,
    Function setSheetState,
    TextEditingController controller,
    String boardType,
  ) async {
    final query = name.trim();
    if (query.isEmpty) return;

    setSheetState(() => _isSearchingCard = true);

    final api = ScryfallService();
    final response = await api.getCards(name: '!"$query"');

    if (response != null && response.cards.isNotEmpty) {
      final card = response.cards.first;
      final format = _currentDeck['format'] as String;

      if (LegalityHelper.isLegal(card, format)) {
        await DatabaseService.instance.addCardToDeck(
          _currentDeck['id'],
          card,
          format,
          boardType: boardType,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${card.name} no ${boardType == "main" ? "Main" : "Side"}!',
              ),
              backgroundColor: Colors.greenAccent,
            ),
          );
          controller.clear();
          _loadCards();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Ilegal/Banida no formato $format!'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Carta não encontrada.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }

    setSheetState(() => _isSearchingCard = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _currentDeck['name'],
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.white,
              ),
            ),
            Text(
              '${_currentDeck['format'].toUpperCase()} • $_mainDeckCount Main | $_sideboardCount Side',
              style: const TextStyle(color: Colors.orange, fontSize: 12),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            color: Colors.grey[850],
            onSelected: (value) {
              if (value == 'edit') _showEditDialog();
              if (value == 'delete') _confirmDelete();
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, color: Colors.white),
                    SizedBox(width: 8),
                    Text('Editar Deck', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.redAccent),
                    SizedBox(width: 8),
                    Text(
                      'Excluir Deck',
                      style: TextStyle(color: Colors.redAccent),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.orange))
          : _groupedCards.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 80, color: Colors.grey[800]),
                  const SizedBox(height: 16),
                  const Text(
                    'Nenhuma carta aqui.',
                    style: TextStyle(color: Colors.white54, fontSize: 18),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 80),
              itemCount: _groupedCards.keys.length,
              itemBuilder: (context, index) {
                final category = _groupedCards.keys.elementAt(index);
                final categoryCards = _groupedCards[category]!;
                final isSideboard = category == 'Sideboard';

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 24, bottom: 8),
                      child: Text(
                        '$category (${categoryCards.fold(0, (sum, c) => sum + (c['quantity'] as int))})'
                            .toUpperCase(),
                        style: TextStyle(
                          color: isSideboard
                              ? Colors.blueAccent
                              : Colors.orangeAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    ...categoryCards.map((card) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[900],
                            borderRadius: BorderRadius.circular(8),
                            border: isSideboard
                                ? Border.all(
                                    color: Colors.blueAccent.withValues(
                                      alpha: 0.3,
                                    ),
                                  )
                                : null,
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.only(
                              left: 0,
                              right: 8,
                            ),
                            leading: ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(8),
                                bottomLeft: Radius.circular(8),
                              ),
                              child:
                                  card['image_url'] != null &&
                                      card['image_url'].toString().isNotEmpty
                                  ? Image.network(
                                      card['image_url'],
                                      width: 45,
                                      height: 60,
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      width: 45,
                                      height: 60,
                                      color: Colors.grey[800],
                                      child: const Icon(
                                        Icons.image,
                                        color: Colors.white54,
                                      ),
                                    ),
                            ),
                            title: Text(
                              card['name'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            subtitle: Text(
                              card['type_line'] ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 11,
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.remove_circle_outline,
                                    color: Colors.redAccent,
                                  ),
                                  onPressed: () => _changeQuantity(card, -1),
                                ),
                                Text(
                                  '${card['quantity']}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.add_circle_outline,
                                    color: Colors.greenAccent,
                                  ),
                                  onPressed: () => _changeQuantity(card, 1),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCardBottomSheet,
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add, color: Colors.black, size: 30),
      ),
    );
  }
}
