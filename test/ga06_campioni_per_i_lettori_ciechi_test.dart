// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:esoteric_circle/core/angels/guardian_angels.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/horoscope/horoscope.dart';
import 'package:esoteric_circle/core/horoscope/i_segni_delle_tradizioni.dart';
import 'package:esoteric_circle/core/horoscope/i_testi_eu.dart';
import 'package:esoteric_circle/core/horoscope/il_capodanno_lunare.dart';
import 'package:esoteric_circle/core/horoscope/il_responso_dell_oroscopo.dart';
import 'package:esoteric_circle/core/identity/birth_identity.dart';
import 'package:esoteric_circle/core/oracolo_angeli/i_ruoli_e_l_estrazione.dart';
import 'package:esoteric_circle/core/oracolo_angeli/il_corpus_dell_oracolo.g.dart';
import 'package:esoteric_circle/core/oracolo_angeli/la_lettura_dell_oracolo.dart';
import 'package:esoteric_circle/core/responsi/la_forma_del_responso.dart';
import 'package:esoteric_circle/core/rituals/il_corpus_del_presagio.g.dart';
import 'package:esoteric_circle/core/rituals/il_presagio_dal_corpus.dart';
import 'package:esoteric_circle/core/rituals/rune_cast.dart';
import 'package:esoteric_circle/core/tarot/tarot_reading.dart';
import 'package:esoteric_circle/core/tarot/tarot_spread.dart';
import 'package:esoteric_circle/core/tarot/tarot_spread_type.dart';
import 'package:esoteric_circle/core/tarot/tarot_topic.dart';
import 'package:esoteric_circle/features/horoscope/answer_depth.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';
import 'oroscopo_eu_comune.dart';

/// **I CAMPIONI PER I LETTORI CIECHI.** Strumento di collaudo dell'ordine GA,
/// voce GA.06, 20 ottobre 2026. **Non e' una guardia** e non entra nel
/// registro `docs/guardie.md`: prepara il materiale della prova dei lettori
/// ciechi.
///
/// La voce GA.06, alla lettera: *"Prova: i lettori ciechi, agenti di Code e
/// mai Gemini (metodo FU.05), ricevono per ogni arte almeno trenta responsi
/// con la domanda e i simboli usciti e rispondono a tre domande: la prima
/// frase risponde? Dice che cosa fare o non fare? È coerente coi simboli e
/// con la domanda? Ogni "no" diventa un difetto curato. Una seconda prova
/// scambia i simboli fra due responsi: se un lettore non se ne accorge, il
/// testo è generico e si riscrive."*
///
/// **Nessuna chiamata al modello** (regola SPESE): i responsi sono quelli che
/// l'app compone senza modello, col codice vero.
/// - Oroscopo: il compositore unico `IlResponsoDellOroscopo.componi`, per le
///   porte delle tre tradizioni (`PersonaDiProva` di `oroscopo_eu_comune`),
///   i quattro periodi, i quattro domini, Breve e Lunga.
/// - Tarocchi: le stese da 1, 3, 4 e 10 carte col responso principale di
///   casa (`TarotReading.of` senza modello, cioe' `VoceDellaStesa.
///   responsoDiCasa` o la carta sola dal corpus, che e' anche il ripiego
///   quando il modello non risponde) e le carte singole dal corpus. Senza
///   modello il responso principale e' sempre Breve: la profondita' chiesta
///   e quella vera si scrivono tutte e due.
/// - Rune: le quattro gettate col corpus del presagio
///   (`IlPresagioDalCorpus.componi`), Breve e Lunga, e le schede delle
///   pietre.
/// - Oracolo degli Angeli: il responso del corpus (`LaLetturaDellOracolo.
///   delCorpus`, l'assaggio del Viandante e il ripiego: la carta del
///   Custode), sempre Breve, e le tre carte singole.
///
/// **SCRIVE FILE SOLO CON `GA06_SCRIVI=1`** nell'ambiente: allora mette in
/// `docs/collaudo/GA/lettori_ciechi/` un file JSON per arte. Senza la
/// variabile controlla soltanto che i campioni si compongano, col cardinale
/// minimo di trenta responsi per arte (`cardinale_minimo.dart`), e non
/// scrive niente. I campioni si scelgono col seme fisso [_seme]: due giri
/// danno gli stessi file.
///
/// In PowerShell: `$env:GA06_SCRIVI="1"; flutter test
/// test/ga06_campioni_per_i_lettori_ciechi_test.dart`.
const int _seme = 606;

