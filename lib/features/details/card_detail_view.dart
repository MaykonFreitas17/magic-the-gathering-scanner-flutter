import '../../models/magic_card.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CardDetailView extends StatelessWidget {
  final MagicCard card;

  const CardDetailView({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: Text(card.name),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Imagem da Carta
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.0),
                child: card.imageUrl.isNotEmpty
                    ? Image.network(
                        card.imageUrl,
                        height: 380,
                        fit: BoxFit.contain,
                      )
                    : Container(
                        height: 380,
                        width: 260,
                        color: Colors.grey[900],
                        child: const Icon(
                          Icons.image_not_supported,
                          size: 50,
                          color: Colors.grey,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 24),

            // 2. Nome e Custo de Mana (Convertido em Ícones)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    card.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                _buildManaDisplay(card.manaCost),
              ],
            ),
            const SizedBox(height: 8),

            // 3. Linha de Tipo e Coleção
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    card.typeLine,
                    style: const TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                    ),
                  ),
                ),
                // Exibe Poder/Resistência se for criatura
                if (card.power != null && card.toughness != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${card.power} / ${card.toughness}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${card.setName} (${card.setCode.toUpperCase()}) • ${card.rarity.toUpperCase()}',
              style: const TextStyle(fontSize: 12, color: Colors.orangeAccent),
            ),

            const Divider(color: Colors.white24, height: 32),

            // 4. Oracle Text
            if (card.oracleText != null && card.oracleText!.isNotEmpty) ...[
              const Text(
                'Regras (Oracle Text)',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                card.oracleText!,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 16),
            ],

            // 5. Flavor Text
            if (card.flavorText != null && card.flavorText!.isNotEmpty) ...[
              Text(
                card.flavorText!,
                style: const TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),
            ],

            const Divider(color: Colors.white24, height: 32),

            // 6. Preços (Agora com cotação ao vivo)
            const Text(
              'Mercado (Scryfall)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            _buildPricesSection(card.prices),

            const SizedBox(height: 24),

            // 7. Legalidade nos Formatos
            const Text(
              'Formatos Válidos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            _buildLegalitiesSection(card.legalities),

            const SizedBox(height: 40), // Espaço no final da tela
          ],
        ),
      ),
    );
  }

  // --- WIDGETS AUXILIARES (COMPONETIZAÇÃO) ---

  // Lógica para transformar a string "{2}{G}{U}" em bolinhas coloridas
  Widget _buildManaDisplay(String? manaString) {
    if (manaString == null || manaString.isEmpty) {
      return const SizedBox.shrink();
    }

    // Expressão regular para pegar tudo que está entre chaves {}
    final matches = RegExp(r'\{([^}]+)\}').allMatches(manaString);

    return Wrap(
      spacing: 4,
      children: matches.map((match) {
        final symbol = match.group(1) ?? '';
        return _buildSingleManaIcon(symbol);
      }).toList(),
    );
  }

  // Desenha cada bolinha de mana com as cores do Magic
  Widget _buildSingleManaIcon(String symbol) {
    Color bgColor = Colors.grey[400]!;
    Color textColor = Colors.black;

    // Tabela de cores padrão do MTG
    switch (symbol) {
      case 'W':
        bgColor = const Color(0xFFF8E7B9);
        break; // Branco
      case 'U':
        bgColor = const Color(0xFF0E68AB);
        textColor = Colors.white;
        break; // Azul
      case 'B':
        bgColor = const Color(0xFF150B00);
        textColor = Colors.white;
        break; // Preto
      case 'R':
        bgColor = const Color(0xFFD3202A);
        textColor = Colors.white;
        break; // Vermelho
      case 'G':
        bgColor = const Color(0xFF00733E);
        textColor = Colors.white;
        break; // Verde
      case 'C':
        bgColor = const Color(0xFFCCCCCC);
        break; // Incolor específico
    }

    // Se for um símbolo híbrido (ex: G/W), aumentamos um pouco a bolinha para caber o texto
    bool isHybrid = symbol.contains('/');

    return Container(
      width: isHybrid ? 30 : 22,
      height: 22,
      decoration: BoxDecoration(
        color: bgColor,
        shape: isHybrid ? BoxShape.rectangle : BoxShape.circle,
        borderRadius: isHybrid ? BorderRadius.circular(11) : null,
        boxShadow: const [
          BoxShadow(color: Colors.black54, blurRadius: 2, offset: Offset(1, 1)),
        ],
      ),
      child: Center(
        child: Text(
          symbol,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: isHybrid ? 10 : 12,
          ),
        ),
      ),
    );
  }

  // Busca a cotação do Dólar na AwesomeAPI
  Future<double> _fetchCotacaoDolar() async {
    try {
      final response = await http.get(
        Uri.parse('https://economia.awesomeapi.com.br/json/last/USD-BRL'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return double.parse(data['USDBRL']['bid']);
      }
    } catch (e) {
      debugPrint('Erro ao buscar cotação: $e');
    }
    return 5.00; // Valor de fallback caso falhe a internet
  }

  // Renderiza a caixa de preços usando FutureBuilder
  Widget _buildPricesSection(Prices? prices) {
    if (prices == null) {
      return const Text(
        'Sem dados de preço',
        style: TextStyle(color: Colors.grey),
      );
    }

    return FutureBuilder<double>(
      future: _fetchCotacaoDolar(),
      builder: (context, snapshot) {
        final bool isLoading =
            snapshot.connectionState == ConnectionState.waiting;
        final double cotacaoAtual = snapshot.data ?? 5.00;

        return Row(
          children: [
            _priceCard(
              'Normal',
              prices.usd,
              Colors.green,
              cotacaoAtual,
              isLoading,
            ),
            const SizedBox(width: 16),
            _priceCard(
              'Foil',
              prices.usdFoil,
              Colors.purpleAccent,
              cotacaoAtual,
              isLoading,
            ),
          ],
        );
      },
    );
  }

  // Card individual de Preço (Real em destaque)
  Widget _priceCard(
    String title,
    String? usdPrice,
    Color color,
    double cotacao,
    bool isLoading,
  ) {
    final String brlValue = _convertToBrl(usdPrice, cotacao);
    final String usdValue = usdPrice != null ? '\$ $usdPrice' : '---';

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 4),
            isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.orange,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    brlValue,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
            const SizedBox(height: 2),
            Text(
              'USD $usdValue',
              style: const TextStyle(color: Colors.white38, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  // Converte USD para BRL e formata no padrão brasileiro
  String _convertToBrl(String? usdPrice, double cotacaoAtual) {
    if (usdPrice == null || usdPrice.isEmpty) return 'R\$ ---';

    final double? usd = double.tryParse(usdPrice);
    if (usd == null) return 'R\$ ---';

    final double brl = usd * cotacaoAtual;

    return 'R\$ ${brl.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  // Renderiza as "Pílulas" de legalidade dos formatos principais
  Widget _buildLegalitiesSection(Legalities? legals) {
    if (legals == null) return const SizedBox.shrink();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _legalityBadge('Standard', legals.standard),
        _legalityBadge('Pioneer', legals.pioneer),
        _legalityBadge('Modern', legals.modern),
        _legalityBadge('Commander', legals.commander),
        _legalityBadge('Pauper', legals.pauper),
      ],
    );
  }

  Widget _legalityBadge(String format, String status) {
    bool isLegal = status == 'legal';
    bool isBanned = status == 'banned';

    Color bgColor = Colors.grey[800]!;
    Color textColor = Colors.grey;

    if (isLegal) {
      bgColor = Colors.green.withValues(alpha: 0.2);
      textColor = Colors.greenAccent;
    } else if (isBanned) {
      bgColor = Colors.red.withValues(alpha: 0.2);
      textColor = Colors.redAccent;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: textColor.withValues(alpha: 0.5)),
      ),
      child: Text(
        format,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
