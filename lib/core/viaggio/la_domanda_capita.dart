import 'dart:async';

import 'package:firebase_ai/firebase_ai.dart';

import 'il_tema_della_domanda_libera.dart';
import 'il_tetto_delle_chiamate.dart';
import 'la_domanda_del_viaggio.dart';

/// **DA DOVE VIENE IL TEMA DI UNA DOMANDA LIBERA**, per il rapporto e per il
/// registro dei guasti.
enum FonteDelTema {
  /// Il modello ha risposto in tempo con uno dei sei id.
  modello,

  /// Il modello non ha risposto in tempo, o ha sbagliato, o non c'e' rete: ha
  /// deciso la tabella delle parole.
  parole,

  /// Nessuno dei due ha trovato un tema: si usa il ramo senza domanda.
  nessuna,
}

/// La firma di una chiamata al modello: riceve l'istruzione e la domanda, e
/// restituisce il testo della risposta. Si inietta nelle prove, dove Firebase
/// non c'e'.
typedef ChiamataDelModello = Future<String?> Function(
    String istruzione, String domanda);

/// **LA DOMANDA LIBERA VIENE CAPITA.** Ordine DI voce 02, 12 settembre 2026.
///
/// **LA VIA PRINCIPALE E' IL MODELLO**: una chiamata secca, a temperatura zero,
/// che riceve la domanda e i sei temi con la loro descrizione e restituisce
/// **un id solo**. Non puo' scrivere altro: la risposta e' vincolata a un
/// elenco chiuso (`text/x.enum`), quindi il testo libero in uscita non esiste
/// per costruzione.
///
/// **LA VIA DI RISERVA E' LA TABELLA DELLE PAROLE**, sempre presente e sempre
/// funzionante senza rete, in `IlTemaDellaDomandaLibera`. Si cade li' **senza
/// che la persona se ne accorga** quando il modello non risponde entro
/// [pazienza], quando risponde con qualcosa che non e' uno dei sei id, o quando
/// la chiamata fallisce. Il guasto va nel registro, **mai alla persona**.
///
/// **La tabella da sola capisce una domanda su tre**, misurato su dodici
/// domande scritte dopo averla congelata, e non ne sbaglia nessuna: e' una rete
/// di sicurezza prudente, non un modo di capire. Il capire e' del modello.
abstract final class LaDomandaCapita {
  /// **IL MODELLO**, in una costante sola.
  ///
  /// **L'ordine nomina Gemini 3.5 Flash Lite**, e il modello esiste: ma a
  /// Vertex AI risponde **solo dall'endpoint `global`**, verificato il 12
  /// settembre 2026 contando i token con ogni modello. L'app fissa Vertex a
  /// `europe-west1` di proposito, e le domande libere sono dati personali.
  /// Finche' il fondatore non sceglie, qui c'e' il modello che l'app usa gia'
  /// in `europe-west1`: passare a quello dell'ordine e' questa riga e la
  /// prossima.
  static const String modello = 'gemini-2.5-flash-lite';

  /// **LA REGIONE**, in una costante sola. Vedi [modello].
  static const String regione = 'europe-west1';

  /// **IL RAGIONAMENTO SI SPEGNE, per tutte le chiamate del Viaggio.**
  ///
  /// **Trovato dalla prova col modello vero della voce DI.03**, 12 settembre
  /// 2026. I modelli Flash *pensano* prima di rispondere, e i token del
  /// pensiero si contano dentro il tetto dell'uscita: con un tetto di ottanta
  /// token Gemini 3.6 Flash rispondeva *"Here"* e si fermava, trenta volte su
  /// trenta, e Gemini 2.5 Flash avrebbe fatto lo stesso nell'app, dove nessuno
  /// gli diceva di non pensare. **Ogni scena sarebbe caduta sulla riserva
  /// senza che nessuna prova se ne accorgesse**, perche' nelle prove il modello
  /// e' una finta.
  ///
  /// Qui si sceglie un elenco o si scrive una riga: il ragionamento non serve.
  /// La serie 2.5 lo spegne col budget a zero, la serie 3 col livello minimo,
  /// che e' il piu' basso che accetta.
  static ThinkingConfig ragionamentoPer(String modello) =>
      modello.startsWith('gemini-2.5')
          ? ThinkingConfig.withThinkingBudget(0)
          : ThinkingConfig.withThinkingLevel(ThinkingLevel.minimal);

  /// **QUANTO SI ASPETTA IL MODELLO**: due secondi, dall'ordine. Oltre, si cade
  /// sulla tabella.
  static const Duration pazienza = Duration(seconds: 2);

