import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'color_tokens.dart';

/// Layer 1: primitivi tipografici.
///
/// Due famiglie incluse nel bundle come asset locali (nessuna rete): una serif
/// cerimoniale per i titoli e le voci dei Maestri (Cinzel), una serif leggibile
/// e calda per il corpo del testo (EB Garamond). Sono font variabili: il peso
/// si applica a runtime con `FontVariation('wght', ...)`, cosi' la resa e'
/// precisa e prevedibile su mobile e in anteprima web.
///
/// Riferimento: Master Tecnico, sistema tipografico del design system.
class TypographyTokens {
  TypographyTokens._();

  /// Famiglia cerimoniale (Cinzel). Pubblica perche' l'anello curvo della ruota
  /// archetipica costruisce uno stile su misura, con una dimensione calcolata
  /// per far stare i dodici nomi sull'arco, e quindi non passa da `label()` che
  /// imporrebbe il minimo leggibile pensato per il testo dritto.
  static const String displayFamily = 'Cinzel';
  static const String _display = displayFamily;
  static const String _body = 'EBGaramond';

  /// Minimi di sola leggibilita': sono una rete di sicurezza contro il testo
  /// illeggibile, non una misura di progetto.
  ///
  /// Erano 20, 17 e 12.5, ed erano tarati male: su 571 chiamate con misura
  /// esplicita sotto `lib/`, 457 stavano sotto il proprio minimo, cioe' l'ottanta
  /// per cento, su 64 file. Un sistema in cui otto chiamate su dieci violano il
  /// minimo non ha un problema nei punti di chiamata: ha un minimo inventato. E
  /// il danno non era teorico, perche' il clamp e' silenzioso: `label(size: 10)`
  /// e `label(size: 12)` finivano tutti e due a 12.5, quindi la gerarchia che il
  /// codice dichiarava non esisteva a video, e nessuno se ne accorgeva.
  ///
  /// Ora sono soglie di leggibilita' vera. Chi vuole una misura piu' grande la
  /// chiede, e la ottiene; chi ne chiede una piu' piccola del minimo sta
  /// scrivendo testo che non si legge, e viene fermato da
  /// `test/tipografia_minimi_test.dart`. I font restano scalabili: il
  /// `textScaler` di sistema si applica sopra queste basi.
  static const double minDisplay = 16;
  static const double minBody = 13;
  static const double minLabel = 11;

  /// Il pavimento assoluto dell'app: sotto dodici punti non si scrive nulla,
  /// qualunque sia la famiglia.
  ///
  /// I tre minimi qui sopra sono per famiglia e nascono da una storia; questo
  /// invece e' una riga sola per tutta l'app, ed e' la stessa misura del ruolo
  /// piu' piccolo che esista, [etichetta]. Chi ha bisogno di qualcosa di piu'
  /// piccolo non ha un problema di tipografia, ha un problema di layout.
  ///
  /// Chi lo viola lo scopre subito: in debug scatta un assert che nomina il
  /// punto di chiamata e la misura chiesta, in release resta il taglio, perche'
  /// un'app che muore per un font non si spedisce.
  static const double pavimento = 12;

  /// Dimensione del corpo informativo: ogni testo che spiega, istruisce o guida
  /// (sottotitoli, istruzioni del gesto, righe di aiuto, descrizioni) usa questa
  /// misura generosa, ben leggibile sul cosmo. Le etichette decorative in
  /// maiuscoletto restano invece compatte con `label()`.
  ///
  /// Resta a 18 e il ragionamento regge anche coi minimi nuovi, anzi meglio: ora
  /// e' una misura scelta per la guida e non il minimo del corpo testo appena
  /// arrotondato, quindi dice davvero qualcosa quando la si chiede.
  static const double guide = 18;

  static List<FontVariation> _wght(double weight) =>
      [FontVariation('wght', weight)];

