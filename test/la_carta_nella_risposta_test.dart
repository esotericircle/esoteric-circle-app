// ignore_for_file: avoid_print
import 'package:esoteric_circle/core/chat/le_forme_del_genere.dart';
import 'package:esoteric_circle/core/responsi/la_forma_del_responso.dart';
import 'package:esoteric_circle/core/tarot/figure_della_stesa.dart';
import 'package:esoteric_circle/core/tarot/la_carta_nella_risposta.dart';
import 'package:esoteric_circle/core/tarot/la_carta_nella_risposta_scritta.dart';
import 'package:esoteric_circle/core/tarot/la_domanda_letta.dart';
import 'package:esoteric_circle/core/tarot/tarot_card.dart';
import 'package:esoteric_circle/core/tarot/tarot_topic.dart';
import 'package:esoteric_circle/core/tarot/voce_della_stesa.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **I TESTI CHE LA VOCE DELLA STESA METTE INTORNO ALLE CARTE.** Ordine GA
/// voce GA.06, 21 ottobre 2026.
///
/// La risposta di casa dei Tarocchi si compone con testi SCRITTI: per ogni
/// carta-verso cio' che dice quando risponde e cio' che aggiunge in ognuno
/// dei sette ruoli (`testiDelleCarte`), il suo gesto, e i gesti della domanda
/// per tono (`gestiDellaDomanda`), tutti generati da
/// `tool/genera_la_carta_nella_risposta.py` dalla fonte in
/// `docs/corpus/tarocchi_risposta/`. Lo strumento li controlla quando li
/// scrive; **questa guardia li ricontrolla nella suite**, perche' un testo
/// toccato a mano nel Dart non passa dallo strumento.
///
/// **I DIFETTI CHE SORVEGLIA**, trovati dal lettore cieco indipendente
/// (`docs/collaudo/GA/lettori_ciechi/esiti/autoverifica_tarocchi.md` e
/// l'esito del 21 ottobre): persone date per scontate (*"Proponi una sera
/// senza telefoni, solo voi due"* a chi vive a distanza, *"il partner"* a
/// chi parla di un ex), figure ripetute, futuri dati per certi, la carta
/// nominata dentro il suo testo, il genere di chi legge.
final RegExp presupposti = RegExp(
    r'(?<![A-Za-zÀ-ÿ])(partner|marit[oi]|mogli[e]?|fidanzat[oaie]|'
    r'compagn[oaie]|colleg[ah]i?|collega|tuo capo|uffici[o]?|squadra|'
    r'dipendent[ei]|stipendi[o]?|figli[oa]?|nipoti|nonni|suocer[oaie]|ex|'
    r'chi ami)(?![A-Za-zÀ-ÿ])',
    caseSensitive: false);

final RegExp _futuro = RegExp(
    r'(?<![A-Za-zÀ-ÿ])([A-Za-zÀ-ÿ]+(?:rò|rà|rai|remo|ranno))(?![A-Za-zÀ-ÿ])',
    caseSensitive: false);

final RegExp _vietate = RegExp(
    r'(?<![A-Za-zÀ-ÿ])(cioè|sì|tendenza|sentenza|destino|voce)(?![A-Za-zÀ-ÿ])',
    caseSensitive: false);

/// I difetti comuni a ogni testo scritto.
List<String> difettiDelTesto(String dove, String t, {String? carta}) => [
      if (t.trim().isEmpty) '$dove: vuoto',
      if (RegExp(r'\d').hasMatch(t)) '$dove: una cifra',
      if (t.contains('—') || t.contains('–')) '$dove: il trattino lungo',
      if (RegExp(r', (e|ed) ').hasMatch(t)) '$dove: una virgola prima di e',
      if (t.contains('!')) '$dove: un punto esclamativo',
      if (carta != null && t.toLowerCase().contains(carta.toLowerCase()))
        '$dove: il nome della carta',
      for (final m in presupposti.allMatches(t))
        '$dove: una persona data per scontata (${m[1]})',
      for (final m in _futuro.allMatches(t))
        if (!const {'però', 'perciò', 'già'}.contains(m[1]!.toLowerCase()))
          '$dove: un futuro (${m[1]})',
      if (_vietate.hasMatch(t)) '$dove: "${_vietate.firstMatch(t)![1]}"',
      for (final f in FigureDellaStesa.di(t)) '$dove: la figura $f',
      for (final g in formeDelGenere(t)) '$dove: il genere di chi legge ($g)',
    ];

