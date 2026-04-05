import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mana_icons_flutter/mana_icons_flutter.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import '../../models/magic_card.dart';
import '../../services/gemini_service.dart';

class CardDetailView extends StatefulWidget {
  final MagicCard card;

  const CardDetailView({super.key, required this.card});

  @override
  State<CardDetailView> createState() => _CardDetailViewState();
}

class _CardDetailViewState extends State<CardDetailView> {
  bool _isPortuguese = false;
  bool _isLoadingTranslation = false;
  String? _translationResult;
  late final GeminiService _geminiService;

  @override
  void initState() {
    super.initState();
    _geminiService = GeminiService();
    _geminiService.initialize();
  }

  Future<void> _toggleLanguage(bool toPortuguese) async {
    if (_isPortuguese == toPortuguese) return;

    setState(() {
      _isPortuguese = toPortuguese;
    });

    if (toPortuguese && _translationResult == null) {
      setState(() => _isLoadingTranslation = true);

      final result = await _geminiService.explainCard(widget.card);

      if (mounted) {
        setState(() {
          _translationResult = result;
          _isLoadingTranslation = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: Text(widget.card.name),
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
                child: widget.card.imageUrl.isNotEmpty
                    ? Image.network(
                        widget.card.imageUrl,
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

            // 2. Nome e Custo de Mana
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    widget.card.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                _buildManaDisplay(widget.card.manaCost),
              ],
            ),
            const SizedBox(height: 8),

            // 3. Linha de Tipo e Coleção
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.card.typeLine,
                    style: const TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                    ),
                  ),
                ),
                if (widget.card.power != null && widget.card.toughness != null)
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
                      '${widget.card.power} / ${widget.card.toughness}',
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
              '${widget.card.setName} (${widget.card.setCode.toUpperCase()}) • ${widget.card.rarity.toUpperCase()}',
              style: const TextStyle(fontSize: 12, color: Colors.orangeAccent),
            ),

            const Divider(color: Colors.white24, height: 32),

            // 4. SEÇÃO DO ORÁCULO
            _buildOracleSection(),

            const Divider(color: Colors.white24, height: 32),