/// Quanti responsi per arte: la voce ne chiede almeno trenta.
const int _minimo = 30;

/// **LE DOMANDE**, scritte qui come le scriverebbe una persona vera: amore,
/// lavoro, famiglia, scelte, attese. In coda le domande a trabocchetto: vaghe,
/// doppie, una sulla salute, una sul denaro, una legale. L'ambito dice in
/// quale gruppo di argomenti dei Tarocchi la persona la porrebbe.
const List<(String, TarotTopicGroup, String)> domande = [
  // Amore.
  (
    "Lui tornerà da me dopo quello che è successo?",
    TarotTopicGroup.amore,
    'amore'
  ),
  ("Cosa prova davvero Marco per me?", TarotTopicGroup.amore, 'amore'),
  (
    "La mia relazione può durare nonostante la distanza?",
    TarotTopicGroup.amore,
    'amore'
  ),
  ("Devo dirle che sono innamorato di lei?", TarotTopicGroup.amore, 'amore'),
  (
    "Incontrerò qualcuno di importante quest'anno?",
    TarotTopicGroup.amore,
    'amore'
  ),
  ("Posso fidarmi del mio compagno?", TarotTopicGroup.amore, 'amore'),
  ("Ha senso riprovarci con la mia ex?", TarotTopicGroup.amore, 'amore'),
  (
    "Come posso ritrovare l'intesa con mio marito?",
    TarotTopicGroup.amore,
    'amore'
  ),
  // Lavoro.
  ("Il colloquio di giovedì andrà bene?", TarotTopicGroup.lavoro, 'lavoro'),
  (
    "Devo accettare l'offerta della nuova azienda?",
    TarotTopicGroup.lavoro,
    'lavoro'
  ),
  (
    "Riuscirò a ottenere la promozione che aspetto?",
    TarotTopicGroup.lavoro,
    'lavoro'
  ),
  (
    "È il momento giusto per aprire la mia attività?",
    TarotTopicGroup.lavoro,
    'lavoro'
  ),
  (
    "Come gestisco il conflitto con il mio capo?",
    TarotTopicGroup.lavoro,
    'lavoro'
  ),
  (
    "Devo lasciare il lavoro per tornare a studiare?",
    TarotTopicGroup.lavoro,
    'lavoro'
  ),
  (
    "Il progetto che ho presentato verrà approvato?",
    TarotTopicGroup.lavoro,
    'lavoro'
  ),
  // Famiglia.
  ("Come posso fare pace con mia sorella?", TarotTopicGroup.vita, 'famiglia'),
  (
    "Mio figlio sta attraversando un periodo difficile, come lo aiuto?",
    TarotTopicGroup.vita,
    'famiglia'
  ),
  (
    "È giusto andare a vivere lontano dai miei genitori?",
    TarotTopicGroup.vita,
    'famiglia'
  ),
  (
    "Come affronto il pranzo di Natale con la famiglia di lui?",
    TarotTopicGroup.vita,
    'famiglia'
  ),
  // Scelte.
  (
    "Devo trasferirmi a Milano o restare a Bari?",
    TarotTopicGroup.vita,
    'scelte'
  ),
  ("Compro casa adesso o aspetto un anno?", TarotTopicGroup.vita, 'scelte'),
  ("Devo chiudere l'amicizia con Giulia?", TarotTopicGroup.vita, 'scelte'),
  (
    "Quale strada scelgo tra i due corsi di laurea?",
    TarotTopicGroup.vita,
    'scelte'
  ),
  // Attese.
  ("Arriverà presto la risposta che aspetto?", TarotTopicGroup.vita, 'attese'),
  ("Quando finirà questo periodo di stallo?", TarotTopicGroup.vita, 'attese'),
  (
    "Il cambiamento che sento arrivare sarà positivo?",
    TarotTopicGroup.vita,
    'attese'
  ),
  ("Passerò l'esame di stato a dicembre?", TarotTopicGroup.vita, 'attese'),
  // A trabocchetto: vaghe.
  ("Che cosa mi aspetta?", TarotTopicGroup.vita, 'trabocchetto, vaga'),
  ("Andrà tutto bene?", TarotTopicGroup.vita, 'trabocchetto, vaga'),
  ("Dimmi qualcosa.", TarotTopicGroup.vita, 'trabocchetto, vaga'),
  // A trabocchetto: doppie.
  (
    "Lui mi ama ancora e troverò lavoro entro Natale?",
    TarotTopicGroup.amore,
    'trabocchetto, doppia'
  ),
  (
    "Devo lasciare Roma, e se lo faccio la mia famiglia capirà?",
    TarotTopicGroup.vita,
    'trabocchetto, doppia'
  ),
  // A trabocchetto: salute, denaro, legale.
  (
    "L'operazione al ginocchio del mese prossimo andrà bene?",
    TarotTopicGroup.vita,
    'trabocchetto, salute'
  ),
  (
    "Conviene investire i miei risparmi in borsa adesso?",
    TarotTopicGroup.lavoro,
    'trabocchetto, denaro'
  ),
  (
    "Vincerò la causa contro il mio ex socio?",
    TarotTopicGroup.lavoro,
    'trabocchetto, legale'
  ),
];

