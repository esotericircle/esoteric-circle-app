import 'dart:math';

import 'package:esoteric_circle/core/angels/angel_catalog.dart';
import 'package:esoteric_circle/core/chat/le_forme_del_genere.dart';
import 'package:esoteric_circle/core/oracolo_angeli/i_ruoli_e_l_estrazione.dart';
import 'package:esoteric_circle/core/oracolo_angeli/il_corpus_dell_oracolo.g.dart';
import 'package:esoteric_circle/core/oracolo_angeli/l_ora_degli_angeli.dart';
import 'package:esoteric_circle/core/oracolo_angeli/la_lettura_dell_oracolo.dart';
import 'package:esoteric_circle/core/oracolo_angeli/la_risposta_dai_doni.dart';
import 'package:esoteric_circle/core/responsi/confine_del_responso.dart';
import 'package:esoteric_circle/core/responsi/la_forma_del_responso.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';
import 'ga06_campioni_per_i_lettori_ciechi_test.dart' show domande;

/// **L'ORACOLO RISPONDE DAI DONI.** Ordine GA voce GA.06, 20 ottobre 2026.
///
/// Il fondatore, 19 ottobre 2026: *"risposte dirette immediatamente [...]
/// L'utente deve avere una risposta o una guida, deve sapere cosa fare o non
/// fare [...] E ogni risposta deve essere coerente con i simboli o carte o
/// segni altro da interpretare e coerente con la domanda posta
/// dall'utente."*
///
/// Il lettore cieco (`docs/collaudo/GA/lettori_ciechi/esiti/
/// esito_tre_domande_oracolo.md`) aveva trovato il responso senza modello
/// uguale alla carta del Custode 40 volte su 40 (D1), lo stesso testo sotto
/// domande diverse (D2), le domande a trabocchetto mai riconosciute (D6).
/// Queste guardie sorvegliano i difetti di sistema, non le frasi:
/// 1. il principale non e' mai la carta singola del Custode, e la prima
///    frase nomina l'angelo del Custode;
/// 2. con tre carte scoperte il principale nomina anche gli angeli del Cuore
///    e dell'Intelletto; nell'assaggio non li nomina;
/// 3. le domande su salute, legge e denaro dicono il limite e a chi
///    rivolgersi nella prima frase; le vaghe e le doppie si riconoscono;
/// 4. sulle stesse tre carte, domande diverse del campione danno testi
///    diversi;
/// 5. ogni responso composto sta nella forma (40-50 parole per paragrafo,
///    titolo entro 80 caratteri), dentro il confine del responso, senza
///    indovinare il genere e senza le rotture di casa.