  /// Il controllo del pavimento, unico per tutte e tre le famiglie.
  ///
  /// In debug il blocco dell'assert gira e solleva, nominando il punto di
  /// chiamata e la misura chiesta: e' la fine del taglio silenzioso, che per
  /// anni ha fatto rendere identiche due misure diverse senza che nessuno se ne
  /// accorgesse. In release il blocco non viene nemmeno compilato e resta il
  /// solo taglio.
  static double _misura(double size, double minimoFamiglia) {
    assert(() {
      if (size < pavimento) {
        throw FlutterError.fromParts([
          // Accenti veri: questo messaggio lo LEGGE una persona, in debug, e
          // vale la stessa regola di ogni altra frase che arriva a video.
          ErrorSummary('Misura tipografica sotto il pavimento dell\'app: '
              'chiesti $size punti, il pavimento è $pavimento.'),
          ErrorDescription('Chiamata da:\n${_chiamante()}'),
          ErrorHint(
              'Usa un ruolo invece di una misura a mano: TypographyTokens.'
              'etichetta è il più piccolo che esista ed è esattamente il '
              'pavimento. Se il testo non ci sta, il problema è il layout, '
              'non il carattere.'),
        ]);
      }
      return true;
    }());
    return math.max(size, math.max(minimoFamiglia, pavimento));
  }

  /// La prima riga della pila che non appartiene a questo file: e' il punto che
  /// ha chiesto la misura, cioe' quello che va corretto. Senza questa riga
  /// l'assert direbbe soltanto che qualcuno da qualche parte ha sbagliato.
  static String _chiamante() {
    for (final riga in StackTrace.current.toString().split('\n')) {
      if (riga.contains('typography_tokens.dart')) continue;
      if (riga.trim().isEmpty) continue;
      return riga.trim();
    }
    return 'punto di chiamata non ricostruibile dalla pila';
  }

  // ---------------------------------------------------------------------
  // I RUOLI. Non prendono una misura, quindi non c'e' piu' niente da tagliare:
  // il posto che il testo occupa nella pagina si dichiara col nome, e la misura
  // e' una conseguenza. Chi domani volesse cambiare la scala dell'app cambia
  // otto numeri qui, non settecento sparsi per le schermate.
  // ---------------------------------------------------------------------

  /// La soglia di una cerimonia: il nome del segno, il momento della
  /// rivelazione. Uno per schermata, mai due.
  static TextStyle cerimonialeGrande({double weight = 700}) =>
      display(size: 34, weight: weight);

  /// Il titolo di una schermata cerimoniale.
  static TextStyle cerimoniale({double weight = 600}) =>
      display(size: 28, weight: weight);

  /// Il titolo di una sezione dentro una schermata.
  static TextStyle titoloSezione({double weight = 600}) =>
      display(size: 22, weight: weight);

  /// Il titolo di una scheda, cioe' di un blocco di contenuto.
  static TextStyle titoloScheda({double weight = 600}) =>
      display(size: 18, weight: weight);

  /// Il titolo di una SCHERMATA: la barra in alto, e l'intestazione di un
  /// blocco che apre una sezione dentro la pagina.
  ///
  /// **VENTI PUNTI, e non e' un numero scelto adesso: e' quello che l'app
  /// gia' usava.** Ordine CE voce 11. Contati, i titoli con la misura
  /// scritta a mano erano centoventuno su quindici grandezze diverse, e
  /// venti era la piu' frequente di tutte, ventisei punti: la barra delle
  /// Impostazioni, quella del Calendario, quella del Bosco, le
  /// intestazioni dei Doni. Il difetto non era la misura, era che
  /// nessuno le avesse dato un nome, e ogni schermata nuova ne
  /// inventava una vicina: diciannove, ventuno.
  static TextStyle titoloDiSchermata({double weight = 600}) =>
      display(size: 20, weight: weight);

