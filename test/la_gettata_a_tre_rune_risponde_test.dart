import 'dart:io';

import 'package:esoteric_circle/core/astro/moon_phase.dart';
import 'package:esoteric_circle/core/rituals/rune_cast.dart';
import 'package:esoteric_circle/core/rituals/rune_voce.dart';
import 'package:esoteric_circle/core/rituals/runes.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **LA GETTATA A TRE RUNE RISPONDE, E PARLA ITALIANO.** Ordine CQ voci 6.14,
/// 6.15, 6.16 e 6.17, 4 settembre 2026.
///
/// **Il fondatore ha mandato cinque schermate di una gettata a tre rune con la
/// domanda "quando diventerò immortale?", e ha chiesto tre cose**: se avessi
/// rispettato le sue richieste, se la risposta fosse pertinente alla domanda,
/// e se i caratteri fossero uniformati. La risposta onesta era no a tutte e
/// tre, e qui stanno le quattro grandezze che lo dicono col numero.
///
/// **6.14, la frase sgrammaticata.** A video si leggeva *"col Sole in Vergine
/// e la ultimo quarto"*, tre volte nello stesso responso. `MoonPhase.comeSiDice`
/// esiste apposta e dice *all'ultimo quarto*: **la porta giusta c'era e nessuno
/// ci passava.**
///
/// **6.15, i caratteri.** Dentro lo stesso riquadro convivevano quattro misure:
/// il nome della runa, le frasi del corpo, il significato con la strofa, e
/// l'etichetta del verso. Le due di mezzo sono tutte e due prosa che si legge.
///
/// **6.16, la domanda ripetuta.** *"Dentro la tua domanda, è qui che guarda"*
/// compariva **identica su tutte e tre le rune**, e non nominava mai la
/// domanda. Una formula ripetuta tre volte in una schermata smette di essere
/// una risposta.
///
/// **6.17, il Sigillo.** Diceva solo cosa il segno E'. Le tre rune intrecciate
/// sono le stesse tre lette una per una, e insieme dicono qualcosa che nessuna
/// dice da sola.
void main() {
  final giorno = DateTime(2026, 9, 4);

  test('la Luna si dice come si dice, in tutte le sue fasi', () {
    // **SI GIRANO TUTTE LE FASI**, non solo quella dello screenshot: la
    // prossima a rompersi sarebbe un'altra, e nessuno la vedrebbe fino al
    // giorno in cui capita.
    final storte = <String>[];
    var guardate = 0;
    for (final nome in const [
      'Luna nuova', 'Luna piena', 'Luna crescente', 'Luna calante',
      'Gibbosa crescente', 'Gibbosa calante', 'Primo quarto', 'Ultimo quarto',
    ]) {
      guardate++;
      final frase = 'e la Luna ${MoonPhase.comeSiDice(nome)}.';
      // Una frase italiana non ha mai "la" seguito da un aggettivo maschile
      // o da un sostantivo senza articolo suo.
      // **LA GRANDEZZA GIUSTA E' LA PAROLA DOPO "Luna", e ci e' voluta la
      // prova del rosso per trovarla.** La prima stesura cercava "la"
      // seguito da un maschile, e restava verde con la porta rotta: la
      // frase dice *e la Luna X*, quindi il maschile viene dopo "Luna" e
      // non dopo "la". Un nome di fase che comincia con un maschile ha
      // bisogno della sua preposizione, e la porta esiste per metterla.
      if (RegExp(r'Luna (ultimo|primo|gibboso)').hasMatch(frase)) {
        storte.add(frase);
      }
    }
    // ignore: avoid_print
    print('ORDINE CQ VOCE 6.14: fasi della Luna guardate $guardate, frasi '
        'sgrammaticate ${storte.length}');
    cardinaleMinimo(guardate, 8,
        cosa: 'fasi della Luna girate nella frase del cielo',
        perche: 'Con meno fasi la prova direbbe che nessuna e storta per non '
            'averle guardate tutte.');
    expect(storte, isEmpty,
        reason: 'queste frasi non sono italiano: ${storte.join(" | ")}');
  });

  test('e la voce della runa passa da quella porta', () {
    // **NON BASTA CHE LA PORTA ESISTA**, ed e' esattamente il difetto di
    // questa voce: `comeSiDice` c'era da sempre e la voce della runa non la
    // chiamava.
    final sorgente = File('lib/core/rituals/rune_voce.dart').readAsStringSync();
    // ignore: avoid_print
    print('ORDINE CQ VOCE 6.14: la voce della runa chiama comeSiDice '
        '${sorgente.contains("MoonPhase.comeSiDice(")}');
    expect(sorgente.contains('MoonPhase.comeSiDice('), isTrue,
        reason: 'la voce della runa non passa dalla porta che sa dire la '
            'Luna: torna a comporre la frase da se');
    // **SI GUARDA IL CODICE, NON I COMMENTI, e si dichiara.** La prima
    // stesura cercava la stringa in tutto il file e cadeva sul COMMENTO che
    // spiega perche' quella chiamata e' stata tolta: era legata al token e
    // non al fatto, cioe' avrebbe costretto a cancellare la spiegazione per
    // far passare la prova. E' la seconda volta oggi.
    final codice = sorgente
        .split(String.fromCharCode(10))
        .where((r) => !r.trimLeft().startsWith('//') &&
            !r.trimLeft().startsWith('///'))
        .join(String.fromCharCode(10));
    expect(codice.contains('luna.italianName.toLowerCase()'), isFalse,
        reason: 'la voce della runa prende di nuovo il nome grezzo della '
            'fase, che attaccato a "e la" produce "e la ultimo quarto"');
  });

  test('la domanda si nomina una volta sola, sulla prima runa', () {
    const domanda = 'quando diventerò immortale?';
    final rune = kElderFuthark.take(3).toList();
    final voci = [
      for (var i = 0; i < rune.length; i++)
        RuneVoce.voce(
          runa: RunaGettata(
            rune: rune[i],
            verso: RuneVerso.dritto,
            posizione: const PosizioneGettata('x', 'y'),
          ),
          persona: 'prova',
          giorno: giorno,
          domanda: domanda,
          indice: i,
        ),
    ];
    final conLaDomanda =
        voci.where((v) => v.contains(domanda)).length;
    // ignore: avoid_print
    print('ORDINE CQ VOCE 6.16: rune ${voci.length}, voci che nominano la '
        'domanda $conLaDomanda');
    cardinaleMinimo(voci.length, 3,
        cosa: 'voci di runa composte dalla prova',
        perche: 'Con meno di tre voci non si vede se una formula si ripete.');
    expect(conLaDomanda, 1,
        reason: 'la domanda compare in $conLaDomanda voci su ${voci.length}: '
            'zero vuol dire che il responso non la nomina mai, piu di una '
            'vuol dire la stessa formula ripetuta, ed e cio che il fondatore '
            'ha letto negli screenshot');
    // **E LA VECCHIA FORMULA VUOTA NON TORNA.**
    final vuote = voci.where((v) => v.contains('Dentro la tua domanda')).length;
    expect(vuote, 0,
        reason: 'torna la formula che dice "dentro la tua domanda" senza mai '
            'dire quale: $vuote voci su ${voci.length}');
  });

  test('il Sigillo del Giorno risponde all intreccio, quando c e una domanda',
      () {
    const domanda = 'quando diventerò immortale?';
    final chiavi = <String>[
      for (final r in kElderFuthark.take(3)) r.keyword
    ];
    final conDomanda = SigilloDelGiorno.riga(
        paroleChiave: chiavi, domanda: domanda, giorno: giorno);
    final senza = SigilloDelGiorno.riga(
        paroleChiave: chiavi, domanda: '  ', giorno: giorno);
    // ignore: avoid_print
    print('ORDINE CQ VOCE 6.17: col la domanda il Sigillo dice "$conDomanda"; '
        'senza dice "$senza"');
    expect(conDomanda.contains(domanda), isTrue,
        reason: 'il Sigillo non nomina la domanda: dice solo cosa il segno e');
    for (final chiave in chiavi) {
      expect(conDomanda.toLowerCase().contains(chiave.toLowerCase()), isTrue,
          reason: 'il Sigillo non porta "$chiave", che e una delle rune '
              'intrecciate: la risposta non nasce dall intreccio');
    }
    expect(senza.contains(domanda), isFalse,
        reason: 'senza domanda il Sigillo ne nomina una lo stesso');
    // **E L ITALIANO E ITALIANO.** A video si leggeva "e cio che ti resta",
    // senza verbo e senza accento.
    for (final riga in [conDomanda, senza]) {
      expect(riga.contains('e cio '), isFalse,
          reason: 'torna "e cio" senza verbo e senza accento: "$riga"');
    }
  });

  test('e la prosa della scheda ha una misura sola', () {
    // **QUATTRO MISURE IN UN RIQUADRO SOLO**, ed e' cio' che il fondatore
    // vede. Qui si pretende che ogni blocco di PROSA passi dal ruolo
    // lettura: il nome della runa resta un titolo e le etichette in
    // maiuscoletto restano etichette, perche' quelle non sono prosa.
    final schermata =
        File('lib/features/maestri/caligo/rune/rune_draw_screen.dart')
            .readAsStringSync();
    final storti = <String>[];
    final ruoli = <String>{};
    var guardati = 0;
    for (final chiave in const [
      'rune_meaning_',
      'rune_strofa_',
      'rune_sigillo_a_cosa_serve',
    ]) {
      final dove = schermata.indexOf("Key('$chiave");
      if (dove < 0) {
        storti.add('$chiave: non e piu a video');
        continue;
      }
      guardati++;
      // Lo stile sta nelle righe subito attorno alla chiave.
      // **LA FINESTRA E' LARGA ABBASTANZA, e ci e' voluta una caduta.**
      // Con quattrocento caratteri per lato la chiave del Sigillo restava
      // fuori dalla vista del suo stile, che sta in fondo a un blocco
      // lungo: la prova diceva "non usa il ruolo lettura" mentre lo usava.
      final intorno = schermata.substring(
          dove > 800 ? dove - 800 : 0,
          dove + 800 < schermata.length ? dove + 800 : schermata.length);
      // **SI MISURA L'UNIFORMITA', NON UN RUOLO PRECISO.** La prima
      // stesura pretendeva `lettura`, e quando la prosa e' salita alla
      // misura ampia e' caduta pur essendo tutto uniforme: **una prova
      // legata al nome del ruolo cade quando il ruolo migliora.** Adesso
      // raccoglie i ruoli trovati e pretende che siano UNO.
      final m = RegExp(r'TypographyTokens\.(\w+)\(\)')
          .firstMatch(intorno);
      if (m == null) {
        storti.add('$chiave: non passa da nessun ruolo della scala');
      } else {
        ruoli.add(m.group(1)!);
      }
    }
    // ignore: avoid_print
    print('ORDINE CQ VOCE 6.15: blocchi di prosa guardati $guardati, con una '
        'misura diversa ${storti.length}');
    cardinaleMinimo(guardati, 3,
        cosa: 'blocchi di prosa della scheda della runa',
        perche: 'Con zero blocchi la prova direbbe che le misure coincidono '
            'per non averne guardata nessuna.');
    // ignore: avoid_print
    print('ORDINE CQ VOCE 6.15: ruoli tipografici trovati $ruoli');
    expect(storti, isEmpty,
        reason: 'questi blocchi di prosa non passano da un ruolo della '
            'scala: ${storti.join(", ")}');
    expect(ruoli.length, 1,
        reason: 'la prosa della schermata usa ${ruoli.length} ruoli diversi, '
            '$ruoli: dentro lo stesso riquadro il fondatore li vede come '
            'misure diverse, ed e la disuniformita che chiede di togliere '
            'da tre ordini');
  });

  test('e la schermata chiama davvero la porta del Sigillo', () {
    // **LA PORTA GIUSTA E LA SCHERMATA CHE NON CI PASSA SONO LO STESSO
    // SILENZIO**, ed e' il difetto della voce 6.14 in un altro punto. La
    // prova del rosso lo ha trovato: rompendo la chiamata nella schermata, le
    // pretese sul Sigillo restavano verdi perche' misuravano la porta.
    final schermata =
        File('lib/features/maestri/caligo/rune/rune_draw_screen.dart')
            .readAsStringSync();
    // ignore: avoid_print
    print('ORDINE CQ VOCE 6.17: la schermata chiama SigilloDelGiorno.riga '
        '${schermata.contains("SigilloDelGiorno.riga(")}');
    expect(schermata.contains('SigilloDelGiorno.riga('), isTrue,
        reason: 'la schermata non chiama la porta che compone la risposta del '
            'Sigillo: la porta sa rispondere e nessuno gliela chiede');
    expect(schermata.contains("'Le rune di questa gettata, strette in un "), 
        isFalse,
        reason: 'la riga vecchia e tornata scritta a mano nella schermata');
  });

  test('la bolla della runa porta tre paragrafi, e le fonti stanno dietro',
      () {
    // **Ordine CQ voci 6.19 e 6.22, 4 settembre 2026.** Parole del fondatore:
    // *Intestazione con immagine runa OK. Poi sotto 3 paragrafi: Giallo,
    // Bianco, Giallo.* E prima: *per quanto riguarda la quantita' di testo
    // nelle bolle delle singole rune, non hai fatto nulla?*
    //
    // **Aveva ragione**: la porta valeva per la sola runa singola, per una
    // decisione mia scritta cosi', *a tre e a cinque restano dove erano*.
    final schermata =
        File('lib/features/maestri/caligo/rune/rune_draw_screen.dart')
            .readAsStringSync();

    // I tre paragrafi, nell'ordine e col loro colore.
    final ordine = <String, String>{
      'rune_meaning_': 'palette.goldSoft',
      'rune_riga_': 'ColorTokens.textPrimary',
      'rune_voce_': 'palette.goldSoft',
    };
    final storti = <String>[];
    var precedente = -1;
    var guardati = 0;
    for (final voce in ordine.entries) {
      final dove = schermata.indexOf("Key('${voce.key}");
      if (dove < 0) {
        storti.add('${voce.key}: non e piu a video');
        continue;
      }
      guardati++;
      if (dove < precedente) storti.add('${voce.key}: e fuori ordine');
      precedente = dove;
      final intorno = schermata.substring(
          dove, dove + 300 < schermata.length ? dove + 300 : schermata.length);
      if (!intorno.contains(voce.value)) {
        storti.add('${voce.key}: non ha il colore ${voce.value}');
      }
      // **E LA MISURA E' QUELLA AMPIA**, che e' l'altra meta' della richiesta.
      if (!intorno.contains('TypographyTokens.lettura()')) {
        storti.add('${voce.key}: non usa la prosa ampia');
      }
    }
    // ignore: avoid_print
    print('ORDINE CQ VOCE 6.22: paragrafi guardati $guardati, storti '
        '${storti.length}');
    cardinaleMinimo(guardati, 3,
        cosa: 'paragrafi della bolla della runa trovati nel sorgente',
        perche: 'Con meno di tre paragrafi la prova direbbe che l ordine e '
            'giusto per non averne guardato nessuno.');
    expect(storti, isEmpty,
        reason: 'la bolla della runa non e come il fondatore l ha chiesta: '
            '${storti.join(", ")}');
  });

  test('e la porta delle fonti non dipende piu dal numero di rune', () {
    // **LA PORTA VALEVA SOLO PER LA RUNA SOLA**, ed e' la decisione che gli
    // screenshot hanno smentito: 1833 caratteri per la gettata a tre, 3055
    // per la Croce delle Cinque.
    final schermata =
        File('lib/features/maestri/caligo/rune/rune_draw_screen.dart')
            .readAsStringSync();
    final dove = schermata.indexOf('_IlRestoDellaRuna(');
    expect(dove, greaterThanOrEqualTo(0),
        reason: 'la porta delle fonti non esiste piu');
    final prima = schermata.substring(
        dove > 500 ? dove - 500 : 0, dove);
    // ignore: avoid_print
    print('ORDINE CQ VOCE 6.19: la porta si monta sotto una condizione che '
        'nomina "sola" ${prima.contains("if (sola)")}');
    expect(prima.contains('if (sola)'), isFalse,
        reason: 'la porta delle fonti si monta ancora solo a una runa sola: '
            'a tre e a cinque il testo resta la parete che il fondatore ha '
            'fotografato');
  });
}