/// Le domande fuori dal campione dei lettori ciechi, scritte qui per vedere
/// se la lettura regge anche su parole che lo strumento non ha mai visto:
/// la domanda, la forma attesa, il limite atteso.
const List<(String, FormaDellaDomanda, LimiteDellaDomanda?)> fuoriCampione = [
  ('Il mio matrimonio reggerà?', FormaDellaDomanda.esito, null),
  ('Supererò il concorso?', FormaDellaDomanda.esito, null),
  ('Ce la farò?', FormaDellaDomanda.esito, null),
  (
    'Mia madre guarirà presto?',
    FormaDellaDomanda.esito,
    LimiteDellaDomanda.salute
  ),
  (
    'Devo fare la risonanza al ginocchio?',
    FormaDellaDomanda.decisione,
    LimiteDellaDomanda.salute
  ),
  // Ordine GA voce GA.09, simulazione sul Realme (gruppo A, difetto D2): una
  // persona che scrive di sintomi senza nominare la salute riceveva un
  // orientamento "verso ciò che puoi cominciare oggi" e nessun rimando al
  // medico. I sintomi si riconoscono anche senza la parola salute.
  (
    'Ho spesso mal di testa e mi sento stanca e poi non so se lasciare il mio compagno. Che cosa devo fare?',
    FormaDellaDomanda.generica,
    LimiteDellaDomanda.salute
  ),
  (
    'Soffro di insonnia da mesi, passerà?',
    FormaDellaDomanda.esito,
    LimiteDellaDomanda.salute
  ),
  (
    'Ho dolori forti al petto da giorni, che cosa devo fare?',
    FormaDellaDomanda.generica,
    LimiteDellaDomanda.salute
  ),
  (
    'Mi conviene chiedere un prestito?',
    FormaDellaDomanda.decisione,
    LimiteDellaDomanda.denaro
  ),
  (
    'Devo comprare azioni in borsa?',
    FormaDellaDomanda.decisione,
    LimiteDellaDomanda.denaro
  ),
  (
    'Devo denunciare il mio vicino?',
    FormaDellaDomanda.decisione,
    LimiteDellaDomanda.legge
  ),
  (
    'Il giudice mi darà l\'affidamento?',
    FormaDellaDomanda.esito,
    LimiteDellaDomanda.legge
  ),
  ('Quando troverò l\'amore?', FormaDellaDomanda.quando, null),
  ('Cosa pensa di me la mia collega?', FormaDellaDomanda.sentimenti, null),
  ('Mi tradisce?', FormaDellaDomanda.fiducia, null),
  ('Tornerà a cercarmi?', FormaDellaDomanda.ritorno, null),
  ('Dovrei cambiare città o restare qui?', FormaDellaDomanda.scelta, null),
  ('Come mi comporto con mia suocera?', FormaDellaDomanda.come, null),
  ('Come trovo la mia strada?', FormaDellaDomanda.come, null),
  ('Vale la pena aspettarlo?', FormaDellaDomanda.decisione, null),
  ('Che cosa devo capire di questo periodo?', FormaDellaDomanda.generica, null),
  ('Parlami.', FormaDellaDomanda.aperta, null),
  ('Cosa mi riserva il futuro?', FormaDellaDomanda.futuro, null),
  ('Mi sposerò e avrò figli?', FormaDellaDomanda.esito, null),
  ('Posso fidarmi della mia socia?', FormaDellaDomanda.fiducia, null),
  ('È il momento di cambiare casa?', FormaDellaDomanda.decisione, null),
];

/// Le forme e i limiti attesi delle domande del campione, nell'ordine di
/// `domande`.
const List<(FormaDellaDomanda, LimiteDellaDomanda?)> attesiDelCampione = [
  (FormaDellaDomanda.ritorno, null),
  (FormaDellaDomanda.sentimenti, null),
  (FormaDellaDomanda.esito, null),
  (FormaDellaDomanda.decisione, null),
  (FormaDellaDomanda.esito, null),
  (FormaDellaDomanda.fiducia, null),
  (FormaDellaDomanda.decisione, null),
  (FormaDellaDomanda.come, null),
  (FormaDellaDomanda.esito, null),
  (FormaDellaDomanda.decisione, null),
  (FormaDellaDomanda.esito, null),
  (FormaDellaDomanda.decisione, LimiteDellaDomanda.denaro),
  (FormaDellaDomanda.come, null),
  (FormaDellaDomanda.decisione, null),
  (FormaDellaDomanda.esito, null),
  (FormaDellaDomanda.come, null),
  (FormaDellaDomanda.come, null),
  (FormaDellaDomanda.decisione, null),
  (FormaDellaDomanda.come, null),
  (FormaDellaDomanda.scelta, null),
  (FormaDellaDomanda.scelta, LimiteDellaDomanda.denaro),
  (FormaDellaDomanda.decisione, null),
  (FormaDellaDomanda.scelta, null),
  (FormaDellaDomanda.esito, null),
  (FormaDellaDomanda.quando, null),
  (FormaDellaDomanda.esito, null),
  (FormaDellaDomanda.esito, null),
  (FormaDellaDomanda.futuro, null),
  (FormaDellaDomanda.futuro, null),
  (FormaDellaDomanda.aperta, null),
  (FormaDellaDomanda.sentimenti, null),
  (FormaDellaDomanda.decisione, null),
  (FormaDellaDomanda.esito, LimiteDellaDomanda.salute),
  (FormaDellaDomanda.decisione, LimiteDellaDomanda.denaro),
  (FormaDellaDomanda.esito, LimiteDellaDomanda.legge),
];

/// Le domande che sono due in una, nel campione.
const Set<String> doppieDelCampione = {
  'Lui mi ama ancora e troverò lavoro entro Natale?',
  'Devo lasciare Roma, e se lo faccio la mia famiglia capirà?',
};

