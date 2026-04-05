import 'package:flutter/material.dart';
import 'package:mana_icons_flutter/mana_icons_flutter.dart';
import '../../services/database_service.dart';
import 'deck_detail_view.dart';

class DecksListView extends StatefulWidget {
  const DecksListView({super.key});

  @override
  State<DecksListView> createState() => _DecksListViewState();
}

class _DecksListViewState extends State<DecksListView> {
  List<Map<String, dynamic>> _decks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDecks();
  }

  // AGORA BUSCA AS CORES TAMBÉM!
  Future<void> _loadDecks() async {
    setState(() => _isLoading = true);

    final rawDecks = await DatabaseService.instance.getAllDecks();
    final List<Map<String, dynamic>> decksWithColors = [];

    // Para cada deck, vamos buscar a identidade de cor dele
    for (var deck in rawDecks) {
      final colors = await DatabaseService.instance.getDeckColors(
        deck['id'] as int,
      );
      decksWithColors.add({...deck, 'colors': colors});
    }

    if (mounted) {
      setState(() {
        _decks = decksWithColors;
        _isLoading = false;
      });
    }
  }

  void _showCreateDeckDialog() {
    final TextEditingController nameController = TextEditingController();
    String selectedFormat = 'pioneer';

    final List<String> formats = [
      'Standard',
      'Pioneer',
      'Modern',
      'Legacy',
      'Commander',
      'Pauper',
      'Mesa de Cozinha',
    ];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              backgroundColor: Colors.grey[900],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text(
                'Forjar Novo Deck',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: nameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Nome do Deck',
                      labelStyle: const TextStyle(color: Colors.orange),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.orange),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.orange, width: 2),
                      ),
                      hintText: 'Ex: Mono Red Aggro...',
                      hintStyle: TextStyle(
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Formato',
                    style: TextStyle(color: Colors.orange, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: selectedFormat.toLowerCase(),
                    dropdownColor: Colors.grey[850],
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[800],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    items: formats.map((format) {
                      return DropdownMenuItem(
                        value: format.toLowerCase(),
                        child: Text(format),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setModalState(() => selectedFormat = val!);
                    },
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
                    final name = nameController.text.trim();
                    if (name.isNotEmpty) {
                      await DatabaseService.instance.createDeck(
                        name,
                        selectedFormat,
                      );
                      if (context.mounted) {
                        Navigator.pop(context);
                        _loadDecks();
                      }
                    }
                  },
                  child: const Text(
                    'Criar',
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

  void _confirmDelete(int id, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Destruir Deck?',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Tem certeza que deseja apagar o deck "$name"?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              await DatabaseService.instance.deleteDeck(id);
              if (context.mounted) {
                Navigator.pop(context);
                _loadDecks();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text(
          'Meu Arsenal',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.orange))
          : _decks.isEmpty
          ? _buildEmptyState()
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.75,
              ),
              itemCount: _decks.length,
              itemBuilder: (context, index) {
                final deck = _decks[index];
                return _buildDeckCard(deck);
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateDeckDialog,
        backgroundColor: Colors.orange,
        icon: const Icon(Icons.add, color: Colors.black),
        label: const Text(
          'Novo Deck',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.style, size: 80, color: Colors.grey[800]),
          const SizedBox(height: 16),
          const Text(
            'Seu arsenal está vazio.',
            style: TextStyle(color: Colors.white54, fontSize: 18),
          ),
          const SizedBox(height: 8),
          const Text(
            'Forje seu primeiro deck!',
            style: TextStyle(color: Colors.orange, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildDeckCard(Map<String, dynamic> deck) {
    final coverUrl = deck['cover_image'] as String?;
    final name = deck['name'] as String;
    final format = deck['format'] as String;
    final colors =
        deck['colors'] as List<String>? ?? []; // Lista de cores do banco

    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DeckDetailView(deck: deck)),
        );
        if (result == true || result == null) {
          _loadDecks();
        }
      },
      onLongPress: () => _confirmDelete(deck['id'] as int, name),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey[900],
          boxShadow: const [
            BoxShadow(
              color: Colors.black54,
              blurRadius: 4,
              offset: Offset(2, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (coverUrl != null && coverUrl.isNotEmpty)
              Image.network(
                coverUrl,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              )
            else
              const Center(
                child: Icon(Icons.shield, size: 50, color: Colors.white12),
              ),

            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.8),
                    Colors.black,
                  ],
                  stops: const [0.4, 0.8, 1.0],
                ),
              ),
            ),

            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // LINHA NOVA: FORMATO + CORES
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          format.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.orangeAccent,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Spacer(), // Empurra os ícones para a direita
                      // Mostra as cores se o deck tiver cartas!
                      if (colors.isNotEmpty)
                        Wrap(
                          spacing: -4, // Ícones levemente sobrepostos
                          children: colors
                              .map((c) => _buildMiniManaIcon(c))
                              .toList(),
                        )
                      else if (coverUrl == null || coverUrl.isEmpty)
                        // Deck vazio (opcional visualmente amigável)
                        const Icon(
                          Icons.hourglass_empty,
                          color: Colors.grey,
                          size: 14,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // WIDGET AUXILIAR PARA DESENHAR AS CORES
  Widget _buildMiniManaIcon(String symbol) {
    IconData iconData;
    Color iconColor;

    switch (symbol) {
      case 'W':
        iconData = ManaIcons.ms_w;
        iconColor = const Color(0xFFF8E7B9);
        break;
      case 'U':
        iconData = ManaIcons.ms_u;
        iconColor = const Color(0xFF0E68AB);
        break;
      case 'B':
        iconData = ManaIcons.ms_b;
        iconColor = const Color(0xFF150B00);
        break;
      case 'R':
        iconData = ManaIcons.ms_r;
        iconColor = const Color(0xFFD3202A);
        break;
      case 'G':
        iconData = ManaIcons.ms_g;
        iconColor = const Color(0xFF00733E);
        break;
      default:
        return const SizedBox.shrink(); // Só nos importamos com as 5 cores bases
    }

    return Container(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Colors.black, blurRadius: 2, offset: Offset(1, 1)),
        ],
      ),
      child: Icon(iconData, color: iconColor, size: 16),
    );
  }
}