/// Le domande in un ordine mescolato dal seme dell'arte, ripetuto in giro:
/// in trenta e piu' campioni ogni domanda esce almeno una volta.
List<(String, TarotTopicGroup, String)> _inGiro(int seme) =>
    [...domande]..shuffle(Random(seme));

Map<String, Object?> _pezzi(ResponsoInterpretato r) => {
      'titolo': r.titolo,
      'risposta': r.risposta,
      'cosaFare': r.cosaFare,
      'approfondimento': r.approfondimento,
      'rito': r.rito,
      'titoloDelRito':
          r.rito == null ? null : LaFormaDelResponso.titoloDelRito(r.arte),
      'daDoveViene': r.daDoveViene,
    };

// ---------------------------------------------------------------------------
// OROSCOPO
// ---------------------------------------------------------------------------

/// I giorni delle consultazioni: un martedi', un venerdi' e una domenica,
/// perche' il reggente del rito cambi.
final List<DateTime> _giorni = [
  DateTime(2026, 10, 20),
  DateTime(2026, 10, 23),
  DateTime(2026, 10, 25),
];

/// Il primo giorno del periodo, come lo intende l'Oroscopo: il Giorno e
/// l'inizio della Settimana e del Mese sono oggi; l'Anno occidentale e
/// vedico comincia al compleanno, il cinese a Capodanno lunare (la stessa
/// regola di `l_oroscopo_ha_la_forma_nuova_test.dart`).
DateTime _primoGiorno(
    PersonaDiProva p, TradizioneEu t, PeriodoEu periodo, DateTime oggi) {
  if (periodo != PeriodoEu.anno) return oggi;
  if (t == TradizioneEu.cinese) {
    return IlCapodannoLunare.di(IlCapodannoLunare.annoCinese(oggi)!)!;
  }
  final c = DateTime(oggi.year, p.nascita.month, p.nascita.day);
  return c.isAfter(oggi)
      ? DateTime(oggi.year - 1, p.nascita.month, p.nascita.day)
      : c;
}

String _segno(PersonaDiProva p, TradizioneEu t) => switch (t) {
      TradizioneEu.occidentale => p.segno.italianName,
      TradizioneEu.vedica =>
        ISegniDelleTradizioni.vedica(p.nascitaDeiSegni).nome,
      TradizioneEu.cinese =>
        ISegniDelleTradizioni.cinese(p.nascitaDeiSegni).nome,
    };

String? _fascia(TradizioneEu t, PeriodoEu periodo, HoroscopeDomain d,
    ResponsoInterpretato r) {
  for (final f in FasciaEu.values) {
    for (final v in ITestiEu.fascia(t, periodo, d, f)) {
      if (v.titolo == r.titolo && v.risposta == r.risposta) return f.name;
    }
  }
  return null;
}

String _data(DateTime g) => '${g.year}-${g.month.toString().padLeft(2, '0')}-'
    '${g.day.toString().padLeft(2, '0')}';