  /// Il titolo di una RIGA in un elenco: la voce delle Impostazioni, la
  /// riga di un permesso, il nome di una funzione dentro una lista.
  ///
  /// **SEDICI, e vale come il [titoloScheda] sta a una scheda.** Ordine CE
  /// voce 11: ventidue punti dell'app lo usavano gia', e la riga di un
  /// elenco e' il gradino sotto la scheda, non un titolo rimpicciolito a
  /// caso. Sotto questo non si scende: il [pavimento] resta il pavimento.
  static TextStyle titoloDiRiga({double weight = 600}) =>
      display(size: 16, weight: weight);

  /// Il testo che si LEGGE per intero: un responso, una narrazione, una lettura
  /// lunga. Interlinea 1,55, piu' larga del corpo, perche' qui l'occhio deve
  /// tornare a capo molte volte di seguito.
  static TextStyle lettura({double weight = 400}) =>
      body(size: 18, weight: weight).copyWith(height: 1.55);

  /// **LA PROSA AMPIA, VENTI PUNTI. Ordine CQ voce 6.22, 4 settembre 2026.**
  ///
  /// **Il fondatore chiede testi piu' grandi da tre ordini, e alzare l'intera
  /// scala non si puo'.** Misurato due volte: alzando tutti i ruoli cadono
  /// piu' di quaranta prove, con chat illeggibili e ventiquattro catture
  /// rotte; alzando il solo ruolo `lettura` da diciotto a venti ne cadono
  /// cinque, fra cui i tre sentieri che escono dalla tela e l'Oroscopo. I
  /// ruoli sono condivisi da tutta l'app, e gonfiarli rompe schermate che
  /// con quei testi non c'entrano.
  ///
  /// **Percio' un gradino in piu', invece di spostare quelli che ci sono.**
  /// Venti punti, per la prosa lunga che si legge di seguito: il responso
  /// delle rune e il presagio. Chi la usa lo dichiara, e chi non la usa resta
  /// dov'e' senza accorgersi di niente.
  ///
  /// **E non e' una misura scritta a mano in una schermata**, che e' il modo
  /// in cui questa scala si sfalda: e' un ruolo, sta qui, e il censimento
  /// dei caratteri lo vede.
  static TextStyle letturaAmpia({double weight = 400}) =>
      body(size: 20, weight: weight).copyWith(height: 1.5);

  /// Il testo informativo ordinario, quello che accompagna e spiega.
  static TextStyle corpo({double weight = 400}) =>
      body(size: 16, weight: weight).copyWith(height: 1.5);

  /// La riga di servizio sotto un contenuto: una fonte, una nota, un dettaglio
  /// che non chiede di essere letto per primo.
  ///
  /// **SEDICI E NON PIU' QUATTORDICI, dall'ordine H**: quattordici punti erano
  /// leggibili ma faticosi, e le didascalie di questa app portano spesso testo
  /// che si legge davvero (fonti, note di metodo, glosse). La differenza dal
  /// [corpo] resta semantica, non di misura: la didascalia e' testo di
  /// servizio, il corpo e' testo di contenuto, e chi legge il codice deve
  /// sapere quale dei due sta scrivendo.
  static TextStyle didascalia({double weight = 400}) =>
      body(size: 16, weight: weight);

  /// L'etichetta cerimoniale in maiuscoletto spaziato. E' il ruolo piu'
  /// piccolo dell'app.
  ///
  /// **QUATTORDICI E NON PIU' DODICI.** Ordine CQ voce 2.11, 3 settembre 2026.
  ///
  /// **Il fatto:** il fondatore ha detto per la QUARTA volta che i caratteri
  /// sono piccoli, e il censimento continuava a rispondere zero fuori misura.
  ///
  /// **La misura che nessuno aveva letto.** Questo ruolo valeva `pavimento`,
  /// cioe' **dodici punti**, e la riga di commento che stava qui diceva "vale
  /// esattamente il pavimento" senza dire quanto fosse quel pavimento. Altrove
  /// nel progetto lo stesso ruolo era descritto come se valesse sedici: **due
  /// documenti dicevano due cose diverse e nessuno dei due era il numero.**
  /// Le etichette sono duecentotre in settantanove sorgenti, e stanno accanto
  /// a una prosa da diciotto: dodici contro diciotto e' un salto che si vede.
  ///
  /// **Perche' quattordici e non sedici.** L'etichetta e' maiuscoletto
  /// spaziato, che a parita' di punti occupa molto piu' orizzontale di una
  /// minuscola: portarla a sedici manderebbe a capo le etichette lunghe dentro
  /// colonne strette, e una riga in piu' non si legge meglio, si legge peggio.
  /// Quattordici e' due punti guadagnati senza cambiare la larghezza di
  /// nessuna colonna.
  static const double misuraEtichetta = 14;

