import 'package:flutter/material.dart';
import '../../models/magic_card.dart';
import '../../services/scryfall_service.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  // A variável que vai guardar a nossa "Promise" de buscar as cartas
  late Future<List<MagicCard>> _cardsFuture;
  final ScryfallService _apiService = ScryfallService();

  @override
  void initState() {
    super.initState();
    // Disparamos a busca na API exatamente no momento em que a tela nasce
    // Como definimos lá no Service, isso vai trazer as cartas válidas no Pioneer!
    _cardsFuture = _apiService.getFeedCards();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<MagicCard>>(
      future: _cardsFuture,
      builder: (context, snapshot) {
        // Estado 1: Está carregando? Mostra o spinner.
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.orange),
          );
        }

        // Estado 2: Deu erro? (Ex: sem internet)
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Erro ao carregar o grimório.\nVerifique sua internet.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red[300]),
            ),
          );
        }

        // Estado 3: Sucesso, mas a lista veio vazia?
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Nenhuma carta encontrada.'));
        }

        // Estado 4: Sucesso com dados! Vamos montar a lista.
        final cards = snapshot.data!;

        return ListView.builder(
          itemCount: cards.length,
          // O padding dá um respiro nas bordas da lista
          padding: const EdgeInsets.all(8.0),
          itemBuilder: (context, index) {
            final card = cards[index];

            return Card(
              margin: const EdgeInsets.only(bottom: 12.0),
              elevation: 4,
              // O ListTile é um widget pronto do Flutter perfeito para listas (Ícone + Título + Subtítulo)
              child: ListTile(
                contentPadding: const EdgeInsets.all(8.0),
                // Lado Esquerdo: A imagem da carta (se não tiver URL, mostra um ícone de erro)
                leading: card.imageUrl.isNotEmpty
                    ? Image.network(card.imageUrl, width: 50, fit: BoxFit.cover)
                    : const Icon(Icons.image_not_supported, size: 50),

                // Centro: Nome da carta
                title: Text(
                  card.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),

                // Abaixo do Título: Custo de Mana e Tipo
                subtitle: Text('${card.manaCost}\n${card.typeLine}'),

                // Lado Direito: Ícone de seta para indicar que é clicável
                trailing: const Icon(Icons.chevron_right, color: Colors.grey),

                // Ação ao clicar (por enquanto não faz nada)
                onTap: () {
                  print('Clicou na carta: ${card.name}');
                },
              ),
            );
          },
        );
      },
    );
  }
}