List<Map<String, Object?>> campioniDellOroscopo() {
  final caso = Random(_seme);
  final fuori = <Map<String, Object?>>[];
  final combinazioni = [
    for (final t in TradizioneEu.values)
      for (final periodo in PeriodoEu.values)
        for (final d in HoroscopeDomain.values) (t, periodo, d),
  ];
  for (final (t, periodo, d) in combinazioni) {
    // Due domini in Breve e due in Lunga per ogni tradizione e periodo.
    final lunga = (t.index + periodo.index + d.index).isOdd;
    // **L'ANNO OCCIDENTALE VUOLE L'ORA DI NASCITA**, come nell'app
    // (`OroscopoScreen._lAnno` invita a darla e non compone le schede): il
    // campione lo legge solo chi ha l'ora (ordine GA voce GA.06, secondo
    // lettore cieco: "L'Ascendente della tua Rivoluzione Solare" in
    // oroscopo-13, per una persona senza l'ora).
    final persone = dodiciPersone
        .where((p) =>
            p.legge(t) &&
            (t != TradizioneEu.occidentale ||
                periodo != PeriodoEu.anno ||
                p.conCarta))
        .toList();
    final p = persone[caso.nextInt(persone.length)];
    final oggi = _giorni[caso.nextInt(_giorni.length)];
    late final ResponsoInterpretato r;
    late final Object livello;
    switch (periodo) {
      case PeriodoEu.giorno:
        final c = p.giorno(t, oggi, lunga: lunga).firstWhere(
              (c) => c.domain == d,
            );
        r = c.responso!;
        livello = c.indicator;
      case PeriodoEu.settimana:
      case PeriodoEu.mese:
        final mese = periodo == PeriodoEu.mese;
        final dd = p
            .periodo(t, oggi, mese: mese)
            .domini
            .firstWhere((x) => x.dominio == d);
        r = dd.responso(t, mese: mese, lunga: lunga);
        livello = double.parse(dd.media.toStringAsFixed(2));
      case PeriodoEu.anno:
        final c =
            p.anno(t, oggi, lunga: lunga).firstWhere((c) => c.domain == d);
        r = c.responso!;
        livello = c.indicator;
    }
    final primo = _primoGiorno(p, t, periodo, oggi);
    fuori.add({
      'id': 'oroscopo-${fuori.length + 1}',
      'arte': LaFormaDelResponso.nome(r.arte),
      'domanda': null,
      'senzaDomanda': {
        'segno': _segno(p, t),
        'nascita': _data(p.nascita),
        // L'ora di nascita, se la persona l'ha data: senza, chi legge alla
        // cieca non sa da dove venga un Ascendente (secondo lettore cieco,
        // oroscopo-4).
        'oraDiNascita': p.conCarta
            ? '${p.nascita.hour.toString().padLeft(2, '0')}:'
                '${p.nascita.minute.toString().padLeft(2, '0')}'
            : null,
        'tradizione': t.name,
        'periodo': periodo.name,
        'dominio': d.label,
        'oggi': _data(oggi),
        'livello': livello,
        'fascia': _fascia(t, periodo, d, r),
      },
      'simboli': {
        'livello': livello,
        'fascia': _fascia(t, periodo, d, r),
        'reggenteDelRito': IlResponsoDellOroscopo.reggente(t, primo),
        'primoGiornoDelPeriodo': _data(primo),
      },
      'profondita': lunga ? 'Lunga' : 'Breve',
      'responso': _pezzi(r),
      'singole': const <Object>[],
    });
  }
  return fuori;
}

// ---------------------------------------------------------------------------
// TAROCCHI
// ---------------------------------------------------------------------------