void main() {
  test('la tavola dei toni: 156 carte-verso, coi temi interi e senza figure',
      () {
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
        if (k.tema.endsWith('.') || k.tema[0] != k.tema[0].toLowerCase()) {
          guasti.add('${c.name} $verso: il tema non e\' un nome in minuscolo');
        }
        final figure = FigureDellaStesa.di(k.tema);
        if (figure.isNotEmpty) {
          guasti.add('${c.name} $verso: il tema porta le figure $figure');
        }
        if (k.distacco && k.legame) {
          guasti.add('${c.name} $verso: distacco e legame insieme');
        }
      }
    }
    print('ORDINE GA VOCE 06: carte-verso con il loro tono $quante, guasti '
        '${guasti.length}');
    cardinaleMinimo(quante, 156, cosa: 'carte-verso con il loro tono');
    expect(LaCartaNellaRisposta.tavola.length, 156);
    expect(guasti, isEmpty, reason: guasti.take(8).join('\n'));
  });

  test('i testi scritti delle carte: dieci per carta-verso, nella misura', () {
    const chiavi = [
      'risposta_ora',
      'risposta_esito',
      'nota_ora',
      'nota_passato',
      'nota_esito',
      'nota_ostacolo',
      'nota_influenza',
      'nota_ambiente',
      'nota_timori',
      'gesto',
    ];
    final guasti = <String>[];
    var quanti = 0;
    for (final c in TarotDeck.cards) {
      for (final verso in ['dritta', 'capovolta']) {
        final testi = testiDelleCarte['${c.name}|$verso'];
        if (testi == null) {
          guasti.add('${c.name} $verso: nessun testo scritto');
          continue;
        }
        for (final k in chiavi) {
          final t = testi[k];
          final dove = '${c.name} $verso, $k';
          if (t == null) {
            guasti.add('$dove: manca');
            continue;
          }
          quanti++;
          final n = LaFormaDelResponso.parole(t);
          final (min, max) = k == 'gesto'
              ? (10, 16)
              : k.startsWith('risposta')
                  ? (16, 22)
                  : (7, 11);
          if (n < min || n > max) {
            guasti.add('$dove: $n parole, fuori da $min-$max');
          }
          if (k == 'gesto') {
            if (t[0] != t[0].toUpperCase() || !t.endsWith('.')) {
              guasti.add('$dove: il gesto non e\' una frase intera');
            }
            if (t.startsWith('Non ')) guasti.add('$dove: il gesto e\' un no');
          } else {
            // Il predicato: la voce gli mette davanti la posizione e la
            // carta, quindi comincia in minuscolo, senza punto e senza i due
            // punti che il verdetto ha gia'.
            if (t[0] != t[0].toLowerCase()) {
              guasti.add('$dove: il predicato comincia in maiuscolo');
            }
            if (t.endsWith('.') || t.contains(':')) {
              guasti.add('$dove: il predicato ha il punto o i due punti');
            }
            if (RegExp(r'rovesciat|capovolt', caseSensitive: false)
                .hasMatch(t)) {
              guasti.add('$dove: il predicato nomina il verso');
            }
          }
          guasti.addAll(difettiDelTesto(dove, t, carta: c.name));
        }
      }
    }
    print('ORDINE GA VOCE 06: testi scritti delle carte $quanti, guasti '
        '${guasti.length}');
    cardinaleMinimo(quanti, 156 * 10, cosa: 'testi scritti delle carte');
    expect(guasti, isEmpty, reason: guasti.take(12).join('\n'));
  });

  test('i gesti scritti della domanda: tre per tono e due cose da non fare',
      () {
    final gruppi = {
      for (final s in Situazione.values) s.name,
      for (final t in TarotTopic.values)
        LaDomandaLetta.di(null).gruppoDeiGesti(t),
      'vaga',
    };
    final guasti = <String>[];
    var quanti = 0;
    for (final g in gruppi) {
      for (final tono in TonoDellaCarta.values) {
        final gesti = gestiDellaDomanda['$g|${tono.name}'];
        if (gesti == null) {
          guasti.add('$g ${tono.name}: nessun gesto scritto');
          continue;
        }
        for (final k in [
          'azione_1',
          'azione_2',
          'azione_3',
          'non_1',
          'non_2'
        ]) {
          final t = gesti[k];
          final dove = '$g ${tono.name}, $k';
          if (t == null) {
            guasti.add('$dove: manca');
            continue;
          }
          quanti++;
          final n = LaFormaDelResponso.parole(t);
          final (min, max) = k.startsWith('non') ? (7, 13) : (10, 18);
          if (n < min || n > max) {
            guasti.add('$dove: $n parole, fuori da $min-$max');
          }
          if (k.startsWith('non') && !t.startsWith('Non ')) {
            guasti.add('$dove: la cosa da non fare non comincia con "Non"');
          }
          if (!t.endsWith('.')) guasti.add('$dove: senza il punto');
          // **LA DOMANDA VAGA NON NOMINA NESSUN AMBITO**: il lettore cieco
          // ha trovato l'amicizia e la famiglia sotto "Che cosa mi aspetta?"
          // (tarocchi-29 e 31).
          if (g == 'vaga' &&
              RegExp(
                      r'(?<![A-Za-zÀ-ÿ])(amor\w*|lavor\w*|famigli\w*|amic\w*|'
                      r'coppia|relazion\w*)',
                      caseSensitive: false)
                  .hasMatch(t)) {
            guasti.add('$dove: la domanda vaga nomina un ambito: "$t"');
          }
          guasti.addAll(difettiDelTesto(dove, t));
        }
      }
    }
    print('ORDINE GA VOCE 06: gesti scritti della domanda $quanti, guasti '
        '${guasti.length}');
    cardinaleMinimo(quanti, 37 * 3 * 5, cosa: 'gesti scritti della domanda');
    expect(guasti, isEmpty, reason: guasti.take(12).join('\n'));
  });

  test('i gesti dei temi sensibili e le frasi di servizio non portano figure',
      () {
    final testi = <String>[
      for (final domanda in [
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
    ];
    cardinaleMinimo(testi.length, 200, cosa: 'gesti sensibili e di servizio');
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
      // Nomina il colloquio: non e' vaga anche se dice "come andrà".
      'Come andrà il colloquio?': (FormaDellaDomanda.come, null, false, false),
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
      // Comprare casa e' una decisione di denaro (tarocchi-28).
      'È il momento giusto per comprare casa o devo aspettare?': (
        FormaDellaDomanda.scelta,
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
    // La doppia sa quale e' la prima domanda, con le parole della persona.
    expect(
        LaDomandaLetta.di('Lui mi ama ancora e troverò lavoro entro Natale?')
            .primaParte,
        'Lui mi ama ancora?');
    // La relazione a distanza ha i suoi gesti, non quelli della coppia.
    expect(
        LaDomandaLetta.di('La nostra relazione a distanza ha un futuro?')
            .situazione,
        Situazione.distanza);
    expect(
        LaDomandaLetta.di('Riuscirò a ritrovare l\'intesa con mio marito?')
            .situazione,
        Situazione.coppia);
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
