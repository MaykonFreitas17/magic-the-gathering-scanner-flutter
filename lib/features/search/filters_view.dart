import 'package:flutter/material.dart';
import 'package:mana_icons_flutter/mana_icons_flutter.dart';
import '../../models/mtg_set.dart';
import 'set_selection_view.dart';

class FiltersView extends StatefulWidget {
  final List<MtgSet> availableSets;
  final Map<String, dynamic>? initialFilters;

  const FiltersView({
    super.key,
    required this.availableSets,
    this.initialFilters,
  });

  @override
  State<FiltersView> createState() => _FiltersViewState();
}

class _FiltersViewState extends State<FiltersView> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _oracleController = TextEditingController();

  List<String> _selectedSets = [];
  String? _selectedFormat;

  final Set<String> _selectedKeywords = {};
  final Set<String> _selectedTypes = {};
  final Set<String> _selectedColors = {};

  final List<String> _formats = [
    'Standard',
    'Pioneer',
    'Modern',
    'Legacy',
    'Commander',
    'Pauper',
  ];

  final List<String> _types = [
    'Artifact',
    'Battle',
    'Creature',
    'Enchantment',
    'Instant',
    'Land',
    'Planeswalker',
    'Sorcery',
  ];

  final List<String> _keywords = [
    'Flying',
    'Haste',
    'Trample',
    'Deathtouch',
    'Lifelink',
    'Menace',
    'First strike',
    'Double strike',
    'Reach',
    'Vigilance',
    'Flash',
    'Defender',
    'Hexproof',
    'Indestructible',
  ];

  final List<Map<String, dynamic>> _colors = [
    {
      'code': 'W',
      'name': 'Branco',
      'color': '0xFFF8E7B9',
      'icon': ManaIcons.ms_w,
    },
    {
      'code': 'U',
      'name': 'Azul',
      'color': '0xFF0E68AB',
      'icon': ManaIcons.ms_u,
    },
    {
      'code': 'B',
      'name': 'Preto',
      'color': '0xFF150B00',
      'icon': ManaIcons.ms_b,
    },
    {
      'code': 'R',
      'name': 'Vermelho',
      'color': '0xFFD3202A',
      'icon': ManaIcons.ms_r,
    },
    {
      'code': 'G',
      'name': 'Verde',
      'color': '0xFF00733E',
      'icon': ManaIcons.ms_g,
    },
    {
      'code': 'C',
      'name': 'Incolor',
      'color': '0xFFCCCCCC',
      'icon': ManaIcons.ms_c,
    },
  ];

  @override
  void initState() {
    super.initState();

    if (widget.initialFilters != null) {
      _nameController.text = widget.initialFilters!['name'] ?? '';
      _oracleController.text = widget.initialFilters!['oracle'] ?? '';
      _selectedFormat = widget.initialFilters!['format'];

      if (widget.initialFilters!['sets'] != null) {
        _selectedSets = List<String>.from(widget.initialFilters!['sets']);
      }
      if (widget.initialFilters!['colors'] != null) {
        _selectedColors.addAll(
          List<String>.from(widget.initialFilters!['colors']),
        );
      }
      if (widget.initialFilters!['keywords'] != null) {
        _selectedKeywords.addAll(
          List<String>.from(widget.initialFilters!['keywords']),
        );
      }
      if (widget.initialFilters!['types'] != null) {
        _selectedTypes.addAll(
          List<String>.from(widget.initialFilters!['types']),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _oracleController.dispose();
    super.dispose();
  }

  void _clearFilters() {
    setState(() {
      _nameController.clear();
      _oracleController.clear();
      _selectedSets.clear();
      _selectedFormat = null;
      _selectedColors.clear();
      _selectedKeywords.clear();
      _selectedTypes.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text(
          'Filtros da Taverna',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          TextButton(
            onPressed: _clearFilters,
            child: const Text('Limpar', style: TextStyle(color: Colors.orange)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Nome da Carta'),
            _buildTextField(_nameController, 'Ex: Sol Ring, Jace...'),
            const SizedBox(height: 24),

            _buildSectionTitle('Regras / Descrição'),
            _buildTextField(_oracleController, 'Ex: draw a card, flying...'),
            const SizedBox(height: 24),

            _buildSectionTitle('Tipos de Carta'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _types.map((type) {
                final isSelected = _selectedTypes.contains(type.toLowerCase());
                return FilterChip(
                  label: Text(
                    type,
                    style: TextStyle(
                      color: isSelected ? Colors.black : Colors.white,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: Colors.orange,
                  backgroundColor: Colors.grey[850],
                  showCheckmark: false,
                  onSelected: (selected) {
                    setState(() {
                      selected
                          ? _selectedTypes.add(type.toLowerCase())
                          : _selectedTypes.remove(type.toLowerCase());
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            _buildSectionTitle('Habilidades (Keywords)'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _keywords.map((kw) {
                final isSelected = _selectedKeywords.contains(kw.toLowerCase());
                return FilterChip(
                  label: Text(
                    kw,
                    style: TextStyle(
                      color: isSelected ? Colors.black : Colors.white,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: Colors.orangeAccent,
                  backgroundColor: Colors.grey[850],
                  showCheckmark: false,
                  onSelected: (selected) {
                    setState(() {
                      selected
                          ? _selectedKeywords.add(kw.toLowerCase())
                          : _selectedKeywords.remove(kw.toLowerCase());
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            _buildSectionTitle('Coleções'),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                _selectedSets.isEmpty
                    ? 'Nenhuma coleção selecionada'
                    : '${_selectedSets.length} coleção(ões) selecionada(s)',
                style: TextStyle(
                  color: _selectedSets.isEmpty ? Colors.grey : Colors.white,
                ),
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                color: Colors.orange,
                size: 16,
              ),
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SetSelectionView(
                      availableSets: widget.availableSets,
                      alreadySelected: _selectedSets,
                    ),
                  ),
                );
                if (result != null) {
                  setState(() => _selectedSets = result as List<String>);
                }
              },
            ),
            const Divider(color: Colors.white24),
            const SizedBox(height: 24),

            _buildSectionTitle('Formato Válido'),
            DropdownButtonFormField<String>(
              value: _selectedFormat,
              dropdownColor: Colors.grey[900],
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[850],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              hint: const Text(
                'Qualquer formato',
                style: TextStyle(color: Colors.grey),
              ),
              items: _formats.map((format) {
                return DropdownMenuItem(
                  value: format.toLowerCase(),
                  child: Text(format),
                );
              }).toList(),
              onChanged: (val) => setState(() => _selectedFormat = val),
            ),
            const SizedBox(height: 24),

            _buildSectionTitle('Cores'),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _colors.map((colorMap) {
                final isSelected = _selectedColors.contains(colorMap['code']);
                final bgColor = Color(int.parse(colorMap['color'] as String));
                final textColor =
                    (colorMap['code'] == 'W' || colorMap['code'] == 'C')
                    ? Colors.black
                    : Colors.white;

                return FilterChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        colorMap['icon'] as IconData,
                        color: textColor,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        colorMap['name'] as String,
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: bgColor.withValues(alpha: 0.3),
                  selectedColor: bgColor,
                  selected: isSelected,
                  showCheckmark: false,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  onSelected: (selected) {
                    setState(() {
                      selected
                          ? _selectedColors.add(colorMap['code'] as String)
                          : _selectedColors.remove(colorMap['code'] as String);
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.pop(context, {
                'name': _nameController.text,
                'oracle': _oracleController.text,
                'sets': _selectedSets,
                'format': _selectedFormat,
                'types': _selectedTypes.toList(),
                'keywords': _selectedKeywords.toList(),
                'colors': _selectedColors.toList(),
              });
            },
            child: const Text(
              'Aplicar Filtros',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38),
        filled: true,
        fillColor: Colors.grey[850],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
