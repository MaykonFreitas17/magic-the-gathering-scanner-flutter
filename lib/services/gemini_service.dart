import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter/foundation.dart';
import '../models/magic_card.dart';

class GeminiService {
  late final GenerativeModel _model;
  bool _isInitialized = false;

  // Inicializa o modelo pegando a chave do .env
  void initialize() {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      debugPrint('⚠️ ALERTA: Chave do Gemini não encontrada no .env');
      return;
    }

    // Vamos usar o modelo Flash, que é absurdamente rápido e barato (ideal para textos dinâmicos)
    _model = GenerativeModel(
      model: 'gemini-2.5-flash', // Modelo atualizado
      apiKey: apiKey,
    );
    _isInitialized = true;
  }

  /// Pede para a IA traduzir e explicar a carta
  Future<String> explainCard(MagicCard card) async {
    if (!_isInitialized) {
      return "O serviço de Oráculo (IA) não está configurado.";
    }

    final prompt =
        '''
Você é um Juiz Nível 3 de Magic: The Gathering e um jogador profissional muito didático.
Sua missão é explicar cartas para jogadores brasileiros.

CARTA: ${card.name}
TIPO: ${card.typeLine}
TEXTO ORIGINAL (ORACLE): ${card.oracleText ?? 'Sem texto de regras.'}

Retorne a sua resposta formatada em Markdown com as seguintes seções (e use os emojis):

### 🇧🇷 Tradução das Regras
[Traduza o Oracle Text da carta para o Português Brasileiro oficial do jogo. Mantenha os nomes de habilidades (Keywords) em inglês entre parênteses logo após a tradução, ex: Voar (Flying)]

### 📖 Como Funciona
[Explique de forma simples e direta o que essa carta faz na prática, como se estivesse ensinando um iniciante.]

### 💡 Dicas Estratégicas
[Dê 1 ou 2 exemplos práticos de como usar essa carta bem, ou sinergias comuns em formatos construídos.]
''';

    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      return response.text ?? "O Oráculo não conseguiu compreender esta carta.";
    } catch (e) {
      debugPrint('Erro no Gemini: $e');
      return "Houve um distúrbio na mana. Não foi possível consultar o Oráculo agora.";
    }
  }
}
