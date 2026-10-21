// ignore_for_file: avoid_print
import 'package:esoteric_circle/core/responsi/la_forma_del_responso.dart';
import 'package:esoteric_circle/core/tarot/figure_della_stesa.dart';
import 'package:esoteric_circle/core/tarot/la_carta_nella_risposta.dart';
import 'package:esoteric_circle/core/tarot/la_domanda_letta.dart';
import 'package:esoteric_circle/core/tarot/tarot_card.dart';
import 'package:esoteric_circle/core/tarot/tarot_topic.dart';
import 'package:esoteric_circle/core/tarot/voce_della_stesa.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **I TESTI CHE LA VOCE DELLA STESA METTE INTORNO ALLE CARTE.** Ordine GA
/// voce GA.06, 21 ottobre 2026.
///
/// La risposta di casa dei Tarocchi si compone con cio' che ogni carta-verso
/// porta (`LaCartaNellaRisposta`) e con i gesti della domanda
/// (`LaDomandaLetta`). La scelta dei posti salta le forme che ripetono una
/// figura gia' detta (ordine DS voce 09), ma un posto obbligatorio la tiene
/// comunque: **per questo i testi non portano nessuna figura del lessico**
/// di `FigureDellaStesa`, e la guardia delle figure resta vera per
/// costruzione e non per fortuna. E il tema sta nel titolo (*"Ora no, pesa
/// l'ansia notturna"*), che ha da tre a otto parole: il tema ne ha da due a
/// cinque.
void main() {
  test('tutte le carte-verso, coi testi interi e senza figure', () {
    final guasti = <String>[];
    var quante = 0;
    for (final c in TarotDeck.cards) {
      for (final verso in ['dritta', 'capovolta']) {
        final k = LaCartaNellaRisposta.tavola['${c.name}|$verso'];
        if (k == null) {
          guasti.add('${c.name} $verso non ha la sua voce');
          continue;
        }
        quante++;
        final parole = LaFormaDelResponso.parole(k.tema);
        if (parole < 2 || parole > 5) {
          guasti.add('${c.name} $verso: il tema ha $parole parole');
        }
        for (final (nome, testo) in [
          ('tema', k.tema),
          ('dice', k.dice),
          ('via', k.via),
        ]) {
          if (testo.trim().isEmpty) guasti.add('${c.name} $verso: $nome vuoto');
          if (testo.endsWith('.')) {
            guasti.add('${c.name} $verso: $nome finisce col punto');
          }
          if (testo[0] != testo[0].toLowerCase()) {
            guasti.add('${c.name} $verso: $nome comincia in maiuscolo');
          }
          final figure = FigureDellaStesa.di(testo);
          if (figure.isNotEmpty) {
            guasti.add('${c.name} $verso: $nome porta le figure $figure');
          }
        }
        if (k.distacco && k.legame) {
          guasti.add('${c.name} $verso: distacco e legame insieme');
        }
      }
    }
    print('ORDINE GA VOCE 06: carte-verso con la loro voce $quante, guasti '
        '${guasti.length}');
    cardinaleMinimo(quante, 156, cosa: 'carte-verso con la loro voce');
    expect(LaCartaNellaRisposta.tavola.length, 156);
    expect(guasti, isEmpty, reason: guasti.take(8).join('\n'));
  });

  test('i gesti della domanda e le frasi di servizio non portano figure', () {
    final testi = <String>[
      for (final s in Situazione.values) ...[...s.azioni, ...s.nonFare],
      for (final domanda in [
        null,
        'L\'operazione andrà bene?',
        'Vincerò la causa?',
        'Conviene investire in borsa?',
      ])
        for (final t in TarotTopic.values) ...[
          ...LaDomandaLetta.di(domanda).azioni(t),
          ...LaDomandaLetta.di(domanda).nonFare(t),
        ],
      ...VoceDellaStesa.frasiDiServizio,
    ];
    final guasti = [
      for (final t in testi)
        if (FigureDellaStesa.di(t).isNotEmpty)
          '${FigureDellaStesa.di(t)}: "$t"',
      for (final s in Situazione.values)
        for (final n in s.nonFare)
          if (!n.startsWith('Non ')) 'la cosa da non fare non dice "Non": "$n"',
    ];
    cardinaleMinimo(testi.length, 200, cosa: 'gesti e frasi di servizio');
    expect(guasti, isEmpty, reason: guasti.take(8).join('\n'));
  });

  test('la domanda si legge: forma, tema sensibile, vaga, doppia', () {
    // I casi del campione dei lettori ciechi, uno per forma.
    final casi = <String, (FormaDellaDomanda, TemaSensibile?, bool, bool)>{
      'Il colloquio di giovedì andrà bene?': (
        FormaDellaDomanda.siNo,
        null,
        false,
        false
      ),
      'Come posso fare pace con mia sorella?': (
        FormaDellaDomanda.come,
        null,
        false,
        false
      ),
      'Mio figlio sta attraversando un periodo difficile, come lo aiuto?': (
        FormaDellaDomanda.come,
        null,
        false,
        false
      ),
      'Cosa prova davvero Marco per me?': (
        FormaDellaDomanda.cosa,
        null,
        false,
        false
      ),
      'Quando finirà questo periodo di stallo?': (
        FormaDellaDomanda.quando,
        null,
        false,
        false
      ),
      'Devo trasferirmi a Milano o restare a Bari?': (
        FormaDellaDomanda.scelta,
        null,
        false,
        false
      ),
      'Quale strada scelgo tra i due corsi di laurea?': (
        FormaDellaDomanda.scelta,
        null,
        false,
        false
      ),
      'Dimmi qualcosa.': (FormaDellaDomanda.cosa, null, true, false),
      'Andrà tutto bene?': (FormaDellaDomanda.siNo, null, true, false),
      'Lui mi ama ancora e troverò lavoro entro Natale?': (
        FormaDellaDomanda.siNo,
        null,
        false,
        true
      ),
      'Devo lasciare Roma, e se lo faccio la mia famiglia capirà?': (
        FormaDellaDomanda.siNo,
        null,
        false,
        true
      ),
      'L\'operazione al ginocchio del mese prossimo andrà bene?': (
        FormaDellaDomanda.siNo,
        TemaSensibile.salute,
        false,
        false
      ),
      'Vincerò la causa contro il mio ex socio?': (
        FormaDellaDomanda.siNo,
        TemaSensibile.legge,
        false,
        false
      ),
      'Conviene investire i miei risparmi in borsa adesso?': (
        FormaDellaDomanda.siNo,
        TemaSensibile.denaro,
        false,
        false
      ),
    };
    final guasti = <String>[];
    for (final MapEntry(key: domanda, value: (forma, sensibile, vaga, doppia))
        in casi.entries) {
      final d = LaDomandaLetta.di(domanda);
      if (d.forma != forma) guasti.add('"$domanda": forma ${d.forma}');
      if (d.sensibile != sensibile) {
        guasti.add('"$domanda": sensibile ${d.sensibile}');
      }
      if (d.vaga != vaga) guasti.add('"$domanda": vaga ${d.vaga}');
      if (d.doppia != doppia) guasti.add('"$domanda": doppia ${d.doppia}');
    }
    expect(
        LaDomandaLetta.di('Il mio compagno mi sta nascondendo qualcosa?')
            .timore,
        isTrue);
    expect(LaDomandaLetta.di('Devo chiudere l\'amicizia con Giulia?').distacco,
        isTrue);
    expect(LaDomandaLetta.di(null).forma, FormaDellaDomanda.nessuna);
    expect(guasti, isEmpty, reason: guasti.join('\n'));
  });
}
