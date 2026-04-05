import '../../models/magic_card.dart';

class LegalityHelper {
  static bool isLegal(MagicCard card, String format) {
    if (card.legalities == null) return false;

    final fmt = format.toLowerCase();

    // Na Mesa de Cozinha, tudo é permitido!
    if (fmt == 'mesa de cozinha') return true;

    String? status;
    switch (fmt) {
      case 'standard':
        status = card.legalities!.standard;
        break;
      case 'pioneer':
        status = card.legalities!.pioneer;
        break;
      case 'modern':
        status = card.legalities!.modern;
        break;
      case 'legacy':
        status = card.legalities!.legacy;
        break;
      case 'commander':
        status = card.legalities!.commander;
        break;
      case 'pauper':
        status = card.legalities!.pauper;
        break;
      default:
        return false;
    }

    return status == 'legal';
  }
}