List<CartaDellOracolo> _carte(int c, int h, int? i) => [
      CartaDellOracolo(
          ruolo: RuoloDellAngelo.custode,
          angelo: AngelCatalog.byNumber(c),
          portatore: AngelCatalog.byNumber(1)),
      CartaDellOracolo(
          ruolo: RuoloDellAngelo.cuore,
          angelo: AngelCatalog.byNumber(h),
          portatore: AngelCatalog.byNumber(2)),
      CartaDellOracolo(
          ruolo: RuoloDellAngelo.intelletto,
          angelo: AngelCatalog.byNumber(i ?? 3),
          portatore: i == null ? null : AngelCatalog.byNumber(3)),
    ];

/// La prima frase: fino al primo punto che chiude una frase.
String primaFrase(String t) {
  final m = RegExp(r'^.*?[.!?](?=\s|$)').firstMatch(t);
  return m == null ? t : m[0]!;
}

/// Le parole che la politica degli angeli vieta anche al responso
/// principale (docs/corpus/angeli.md e `LaLetturaDellOracolo`): promesse di
/// esito, protezione, guarigione, certezze, entita' avverse.
final RegExp _vietate = RegExp(
    r'(?<![\p{L}])(proteg\w*|protezion\w*|vincer\w*|vittori\w*|guari\w*|'
    r'ricchezz\w*|sicuramente|accadrà|succederà|otterrai|vincerai|demon\w*|'
    r'goet\w*|garantit\w*|miracol\w*|chiama (?:la|quella|una|un|oggi|'
    r'qualcuno)|telefon\w*)',
    caseSensitive: false,
    unicode: true);

/// **LE CUCITURE** che il secondo lettore cieco ha sentito (ordine GA voce
/// GA.06, 21 ottobre 2026): il gesto attribuito all'angelo, la voce che
/// cambia persona, i riempitivi che valgono per tutto, la fretta su scelte
/// grandi, l'etichetta "ti riporta a ciò che è tuo".
final RegExp _cuciture = RegExp(
    r"(è il gesto che|lega a|nella mia lettura|questo angelo|basta un passo|"
    r"non serve fare tutto oggi|un passo piccolo vale|a mente fresca|"
    r"decidi domani|ti riporta a ciò che è tuo)",
    caseSensitive: false);

/// Le rotture di casa di un testo a video, in un elenco.
List<String> rottureDi(String nome, String t) => [
      if (t.contains(String.fromCharCode(0x2014)) ||
          t.contains(String.fromCharCode(0x2013)))
        '$nome: trattino lungo',
      if (RegExp(r',\s+(e|ed)(?![\p{L}])', unicode: true).hasMatch(t))
        '$nome: virgola prima di "e"',
      if (t.contains('  ')) '$nome: due spazi',
      if (t.isNotEmpty && t[0] != t[0].toUpperCase())
        '$nome: comincia con la minuscola',
      if (!RegExp(r'[.!?]$').hasMatch(t) && nome != 'titolo')
        '$nome: non chiude con un punto',
      if (_vietate.hasMatch(t))
        '$nome: parola vietata «${_vietate.firstMatch(t)![0]}»',
      if (RegExp(
              r"(?<![\p{L}])(su|di|a|da|in) (il|lo|la|i|gli|le|l')(?![\p{L}])",
              caseSensitive: false,
              unicode: true)
          .hasMatch(t))
        '$nome: preposizione senza articolo unito «${RegExp(r"(?<![\p{L}])(su|di|a|da|in) (il|lo|la|i|gli|le|l')(?![\p{L}])", caseSensitive: false, unicode: true).firstMatch(t)![0]}»',
      if (_cuciture.hasMatch(t))
        '$nome: cucitura «${_cuciture.firstMatch(t)![0]}»',
      for (final v in ConfineDelResponso.violazioni(t)) '$nome: confine $v',
      for (final g in formeDelGenere(t)) '$nome: genere «$g»',
    ];

