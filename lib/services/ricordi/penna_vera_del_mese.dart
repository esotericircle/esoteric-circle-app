/// LA PENNA VERA DELLA LETTURA DEL MESE. Ordine CG voce 11.
///
/// **Il runtime resta Google**, cioe' Gemini su Vertex, mai le API Anthropic:
/// e' la regola d'oro dello stack.
///
/// **Il modello e' Flash-Lite, e la ragione e' il listino.** La lettura lavora
/// su un pugno di numeri, non su un testo lungo, e non deve ragionare: e' il
/// compito piu' economico che il progetto abbia. Il nome vive gia' in
/// `FirebaseMaestroAiProvider.kMaestroBreveModel`, e qui si legge da li'
/// invece di riscriverlo: due nomi di modello nello stesso progetto
/// divergerebbero al primo aggiornamento.
///
/// **L'INGRESSO SONO I RIASSUNTI, MAI I TESTI PIENI**, ed e' misurabile: cio'
/// che entra in questo prompt sono conti, e i conti di un mese stanno in
/// poche centinaia di token. Una prova conta i caratteri che partono e cade se
/// crescono oltre il tetto dichiarato.
library;

import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/foundation.dart';

import '../../core/maestro/maestro.dart';
import '../../core/ricordi/lettura_del_mese.dart';
import '../../core/ricordi/riassunti_del_tempo.dart';
import '../ai/firebase_maestro_ai_provider.dart';

class PennaVeraDelMese extends PennaDelMese {
  const PennaVeraDelMese();

  /// **QUANTI CARATTERI PUO' PESARE L'INGRESSO, dichiarato e misurato.**
  ///
  /// Duemila. Un mese di riassunti sono dodici righe di numeri piu' i nomi
  /// delle arti: se questo tetto viene sfondato vuol dire che qualcuno ha
  /// infilato i testi pieni nel prompt, che e' esattamente cio' che l'ordine
  /// vieta.
  static const int massimiCaratteriInIngresso = 2000;

  /// L'ingresso della lettura, composto dai soli riassunti.
  ///
  /// Statico e pubblico perche' una prova possa misurarlo senza chiamare
  /// nessun modello.
  static String ingresso({
    required String mese,
    required RiassuntoDelTempo riassunto,
    required List<RiassuntoDelTempo> settimane,
  }) {
    final buffer = StringBuffer()
      ..writeln('Mese: $mese.')
      ..writeln('Momenti in tutto: ${riassunto.quanteVoci}.')
      ..writeln('Traguardi accesi: ${riassunto.quantiTraguardi}.')
      ..writeln('Doni aperti: ${riassunto.quantiDoni}.')
      ..writeln('Eos guadagnati: ${riassunto.eosGuadagnati}.')
      ..writeln('Momenti per Maestro: ${riassunto.perMaestro}.')
      ..writeln('Momenti per arte: ${riassunto.perArte}.')
      ..writeln('Settimane:');
    for (final s in settimane) {
      buffer.writeln('- ${s.chiave}: ${s.quanteVoci} momenti, '
          '${s.quantiTraguardi} traguardi');
    }
    return buffer.toString();
  }

  @override
  Future<String?> scrivi({
    required String mese,
    required RiassuntoDelTempo riassunto,
    required List<RiassuntoDelTempo> settimane,
    required String maestro,
  }) async {
    final chi = Maestro.values.firstWhere((m) => m.id == maestro,
        orElse: () => Maestro.medora);
    try {
      final model = FirebaseAI.vertexAI().generativeModel(
        model: FirebaseMaestroAiProvider.kMaestroBreveModel,
        systemInstruction: Content.system(_istruzione(chi)),
      );
      final testo = ingresso(
          mese: mese, riassunto: riassunto, settimane: settimane);
      final risposta = await model.generateContent([Content.text(testo)]);
      final fuori = risposta.text?.trim();
      if (fuori == null || fuori.isEmpty) return null;
      return fuori;
    } catch (errore) {
      // **Una lettura mancata non e' un guasto che la persona debba gestire**:
      // la riga non compare, e non compare nemmeno un messaggio di errore.
      debugPrint('Lettura del mese: il modello non ha risposto. $errore');
      return null;
    }
  }

  /// L'istruzione di sistema.
  ///
  /// **Parla dei NUMERI e mai della vita di una persona reale**, che e' la
  /// regola del fondatore del 28 agosto 2026: qui arrivano conti, e cio' che
  /// si puo' dire e' cosa quei conti raccontano del cammino, non cosa e'
  /// successo nella vita di chi li ha prodotti.
  static String _istruzione(Maestro maestro) =>
      'Sei ${maestro.displayName}, uno dei tre Maestri del Cerchio. Ti '
      'arrivano i CONTI del mese di una persona: quanti momenti, con quali '
      'arti, con quali Maestri, quanti traguardi. Scrivi tre o quattro frasi '
      'che raccontino il suo mese guardando quei numeri: dove è tornata '
      'spesso, cosa ha lasciato stare, cosa è cambiato da una settimana '
      'all\'altra. Parla a lei in seconda persona, con parole di uso comune. '
      'Non inventare nulla che i numeri non dicano. Non parlare della sua '
      'vita fuori dal Cerchio: tu vedi il cammino, non la persona.';
}
