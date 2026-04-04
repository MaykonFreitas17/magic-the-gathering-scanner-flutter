import 'package:flutter/material.dart';
import '../../models/magic_card.dart';
import '../../models/mtg_set.dart';
import '../../services/scryfall_service.dart';
import '../details/card_detail_view.dart';
import '../search/filters_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final ScryfallService _apiService = ScryfallService();
  final ScrollController _scrollController = ScrollController();

  final List<MagicCard> _cards = [];
  int _currentPage = 1;
  int _totalCards = 0;
  bool _isLoading = false;
  bool _hasMore = true;

  // Lista que vai guardar as coleções no fundo
  List<MtgSet> _availableSets = [];

  @override
  void initState() {
    super.initState();
    _fetchNextPage();
    _loadSetsInBackground();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent * 0.9) {
        if (!_isLoading && _hasMore) {
          _fetchNextPage();
        }
      }
    });
  }

  Future<void> _loadSetsInBackground() async {
    final sets = await _apiService.getSets();
    if (sets != null && mounted) {
      setState(() {
        _availableSets = sets;
      });
    }
  }

  Future<void> _fetchNextPage() async {
    setState(() => _isLoading = true);

    final response = await _apiService.getCards(page: _currentPage);

    if (response != null) {
      setState(() {
        _cards.addAll(response.cards);
        _totalCards = response.totalCards;
        _hasMore = response.hasMore;
        _currentPage++;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Grimório Completo',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '$_totalCards cartas',
                    style: const TextStyle(color: Colors.orange, fontSize: 12),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.tune, color: Colors.white),
                onPressed: () async {
                  if (_availableSets.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Carregando filtros, tente novamente em um segundo...',
                        ),
                        backgroundColor: Colors.orange,
                      ),
                    );
                    return;
                  }

                  final filters = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          FiltersView(availableSets: _availableSets),
                    ),
                  );

                  if (filters != null) {
                    debugPrint("Filtros escolhidos: $filters");
                  }
                },
              ),
            ],
          ),
        ),

        Expanded(
          child: _cards.isEmpty && _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.orange),
                )
              : GridView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(12.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.65,
                  ),
                  itemCount: _cards.length + (_hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _cards.length) {
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.orange),
                      );
                    }
                    return _buildCardItem(_cards[index]);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildCardItem(MagicCard card) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CardDetailView(card: card)),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: card.imageUrl.isNotEmpty
                  ? Image.network(
                      card.imageUrl,
                      fit: BoxFit.contain, // Contain manterá a carta inteira
                      width: double.infinity,
                    )
                  : Container(
                      color: Colors.grey[900],
                      width: double.infinity,
                      child: const Icon(
                        Icons.image_not_supported,
                        color: Colors.grey,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            card.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          ),
          Text(
            card.setName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
