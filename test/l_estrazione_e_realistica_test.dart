// ignore_for_file: avoid_print
import 'dart:io';
import 'dart:math';

import 'package:esoteric_circle/core/rituals/rune_cast.dart';
import 'package:esoteric_circle/core/rituals/runes.dart';
import 'package:esoteric_circle/core/tarot/tarot_card.dart';
import 'package:esoteric_circle/core/tarot/tarot_spread.dart';
import 'package:flutter_test/flutter_test.dart';

/// **L'ESTRAZIONE E' REALISTICA E NON PILOTATA.**
/// Ordine DF voci 03 e 06.2, 11 settembre 2026.
///
/// **Parole del fondatore**: *"IO ESIGO CHE L'ESTRAZIONE DELLE CARTE SIA
/// REALISTICA E NON PILOTATA."*
///
/// **L'INDIZIO CHE HA APERTO LA VOCE, e andava verificato e non creduto.**
/// Nelle quattro letture del fondatore **Il Mondo e' comparso tre volte su
/// quattro**. La probabilita' che una carta scelta in anticipo compaia in
/// almeno tre stese di tre carte su quattro estrazioni da settantotto e'
/// attorno a **due su diecimila**.
///
/// **VERIFICATO: l'estrazione delle CARTE non era pilotata. IL VERSO SI'.**
/// `TarotSpread.mazzoMescolato` in produzione riceve un seme nullo e usa
/// `Random()` senza seme, quindi le tre carte erano davvero a sorte, e le tre
/// comparse de Il Mondo sono il caso raro capitato al fondatore. **Il verso
/// no**: la schermata ripiegava sulla **costante zero** quando il seme non era
/// dichiarato, e in produzione non lo e' mai, quindi **ogni carta aveva un
/// verso fisso per sempre**, uguale per tutti gli utenti.
///
/// **La riga del difetto non si cita testualmente qui dentro**: la guardia del
/// sorgente, piu' in basso, cerca proprio quel ripiego, e una citazione la
/// farebbe cadere pescando se stessa. E' successo davvero, mentre la
/// scrivevo.
///
/// **E il conto globale tornava**, il che e' la parte istruttiva: le carte che
/// col seme zero cadevano rovesciate erano il ventinove virgola cinque per
/// cento, cioe' quasi esattamente la probabilita' dichiarata. **Una prova che
/// avesse contato solo la percentuale di rovesciate sarebbe stata verde**, e
/// il fatto sarebbe rimasto falso. Per questo qui si misura anche **quante
/// carte cambiano verso fra due estrazioni**, che e' la grandezza che il
/// difetto tocca.
void main() {
  /// Diecimila, come l'ordine chiede.
  const quante = 10000;

  test('LE SETTANTOTTO CARTE ESCONO TUTTE, e nessuna piu del dovuto', () {
    final caso = Random(2026);
    final conto = <String, int>{};
    var doppioni = 0;
    for (var i = 0; i < quante; i++) {
      final stesa = TarotSpread.draw(seed: caso.nextInt(1 << 31));
      final nomi = <String>{};
      for (final c in stesa.cards) {
        conto[c.card.name] = (conto[c.card.name] ?? 0) + 1;
        if (!nomi.add(c.card.name)) doppioni++;
      }
    }
    final estratte = quante * 3;
    final attesa = estratte / TarotDeck.cards.length;
    var scartoMassimo = 0.0;
    var quale = '';
    for (final c in TarotDeck.cards) {
      final v = conto[c.name] ?? 0;
      final scarto = (v - attesa).abs() / attesa;
      if (scarto > scartoMassimo) {
        scartoMassimo = scarto;
        quale = '${c.name} uscita $v volte contro ${attesa.toStringAsFixed(1)}';
      }
    }
    print('ORDINE DF VOCE 03: $quante stese, $estratte carte estratte. '
        'Carte diverse uscite ${conto.length} su ${TarotDeck.cards.length}. '
        'Attesa per carta ${attesa.toStringAsFixed(1)}. '
        'Scarto massimo ${(scartoMassimo * 100).toStringAsFixed(1)} per cento '
        '($quale). Doppioni dentro la stessa stesa: $doppioni.');
    expect(conto.length, TarotDeck.cards.length,
        reason: 'su $estratte estrazioni ${TarotDeck.cards.length - conto.length} '
            'carte non sono mai uscite: il mazzo non e tutto in gioco');
    expect(doppioni, 0,
        reason: 'la stessa carta e uscita due volte nella stessa stesa '
            '$doppioni volte');
    // **LA SOGLIA DICHIARATA: il dodici per cento.** Con 384 attese per carta
    // lo scarto tipico di un dado onesto e la radice di 384 diviso 384, cioe
    // il cinque per cento; su settantotto carte il massimo fra tante estrazioni
    // arriva naturalmente a due deviazioni e mezza, cioe intorno al dodici.
    // Sopra quella riga non e piu caso, e il numero misurato si stampa qui
    // sopra perche chi legge non debba fidarsi della soglia.
    expect(scartoMassimo, lessThan(0.12),
        reason: 'una carta si discosta del '
            '${(scartoMassimo * 100).toStringAsFixed(1)} per cento '
            'dall attesa: $quale');
  });

  test('LE ROVESCIATE SONO IL TRENTA PER CENTO, e CAMBIANO fra una stesa e '
      'l altra', () {
    final caso = Random(11);
    var rovesciate = 0;
    // **La grandezza che coglie il difetto**: per ogni carta, quante volte e
    // uscita dritta e quante rovesciata. Col seme fisso a zero ogni carta
    // aveva **un verso solo** in tutta la sua vita.
    final dritte = <String, int>{};
    final storte = <String, int>{};
    for (var i = 0; i < quante; i++) {
      final stesa = TarotSpread.draw(seed: caso.nextInt(1 << 31));
      for (final c in stesa.cards) {
        if (c.reversed) {
          rovesciate++;
          storte[c.card.name] = (storte[c.card.name] ?? 0) + 1;
        } else {
          dritte[c.card.name] = (dritte[c.card.name] ?? 0) + 1;
        }
      }
    }
    final quota = rovesciate / (quante * 3);
    final conUnVersoSolo = [
      for (final c in TarotDeck.cards)
        if ((dritte[c.name] ?? 0) == 0 || (storte[c.name] ?? 0) == 0) c.name,
    ];
    print('ORDINE DF VOCE 03: rovesciate ${(quota * 100).toStringAsFixed(2)} '
        'per cento contro il ${(TarotSpread.reversedChance * 100).toStringAsFixed(0)} '
        'dichiarato. Carte che escono SEMPRE nello stesso verso: '
        '${conUnVersoSolo.length} su ${TarotDeck.cards.length}.');
    expect((quota - TarotSpread.reversedChance).abs(), lessThan(0.02),
        reason: 'le rovesciate sono il ${(quota * 100).toStringAsFixed(2)} per '
            'cento contro il ${(TarotSpread.reversedChance * 100).toStringAsFixed(0)} '
            'dichiarato');
    expect(conUnVersoSolo, isEmpty,
        reason: 'queste carte escono sempre nello stesso verso, cioe il verso '
            'non e a sorte: ${conUnVersoSolo.take(8).join(", ")}');
  });

  test('IL VERSO CALCOLATO DAL SEME CAMBIA COL SEME, e col seme zero NO', () {
    // **QUESTA E LA PROVA DEL DIFETTO VERO, e sta qui per due ragioni.**
    // La prima: dimostra che `versoDi` col seme fisso da un verso fisso,
    // cioe che il difetto era reale e non dedotto. La seconda: dimostra che
    // col seme che cambia il verso cambia, cioe che la cura funziona.
    final colSemeZero = <bool>[
      for (var i = 0; i < TarotDeck.cards.length; i++)
        TarotSpread.versoDi(i, 0),
    ];
    final ancoraColSemeZero = <bool>[
      for (var i = 0; i < TarotDeck.cards.length; i++)
        TarotSpread.versoDi(i, 0),
    ];
    expect(colSemeZero, ancoraColSemeZero,
        reason: 'col seme zero il verso non e nemmeno deterministico');
    final quanteRovesceCol0 = colSemeZero.where((r) => r).length;
    print('ORDINE DF VOCE 03: col seme fisso a zero, le carte rovesciate sono '
        '$quanteRovesceCol0 su ${TarotDeck.cards.length}, cioe il '
        '${(quanteRovesceCol0 / TarotDeck.cards.length * 100).toStringAsFixed(1)} '
        'per cento: la percentuale tornava e il fatto era falso');

    // Con semi diversi, ogni carta cambia verso almeno una volta.
    final semi = [for (var s = 1; s <= 40; s++) s * 7919];
    final immobili = <String>[];
    for (var i = 0; i < TarotDeck.cards.length; i++) {
      final versi = {for (final s in semi) TarotSpread.versoDi(i, s)};
      if (versi.length < 2) immobili.add(TarotDeck.cards[i].name);
    }
    print('ORDINE DF VOCE 03: su ${semi.length} semi diversi, le carte che non '
        'cambiano mai verso sono ${immobili.length}');
    expect(immobili, isEmpty,
        reason: 'queste carte non cambiano verso nemmeno cambiando il seme: '
            '${immobili.take(8).join(", ")}');
  });

  test('LA SCHERMATA NON RIPIEGA SULLO ZERO PER IL SEME DEI VERSI', () {
    // **E' LA GUARDIA DEL DIFETTO VERO, e legge il sorgente.**
    //
    // Le prove qui sopra misurano `TarotSpread`, che e' sano: e' la
    // **schermata** a decidere il seme, e la schermata ripiegava sullo zero.
    // Nessuna misura sulle diecimila estrazioni poteva accorgersene, perche'
    // quelle estrazioni non passano di li'.
    //
    // **La grandezza misurata e' il ripiego scritto nel sorgente**, ed e' il
    // solo modo di sorvegliare una riga che in prova non viene mai eseguita
    // col valore che ha in produzione.
    final schermata = File(
        'lib/features/tarot/stesa_tre_carte_screen.dart');
    expect(schermata.existsSync(), isTrue,
        reason: 'la schermata della Stesa non e piu dove questa guardia la '
            'cerca, e la guardia sta guardando il nulla');
    final sorgente = schermata.readAsStringSync();
    // Le forme del ripiego che rendono il verso una costante del mazzo.
    final ripieghi = [
      'widget.seed ?? 0',
      'seed ?? 0;',
      '_seme = 0',
    ];
    final trovati = [for (final r in ripieghi) if (sorgente.contains(r)) r];
    print('ORDINE DF VOCE 03: ripieghi a zero trovati nel sorgente della '
        'Stesa: ${trovati.length} ${trovati.isEmpty ? "" : trovati}');
    expect(trovati, isEmpty,
        reason: 'la schermata ripiega su un seme costante: ogni carta '
            'tornerebbe ad avere un verso fisso per sempre, uguale per tutti '
            'gli utenti. Trovato: ${trovati.join(", ")}');
    // **REGOLA H: e il seme nuovo c e davvero.** Senza questa meta, togliere
    // la riga del ripiego e non metterci niente passerebbe.
    expect(sorgente.contains('Random().nextInt('), isTrue,
        reason: 'il seme dei versi non nasce piu dal caso: il ripiego e stato '
            'tolto senza metterci niente al suo posto');
  });

  test('LE VENTIQUATTRO RUNE ESCONO TUTTE, e nessuna piu del dovuto', () {
    final caso = Random(77);
    final conto = <String, int>{};
    var doppioni = 0;
    var merkstave = 0;
    var gettate = 0;
    const quantePerGettata = 3;
    for (var i = 0; i < quante; i++) {
      final esito = RuneCast.getta(
          gettataNorne, random: Random(caso.nextInt(1 << 31)));
      final nomi = <String>{};
      for (final r in esito.rune) {
        gettate++;
        conto[r.rune.name] = (conto[r.rune.name] ?? 0) + 1;
        if (!nomi.add(r.rune.name)) doppioni++;
        if (r.verso == RuneVerso.merkstave) merkstave++;
      }
    }
    final attesa = gettate / kElderFuthark.length;
    var scartoMassimo = 0.0;
    var quale = '';
    for (final r in kElderFuthark) {
      final v = conto[r.name] ?? 0;
      final scarto = (v - attesa).abs() / attesa;
      if (scarto > scartoMassimo) {
        scartoMassimo = scarto;
        quale = '${r.name} uscita $v volte contro ${attesa.toStringAsFixed(1)}';
      }
    }
    print('ORDINE DF VOCE 03: $quante gettate da $quantePerGettata, $gettate '
        'rune estratte. Rune diverse uscite ${conto.length} su '
        '${kElderFuthark.length}. Attesa ${attesa.toStringAsFixed(1)}. '
        'Scarto massimo ${(scartoMassimo * 100).toStringAsFixed(1)} per cento '
        '($quale). Doppioni nella stessa gettata: $doppioni. '
        'Merkstave ${(merkstave / gettate * 100).toStringAsFixed(1)} per cento.');
    expect(conto.length, kElderFuthark.length,
        reason: 'non tutte le rune sono uscite in $gettate estrazioni');
    expect(doppioni, 0,
        reason: 'la stessa runa e uscita due volte nella stessa gettata');
    expect(scartoMassimo, lessThan(0.12),
        reason: 'una runa si discosta del '
            '${(scartoMassimo * 100).toStringAsFixed(1)} per cento: $quale');

    // **LE SIMMETRICHE NON ESCONO MAI IN MERKSTAVE**, ed e' una regola della
    // tradizione: una runa uguale a se' stessa capovolta non ha un rovescio.
    // Quindi la percentuale attesa di merkstave NON e' il cinquanta per cento.
    final quanteSimmetriche = kRuneSimmetriche.length;
    final attesoMerkstave =
        0.5 * (kElderFuthark.length - quanteSimmetriche) / kElderFuthark.length;
    print('ORDINE DF VOCE 03: le rune simmetriche sono $quanteSimmetriche su '
        '${kElderFuthark.length}, quindi il merkstave atteso e il '
        '${(attesoMerkstave * 100).toStringAsFixed(1)} per cento');
    expect((merkstave / gettate - attesoMerkstave).abs(), lessThan(0.03),
        reason: 'il merkstave e il '
            '${(merkstave / gettate * 100).toStringAsFixed(1)} per cento '
            'contro un atteso del '
            '${(attesoMerkstave * 100).toStringAsFixed(1)}');
  });
}
