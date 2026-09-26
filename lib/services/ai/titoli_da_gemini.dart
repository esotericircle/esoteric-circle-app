/// IL TITOLO DI UNA CONVERSAZIONE, SCRITTO DA GEMINI. Ordine DZ voce 04.
///
/// **Decisione del fondatore del 18 settembre 2026**: il titolo lo scrive il
/// modello, come fanno i chatbot, dopo la prima risposta. Una chiamata breve
/// per conversazione, sul modello leggero: e' un compito ripetitivo, e il
/// modello leggero e' quello che la regola del progetto vuole per i compiti
/// ripetitivi.
///
/// **Il modello sta nella regione dei dati**, regola DJ.03: `gemini-2.5-flash-
/// lite` e' fra i modelli verificati in `LaRegioneDeiDati`, e la guardia
/// `i_modelli_stanno_nella_regione_dei_dati` lo pretende.
///
/// **Se qualcosa non va, il titolo e' nullo**, e vale quello di ripiego: la
/// prima domanda accorciata. Un titolo non e' mai un motivo per un errore a
/// video.
library;

import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/foundation.dart';

import '../../core/chat/le_conversazioni_passate.dart';
import '../../core/config/la_regione_dei_dati.dart';
import '../../core/maestro/maestro.dart';
import '../../core/viaggio/la_domanda_capita.dart';

class TitoliDaGemini extends ScrittoreDeiTitoli {
  const TitoliDaGemini();

  static const String modello = 'gemini-2.5-flash-lite';

  /// L'istruzione, in italiano come l'app: poche parole, niente virgolette,
  /// niente nomi di Maestri, e mai il contenuto di un responso al posto del
  /// tema della domanda.
  ///
  /// **Scelta fra tre stesure con la sonda vera**, sei chiamate ciascuna nella
  /// regione dei dati: chiedere di "non rivolgersi alla persona" faceva
  /// scrivere *"Il cielo di oggi ti chiede di rallentare"*, cioe' la risposta
  /// in seconda persona; l'etichetta di una cartella e il divieto della
  /// seconda persona danno *"Oroscopo di oggi e cielo"*, *"Energia nelle
  /// relazioni questa settimana"*, *"Fronte verticale e natura ricercatrice"*.
  static const String istruzione =
      'Scrivi il titolo di una conversazione fra una persona e un Maestro '
      'esoterico, come l\'etichetta di una cartella: nomina il tema della '
      'domanda della persona in tre-sei parole, in italiano, con la maiuscola '
      'solo alla prima parola e ai nomi propri. Non usare la seconda persona. '
      'Niente virgolette, niente punto finale, niente emoji, niente nome del '
      'Maestro. Rispondi solo col titolo.';

  @override
  Future<String?> scrivi({
    required Maestro maestro,
    required String domanda,
    required String risposta,
  }) async {
    try {
      final m = FirebaseAI.vertexAI(location: LaRegioneDeiDati.regione)
          .generativeModel(
        model: modello,
        systemInstruction: Content.system(istruzione),
        generationConfig: GenerationConfig(
          temperature: 0.3,
          maxOutputTokens: 24,
          // Senza ragionamento: ventiquattro token servono al titolo, e un
          // ragionamento acceso se li prenderebbe tutti.
          thinkingConfig: LaDomandaCapita.ragionamentoPer(modello),
        ),
      );
      final breveRisposta =
          risposta.length > 600 ? risposta.substring(0, 600) : risposta;
      final r = await m.generateContent([
        Content.text('Domanda della persona: $domanda\n'
            'Inizio della risposta: $breveRisposta'),
      ]).timeout(const Duration(seconds: 12));
      return LeConversazioniPassate.pulisci(r.text);
    } catch (errore) {
      debugPrint('Titolo della conversazione: il modello non risponde. '
          '$errore');
      return null;
    }
  }
}
