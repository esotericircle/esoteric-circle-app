// ignore_for_file: avoid_print
import 'dart:io';

import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/features/maestri/live/stato_della_schermata_live.dart';
import 'package:esoteric_circle/services/live/porta_del_live.dart';
import 'package:flutter_test/flutter_test.dart';

/// **IL LIVE NON E' MAI UN VICOLO CIECO.** Ordine EG voci 05 e 06.
///
/// ## PERCHE' QUESTA PROVA GUARDA PROPRIO I RIFIUTI
///
/// Il LIVE e' la funzione con piu' cose che possono andare storte di tutta
/// l'app: la rete, il diritto, i minuti, il microfono, il volto che non
/// arriva, il tempo che scade. **Ognuna di quelle deve lasciare una strada**,
/// perche' `CLAUDE.md` vieta il vicolo cieco su ogni funzione, e qui vietarlo
/// e' piu' difficile che altrove.
///
/// E c'e' una regola che rischia di saltare proprio qui: **ogni esperienza
/// basata su un sensore ha sempre un ripiego a gesto tattile**. Il sensore e'
/// il microfono, il ripiego e' scrivere, e non e' un ripiego di serie B: in
/// treno o accanto a qualcuno che dorme e' l'unico modo di usare il LIVE.
///
/// ## E PERCHE' STA AL BANCO E NON DENTRO IL WIDGET
///
/// L'ordine EI ha insegnato che una cosa chiusa dentro uno `State` privato non
/// la puo' chiamare nessuna prova, e quello che nessuna prova raggiunge non e'
/// sorvegliato da niente: era il caso della frase delle sette sere. Qui la
/// macchina degli stati vive fuori dal widget apposta.
void main() {
  const sessione = SessioneLive(
    url: 'wss://esoteric.livekit.cloud',
    gettone: 'gettone-della-persona',
    stanza: 'live_medora_abc',
    sessione: 'sess_01M35EYZ9REM14BFYN64SK3S6S',
    avatar: 'av_01M0N4GC9M1791PVH6NDD4FMMG',
    minutiRimasti: 97,
    durataMassimaSecondi: 1200,
  );

  QuadroDelLive vivoDopo(int secondi) => QuadroDelLive(
        momento: MomentoDelLive.vivo,
        maestro: Maestro.medora,
        sessione: sessione,
        secondiPassati: secondi,
      );

  test('si puo\' sempre scrivere mentre il LIVE e\' in piedi', () {
    // **Il ripiego tattile non aspetta che il volto arrivi.** Se si potesse
    // scrivere solo a sessione viva, chi ha il microfono rotto resterebbe
    // fermo a guardare un volto che non arriva, senza poter fare niente.
    expect(vivoDopo(0).siPuoScrivere, isTrue);
    expect(
        const QuadroDelLive(
          momento: MomentoDelLive.siAspettaIlVolto,
          maestro: Maestro.medora,
          sessione: sessione,
        ).siPuoScrivere,
        isTrue,
        reason: 'mentre il volto non arriva non si puo\' scrivere: chi ha il '
            'microfono rotto resta fermo a guardare');
  });

  test('il Maestro saluta prima che il tempo finisca', () {
    // **Una sessione non si tronca a meta' frase.** La finestra e' un minuto:
    // abbastanza perche' il Maestro dica una cosa intera, poco perche' non
    // sembri che stia gia' andando via.
    expect(vivoDopo(0).eOraDiSalutare, isFalse);
    expect(vivoDopo(1100).eOraDiSalutare, isFalse,
        reason: 'a cento secondi dalla fine il Maestro sta gia\' salutando, e '
            'la sessione sembra piu\' corta di quella che si e\' pagata');
    expect(vivoDopo(1141).eOraDiSalutare, isTrue,
        reason: 'a meno di un minuto dalla fine il Maestro non saluta, e la '
            'sessione si tronchera\' a meta\' frase');
    expect(vivoDopo(1200).ilTempoEFinito, isTrue);
    expect(vivoDopo(1300).mancanoSecondi(), 0,
        reason: 'il tempo rimasto va sotto zero, e a video comparirebbe un '
            'numero negativo');
  });

  test(
      'le tre ragioni del rifiuto danno tre frasi diverse, e nessuna e\' un '
      'errore', () {
    final frasi = <PerchePerILiveNonSiApre, String>{};
    for (final p in PerchePerILiveNonSiApre.values) {
      frasi[p] = QuadroDelLive(
        momento: MomentoDelLive.nonSiApre,
        maestro: Maestro.medora,
        perche: p,
      ).laFraseDelRifiuto();
    }
    print('ORDINE EG VOCE 05: ragioni del rifiuto ${frasi.length}');
    // Il cardinale: tre ragioni, tre frasi.
    expect(PerchePerILiveNonSiApre.values.length, 3);
    expect(frasi.values.toSet().length, 3,
        reason: 'due ragioni diverse danno la stessa frase: chi ha finito i '
            'minuti legge la stessa cosa di chi non ha il diritto');

    // **Nessuna frase e' un messaggio d'errore**, e nessuna lascia fermi: in
    // tutte e tre il Maestro dice cosa si puo' fare adesso.
    final senzaStrada = <String>[];
    for (final e in frasi.entries) {
      final f = e.value.toLowerCase();
      final offreLaChat = f.contains('scriv') || f.contains('per iscritto');
      if (!offreLaChat) senzaStrada.add('${e.key.name}: "${e.value}"');
      for (final brutta in ['errore', 'impossibile', 'fallit', 'non valido']) {
        if (f.contains(brutta)) {
          senzaStrada.add('${e.key.name} parla come un errore: "$brutta"');
        }
      }
    }
    expect(senzaStrada, isEmpty,
        reason: 'queste frasi lasciano la persona in un vicolo cieco: '
            '$senzaStrada');
  });

  test('la prova della voce EG.05 resta scritta su disco', () {
    final b = StringBuffer()
      ..writeln('IL LIVE NON E\' MAI UN VICOLO CIECO')
      ..writeln('Ordine EG voci 05 e 06.')
      ..writeln()
      ..writeln('LE TRE RAGIONI PER CUI IL LIVE PUO\' NON APRIRSI, e cosa la')
      ..writeln('persona legge in ciascuna:')
      ..writeln();
    for (final p in PerchePerILiveNonSiApre.values) {
      final q = QuadroDelLive(
        momento: MomentoDelLive.nonSiApre,
        maestro: Maestro.medora,
        perche: p,
      );
      b
        ..writeln('--- ${p.name}')
        ..writeln('    ${q.laFraseDelRifiuto()}')
        ..writeln();
    }
    b
      ..writeln('IL TEMPO, voce 06: tetto di ${sessione.durataMassimaSecondi} '
          'secondi, cioe\' venti minuti.')
      ..writeln('    a 0 secondi passati il Maestro non saluta ancora')
      ..writeln('    a 1141 secondi mancano meno di 60 secondi: SALUTA')
      ..writeln('    a 1200 il tempo e\' finito')
      ..writeln('    a 1300 il tempo rimasto resta 0, mai negativo')
      ..writeln()
      ..writeln(
          'IL RIPIEGO TATTILE, regola di CLAUDE.md: si puo\' scrivere sia')
      ..writeln('a sessione viva sia mentre il volto non e\' ancora arrivato.')
      ..writeln('Chi ha il microfono rotto non resta mai fermo a guardare.');
    final cartella = Directory('docs/collaudo/EG')..createSync(recursive: true);
    final f = File('${cartella.path}/il_live_non_e_un_vicolo_cieco.txt')
      ..writeAsStringSync(b.toString());
    expect(f.lengthSync(), greaterThan(700));
  });
}