  /// **L'ISTRUZIONE**, costruita dalle sei domande scritte: i temi e le loro
  /// parole non si ricopiano qui a mano.
  static String get istruzione {
    final b = StringBuffer(
        'Sei un classificatore. Ricevi una domanda scritta da una persona '
        'prima di un viaggio interiore. Rispondi con UNO SOLO di questi sei '
        'identificatori: quello che dice cosa la persona sta chiedendo, non di '
        'chi o di cosa parla.\n');
    for (final d in LaDomandaDelViaggio.gliaScritte) {
      b.writeln('- ${d.id}: ${d.tema}. Per esempio: ${d.testo}');
    }
    b.write('Esempio: "Mia sorella diventerà presto mamma?" parla di una '
        'persona ma chiede quando: quindi è attesa. Rispondi solo con '
        'l\'identificatore, senza altro testo.');
    return b.toString();
  }

  /// **IL TEMA DI UNA DOMANDA LIBERA, e da dove viene.**
  ///
  /// [chiamata] si inietta nelle prove; [seGuasto] riceve il perche' quando
  /// il modello non ha deciso, per il registro dei guasti.
  static Future<(TemaDellaDomanda?, FonteDelTema)> tema(
    String domanda, {
    ChiamataDelModello? chiamata,
    void Function(Object errore)? seGuasto,
    Future<bool> Function() prendiUnaChiamata =
        IlTettoDelleChiamate.prendiUnaChiamata,
  }) async {
    final testo = domanda.trim();
    if (testo.isEmpty) return (null, FonteDelTema.nessuna);
    // **IL TETTO TECNICO, ordine DI voce 15.** Oltre la decima chiamata del
    // giorno il modello non si chiama: decide la tabella, e la persona non se
    // ne accorge.
    if (!await prendiUnaChiamata()) {
      final dalleParole = IlTemaDellaDomandaLibera.perParole(testo);
      return (
        dalleParole,
        dalleParole == null ? FonteDelTema.nessuna : FonteDelTema.parole,
      );
    }
    try {
      final risposta =
          await (chiamata ?? _chiamataVera)(istruzione, testo).timeout(pazienza);
      final id = _pulisci(risposta);
      final dalModello = TemaDellaDomanda.daId(id);
      if (dalModello != null) return (dalModello, FonteDelTema.modello);
      seGuasto?.call(RispostaFuoriDaiSei(risposta));
    } catch (errore) {
      // **IL GUASTO VA NEL REGISTRO, MAI ALLA PERSONA.** Timeout, rete
      // assente, servizio spento: la persona non se ne accorge, perche' la
      // tabella risponde lo stesso.
      seGuasto?.call(errore);
    }
    final dalleParole = IlTemaDellaDomandaLibera.perParole(testo);
    return (
      dalleParole,
      dalleParole == null ? FonteDelTema.nessuna : FonteDelTema.parole,
    );
  }

  /// Toglie spazi, virgolette e maiuscole: l'elenco chiuso rende il testo
  /// libero impossibile, ma una virgoletta di troppo non deve costare il tema.
  static String? _pulisci(String? s) =>
      s?.trim().replaceAll(RegExp(r'''["'`.\s]'''), '').toLowerCase();

  static Future<String?> _chiamataVera(
      String istruzione, String domanda) async {
    final m = FirebaseAI.vertexAI(location: regione).generativeModel(
      model: modello,
      systemInstruction: Content.system(istruzione),
      generationConfig: GenerationConfig(
        temperature: 0,
        maxOutputTokens: 64,
        thinkingConfig: ragionamentoPer(modello),
        // **L'ELENCO CHIUSO**: il modello non puo' scrivere altro che uno dei
        // sei id. E' la regola dell'ordine, "nessun testo libero in uscita",
        // resa impossibile da violare invece che chiesta per favore.
        responseMimeType: 'text/x.enum',
        responseSchema: Schema.enumString(enumValues: [
          for (final t in TemaDellaDomanda.values) t.name,
        ]),
      ),
    );
    final r = await m.generateContent([Content.text(domanda)]);
    return r.text;
  }
}

/// Il modello ha risposto con qualcosa che non e' uno dei sei id.
class RispostaFuoriDaiSei implements Exception {
  const RispostaFuoriDaiSei(this.risposta);
  final String? risposta;
  @override
  String toString() => 'il modello ha risposto "$risposta", che non è uno '
      'dei sei temi';
}
