import 'dart:convert';

import '../maestro/maestro.dart';
import 'chat_message.dart';
import 'il_filo_del_consulto.dart';

/// La porta verso il modello che giudica la coerenza: un'istruzione e un
/// testo, e torna il testo grezzo del verdetto. Il provider dei Maestri la
/// apre con Flash-Lite, il banco del filo con la sua chiamata a Vertex.
typedef ChiamataDellaCoerenza = Future<String?> Function(
    String istruzione, String testo);

/// Chi sa giudicare la coerenza di una risposta: il provider vero.
abstract interface class LaPortaDellaCoerenza {
  Future<String?> giudicaLaCoerenza(String istruzione, String testo);
}

/// Il verdetto della rete: il punto fermo contraddetto e perche'.
typedef PuntoContraddetto = ({String punto, String motivo, String di});

/// **LA RETE DELLA COERENZA. Ordine FE voci 10 e 17.**
///
/// La legge della coerenza e il controllo finale stanno nell'istruzione,
/// ma al banco del filo col modello vero le contraddizioni scendevano senza
/// sparire: 0, 4 e 2 su sessanta giudizi in tre giri del 6 ottobre 2026
/// (docs/collaudo/banchi_col_modello/filo/2026-10-06T0819, 0833, 0839).
/// Erano vere: nel percorso B Medora diceva "non affrettare, pianifica" e
/// Calìgo "Inizia. Non procrastinare", senza scrivere "io leggo
/// diversamente". La voce di Calìgo, fatta di frasi nette, vinceva
/// sull'istruzione.
///
/// Qui la risposta si controlla dopo che e' nata: quando nel consulto ha
/// gia' parlato un altro Maestro, una chiamata breve chiede se la risposta
/// nuova contraddice un punto fermo senza dirlo. Se si', la risposta si
/// corregge corta come per le altre reti, con la correzione che nomina il
/// punto.
///
/// **Le altre forme provate e misurate, il 6 ottobre 2026**, tre giri del
/// banco ciascuna (180 risposte giudicate): la rete accesa a ogni turno
/// (3 contraddizioni, ma il 18 per cento di costo in piu'), la rete su
/// Flash invece di Flash-Lite (7), i punti fermi strutturati con il tempo e
/// il mezzo estratti e confrontati campo con campo (9, e l'11 per cento di
/// costo in piu'). Questa forma ne ha date 4 col 2 per cento di costo in
/// piu', ed e' quella scelta dal fondatore: nessuna scendeva sotto il
/// rumore, che fra un giro e l'altro va da 0 a 5.
abstract final class LaReteDellaCoerenza {
  /// Quante risposte di prima si mettono fra i punti fermi.
  static const int risposteDiPrima = 3;

  /// Quanto di ciascuna risposta di prima: il consiglio e il tempo stanno
  /// in testa e nella riga d'oro, che sta in coda.
  static const int caratteriPerRisposta = 700;

  /// Il modello della rete: un controllo piccolo, Flash-Lite.
  static const String modello = 'gemini-2.5-flash-lite';

  /// La regola del controllo: la stessa definizione di contraddizione del
  /// giudice del banco (tool/banchi_col_modello/il_filo_del_consulto_col_modello_test.dart),
  /// perche' la rete guardi la stessa cosa che il banco misura.
  static const String istruzione = 'Controlli la coerenza di un consulto '
      'fra una persona e una o più guide spirituali. Ricevi i PUNTI FERMI già '
      'dati nel consulto e una RISPOSTA NUOVA.\n\n'
      'La risposta nuova CONTRADDICE se afferma il contrario di un '
      'consiglio, di un gesto (il mezzo, l’oggetto), di un tempo o di un '
      'fatto già dato nei punti fermi, senza dire apertamente che cambia '
      'parere e perché. Esempio: prima «aspetta la fine del mese», poi '
      '«muoviti subito» senza spiegare il cambio; prima «tra due giorni», poi '
      '«il tempo è maturo» o «adesso». Una guida diversa che dice '
      'di vedere le cose in un altro modo e lo dichiara apertamente («io '
      'leggo diversamente») NON contraddice. Un passo nuovo che si aggiunge '
      'al consiglio già dato NON contraddice. Una risposta su un tema '
      'diverso da quello dei punti fermi NON contraddice.\n\n'
      'Rispondi SOLO con un oggetto JSON: {"contraddice": true o false, '
      '"punto": "il punto fermo contraddetto, con le sue parole", '
      '"di": "il nome della guida che lo ha dato", '
      '"motivo": "una frase"}. Se non contraddice, "punto", "di" e '
      '"motivo" sono vuoti.';

