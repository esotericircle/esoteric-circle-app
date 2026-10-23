// ignore_for_file: avoid_print
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/horoscope/horoscope.dart';
import 'package:esoteric_circle/core/horoscope/i_dodici_mesi.dart';
import 'package:esoteric_circle/core/horoscope/i_testi_eu.dart';
import 'package:esoteric_circle/core/horoscope/l_almanacco_cinese.dart';
import 'package:esoteric_circle/core/horoscope/l_anno_delle_tradizioni.dart';
import 'package:esoteric_circle/core/horoscope/la_lettura_cinese.dart';
import 'package:esoteric_circle/core/horoscope/la_lettura_vedica.dart';
import 'package:esoteric_circle/core/horoscope/la_rivoluzione_solare.dart';
import 'package:esoteric_circle/design_system/theme/maestro_palette.dart';
import 'package:esoteric_circle/design_system/tokens/color_tokens.dart';
import 'package:esoteric_circle/features/horoscope/i_dodici_mesi_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';
import 'oroscopo_eu_comune.dart';

/// **I DODICI MESI DELL'ANNO.** Il fondatore, 1 ottobre 2026: *"Hai messo
/// infografica anche per oroscopo annuale? Magari per i 12 mesi indicando i
/// migliori o quello che ritieni migliore."*
///
/// Si misura, per tre persone nelle tre tradizioni:
/// - i dodici mesi coprono l'anno della tradizione senza buchi, dal suo primo
///   giorno;
/// - i giorni favorevoli di un mese sono quelli in cui la scheda del Giorno di
///   quel giorno ha il livello 4 o 5: si confrontano, su dieci giorni per
///   anno, i livelli usati coi livelli delle schede del Giorno (0 diversi);
/// - le barre non sono tutte uguali: in ogni dominio il mese migliore ha piu'
///   giorni favorevoli del peggiore;
/// - a video, a 360 punti, al carattere normale e massimo: dodici barre alte
///   in proporzione ai giorni favorevoli e del colore del loro gradino, la
///   percentuale sopra il mese migliore, la riga dei mesi migliori, nessun
///   pixel che trabocca.
void main() {
  final persone = [dodiciPersone[0], dodiciPersone[1], dodiciPersone[2]];
  final oggi = DateTime(2026, 10, 1);

  (DateTime, DateTime, List<int> Function(DateTime))? anno(
      PersonaDiProva p, TradizioneEu t) {
    switch (t) {
      case TradizioneEu.occidentale:
        final da = LaRivoluzioneSolare.ritornoInCorso(p.nascita.toUtc(),
                DateTime(oggi.year, oggi.month, oggi.day, 12))
            .toLocal();
        final a = LaRivoluzioneSolare.prossimoRitorno(p.nascita.toUtc(),
                DateTime(oggi.year, oggi.month, oggi.day, 12))
            .toLocal();
        return (
          DateTime(da.year, da.month, da.day),
          DateTime(a.year, a.month, a.day),
          (g) => Horoscope.livelliDelGiorno(p.segno, p.carta, g),
        );
      case TradizioneEu.vedica:
        if (p.rashi == null) return null;
        final an = LAnnoDelleTradizioni.vedico(oggi, p.nascita, p.rashi!);
        final nak = LaLetturaVedica.lunaDiNascita(p.nascitaDeiSegni)?.$2;
        return (
          an.da,
          an.a,
          (g) => LaLetturaVedica.livelliDelGiorno(g, p.rashi!, nak, null),
        );
      case TradizioneEu.cinese:
        final an = LAnnoDelleTradizioni.cinese(oggi, p.animale)!;
        final signore = LAlmanaccoCinese.tronco(p.nascita);
        return (
          an.da,
          an.a,
          (g) => LaLetturaCinese.livelliDelGiorno(
              g, p.animale, signore, CourtesyForm.unknown),
        );
    }
  }

  test('i dodici mesi coprono l\'anno e contano i giorni del Giorno', () {
    final colpe = <String>[];
    final righe = <String>[];
    var anni = 0;
    var giorniConfrontati = 0;
    for (final p in persone) {
      for (final t in TradizioneEu.values) {
        final a = anno(p, t);
        if (a == null) continue;
        final (da, fine, livelli) = a;
        final orologio = Stopwatch()..start();
        IDodiciMesi.dimentica();
        final mesi = IDodiciMesi.di(
            chiave: '${t.name}|${p.nome}', inizio: da, livelli: livelli);
        orologio.stop();
        anni++;
        if (mesi.length != 12) {
          colpe.add('${p.nome} ${t.name}: ${mesi.length} mesi');
        }
        if (mesi.first.da != da) {
          colpe.add('${p.nome} ${t.name}: non comincia dal primo giorno');
        }
        for (var i = 1; i < mesi.length; i++) {
          if (mesi[i].da != mesi[i - 1].a) {
            colpe.add('${p.nome} ${t.name}: buco fra il mese $i e il ${i + 1}');
          }
        }
        // L'anno della tradizione finisce entro la fine del dodicesimo mese
        // (il Capodanno lunare cade prima del dodicesimo compleanno di mese).
        if (mesi.last.a.difference(fine).inDays.abs() > 31) {
          colpe.add('${p.nome} ${t.name}: i mesi finiscono il ${mesi.last.a}, '
              'l\'anno il $fine');
        }
        // Coerenti col Giorno: dieci giorni dell'anno, i livelli contati qui
        // e quelli della scheda del Giorno di quel giorno.
        for (var k = 0; k < 10; k++) {
          final g = DateTime(da.year, da.month, da.day + 7 + k * 33);
          final schede = p.giorno(t, g, lunga: false);
          final contati = livelli(g);
          for (final s in schede) {
            giorniConfrontati++;
            if (s.indicator != contati[s.domain.index]) {
              colpe.add('${p.nome} ${t.name} ${g.day}/${g.month} '
                  '${s.domain.name}: scheda ${s.indicator}, contato '
                  '${contati[s.domain.index]}');
            }
          }
        }
        for (final d in HoroscopeDomain.values) {
          final q = [for (final m in mesi) m.quota(d)];
          final massimo = q.reduce((a, b) => a > b ? a : b);
          final minimo = q.reduce((a, b) => a < b ? a : b);
          if (massimo <= minimo) {
            colpe.add('${p.nome} ${t.name} ${d.name}: dodici barre uguali');
          }
          righe.add('${p.nome} ${t.name} ${d.name}: '
              '${[for (final m in mesi) m.favorevoli![d.index]].join(' ')} '
              '(conto in ${orologio.elapsedMilliseconds} ms); '
              '${IDodiciMesiView.rigaDeiMigliori(mesi, d)}');
        }
      }
    }
    cardinaleMinimo(anni, 8,
        cosa: 'anni guardati',
        perche: 'tre persone in tre tradizioni, la Vedica senza Luna di '
            'nascita ne salta una');
    cardinaleMinimo(giorniConfrontati, 300,
        cosa: 'schede del Giorno confrontate');
    print('I DODICI MESI: anni $anni, schede del Giorno confrontate '
        '$giorniConfrontati, difetti ${colpe.length}\n${righe.join('\n')}');
    expect(colpe, isEmpty, reason: colpe.take(8).join('\n'));
  });

  // **LA VEDICA E LA CINESE SI LEGGONO COL MESE**: i loro giorni tornano ogni
  // dodici (l'animale) e ogni ventisette (la Luna), e contati coi giorni i
  // dodici mesi venivano uguali (misurato il 1 ottobre 2026: da 6 a 9 giorni
  // favorevoli in ogni mese cinese, da 15 a 20 in ogni mese vedico).
  test('la Vedica e la Cinese col pilastro e col transito del mese', () {
    // I pilastri dei mesi del 2026 (anno Bing Wu): il mese del Gallo da
    // meta' settembre e' Ding You, quello del Cane da meta' ottobre Wu Xu,
    // quello della Tigre di febbraio Geng Yin.
    expect(LAnnoDelleTradizioni.pilastroDelMese(DateTime(2026, 9, 20)), (9, 3));
    expect(
        LAnnoDelleTradizioni.pilastroDelMese(DateTime(2026, 10, 20)), (10, 4));
    expect(LAnnoDelleTradizioni.pilastroDelMese(DateTime(2026, 2, 20)), (2, 6));
    // Il Topo di gennaio 2027 e' ancora dell'anno Bing Wu: Geng Zi.
    expect(LAnnoDelleTradizioni.pilastroDelMese(DateTime(2027, 1, 2)), (0, 6));
    final righe = <String>[];
    var anni = 0;
    final piatti = <String>[];
    for (final p in persone) {
      final cinese = LAnnoDelleTradizioni.cinese(oggi, p.animale)!;
      final signore = LAlmanaccoCinese.tronco(p.nascita);
      final mc = IDodiciMesi.perLivelli(
          chiave: 'prova|cinese|${p.nome}',
          inizio: cinese.da,
          livelliDelMese: (da, a) => LAnnoDelleTradizioni.livelliDelMeseCinese(
              da, a, p.animale, signore, CourtesyForm.unknown));
      anni++;
      final insiemi = [(TradizioneEu.cinese, mc)];
      if (p.rashi != null) {
        final vedico = LAnnoDelleTradizioni.vedico(oggi, p.nascita, p.rashi!);
        insiemi.add((
          TradizioneEu.vedica,
          IDodiciMesi.perLivelli(
              chiave: 'prova|vedica|${p.nome}',
              inizio: vedico.da,
              livelliDelMese: (da, a) =>
                  LAnnoDelleTradizioni.livelliDelMeseVedico(da, a, p.rashi!))
        ));
        anni++;
      }
      for (final (t, mesi) in insiemi) {
        expect(mesi, hasLength(12));
        for (final d in HoroscopeDomain.values) {
          final l = [for (final m in mesi) m.livelli![d.index]];
          if (l.toSet().length < 2) piatti.add('${p.nome} ${t.name} ${d.name}');
          righe.add('${p.nome} ${t.name} ${d.name}: ${l.join(' ')}; '
              '${IDodiciMesiView.rigaDeiMigliori(mesi, d)}');
        }
      }
    }
    cardinaleMinimo(anni, 5, cosa: 'anni vedici e cinesi');
    print('I DODICI MESI DELLA VEDICA E DELLA CINESE: anni $anni, domini con '
        'dodici mesi uguali ${piatti.length}\n${righe.join('\n')}');
    // Un dominio puo' restare uguale tutto l'anno quando il pianeta non
    // cambia casa (Giove resta nello stesso segno un anno): si conta, e non
    // devono essere la maggioranza.
    expect(piatti.length, lessThan(righe.length ~/ 2),
        reason: piatti.join('\n'));
  });

  for (final scala in const [1.0, 2.0]) {
    testWidgets('le dodici barre a video alla scala $scala', (tester) async {
      final p = persone[0];
      final (da, _, livelli) = anno(p, TradizioneEu.occidentale)!;
      final mesi = IDodiciMesi.di(
          chiave: 'occidentale|${p.nome}', inizio: da, livelli: livelli);
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(
              size: const Size(360, 800),
              textScaler: TextScaler.linear(scala),
              disableAnimations: true),
          child: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(32),
              child: SingleChildScrollView(
                child: IDodiciMesiView(
                    mesi: mesi,
                    dominio: HoroscopeDomain.generale,
                    palette: MaestroPalette.medora),
              ),
            ),
          ),
        ),
      ));
      await tester.pump();
      expect(tester.takeException(), isNull);
      var barre = 0;
      for (final m in mesi) {
        final b = find.byKey(Key('oroscopo_anno_barra_generale_${m.da.month}'));
        expect(b, findsOneWidget);
        barre++;
        final h = tester.getSize(b).height;
        expect(
            h,
            closeTo(
                IDodiciMesiView.altezzaDi(m.quota(HoroscopeDomain.generale)),
                0.5));
        final colore =
            ((tester.widget<Container>(b).decoration as BoxDecoration).color)!;
        expect(
            colore,
            ColorTokens.delLivello(
                IDodiciMesi.gradino(m.quota(HoroscopeDomain.generale))));
      }
      cardinaleMinimo(barre, 12, cosa: 'barre dei mesi');
      final migliore =
          IDodiciMesi.migliori(mesi, HoroscopeDomain.generale, quanti: 1).first;
      final perc = find.byKey(const Key('oroscopo_anno_percentuale_generale'));
      expect(perc, findsOneWidget);
      final sopra = tester.getRect(perc);
      final barra = tester.getRect(
          find.byKey(Key('oroscopo_anno_barra_generale_${migliore.da.month}')));
      expect(sopra.bottom, lessThanOrEqualTo(barra.top + 0.5),
          reason: 'la percentuale non sta sopra il mese migliore');
      expect(find.byKey(const Key('oroscopo_anno_migliori_generale')),
          findsOneWidget);
      print('I DODICI MESI A VIDEO, scala $scala: barre $barre, il migliore '
          '${IDodiciMesiView.nomiDeiMesi[migliore.da.month - 1]}');
    });
  }
}