  static TextStyle etichetta({double weight = 600}) =>
      label(size: misuraEtichetta, weight: weight);

  /// Serif cerimoniale per display, titoli e nomi dei Maestri.
  ///
  /// CHIAMARLA CON UNA MISURA E' DEBITO, non una eccezione. L'unico punto che
  /// ha davvero bisogno di scegliere il numero e' l'anello curvo della ruota
  /// archetipica, dove la dimensione si calcola per far stare i dodici nomi
  /// sull'arco e nessun ruolo puo' saperlo in anticipo. Tutti gli altri punti
  /// che passano di qui sono elencati uno per uno in
  /// `docs/tipografia/censimento.md`, e quel numero puo' solo scendere.
  static TextStyle display({double size = 34, double weight = 600}) =>
      TextStyle(
        fontFamily: _display,
        fontSize: _misura(size, minDisplay),
        fontVariations: _wght(weight),
        fontWeight: _nearest(weight),
        height: 1.18,
        letterSpacing: 1.2,
        color: ColorTokens.textPrimary,
      );

  /// Serif leggibile per il testo narrato e il corpo.
  ///
  /// Come [display]: con una misura esplicita e' debito censito, non una scelta.
  /// I ruoli da usare sono [lettura], [corpo] e [didascalia].
  static TextStyle body({double size = 16, double weight = 400}) => TextStyle(
        fontFamily: _body,
        fontSize: _misura(size, minBody),
        fontVariations: _wght(weight),
        fontWeight: _nearest(weight),
        height: 1.5,
        color: ColorTokens.textPrimary,
      );

  /// Etichetta in stile cerimoniale (maiuscoletto spaziato).
  ///
  /// Come [display]: con una misura esplicita e' debito censito. Il ruolo da
  /// usare e' [etichetta].
  static TextStyle label({double size = 13, double weight = 600}) => TextStyle(
        fontFamily: _display,
        fontSize: _misura(size, minLabel),
        fontVariations: _wght(weight),
        fontWeight: _nearest(weight),
        letterSpacing: 1.6,
        color: ColorTokens.textPrimary,
      );

  /// Costruisce il TextTheme completo dell'app a partire dalle due famiglie.
  static TextTheme buildTextTheme() {
    return TextTheme(
      displayLarge: display(size: 44, weight: 700),
      displayMedium: display(size: 34),
      displaySmall: display(size: 28),
      headlineMedium: display(size: 24, weight: 500),
      headlineSmall: display(size: 20, weight: 500),
      titleLarge: display(size: 18, weight: 600),
      titleMedium: body(size: 17, weight: 600),
      titleSmall: body(size: 15, weight: 600),
      bodyLarge: body(size: 18),
      bodyMedium: body(size: 16),
      bodySmall: body(size: 15).copyWith(color: ColorTokens.textSecondary),
      labelLarge: label(size: 14),
      labelMedium: label(size: 12, weight: 600)
          .copyWith(color: ColorTokens.textSecondary),
    );
  }

  /// Mappa un peso numerico sul FontWeight piu' vicino, usato come fallback e
  /// per la semantica; la resa reale passa da FontVariation.
  static FontWeight _nearest(double weight) {
    final index = ((weight / 100).round().clamp(1, 9)) - 1;
    return FontWeight.values[index];
  }
}