  /// **LA RETE PARTE SOLO DOVE SERVE. Scelta del fondatore del 6 ottobre
  /// 2026**, *"Tienila, recupero il costo"*: in ogni turno del consulto la
  /// rete aggiungeva circa il 18 per cento al costo della chat (banco del
  /// filo, 0,28 dollari a giro senza, 0,33 con), e l'ordine FE voce 20
  /// vuole il costo per consulto non piu' alto di prima. Parte quando nel
  /// consulto ha gia' parlato un Maestro diverso da [chi]: e' li' che la
  /// voce di un Maestro ne contraddice un altro (percorso B), mentre dentro
  /// le risposte di un Maestro solo regge l'istruzione. Misurato: 0,289
  /// dollari a giro, il 2 per cento in piu'.
  ///
  /// **LA RETE SUL RITORNO AL TEMA, PROVATA E TOLTA, 7 ottobre 2026.** Al
  /// banco del filo sul commit 6e7511db il percorso D (una domanda, un tema
  /// diverso, poi "Torniamo alla mia prima domanda") ha dato due
  /// contraddizioni di un Maestro con se stesso
  /// (docs/collaudo/banchi_col_modello/filo/2026-10-07T0008). La rete accesa
  /// anche sul ritorno (commit 74a1e00f e 297da8e7) le toglieva, ma con 12-13
  /// chiamate in piu' a giro (167 contro 154-155, 0,297 dollari contro
  /// 0,287), e il fondatore non accetta aumenti di costo. Il ritorno al tema
  /// lo tiene adesso il controllo finale del consulto, che porta il gesto
  /// vero del Maestro (`LaLeggeDellaCoerenza.controlloFinalePer`), a costo
  /// zero.
  static bool serve(Maestro chi) {
    final s = IlFiloDelConsulto.scheda;
    if (s == null) return false;
    return s.daMaestro != chi || s.pareri.any((p) => p.maestro != chi);
  }

  /// I punti fermi per [chi]: la scheda del consulto, le risposte di prima
  /// del Maestro nella [storia] e quelle intere degli altri che il filo
  /// ricorda. Nullo quando non c'e' niente da rispettare.
  static String? puntiFermi(Maestro chi, List<ChatMessage> storia) {
    final righe = <String>[];
    final s = IlFiloDelConsulto.scheda;
    if (s != null) {
      righe.add('La domanda iniziale, fatta a ${s.daMaestro.displayName}: '
          '«${s.tema}»');
      for (final p in s.pareri) {
        righe.add('${p.maestro.displayName} ha detto: «${p.parere}»');
      }
    }
    String corto(String testo) {
      final t = testo.trim();
      return t.length > caratteriPerRisposta
          ? '${t.substring(0, caratteriPerRisposta ~/ 2)} [...] '
              '${t.substring(t.length - caratteriPerRisposta ~/ 2)}'
          : t;
    }

    final prima = [
      for (final m in storia.reversed)
        if (m.isMaestro && m.text.trim().isNotEmpty) m,
    ].take(risposteDiPrima).toList().reversed;
    final gia = <String>{};
    for (final m in prima) {
      gia.add(m.text.trim());
      righe.add('${m.autoreEffettivo(chi).displayName}, risposta di prima: '
          '«${corto(m.text)}»');
    }
    // **LE RISPOSTE INTERE DEGLI ALTRI MAESTRI.** La scheda porta di ogni
    // parere il nucleo, la prima frase e la riga d'oro; il tempo ("aspetta
    // la Luna in Bilancia") sta spesso nel corpo. Al banco del 6 ottobre
    // 2026 (giro delle 09:16, percorso B) Calìgo diceva "non rimandare"
    // contro un'attesa di Medora scritta nel corpo, e la rete non la vedeva.
    final dalFilo = [
      for (final t in IlFiloDelConsulto.frasiDelConsulto)
        if (!gia.contains(t.trim()) && t.trim().length > 80) t,
    ].take(risposteDiPrima).toList().reversed;
    for (final t in dalFilo) {
      righe.add('Risposta di prima nel consulto: «${corto(t)}»');
    }
    return righe.isEmpty ? null : righe.join('\n');
  }

