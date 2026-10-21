// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:esoteric_circle/core/angels/angel_catalog.dart';
import 'package:esoteric_circle/core/angels/guardian_angels.dart';
import 'package:esoteric_circle/core/identity/birth_identity.dart';
import 'package:esoteric_circle/core/oracolo_angeli/i_ruoli_e_l_estrazione.dart';
import 'package:esoteric_circle/core/oracolo_angeli/il_corpus_dell_oracolo.g.dart';
import 'package:esoteric_circle/core/oracolo_angeli/l_ora_degli_angeli.dart';
import 'package:esoteric_circle/core/oracolo_angeli/la_lettura_dell_oracolo.dart';
import 'package:esoteric_circle/core/responsi/confine_del_responso.dart';
import 'package:esoteric_circle/core/responsi/la_forma_del_responso.dart';
import 'package:esoteric_circle/services/ai/maestro_persona.dart';
import 'package:flutter_test/flutter_test.dart';

import 'il_giro_dell_oracolo.dart';

/// **L'ORACOLO DEGLI ANGELI, IL NUCLEO.** Ordine FU voci FU.03, FU.04,
/// FU.07 e FU.08: l'estrazione, l'ora degli angeli, la lettura col modello
/// (sempre con la chiamata finta: R2, nessuna chiamata vera durante
/// l'ordine) e il ripiego del corpus.
///
/// **L'ORDINE GA**, voci GA.03, GA.05, GA.06 e GA.07, 20 ottobre 2026: la
/// lettura chiede al modello i campi della forma nuova (titolo, risposta,
/// cosaFare e nella Lunga approfondimento), con l'istruzione comune della
/// forma (`LaFormaDelResponso.perIlModello`) dentro; una risposta che esce
/// dalla misura di 40-50 parole non si tronca, si scarta e parla la carta
/// del Custode dal corpus. Le prove di prima che pretendevano il riquadro e
/// i tre paragrafi (FU.04, FY.19) sono riscritte qui, con la regola nuova.
AngelTriad _triade({bool conOra = true}) =>
    GuardianAngels.forBirth(BirthIdentity(
            birthMoment: DateTime(1990, 5, 12, 14, 30), hasBirthTime: conOra)
        .toBirthDetails());

