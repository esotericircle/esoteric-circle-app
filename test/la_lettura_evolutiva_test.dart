import 'dart:math' as math;

import 'package:esoteric_circle/core/astro/natal_chart.dart';
import 'package:esoteric_circle/core/synastry_evolutiva/cielo_evolutivo.dart';
import 'package:esoteric_circle/core/synastry_evolutiva/il_composito_e_keplero.dart';
import 'package:esoteric_circle/core/synastry_evolutiva/il_corpus_della_sinastria_evolutiva.g.dart';
import 'package:esoteric_circle/core/synastry_evolutiva/la_lettura_evolutiva.dart';
import 'package:esoteric_circle/core/synastry_evolutiva/legame_e_eta.dart';
import 'package:esoteric_circle/core/synastry_evolutiva/oggi_e_il_momento.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **LA LETTURA APPROFONDITA, SUL CORPUS VERO.** Ordine FT voci FT.06,
/// FT.07, FT.08, FT.09, FT.10 e FT.12, 14 ottobre 2026.
void main() {
  const corpus = corpusDellaSinastriaEvolutiva;
  final caso = math.Random(20261014);
  CieloEvolutivo unCielo() => CieloEvolutivo.perNascita(
      momentoUtc: DateTime.utc(1940).add(
          Duration(days: caso.nextInt(365 * 70), hours: caso.nextInt(24))));

  test('il corpus porta tutti i 1.231 testi, senza celle vuote', () {
    final testi = corpus.values.fold<int>(0, (n, v) => n + v.length);
    cardinaleMinimo(testi, 1231,
        cosa: 'testi del corpus della Sinastria evolutiva',
        perche: 'il disegno ne dichiara 1.231 (LEGGIMI.md)');
    expect(testi, 1231);
    for (final v in corpus.values) {
      for (final t in v) {
        expect(t.trim(), isNotEmpty);
      }
    }
  });

  test('ogni cella che il motore puo\' chiedere esiste', () {
    final mancanti = <String>[];
    void c(String k) {
      if (!corpus.containsKey(k)) mancanti.add(k);
    }

    for (final cap in Capitolo.values) {
      for (final l in Legame.values) {
        for (final t in Tono.values) {
          for (final campo in ['titolo', 'apertura', 'fare']) {
            c('capitolo_${cap.name}|${l.name} ${t.name}|$campo');
          }
        }
      }
      final file = cap.index <= Capitolo.mente.index
          ? 'contatti_cuore_e_mente'
          : 'contatti_durata_e_destino';
      for (final (a, b) in cap.coppie) {
        for (final tipo in AspectType.values) {
          c('$file|${nomeNelCorpus(a)}-${nomeNelCorpus(b)} '
              '${aspettoNelCorpus(tipo)}|testo');
        }
      }
    }
    for (var i = 0; i < IlComposito.deiPunti.length; i++) {
      for (var j = i + 1; j < IlComposito.deiPunti.length; j++) {
        for (final f in ['fuso', 'armonico', 'teso']) {
          final cella = '${nomeNelCorpus(IlComposito.deiPunti[i])}-'
              '${nomeNelCorpus(IlComposito.deiPunti[j])} $f';
          c('composito|$cella|titolo');
          c('composito|$cella|testo');
        }
      }
    }
    c('composito|nessuno|titolo');
    c('composito|nessuno|testo');
    for (final k in Consonanza.values) {
      c('keplero_oggi_momento|keplero ${k.cella}|testo');
    }
    c('keplero_oggi_momento|keplero nessuna|testo');
    for (final t in OggiFraVoi.transitiGuardati) {
      for (final cap in Capitolo.values) {
        c('keplero_oggi_momento|oggi ${t.name} ${cap.name}|testo');
      }
    }
    c('keplero_oggi_momento|oggi nessuno|testo');
    for (final l in Legame.values) {
      for (final t in IlMomentoGiusto.transitiFavorevoli) {
        c('keplero_oggi_momento|momento ${t.name} ${l.name}|testo');
      }
      c('keplero_oggi_momento|momento nessuno ${l.name}|testo');
    }
    expect(mancanti, isEmpty,
        reason: 'il motore chiederebbe celle che il corpus non ha: le tabelle '
            'di tool/il_corpus_della_sinastria.py e del motore non coincidono');
  });

  test('duecento letture: cinque capitoli, tre paragrafi, nessun segnaposto',
      () {
    final toni = <Tono, int>{};
    var attacchiRipetuti = 0;
    for (var i = 0; i < 200; i++) {
      final tuo = unCielo();
      final suo = unCielo();
      final legame = Legame.values[i % 4];
      final lettura = LetturaEvolutiva.componi(
          tuo: tuo,
          suo: suo,
          nomeSuo: 'Giulia',
          legame: legame,
          corpus: corpus);
      expect(lettura.length, 5);
      final titoli = <String>{};
      for (final c in lettura) {
        toni[c.tono] = (toni[c.tono] ?? 0) + 1;
        expect(c.paragrafi.length, 3);
        for (final t in [c.titolo, ...c.paragrafi, c.daDoveViene]) {
          expect(t.contains('{'), isFalse, reason: t);
          expect(t.contains('['), isFalse, reason: t);
        }
        if (!titoli.add(LetturaEvolutiva.attacco(c.titolo))) {
          attacchiRipetuti++;
        }
        if (c.aspetto != null) {
          expect(c.daDoveViene, contains('Giulia'));
        }
      }
      // Stessa coppia, stessa lettura.
      final ancora = LetturaEvolutiva.componi(
          tuo: tuo,
          suo: suo,
          nomeSuo: 'Giulia',
          legame: legame,
          corpus: corpus);
      expect(ancora.map((c) => c.titolo), lettura.map((c) => c.titolo));
    }
    // ignore: avoid_print
    print('FT.06 TONI su mille capitoli: $toni; titoli con lo stesso attacco '
        'nella stessa lettura: $attacchiRipetuti');
    // Tutti e quattro i toni capitano davvero.
    expect(toni.keys.toSet(), Tono.values.toSet());
    expect(attacchiRipetuti, lessThan(10));
  });

  test('il punto medio e\' quello dell\'arco piu\' corto, come in Hand', () {
    expect(IlComposito.puntoMedio(10, 350), closeTo(0, 1e-9));
    expect(IlComposito.puntoMedio(350, 10), closeTo(0, 1e-9));
    expect(IlComposito.puntoMedio(0, 90), closeTo(45, 1e-9));
    expect(IlComposito.puntoMedio(100, 300), closeTo(20, 1e-9));
  });

  test(
      'il Composito non parla delle congiunzioni obbligate di Sole, Mercurio '
      'e Venere', () {
    var conCella = 0;
    for (var i = 0; i < 200; i++) {
      final k = IlComposito.fra(unCielo(), unCielo());
      final a = k.aspetto;
      if (a != null) {
        conCella++;
        const vicini = {
          PuntoDelCieloEvolutivo.sole,
          PuntoDelCieloEvolutivo.mercurio,
          PuntoDelCieloEvolutivo.venere,
        };
        expect(
            a.tipo == AspectType.conjunction &&
                vicini.contains(a.a) &&
                vicini.contains(a.b),
            isFalse);
      }
      expect(corpus.containsKey('composito|${k.cella}|titolo'), isTrue);
    }
    expect(conCella, greaterThan(150));
  });

  test('le consonanze di Keplero cadono nei loro gradi, una sola per distanza',
      () {
    expect(IntervalliDiKeplero.consonanzaDi(0.5), Consonanza.unisono);
    expect(IntervalliDiKeplero.consonanzaDi(61), Consonanza.terzaMinore);
    expect(IntervalliDiKeplero.consonanzaDi(71), Consonanza.terzaMaggiore);
    expect(IntervalliDiKeplero.consonanzaDi(121.9), Consonanza.quinta);
    expect(IntervalliDiKeplero.consonanzaDi(134), Consonanza.sestaMinore);
    expect(IntervalliDiKeplero.consonanzaDi(145), Consonanza.sestaMaggiore);
    expect(IntervalliDiKeplero.consonanzaDi(179), Consonanza.ottava);
    expect(IntervalliDiKeplero.consonanzaDi(100), isNull);
    // Con l'orbo di due gradi nessuna distanza cade in due consonanze.
    for (var s = 0.0; s <= 180; s += 0.25) {
      final dentro = Consonanza.values
          .where((c) => (s - c.gradi).abs() <= IntervalliDiKeplero.orbo)
          .length;
      expect(dentro, lessThanOrEqualTo(1), reason: 'a $s gradi');
    }
  });

  test('Oggi fra voi cambia col giorno e dice sempre qualcosa', () {
    final tuo = unCielo();
    final suo = unCielo();
    final testi = <String>{};
    for (var d = 0; d < 20; d++) {
      final o = OggiFraVoi.per(
          tuo: tuo,
          suo: suo,
          nomeSuo: 'Marco',
          giorno: DateTime.utc(2026, 10, 14).add(Duration(days: d)),
          corpus: corpus);
      expect(o.testo, isNotEmpty);
      expect(o.testo.contains('{'), isFalse);
      testi.add(o.testo);
    }
    expect(testi.length, greaterThan(5),
        reason: 'in venti giorni Oggi fra voi deve cambiare');
  });

  test('il Momento giusto: al piu\' tre giorni, distanti, dentro sessanta', () {
    final da = DateTime.utc(2026, 10, 14);
    var conGiorni = 0;
    for (var i = 0; i < 20; i++) {
      final tuo = unCielo();
      final suo = unCielo();
      final legame = Legame.values[i % 4];
      final giorni = IlMomentoGiusto.per(
          tuo: tuo,
          suo: suo,
          nomeSuo: 'Marco',
          legame: legame,
          da: da,
          corpus: corpus);
      expect(giorni.length, lessThanOrEqualTo(3));
      if (giorni.isNotEmpty) conGiorni++;
      for (var k = 0; k < giorni.length; k++) {
        expect(giorni[k].giorno.difference(da).inDays,
            inInclusiveRange(0, IlMomentoGiusto.giorniDaGuardare - 1));
        expect(
            IlMomentoGiusto.transitiFavorevoli, contains(giorni[k].transito));
        if (k > 0) {
          expect(giorni[k].giorno.isAfter(giorni[k - 1].giorno), isTrue);
          expect(giorni[k].giorno.difference(giorni[k - 1].giorno).inDays,
              greaterThanOrEqualTo(IlMomentoGiusto.giorniFraUnoEAltro));
        }
      }
      if (giorni.isEmpty) {
        expect(
            IlMomentoGiusto.testoSenzaGiorni(
                tuo: tuo,
                suo: suo,
                nomeSuo: 'Marco',
                legame: legame,
                corpus: corpus),
            isNotEmpty);
      }
    }
    expect(conGiorni, greaterThan(10));
  });
}