            // 5. Preços
            const Text(
              'Mercado (Scryfall)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            _buildPricesSection(widget.card.prices),
            const SizedBox(height: 24),

            // 6. Legalidade nos Formatos
            const Text(
              'Formatos Válidos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            _buildLegalitiesSection(widget.card.legalities),

            const SizedBox(height: 40),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            Navigator.pop(context), // Volta pra tela anterior (Scanner)
        backgroundColor: Colors.orange,
        icon: const Icon(Icons.document_scanner, color: Colors.black),
        label: const Text(
          'Escanear Outra',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildOracleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'O Oráculo',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  _languageButton('EN', !_isPortuguese),
                  _languageButton('PT-BR ✨', _isPortuguese),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        if (!_isPortuguese) ...[
          if (widget.card.oracleText != null &&
              widget.card.oracleText!.isNotEmpty)
            MarkdownBody(
              data: widget.card.oracleText!,
              inlineSyntaxes: [ManaSyntax()],
              builders: {'mana': ManaBuilder()},
              styleSheet: MarkdownStyleSheet(
                p: const TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  color: Colors.white70,
                ),
              ),
            )
          else
            const Text(
              'Sem texto de regras.',
              style: TextStyle(color: Colors.grey),
            ),

          if (widget.card.flavorText != null &&
              widget.card.flavorText!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              widget.card.flavorText!,
              style: const TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
          ],
        ] else ...[
          if (_isLoadingTranslation)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24.0),
              child: Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(color: Colors.orange),
                    SizedBox(height: 16),
                    Text(
                      'Consultando o mestre...',
                      style: TextStyle(color: Colors.orange),
                    ),
                  ],
                ),
              ),
            )
          else if (_translationResult != null)
            MarkdownBody(
              data: _translationResult!,
              inlineSyntaxes: [ManaSyntax()],
              builders: {'mana': ManaBuilder()},
              styleSheet: MarkdownStyleSheet(
                p: const TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  color: Colors.white70,
                ),
                h3: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                  height: 2,
                ),
                strong: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ],
    );
  }

  Widget _languageButton(String text, bool isSelected) {
    return GestureDetector(
      onTap: () => _toggleLanguage(text.contains('PT')),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.orange : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white54,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildManaDisplay(String? manaString) {
    if (manaString == null || manaString.isEmpty) {
      return const SizedBox.shrink();
    }
    final matches = RegExp(r'\{([^}]+)\}').allMatches(manaString);
    return Wrap(
      spacing: 4,
      children: matches.map((match) {
        final symbol = match.group(1) ?? '';
        return ManaIconHelper.getIconWidget(symbol, size: 22);
      }).toList(),
    );
  }

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
    return 5.00;
  }

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

  String _convertToBrl(String? usdPrice, double cotacaoAtual) {
    if (usdPrice == null || usdPrice.isEmpty) return 'R\$ ---';
    final double? usd = double.tryParse(usdPrice);
    if (usd == null) return 'R\$ ---';
    final double brl = usd * cotacaoAtual;
    return 'R\$ ${brl.toStringAsFixed(2).replaceAll('.', ',')}';
  }

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

// ==============================================================================
// --- CLASSES AUXILIARES PARA EXTENDER O MARKDOWN ---
// ==============================================================================

class ManaIconHelper {
  static Widget getIconWidget(String symbol, {double size = 16}) {
    IconData? iconData;
    Color? iconColor;

    final s = symbol.toUpperCase();

    switch (s) {
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
      case 'C':
        iconData = ManaIcons.ms_c;
        iconColor = const Color(0xFFCCCCCC);
        break;
      case 'X':
        iconData = ManaIcons.ms_x;
        iconColor = Colors.grey[400];
        break;
      case 'T':
        iconData = ManaIcons.ms_tap;
        iconColor = Colors.grey[400];
        break;
      case '0':
        iconData = ManaIcons.ms_0;
        iconColor = Colors.grey[400];
        break;
      case '1':
        iconData = ManaIcons.ms_1;
        iconColor = Colors.grey[400];
        break;
      case '2':
        iconData = ManaIcons.ms_2;
        iconColor = Colors.grey[400];
        break;
      case '3':
        iconData = ManaIcons.ms_3;
        iconColor = Colors.grey[400];
        break;
      case '4':
        iconData = ManaIcons.ms_4;
        iconColor = Colors.grey[400];
        break;
      case '5':
        iconData = ManaIcons.ms_5;
        iconColor = Colors.grey[400];
        break;
      case '6':
        iconData = ManaIcons.ms_6;
        iconColor = Colors.grey[400];
        break;
      case '7':
        iconData = ManaIcons.ms_7;
        iconColor = Colors.grey[400];
        break;
      case '8':
        iconData = ManaIcons.ms_8;
        iconColor = Colors.grey[400];
        break;
      case '9':
        iconData = ManaIcons.ms_9;
        iconColor = Colors.grey[400];
        break;
      case '10':
        iconData = ManaIcons.ms_10;
        iconColor = Colors.grey[400];
        break;
      default:
        if (RegExp(r'^\d+$').hasMatch(s)) {
          iconData = IconData(
            0xe900 + int.parse(s),
            fontFamily: ManaIcons.ms_0.fontFamily,
          );
          iconColor = Colors.grey[400];
        }
    }

    if (iconData != null) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 1),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black54,
              blurRadius: 1,
              offset: Offset(1, 1),
            ),
          ],
        ),
        child: Icon(iconData, color: iconColor, size: size),
      );
    }

    bool isHybrid = s.contains('/');
    return Container(
      width: isHybrid ? size * 1.4 : size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFCCCCCC),
        shape: isHybrid ? BoxShape.rectangle : BoxShape.circle,
        borderRadius: isHybrid ? BorderRadius.circular(size / 2) : null,
        border: Border.all(color: Colors.black45, width: 0.5),
      ),
      child: Center(
        child: Text(
          s,
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: size * 0.6,
            height: 1,
          ),
        ),
      ),
    );
  }
}

class ManaSyntax extends md.InlineSyntax {
  ManaSyntax() : super(r'\{([^{}]+)\}');

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    final symbol = match.group(1);

    final element = md.Element.empty('mana');
    element.attributes['symbol'] = symbol!;

    parser.addNode(element);
    return true;
  }
}

class ManaBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final symbol = element.attributes['symbol'] ?? '';

    return Baseline(
      baseline: 14,
      baselineType: TextBaseline.alphabetic,
      child: ManaIconHelper.getIconWidget(symbol, size: 16),
    );
  }
}