  /// Il testo che il modello giudica.
  static String richiesta(
          {required String puntiFermi, required String risposta}) =>
      'PUNTI FERMI DEL CONSULTO:\n$puntiFermi\n\nRISPOSTA NUOVA:\n$risposta';

  /// Legge il verdetto. Nullo se la risposta non contraddice, o se il
  /// verdetto non si legge: una rete che non capisce non corregge.
  static PuntoContraddetto? leggi(String? grezzo) {
    if (grezzo == null) return null;
    final inizio = grezzo.indexOf('{');
    final fine = grezzo.lastIndexOf('}');
    if (inizio < 0 || fine <= inizio) return null;
    try {
      final j = jsonDecode(grezzo.substring(inizio, fine + 1));
      if (j is! Map || j['contraddice'] != true) return null;
      final punto = '${j['punto'] ?? ''}'.trim();
      if (punto.isEmpty) return null;
      return (
        punto: punto,
        motivo: '${j['motivo'] ?? ''}'.trim(),
        di: '${j['di'] ?? ''}'.trim(),
      );
    } on FormatException {
      return null;
    }
  }

  /// La correzione per la voce: nomina il punto fermo e le due strade.
  ///
  /// **LE DUE STRADE SONO DUE FRASI D'APERTURA, dal 7 ottobre 2026.** Al
  /// banco del filo sul commit 4035a096 (filo/2026-10-07T0259, percorso B)
  /// le tre contraddizioni del giro erano risposte gia' corrette dalla rete:
  /// Calìgo, dopo la correzione, diceva ancora "esponi domani" contro il
  /// "fine mese" di Medora e "Non aspettare" contro "attendi un ciclo
  /// lunare". La correzione su Flash-Lite (scelta del fondatore, FE.20)
  /// riceveva due strade descritte e non ne prendeva nessuna: adesso
  /// riceve le due prime frasi da scrivere, col nome di chi ha dato il
  /// punto (memoria del progetto: la correzione ripete le parole da
  /// scrivere). Stessa chiamata, stesso modello: nessun costo in piu'.
  static String correzione(PuntoContraddetto p, {Maestro? chi}) {
    final di = p.di.toLowerCase();
    Maestro? daChi;
    for (final m in Maestro.values) {
      if (di == m.displayName.toLowerCase() ||
          di == m.nomeAVideo.toLowerCase()) {
        daChi = m;
      }
    }
    final suo = di.isEmpty || (chi != null && daChi == chi);
    // Il nome come la persona lo legge a video, con l'accento di Calìgo.
    final nome = daChi?.nomeAVideo ?? p.di;
    final strade = suo
        ? 'Riscrivi la risposta cominciando con «Come ti ho già detto, …» e '
            'porta avanti quel punto: stesso gesto, stesso mezzo, stesso '
            'tempo, poi il passo che viene dopo.'
        : 'Riscrivi la risposta cominciando con una di queste due frasi, '
            'completata con parole tue: «Come ti ha detto $nome, …» per '
            'portare avanti quel punto con lo stesso gesto, lo stesso mezzo e '
            'lo stesso tempo; oppure «Io leggo diversamente da $nome: …» col '
            'perché.';
    return 'LA TUA RISPOSTA CONTRADDICE UN PUNTO FERMO DEL CONSULTO SENZA '
        'DIRLO: «${p.punto}»${p.motivo.isEmpty ? '' : ' (${p.motivo})'}. '
        '$strade Il gesto finale non contraddice quel punto. Tutto il resto '
        'della risposta resta com’è.';
  }

  /// **IL CONTROLLO.** Torna la correzione da dare alla voce, o nullo.
  /// Senza un altro Maestro nel consulto, o senza punti fermi, non chiama
  /// il modello.
  static Future<String?> controlla({
    required Maestro chi,
    required List<ChatMessage> storia,
    required String risposta,
    required ChiamataDellaCoerenza chiamata,
  }) async {
    if (!serve(chi)) return null;
    final punti = puntiFermi(chi, storia);
    if (punti == null || risposta.trim().isEmpty) return null;
    final verdetto = leggi(await chiamata(
        istruzione, richiesta(puntiFermi: punti, risposta: risposta)));
    return verdetto == null ? null : correzione(verdetto, chi: chi);
  }
}