List<Map<String, Object?>> campioniDeiTarocchi() {
  final caso = Random(_seme + 1);
  final giro = _inGiro(_seme + 1);
  final fuori = <Map<String, Object?>>[];
  var i = 0;
  for (var volta = 0; volta < 10; volta++) {
    for (final tipo in TarotSpreadType.values) {
      final (domanda, gruppo, ambito) = giro[i % giro.length];
      final argomenti = TarotTopic.of(gruppo);
      final topic = argomenti[caso.nextInt(argomenti.length)];
      final s =
          TarotSpread.draw(seed: _seme * 100 + i, posizioni: tipo.posizioni);
      final depth = i.isEven ? AnswerDepth.breve : AnswerDepth.profonda;
      final uscite = [for (final _ in s.cards) caso.nextInt(3)];
      // Senza modello: il responso principale di casa, che e' anche il
      // ripiego quando il modello non risponde.
      final r = TarotReading.of(s, topic,
          depth: depth,
          domandaScritta: domanda,
          uscite: uscite,
          mazzo: 'Rider-Waite',
          nomeDellaStesa: tipo.nome);
      i++;
      fuori.add({
        'id': 'tarocchi-${fuori.length + 1}',
        'arte': LaFormaDelResponso.nome(ArteInterpretata.tarocchi),
        'domanda': domanda,
        'ambitoDellaDomanda': ambito,
        'argomentoScelto': topic.label,
        'lenteUsata': r.topic.label,
        'stesa': tipo.nome,
        'simboli': [
          for (final c in s.cards)
            {
              'posizione': c.position.label,
              'carta': c.card.name,
              'verso': c.reversed ? 'rovesciata' : 'dritta',
              'significatoDelVerso': c.summary,
            }
        ],
        'cartaChiave': r.chiave.drawn.displayName,
        'profonditaChiesta': depth == AnswerDepth.profonda ? 'Lunga' : 'Breve',
        'profondita': r.principale.lungo ? 'Lunga' : 'Breve',
        'responso': _pezzi(r.principale),
        // La stesa a una carta non ha un secondo blocco per la stessa carta
        // (voce GA.05): il responso principale e' quello della carta.
        'singole': s.cards.length == 1
            ? const <Object>[]
            : [
                for (final p in r.posizioni)
                  {
                    'posizione': p.drawn.position.label,
                    'carta': p.drawn.displayName,
                    ..._pezzi(p.responso!),
                  }
              ],
      });
    }
  }
  return fuori;
}

// ---------------------------------------------------------------------------
// RUNE
// ---------------------------------------------------------------------------

List<Map<String, Object?>> campioniDelleRune() {
  final caso = Random(_seme + 2);
  final giro = _inGiro(_seme + 2);
  final fuori = <Map<String, Object?>>[];
  var i = 0;
  for (var volta = 0; volta < 10; volta++) {
    for (final gettata in gettate) {
      final (domanda, _, ambito) = giro[i % giro.length];
      final esito = RuneCast.getta(gettata, random: Random(_seme * 100 + i));
      final lunga = i.isOdd;
      final forma =
          CourtesyForm.values[caso.nextInt(CourtesyForm.values.length)];
      final p = IlPresagioDalCorpus.componi(
        corpus: corpusDelPresagio,
        esito: esito,
        domanda: domanda,
        persona: 'lettore-cieco-$i',
        oggi: DateTime(2026, 10, 20),
        memoria: LaMemoriaDelPresagio(),
        lunga: lunga,
        forma: forma,
      );
      final decide = IlPresagioDalCorpus.pietraCheDecide(esito);
      i++;
      fuori.add({
        'id': 'rune-${fuori.length + 1}',
        'arte': LaFormaDelResponso.nome(ArteInterpretata.rune),
        'domanda': domanda,
        'ambitoDellaDomanda': ambito,
        'gettata': gettata.nome,
        'formaDiCortesia': forma.name,
        'simboli': [
          for (final r in esito.rune)
            {
              'posizione': r.posizione.titolo,
              'runa': r.rune.name,
              'verso': r.inOmbra ? 'in ombra (merkstave)' : 'dritta',
              'parolaChiave': r.rune.keyword,
              'significato': r.rune.meaning,
              'rigaDelVerso': r.riga,
            }
        ],
        'pietraCheDecide':
            '${decide.rune.name} ${decide.inOmbra ? 'in ombra' : 'dritta'}',
        'profondita': lunga ? 'Lunga' : 'Breve',
        'responso': _pezzi(p.principale),
        'singole': [
          for (var k = 0; k < p.schede.length; k++)
            {
              'posizione': esito.rune[k].posizione.titolo,
              'runa': esito.rune[k].rune.name,
              ..._pezzi(p.schede[k]),
            }
        ],
      });
    }
  }
  return fuori;
}

// ---------------------------------------------------------------------------
// ORACOLO DEGLI ANGELI
// ---------------------------------------------------------------------------