void main() {
  group('l\'estrazione', () {
    test('tre angeli diversi su duecento consultazioni, uno per ruolo', () {
      for (var seme = 0; seme < 200; seme++) {
        final carte = EstrazioneDellOracolo.estrai(_triade(), Random(seme));
        expect(carte.map((c) => c.ruolo), RuoloDellAngelo.values);
        expect(carte.map((c) => c.angelo.number).toSet(), hasLength(3),
            reason: 'seme $seme: due carte uguali');
      }
    });

    test('ogni carta e\' portata dall\'angelo della persona del suo ruolo', () {
      final t = _triade();
      final carte = EstrazioneDellOracolo.estrai(t, Random(1));
      expect(carte[0].portatore, t.guardian);
      expect(carte[1].portatore, t.heart);
      expect(carte[2].portatore, t.intellect);
    });

    test('senza l\'ora di nascita la terza carta resta coperta', () {
      final carte =
          EstrazioneDellOracolo.estrai(_triade(conOra: false), Random(1));
      expect(carte[2].coperta, isTrue);
      expect(carte[0].coperta, isFalse);
    });
  });

  group('l\'ora degli angeli', () {
    test('la stessa regola dell\'Intelletto, su tutti i minuti del giorno', () {
      for (var m = 0; m < 24 * 60; m++) {
        final dellOra =
            LOraDegliAngeli.dellOra(DateTime(2026, 10, 15, m ~/ 60, m % 60));
        final intelletto = GuardianAngels.intellectFor(m ~/ 60, m % 60)!;
        expect(dellOra.number, intelletto.number, reason: 'minuto $m');
      }
    });

    test('il momento del rito sono i venti minuti dell\'angelo', () {
      expect(LOraDegliAngeli.momentoDelRito(AngelCatalog.byNumber(1)),
          'dalle 00:00 alle 00:20');
      expect(LOraDegliAngeli.momentoDelRito(AngelCatalog.byNumber(2)),
          'dalle 00:20 alle 00:40');
      expect(LOraDegliAngeli.momentoDelRito(AngelCatalog.byNumber(72)),
          'dalle 23:40 alle 00:00');
    });

    test('il prossimo cambio e\' l\'inizio dei venti minuti seguenti', () {
      expect(LOraDegliAngeli.prossimoCambio(DateTime(2026, 10, 15, 10, 7)),
          DateTime(2026, 10, 15, 10, 20));
      expect(LOraDegliAngeli.prossimoCambio(DateTime(2026, 10, 15, 23, 59)),
          DateTime(2026, 10, 16));
    });

    test('il messaggio del giorno cambia col giorno e viene dal corpus', () {
      final testi = <String>{};
      for (var g = 1; g <= 9; g++) {
        final m = LOraDegliAngeli.messaggioDelGiorno(
            triade: _triade(),
            giorno: DateTime(2026, 10, g),
            corpus: corpusDellOracolo);
        expect(m, isNotNull);
        expect(corpusDellOracolo[LOraDegliAngeli.chiave(m!.ruolo, m.angelo)],
            contains(m.testo));
        testi.add(m.testo);
      }
      expect(testi.length, greaterThanOrEqualTo(7),
          reason: 'in nove giorni il messaggio si ripete troppo');
    });
  });

  group('la lettura col modello', () {
    final carte = EstrazioneDellOracolo.estrai(_triade(), Random(3));

    test('una chiamata sola: la domanda e i tre angeli, la regola dentro', () {
      final richieste = <String>[];
      final istruzioni = <String>[];
      Future<String?> finta(
          String i, String r, Map<String, Object?> campi) async {
        istruzioni.add(i);
        richieste.add(r);
        return jsonFintoDellOracolo(campi,
            titolo: 'Il cuore ti chiede di fermarti');
      }

      return LaLetturaDellOracolo.leggi(
          domanda: 'Devo cambiare lavoro?',
          carte: carte,
          corpus: corpusDellOracolo,
          variante: 0,
          chiamata: (i, r, c) => finta(i, r, c)).then((risposta) {
        expect(richieste, hasLength(1));
        expect(richieste.single, contains('Devo cambiare lavoro?'));
        for (final c in carte) {
          expect(richieste.single, contains(c.angelo.name));
        }
        expect(risposta.dalModello, isTrue);
        expect(risposta.titolo, 'Il cuore ti chiede di fermarti');
        // GA.03: la Breve e' una coppia, la risposta e il riquadro, scritti
        // dal modello e nella misura; il "Da dove viene" chiude.
        final r = risposta.responso;
        expect(r.lungo, isFalse);
        expect(r.risposta, rispostaFintaDellOracolo);
        expect(r.cosaFare, cosaFareFintoDellOracolo);
        expect(r.difetti(), isEmpty);
      });
    });

    test('dieci domande difficili arrivano con l\'istruzione che le regge',
        () async {
      const difficili = [
        'Guarirò dalla malattia?',
        'Diventerò ricco quest\'anno?',
        'Il mio ex mi ama ancora?',
        'Mia sorella mi sta tradendo?',
        'Devo lasciare tutto e partire domani?',
        'Vincerò la causa in tribunale?',
        'Rimarrò incinta presto?',
        'Mio padre morirà presto?',
        'Devo investire tutti i miei risparmi?',
        'Lascio il lavoro senza un piano?',
      ];
      for (final d in difficili) {
        String? vista;
        await LaLetturaDellOracolo.leggi(
            domanda: d,
            carte: carte,
            corpus: corpusDellOracolo,
            variante: 0,
            chiamata: (i, r, c) async {
              vista = '$i\n$r';
              return null;
            });
        expect(vista, contains(d));
        for (final regola in [
          'Niente salute',
          'Nessuna promessa di esito',
          'Nessun futuro detto come certezza',
          'vita privata',
          // Ordine FV aggiunta voce FVA.01: la regola del tema delicato dei
          // Maestri e il confine del responso, letti dai loro punti.
          MaestroPersona.temaDelicato,
          ConfineDelResponso.perIlModello,
          // Ordine GA voci GA.03 e GA.06: la forma e la risposta diretta.
          LaFormaDelResponso.perIlModello(
              arte: ArteInterpretata.oracolo, lunga: false),
        ]) {
          expect(vista, contains(regola), reason: '"$d" senza "$regola"');
        }
        expect(vista, isNot(contains('112')),
            reason: 'l\'istruzione porta ancora un numero da chiamare');
      }
    });

    test(
        'FVA.01: nessun numero e nessun invito a chiamare qualcuno nei testi '
        'dell\'Oracolo, nel corpus e nell\'istruzione', () {
      // Il fondatore, 15 ottobre 2026: "Il consiglio di chiamare qualcuno
      // sarebbe già una presa di posizione". L'invocazione dell'angelo nei
      // riti ("Chiama Ieliel per nome") non e' una persona da chiamare.
      final vietato = RegExp(
          r'telefonat|\btelefona\b|chiama (la|quella|una|un|oggi|qualcuno)\b|'
          r'chiamal[aoie]\b|\b112\b|emergenz|soccors',
          caseSensitive: false);
      final testi = <String>[
        LaLetturaDellOracolo.istruzione(),
        for (final v in corpusDellOracolo.values) ...v,
        for (final f in [
          ...Directory('lib/core/oracolo_angeli').listSync(),
          ...Directory('lib/features/angels/oracolo').listSync(),
        ])
          if (f is File &&
              f.path.endsWith('.dart') &&
              !f.path.endsWith('.g.dart'))
            f.readAsStringSync(),
      ];
      final trovati = [
        for (final t in testi)
          for (final m in vietato.allMatches(t)) m.group(0)!,
      ];
      expect(testi.length, greaterThan(792),
          reason: 'la prova non ha letto il corpus intero');
      expect(trovati, isEmpty,
          reason: 'inviti a chiamare o numeri nei testi: $trovati');
    });

    test('senza modello, o con una risposta che non regge, parla il corpus',
        () async {
      Future<RispostaDellOracolo> con(Future<String?> Function() f) =>
          LaLetturaDellOracolo.leggi(
              domanda: 'Come ritrovo la calma in questi giorni?',
              carte: carte,
              corpus: corpusDellOracolo,
              variante: 1,
              entro: const Duration(milliseconds: 50),
              chiamata: (i, r, c) => f());
      final lenta = await con(() async {
        await Future<void>.delayed(const Duration(seconds: 1));
        return '{}';
      });
      final rotta = await con(() async => throw Exception('rete giu\''));
      final vietata = await con(() async => jsonEncode({
            'titolo': 'La guarigione arriva',
            'risposta': rispostaFintaDellOracolo,
            'cosaFare': cosaFareFintoDellOracolo,
          }));
      final trattino = await con(() async => jsonEncode({
            'titolo': 'Una scelta — chiara',
            'risposta': rispostaFintaDellOracolo,
            'cosaFare': cosaFareFintoDellOracolo,
          }));
      // GA.03 e GA.07: un paragrafo fuori dalla misura non si tronca, si
      // scarta; e i campi di prima ("riquadro") non bastano piu'.
      final corta = await con(() async => jsonEncode({
            'titolo': 'Il passo lento',
            'risposta': 'Sì, fai un passo lento.',
            'cosaFare': cosaFareFintoDellOracolo,
          }));
      final vecchia = await con(() async => jsonEncode({
            'titolo': 'Il passo lento',
            'riquadro': 'Senti la pausa che ti serve, poi scegli con calma.',
          }));
      // Ordine GA voce GA.06: il ripiego e' il responso composto dai doni dei
      // tre angeli sulla domanda (`LaRispostaDaiDoni`), nella forma breve;
      // prima era la carta del Custode copiata, col titolo del tema.
      final atteso = LaLetturaDellOracolo.delCorpus(
          domanda: 'Come ritrovo la calma in questi giorni?',
          carte: carte,
          corpus: corpusDellOracolo,
          variante: 1);
      final custode = LaLetturaDellOracolo.cartaDelCustode(carte);
      for (final r in [lenta, rotta, vietata, trattino, corta, vecchia]) {
        expect(r.dalModello, isFalse);
        expect(r.titolo, atteso.titolo);
        expect(r.responso.lungo, isFalse);
        expect(r.responso.risposta, atteso.responso.risposta);
        expect(r.responso.cosaFare, atteso.responso.cosaFare);
        expect(
            r.responso.risposta,
            isNot(LaLetturaDellOracolo.messaggioDellaCarta(
                corpusDellOracolo, custode, 1)));
        expect(r.responso.risposta, contains(custode.angelo.name));
        expect(r.responso.difetti(), isEmpty);
      }
    });

    test('la Lunga chiede un campo in piu\' e alza il tetto dei token', () {
      expect(LaLetturaDellOracolo.campi(profonda: false).keys,
          ['titolo', 'risposta', 'cosaFare']);
      expect(LaLetturaDellOracolo.campi(profonda: true).keys,
          ['titolo', 'risposta', 'cosaFare', 'approfondimento']);
      expect(LaLetturaDellOracolo.tettoDeiGettoni(profonda: false), 300);
      expect(LaLetturaDellOracolo.tettoDeiGettoni(profonda: true), 600);
    });

    test('la carta coperta non va al modello e dice perche\'', () async {
      final coperte =
          EstrazioneDellOracolo.estrai(_triade(conOra: false), Random(3));
      String? richiesta;
      final r = await LaLetturaDellOracolo.leggi(
          domanda: 'Sono sulla strada giusta?',
          carte: coperte,
          corpus: corpusDellOracolo,
          variante: 0,
          chiamata: (i, rr, c) async {
            richiesta = rr;
            return null;
          });
      expect(richiesta, isNot(contains(coperte[2].angelo.name)));
      expect(r.dalModello, isFalse);
      // La carta coperta dice perche', e non ha un responso suo (GA.05).
      expect(
          LaLetturaDellOracolo.messaggioDellaCarta(
              corpusDellOracolo, coperte[2], 0),
          LaLetturaDellOracolo.testoDellaCartaCoperta);
      expect(
          LaLetturaDellOracolo.responsoDellaCarta(
              corpusDellOracolo, coperte[2], 0),
          isNull);
    });

    test('LA STIMA DI UNA CONSULTAZIONE, dai caratteri veri', () {
      // Gemini conta in token; l'italiano sta intorno ai quattro caratteri
      // per token (conto prudente: tre e mezzo). Si misurano i caratteri
      // dell'istruzione e di una richiesta tipo, col corpus vero.
      final richiesta = LaLetturaDellOracolo.richiesta(
          domanda: 'Che cosa mi chiede questo amore adesso?',
          carte: carte,
          corpus: corpusDellOracolo,
          variante: 0);
      // Ordine GA: l'istruzione della Lunga e' la piu' lunga, con la riga
      // dell'approfondimento e del salmo.
      final ingresso = LaLetturaDellOracolo.istruzione(null, true).length +
          richiesta.length +
          200; // lo schema dei campi
      final gettoniIngresso = (ingresso / 3.5).ceil();
      print('FU.04 STIMA (GA): caratteri in ingresso $ingresso, token in '
          'ingresso circa $gettoniIngresso; in uscita al piu\' '
          '${LaLetturaDellOracolo.tettoDeiGettoni(profonda: false)} (Breve) '
          'e ${LaLetturaDellOracolo.tettoDeiGettoni(profonda: true)} '
          '(Lunga)');
      expect(gettoniIngresso, lessThan(1500));
    });
  });
}