void main() {
  final tutte = [for (final (d, _, _) in domande) d];

  group('la lettura della domanda', () {
    test('le domande del campione: forma, limite e doppie', () {
      expect(attesiDelCampione.length, domande.length);
      final colpe = <String>[];
      for (var k = 0; k < domande.length; k++) {
        final d = domande[k].$1;
        final q = LaDomandaDellOracolo.leggi(d);
        final (forma, limite) = attesiDelCampione[k];
        if (q.forma != forma || q.limite != limite) {
          colpe.add('$d: ${q.forma.name}/${q.limite?.name} invece di '
              '${forma.name}/${limite?.name}');
        }
        if (q.doppia != doppieDelCampione.contains(d)) {
          colpe.add('$d: doppia ${q.doppia}');
        }
      }
      expect(colpe, isEmpty, reason: colpe.join('\n'));
    });

    test('le domande fuori campione: la lettura regge su parole nuove', () {
      final colpe = <String>[];
      for (final (d, forma, limite) in fuoriCampione) {
        final q = LaDomandaDellOracolo.leggi(d);
        if (q.forma != forma || q.limite != limite) {
          colpe.add('$d: ${q.forma.name}/${q.limite?.name} invece di '
              '${forma.name}/${limite?.name}');
        }
      }
      // ignore: avoid_print
      print(
          'GA.06 MISURA fuori campione: ${fuoriCampione.length - colpe.length}'
          ' su ${fuoriCampione.length} lette come atteso');
      expect(colpe, isEmpty, reason: colpe.join('\n'));
    });

    test('a te: la prima persona passa alla seconda', () {
      expect(
          LaDomandaDellOracolo.allInfinito('posso fare pace con mia sorella'),
          'fare pace con tua sorella');
      expect(
          LaDomandaDellOracolo.allInfinito('lo aiuto', persona: 'tuo figlio'),
          'aiutare tuo figlio');
      expect(
          LaDomandaDellOracolo.allInfinito(
              'gestisco il conflitto con il mio capo'),
          'gestire il conflitto con il tuo capo');
      expect(LaDomandaDellOracolo.allInfinito('trasferirmi a Milano'),
          'trasferirti a Milano');
      expect(LaDomandaDellOracolo.aTe('i miei risparmi'), 'i tuoi risparmi');
      expect(LaDomandaDellOracolo.allInfinito('sto accanto a chi amo'), isNull,
          reason: '"amo" non si sa girare: la frase non si usa');
      expect(LaRispostaDaiDoni.con('di', 'il colloquio'), 'del colloquio');
      expect(LaRispostaDaiDoni.con('a', "l'esame"), "all'esame");
      expect(LaRispostaDaiDoni.con('a', 'tuo marito'), 'a tuo marito');
      expect(
          LaDomandaDellOracolo.leggi('Posso fidarmi del mio compagno?').persona,
          'il tuo compagno');
    });
  });

  group('i difetti di sistema del lettore cieco', () {
    test(
        'D1: il principale non e\' mai la carta singola del Custode, e la '
        'prima frase nomina l\'angelo del Custode', () {
      final colpe = <String>[];
      var visti = 0;
      for (var n = 1; n <= 72; n++) {
        final carte = _carte(n, n % 72 + 1, (n + 9) % 72 + 1);
        final custode = carte.first;
        for (var v = 0; v < 3; v++) {
          for (final d in [
            tutte[n % tutte.length],
            tutte[(n * 7) % tutte.length]
          ]) {
            final r = LaLetturaDellOracolo.delCorpus(
                    domanda: d,
                    carte: carte,
                    corpus: corpusDellOracolo,
                    variante: v)
                .responso;
            visti++;
            final messaggio = LaLetturaDellOracolo.messaggioDellaCarta(
                corpusDellOracolo, custode, v);
            final consiglio = LaLetturaDellOracolo.consiglioDellaCarta(
                corpusDellOracolo, custode, v);
            if (r.risposta == messaggio || r.cosaFare == consiglio) {
              colpe
                  .add('${custode.angelo.name} $v: copia la carta del Custode');
            }
            // Sotto salute, legge e denaro la prima frase dice il limite e
            // chi e' competente; l'angelo viene nella seconda.
            final limite = LaDomandaDellOracolo.leggi(d).limite != null;
            final dove = limite
                ? r.risposta.substring(primaFrase(r.risposta).length)
                : primaFrase(r.risposta);
            if (!dove.contains(custode.angelo.name)) {
              colpe
                  .add('${custode.angelo.name} "$d": la prima frase non nomina '
                      'l\'angelo: ${primaFrase(r.risposta)}');
            }
          }
        }
      }
      cardinaleMinimo(visti, 432, cosa: 'responsi del corpus guardati');
      expect(colpe, isEmpty, reason: colpe.take(10).join('\n'));
    });

    test(
        'D1: con tre carte scoperte entrano il Cuore e l\'Intelletto; '
        'nell\'assaggio no', () {
      final colpe = <String>[];
      var visti = 0;
      for (var n = 1; n <= 72; n++) {
        final h = (n + 20) % 72 + 1;
        final i = (n + 40) % 72 + 1;
        final carte = _carte(n, h, i);
        final d = tutte[n % tutte.length];
        final tre = LaRispostaDaiDoni.componi(
            domanda: d, carte: carte, corpus: corpusDellOracolo);
        final solo = LaRispostaDaiDoni.componi(
            domanda: d,
            carte: carte,
            corpus: corpusDellOracolo,
            soloIlCustode: true);
        visti++;
        final nomeH = AngelCatalog.byNumber(h).name;
        final nomeI = AngelCatalog.byNumber(i).name;
        if (!tre.risposta.contains(nomeH) || !tre.risposta.contains(nomeI)) {
          colpe.add('$n "$d": il Cuore ($nomeH) o l\'Intelletto ($nomeI) non '
              'entrano: ${tre.risposta}');
        }
        if (solo.risposta.contains(nomeH) ||
            solo.risposta.contains(nomeI) ||
            solo.cosaFare.contains(nomeH) ||
            solo.cosaFare.contains(nomeI)) {
          colpe.add('$n "$d": l\'assaggio nomina una carta col lucchetto');
        }
      }
      cardinaleMinimo(visti, 72, cosa: 'consultazioni a tre carte guardate');
      expect(colpe, isEmpty, reason: colpe.take(10).join('\n'));
    });

    test(
        'D6: salute, legge e denaro dicono il limite e a chi rivolgersi nella '
        'prima frase; le vaghe e le doppie si riconoscono', () {
      const chi = {
        LimiteDellaDomanda.salute: 'medico',
        LimiteDellaDomanda.legge: 'avvocato',
        LimiteDellaDomanda.denaro: 'consulente',
      };
      final colpe = <String>[];
      var limiti = 0;
      var vaghe = 0;
      var doppie = 0;
      final carte = _carte(47, 9, 31);
      // Il limite atteso di ogni domanda: una domanda su salute, legge o
      // denaro che il responso non riconosce e' il difetto D6.
      final attesi = <String, LimiteDellaDomanda?>{
        for (var k = 0; k < domande.length; k++)
          domande[k].$1: attesiDelCampione[k].$2,
        for (final (f, _, l) in fuoriCampione) f: l,
      };
      for (final MapEntry(key: d, value: atteso) in attesi.entries) {
        final q = LaDomandaDellOracolo.leggi(d);
        final r = LaRispostaDaiDoni.componi(
            domanda: d, carte: carte, corpus: corpusDellOracolo);
        final prima = primaFrase(r.risposta);
        if (atteso != null && !prima.contains(chi[atteso]!)) {
          colpe.add('$d: domanda su ${atteso.name} non riconosciuta, la prima '
              'frase non nomina chi e\' competente (${chi[atteso]}): $prima');
        }
        if (atteso != null) limiti++;
        if (q.limite != null) {
          if (!prima.contains(chi[q.limite]!)) {
            colpe.add('$d: la prima frase non rimanda al ${chi[q.limite]}: '
                '$prima');
          }
          if (!r.cosaFare.contains(chi[q.limite]!)) {
            colpe.add('$d: il "Cosa fare" non rimanda al ${chi[q.limite]}');
          }
        }
        if (q.limite == null &&
            (q.forma == FormaDellaDomanda.futuro ||
                q.forma == FormaDellaDomanda.aperta)) {
          vaghe++;
          if (!r.cosaFare.contains('rifai la domanda') &&
              !r.cosaFare.contains('Rifai la domanda')) {
            colpe.add('$d: la domanda vaga non invita a precisarla');
          }
        }
        if (q.doppia) {
          doppie++;
          if ('${r.risposta} ${r.cosaFare}'
                  .split('un\'altra consultazione')
                  .length !=
              2) {
            colpe.add('$d: la doppia non rimanda la seconda domanda');
          }
        }
      }
      cardinaleMinimo(limiti, 11, cosa: 'domande su salute, legge e denaro');
      cardinaleMinimo(vaghe, 5, cosa: 'domande vaghe');
      cardinaleMinimo(doppie, 3, cosa: 'domande doppie');
      expect(colpe, isEmpty, reason: colpe.join('\n'));
    });

    test(
        'D2: sulle stesse tre carte, le domande diverse del campione danno '
        'risposte diverse', () {
      final caso = Random(606);
      final colpe = <String>[];
      var guardate = 0;
      for (var k = 0; k < 40; k++) {
        final numeri = <int>{};
        while (numeri.length < 3) {
          numeri.add(caso.nextInt(72) + 1);
        }
        final n = numeri.toList();
        final carte = _carte(n[0], n[1], k % 8 == 7 ? null : n[2]);
        final viste = <String, String>{};
        final gesti = <String, String>{};
        final titoli = <String, String>{};
        for (final d in tutte.toSet()) {
          final r = LaRispostaDaiDoni.componi(
              domanda: d, carte: carte, corpus: corpusDellOracolo);
          guardate++;
          final gia = viste[r.risposta];
          if (gia != null) {
            colpe.add('carte $n: "$gia" e "$d" hanno la stessa risposta');
          }
          viste[r.risposta] = d;
          // Anche il "Cosa fare" segue la domanda. L'unica eccezione,
          // dichiarata: due domande vaghe ("Che cosa mi aspetta?", "Andrà
          // tutto bene?") ricevono lo stesso invito a precisare la domanda.
          final q = LaDomandaDellOracolo.leggi(d);
          final vaga = q.limite == null &&
              (q.forma == FormaDellaDomanda.futuro ||
                  q.forma == FormaDellaDomanda.aperta);
          if (vaga) continue;
          final giaGesto = gesti[r.cosaFare];
          if (giaGesto != null) {
            colpe.add('carte $n: "$giaGesto" e "$d" hanno lo stesso "Cosa '
                'fare"');
          }
          gesti[r.cosaFare] = d;
          final giaTitolo = titoli[r.titolo];
          if (giaTitolo != null) {
            colpe.add('carte $n: "$giaTitolo" e "$d" hanno lo stesso titolo '
                '«${r.titolo}»');
          }
          titoli[r.titolo] = d;
        }
      }
      cardinaleMinimo(guardate, 40 * 35, cosa: 'risposte guardate');
      expect(colpe, isEmpty, reason: colpe.take(10).join('\n'));
    });
  });

  test(
      'la forma e il confine: ogni responso composto sta fra 40 e 50 parole '
      'per paragrafo, col titolo entro 80 caratteri, senza rotture', () {
    // Gli angeli con le frasi del Cuore e dell'Intelletto piu' lunghe e piu'
    // corte nel gruppo della domanda: la misura e' additiva, quindi i casi
    // estremi coprono il resto. Le frasi del Custode e i gesti li coprono i
    // 72 custodi.
    int lunghezza(int n, String campo) =>
        LaFormaDelResponso.parole(LaRispostaDaiDoni.lettura(
                corpusDellOracolo, AngelCatalog.byNumber(n), campo) ??
            '');
    List<(int, int)> estremiDi(String gruppo) {
      final numeri = [for (var n = 1; n <= 72; n++) n];
      final perCuore = [...numeri]..sort((a, b) => lunghezza(a, 'cuore_$gruppo')
          .compareTo(lunghezza(b, 'cuore_$gruppo')));
      final perIntelletto = [...numeri]..sort((a, b) =>
          lunghezza(a, 'intelletto_$gruppo')
              .compareTo(lunghezza(b, 'intelletto_$gruppo')));
      return [
        (perCuore.last, perIntelletto.last),
        (perCuore.first, perIntelletto.first),
        (perCuore.last, perIntelletto.first),
        (perCuore.first, perIntelletto.last),
      ];
    }

    final domandeTutte = [...tutte, for (final (f, _, _) in fuoriCampione) f];
    final colpe = <String>[];
    var guardati = 0;
    for (final d in domandeTutte) {
      final gruppo =
          FamigliaDellaDomanda.di(LaDomandaDellOracolo.leggi(d)).gruppo;
      final estremi = estremiDi(gruppo);
      for (var c = 1; c <= 72; c++) {
        for (final (h, i) in estremi) {
          if (h == c || i == c || h == i) continue;
          for (final caso in const ['tre', 'coperta', 'assaggio']) {
            final r = LaRispostaDaiDoni.componi(
                domanda: d,
                carte: _carte(c, h, caso == 'coperta' ? null : i),
                corpus: corpusDellOracolo,
                soloIlCustode: caso == 'assaggio');
            guardati++;
            final chi = '"$d" custode $c, $caso';
            for (final x in r.difetti(conLaFonte: false)) {
              colpe.add('$chi: $x');
            }
            if (r.titolo.length > LaLetturaDellOracolo.tettoDelTitolo) {
              colpe.add('$chi: titolo di ${r.titolo.length} caratteri');
            }
            for (final x in [
              ...rottureDi('titolo', r.titolo),
              ...rottureDi('risposta', r.risposta),
              ...rottureDi('cosaFare', r.cosaFare),
            ]) {
              colpe.add('$chi: $x');
            }
          }
        }
      }
    }
    cardinaleMinimo(guardati, 72 * 3 * 50,
        cosa: 'responsi composti guardati',
        perche: 'tutte le domande, tutti i custodi, i casi estremi dei doni');
    // ignore: avoid_print
    print('GA.06 MISURA responsi composti guardati $guardati, difetti '
        '${colpe.length}');
    final specie = <String>{
      for (final x in colpe)
        x
            .replaceAll(RegExp(r'custode \d+'), 'custode')
            .replaceAll(RegExp(r'«[^»]*»'), '')
            .replaceAll(RegExp(r'\d+ parole'), 'N parole'),
    };
    for (final s in specie.take(40)) {
      // ignore: avoid_print
      print('SPECIE $s');
    }
    expect(colpe, isEmpty, reason: colpe.take(15).join('\n'));
  });

  /// **IL CUORE DETTO SULLA DOMANDA**, ordine GA voce GA.06, terza lettura
  /// cieca: le frasi del Cuore e dell'Intelletto erano "glosse fisse
  /// dell'angelo, incollate", vere sotto qualunque domanda e legate a
  /// nessuna. La frase dei ruoli si apre con la situazione della domanda
  /// ("Mentre aspetti, nel Cuore, ..."), o la frase scritta la nomina gia'.
  /// La misura: su ogni domanda del campione e fuori campione, per ognuno dei
  /// 72 custodi con tre carte scoperte, quante frasi dei ruoli sono dette
  /// sulla situazione.
  test('il Cuore e l\'Intelletto sono detti sulla situazione della domanda',
      () {
    final situazione = RegExp(
        r'(In questa situazione|Mentre ti prepari|Mentre aspetti|Intanto|'
        r'In questo rapporto|Davanti a questa scelta|Per riuscirci|'
        r'Per questo periodo), nel Cuore,');
    var guardati = 0;
    var detti = 0;
    final senza = <String>[];
    for (final d in [...tutte, for (final (f, _, _) in fuoriCampione) f]) {
      for (var n = 1; n <= 72; n++) {
        final h = n % 72 + 1;
        final i = (n + 30) % 72 + 1;
        final r = LaRispostaDaiDoni.componi(
            domanda: d, carte: _carte(n, h, i), corpus: corpusDellOracolo);
        if (!r.risposta.contains('Nel Cuore,') &&
            !r.risposta.contains('nel Cuore,')) {
          continue;
        }
        guardati++;
        final frase = LaRispostaDaiDoni.lettura(
                corpusDellOracolo,
                AngelCatalog.byNumber(h),
                'cuore_${FamigliaDellaDomanda.di(LaDomandaDellOracolo.leggi(d)).gruppo}') ??
            '';
        final f = FamigliaDellaDomanda.di(LaDomandaDellOracolo.leggi(d));
        final delCustode = (LaRispostaDaiDoni.lettura(
                    corpusDellOracolo, AngelCatalog.byNumber(n), f.custode) ??
                '')
            .toLowerCase();
        if (situazione.hasMatch(r.risposta) ||
            // La frase del Custode dice gia' la situazione con le stesse
            // parole della cornice ("imparando mentre aspetti").
            [
              'in questa situazione',
              'mentre ti prepari',
              'mentre aspetti',
              'intanto',
              'in questo rapporto',
              'davanti a questa scelta',
              'per riuscirci',
              'per questo periodo',
            ].any(delCustode.contains) ||
            RegExp(
                    r'situazione|prepar|aspett|attes|mentre|intanto|rapporto|'
                    r'scelt|davanti|riuscir|periodo',
                    caseSensitive: false)
                .hasMatch(frase)) {
          detti++;
        } else if (senza.length < 10) {
          senza.add('"$d" custode $n: ${r.risposta}');
        }
      }
    }
    cardinaleMinimo(guardati, 72 * 30, cosa: 'frasi dei ruoli guardate');
    final quota = detti / guardati;
    // ignore: avoid_print
    print('GA.06 MISURA ruoli detti sulla situazione $detti su $guardati '
        '(${(quota * 100).toStringAsFixed(1)} per cento)');
    // 88,5 per cento alla nascita della guardia (3695 su 4176): il resto
    // sono le domande in cui con la cornice il paragrafo supera le 50 parole
    // e l'unica apertura che lascia posto e' quella generica, che darebbe la
    // stessa risposta a domande diverse.
    expect(quota, greaterThanOrEqualTo(0.85), reason: senza.join('\n'));
  });

  /// **LE LETTURE ENTRANO INTERE**, ordine GA voce GA.06, seconda cura: il
  /// secondo lettore cieco ha sentito il dono incollato sulla domanda e il
  /// Cuore e l'Intelletto come etichette. Adesso il responso porta le frasi
  /// SCRITTE per quell'angelo e quella famiglia di domanda: la frase del
  /// Custode e quelle del Cuore e dell'Intelletto nella risposta, il gesto
  /// nel "Cosa fare". Nessun ripiego sul dono incollato.
  test('le letture scritte entrano intere nel responso, per ogni famiglia', () {
    final colpe = <String>[];
    var guardati = 0;
    final perFamiglia = <FamigliaDellaDomanda, String>{};
    for (final d in [...tutte, for (final (f, _, _) in fuoriCampione) f]) {
      perFamiglia.putIfAbsent(
          FamigliaDellaDomanda.di(LaDomandaDellOracolo.leggi(d)), () => d);
    }
    cardinaleMinimo(perFamiglia.length, FamigliaDellaDomanda.values.length,
        cosa: 'famiglie di domanda con una domanda di prova');
    for (final MapEntry(key: f, value: d) in perFamiglia.entries) {
      for (var n = 1; n <= 72; n++) {
        final h = n % 72 + 1;
        final i = (n + 30) % 72 + 1;
        final r = LaRispostaDaiDoni.componi(
            domanda: d, carte: _carte(n, h, i), corpus: corpusDellOracolo);
        guardati++;
        String? l(int a, String campo) => LaRispostaDaiDoni.lettura(
            corpusDellOracolo, AngelCatalog.byNumber(a), campo);
        final pezzi = {
          'custode ${f.custode}': (l(n, f.custode), r.risposta),
          'cuore_${f.gruppo}': (l(h, 'cuore_${f.gruppo}'), r.risposta),
          'intelletto_${f.gruppo}': (
            l(i, 'intelletto_${f.gruppo}'),
            r.risposta
          ),
          'gesto_${f.gruppo}': (l(n, 'gesto_${f.gruppo}'), r.cosaFare),
        };
        for (final MapEntry(key: k, value: (frase, testo)) in pezzi.entries) {
          if (frase == null) {
            colpe.add('angelo $n: manca la lettura $k');
          } else if (!testo.contains(frase)) {
            colpe.add('"$d", angelo $n: la lettura $k non entra intera');
          }
        }
      }
    }
    cardinaleMinimo(guardati, 72 * 8, cosa: 'responsi guardati');
    expect(colpe, isEmpty, reason: colpe.take(10).join('\n'));
  });

  test('i doni del corpus: uno e una via per ognuno dei 72 angeli', () {
    var visti = 0;
    for (var n = 1; n <= 72; n++) {
      final a = AngelCatalog.byNumber(n);
      final dono = LaRispostaDaiDoni.dono(corpusDellOracolo, a);
      final via = LaRispostaDaiDoni.via(corpusDellOracolo, a);
      expect(dono, isNot(a.choir.domain), reason: '$n: manca il dono');
      expect(via, isNot(startsWith('restare fedele a ciò che conta per te')),
          reason: '$n: manca la via');
      expect(LOraDegliAngeli.chiave(RuoloDellAngelo.custode, a), isNotEmpty);
      visti++;
    }
    cardinaleMinimo(visti, 72, cosa: 'angeli col dono e la via');
  });
}