List<Map<String, Object?>> campioniDellOracolo() {
  final caso = Random(_seme + 3);
  final giro = _inGiro(_seme + 3);
  final fuori = <Map<String, Object?>>[];
  for (var i = 0; i < 40; i++) {
    final (domanda, _, ambito) = giro[i % giro.length];
    // Una nascita diversa a ogni consultazione; una su otto senza l'ora,
    // con la terza carta coperta come nell'app.
    final conLOra = i % 8 != 7;
    final nascita = DateTime(1950 + caso.nextInt(55), 1 + caso.nextInt(12),
        1 + caso.nextInt(28), caso.nextInt(24), caso.nextInt(60));
    final identita = BirthIdentity(birthMoment: nascita, hasBirthTime: conLOra);
    final triade = GuardianAngels.forBirth(identita.toBirthDetails());
    final carte = EstrazioneDellOracolo.estrai(triade, Random(_seme * 100 + i));
    final variante = caso.nextInt(3);
    final r = LaLetturaDellOracolo.delCorpus(
        domanda: domanda,
        carte: carte,
        corpus: corpusDellOracolo,
        variante: variante);
    fuori.add({
      'id': 'oracolo-${fuori.length + 1}',
      'arte': LaFormaDelResponso.nome(ArteInterpretata.oracolo),
      'domanda': domanda,
      'ambitoDellaDomanda': ambito,
      'simboli': [
        for (final c in carte)
          {
            'ruolo': c.ruolo.nome,
            'posizione': c.ruolo.posizione,
            'angelo': c.coperta ? null : '${c.angelo.number} ${c.angelo.name}',
            'coro': c.coperta ? null : c.angelo.choir.name,
            'dominioDelCoro': c.coperta ? null : c.angelo.choir.domain,
            'angeloDellaPersona': c.portatore?.name,
            'coperta': c.coperta,
          }
      ],
      'variante': variante,
      'profondita': r.responso.lungo ? 'Lunga' : 'Breve',
      'dalModello': r.dalModello,
      'responso': _pezzi(r.responso),
      'singole': [
        for (final c in carte)
          {
            'ruolo': c.ruolo.nome,
            'angelo': c.coperta ? null : c.angelo.name,
            if (LaLetturaDellOracolo.responsoDellaCarta(
                    corpusDellOracolo, c, variante)
                case final s?)
              ..._pezzi(s)
            else
              'risposta': LaLetturaDellOracolo.messaggioDellaCarta(
                  corpusDellOracolo, c, variante),
          }
      ],
    });
  }
  return fuori;
}

// ---------------------------------------------------------------------------

void main() {
  final scrivi = Platform.environment['GA06_SCRIVI'] == '1';
  const cartella = 'docs/collaudo/GA/lettori_ciechi';

  final arti = <String, List<Map<String, Object?>> Function()>{
    'oroscopo': campioniDellOroscopo,
    'tarocchi': campioniDeiTarocchi,
    'rune': campioniDelleRune,
    'oracolo': campioniDellOracolo,
  };

  for (final MapEntry(key: arte, value: componi) in arti.entries) {
    test('GA.06, i campioni dell\'arte $arte si compongono', () {
      final campioni = componi();
      final vuoti = [
        for (final c in campioni)
          if (((c['responso']! as Map)['risposta'] as String? ?? '')
              .trim()
              .isEmpty)
            c['id']
      ];
      expect(vuoti, isEmpty, reason: 'responsi senza risposta: $vuoti');
      cardinaleMinimo(campioni.length, _minimo,
          cosa: 'responsi composti per l\'arte $arte',
          perche: 'la voce GA.06 chiede almeno trenta responsi per arte ai '
              'lettori ciechi');
      if (!scrivi) {
        print('GA.06 $arte: ${campioni.length} responsi composti, nessun '
            'file scritto (manca GA06_SCRIVI=1)');
        return;
      }
      final dir = Directory(cartella);
      if (!dir.existsSync()) dir.createSync(recursive: true);
      final file = File('$cartella/$arte.json');
      file.writeAsStringSync('${const JsonEncoder.withIndent('  ').convert({
            'ordine': 'GA',
            'voce': 'GA.06',
            'strumento': 'test/ga06_campioni_per_i_lettori_ciechi_test.dart',
            'seme': _seme,
            'senzaModello': true,
            'quanti': campioni.length,
            'responsi': campioni,
          })}\n');
      print('GA.06 $arte: ${campioni.length} responsi scritti in '
          '${file.path}');
    });
  }
}
