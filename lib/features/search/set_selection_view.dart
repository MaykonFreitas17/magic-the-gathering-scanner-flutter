import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/mtg_set.dart';

class SetSelectionView extends StatefulWidget {
  final List<MtgSet> availableSets;
  final List<String>
  alreadySelected; // Para lembrar o que o usuário já tinha marcado

  const SetSelectionView({
    super.key,
    required this.availableSets,
    required this.alreadySelected,
  });

  @override
  State<SetSelectionView> createState() => _SetSelectionViewState();
}

class _SetSelectionViewState extends State<SetSelectionView> {
  List<MtgSet> _filteredSets = [];
  final Set<String> _selectedCodes = {};
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Ordena da mais nova para a mais antiga (Z-A pela data)
    widget.availableSets.sort((a, b) => b.releasedAt.compareTo(a.releasedAt));

    _filteredSets = widget.availableSets;
    _selectedCodes.addAll(widget.alreadySelected);

    // Ouvinte para a barra de pesquisa local
    _searchController.addListener(_filterList);
  }

  void _filterList() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredSets = widget.availableSets.where((set) {
        return set.name.toLowerCase().contains(query) ||
            set.code.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text(
          'Selecionar Coleções',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.grey[900],
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          TextButton(
            onPressed: () => setState(() => _selectedCodes.clear()),
            child: const Text('Limpar', style: TextStyle(color: Colors.orange)),
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de pesquisa fixa no topo
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Buscar coleção (Ex: Zendikar, MH3)',
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: Colors.orange),
                filled: true,
                fillColor: Colors.grey[850],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Lista desenhada dinamicamente (ListView.builder evita travamentos)
          Expanded(
            child: ListView.builder(
              itemCount: _filteredSets.length,
              itemBuilder: (context, index) {
                final set = _filteredSets[index];
                final isSelected = _selectedCodes.contains(set.code);

                final DateTime date = DateTime.parse(set.releasedAt);

                final String formattedDate = DateFormat(
                  'dd/MM/yyyy',
                ).format(date);

                return CheckboxListTile(
                  title: Text(
                    set.name,
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    '${set.code.toUpperCase()} • Lançamento: $formattedDate',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  activeColor: Colors.orange,
                  checkColor: Colors.black,
                  value: isSelected,
                  onChanged: (bool? checked) {
                    setState(() {
                      if (checked == true) {
                        _selectedCodes.add(set.code);
                      } else {
                        _selectedCodes.remove(set.code);
                      }
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
      // Botão para confirmar a seleção
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
              // Devolve a lista de códigos selecionados para a tela anterior
              Navigator.pop(context, _selectedCodes.toList());
            },
            child: Text(
              'Confirmar (${_selectedCodes.length})',
              style: const TextStyle(
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
}
