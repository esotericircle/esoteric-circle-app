// ignore_for_file: avoid_print
import 'dart:io';

import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/horoscope/i_segni_delle_tradizioni.dart';
import 'package:esoteric_circle/core/horoscope/i_testi_eu.dart';
import 'package:esoteric_circle/core/horoscope/il_lessico_del_cielo.dart';
import 'package:esoteric_circle/core/horoscope/il_responso_dell_oroscopo.dart';
import 'package:esoteric_circle/core/horoscope/l_anno_delle_tradizioni.dart';
import 'package:esoteric_circle/core/horoscope/la_lettura_vedica.dart';
import 'package:esoteric_circle/features/horoscope/oroscopo_screen.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **IL "DA DOVE VIENE" DICE PERCHE', ordine GA voce GA.06, quarto giro e
/// sesto giro.**
///
/// Il fondatore, 21 ottobre 2026: *"Le risposte vanno curate, sono la parte
/// più importante e criticata dell'app."* L'ultima lettura cieca del quarto
/// giro (12 responsi) ha dato tre sì su dodici meno due, e i due no avevano un
/// padre ciascuno:
/// - **oroscopo-17** (vedica, giorno): la riga apriva con la Luna in terza
///   casa, "successo e vesti, affetti e beni in abbondanza", sotto una
///   risposta che dice "giornata stancante"; la ragione vera, la tara
///   Naidhana, arrivava tre frasi dopo. Padre: ordine ES voce 09 (l'ordine
///   fisso Luna, stella), non curato da GA.06 prima cura;
/// - **oroscopo-45** (cinese, anno): il rito parlava di "cose finite" sotto
///   una lettura sulla casa rinnovata, e il Da dove viene aveva due volte i
///   due punti ("il tuo animale non lo offende: l'anno non ti chiede...").
///   Padre: ordine ES voce 28 (la riga del Tai Sui) e GA.06 terza cura (che
///   aveva tolto una virgola mettendo i due punti).
///
/// **Sesto giro**: il "Da dove viene" non ha piu' gergo ne' nomi propri del
/// metodo (Tara, Chandra Bala, Naidhana, Tai Sui, Inno orfico): le prove
/// qui sotto controllano la stessa cosa, la ragione vera detta in parole, e
/// la forma nuova del rito e della fonte. La guardia del gergo e'
/// `il_da_dove_viene_non_ha_gergo_test`.
///
/// Il rito non si lega al tema della lettura (si sceglie dal reggente del
/// primo giorno): la riga del rito lo dice in una frase breve. In piu', dal
/// Realme (gruppo B): "L'oroscopo della mese".
void main() {
  test('vedica: la ragione che porta il livello e\' detta in parole', () {
    // LAPIDE, ordine GA voce GA.06, sesto giro (21 ottobre 2026): qui si
    // pretendeva l'ordine fra le frasi del corpus (la Luna in casa, poi la
    // stella, "Il livello viene dalla Luna ..., Rahu Kalam"). Quelle frasi
    // sono gergo e non vanno piu' a video: il corpo e' di due frasi, la
    // posizione della Luna e la costellazione (che dice "la piu' delicata"
    // nel giorno peggiore), poi il giudizio del livello.
    final conOra = NascitaDeiSegni(
        locale: DateTime(1990, 3, 15, 8, 30),
        oraNota: true,
        fuso: 'Europe/Rome');
    const roma = LuogoDelGiorno(
        lat: 41 + 53 / 60 + 30 / 3600,
        lon: 12 + 30 / 60 + 40 / 3600,
        citta: 'Roma');
    final (rashiN, nakN) = LaLetturaVedica.lunaDiNascita(conOra)!;
    var stellaPeggiore = 0;
    var naidhana = 0;
    final fuori = <String>[];
    for (var k = 0; k < 180; k++) {
      final s = LaLetturaVedica.schede(
          adesso: DateTime(2026, 9, 1 + k, 9),
          nascita: conOra,
          luogo: roma,
          forma: CourtesyForm.unknown)!;
      final (r, n) = LaLetturaVedica.lunaAlle(
          LaLetturaVedica.istanteDelGiorno(DateTime(2026, 9, 1 + k), roma));
      final h = (r - rashiN + 12) % 12 + 1;
      final t = ((n - nakN! + 27) % 27) % 9 + 1;
      final luna = LaLetturaVedica.esitoDellaCasa(h);
      final stella = LaLetturaVedica.esitoDellaTara(t);
      final riga = s[0].rigaDelLivello!;
      if (RegExp(r'Naidhana|Chandra Bala|Tara Bala|\btara\b|Rahu Kalam')
          .hasMatch(riga)) {
        fuori.add('giorno $k: gergo nella riga: $riga');
      }
      final giudizio = IlLessicoDelCielo.giudizio(s[0].indicator);
      if (!riga.contains(giudizio)) {
        fuori.add('giorno $k: la riga non dice il giudizio $giudizio: $riga');
      }
      final stellaDecide =
          t == 7 || (luna != EsitoVedico.ottava && stella.index > luna.index);
      if (stellaDecide) {
        stellaPeggiore++;
        if (!riga.contains('costellazione in cui sta la Luna')) {
          fuori.add('giorno $k: la costellazione non e\' detta: $riga');
        }
        if (t == 7) {
          naidhana++;
          if (!riga.contains('la più delicata')) {
            fuori.add('giorno $k: il giorno piu\' delicato non e\' detto');
          }
        }
      }
    }
    cardinaleMinimo(stellaPeggiore, 40, cosa: 'giorni con la stella peggiore');
    cardinaleMinimo(naidhana, 12, cosa: 'giorni del giorno piu\' delicato');
    print('GA.06 giro 6: giorni vedici letti 180, con la stella che porta il '
        'livello $stellaPeggiore (il piu\' delicato $naidhana), fuori posto '
        '${fuori.length}');
    expect(fuori, isEmpty, reason: fuori.take(5).join('\n'));
  });

  test('il rito dichiara di essere quello del reggente, non finge un nesso',
      () {
    // LAPIDE, ordine GA voce GA.06, sesto giro: qui si pretendeva la coda
    // "Il rito è quello del primo giorno ..., scelto dal suo reggente: ...".
    // E' gergo ("reggente") e allungava il muro. Adesso il rito ha la sua
    // riga breve, "Il rito del giorno: ...", e la fonte una riga sua.
    var righe = 0;
    final fuori = <String>[];
    for (final tr in TradizioneEu.values) {
      for (final per in PeriodoEu.values) {
        final riga = IlResponsoDellOroscopo.daDoveViene('Il cielo di oggi.',
            fonteDelRito: 'La formula che saluta il Sole.',
            periodo: per,
            primoGiorno: DateTime(2026, 10, 25),
            tradizione: tr)!;
        righe++;
        final linee = riga.split('\n');
        final quando = switch (per) {
          PeriodoEu.giorno => 'del giorno',
          PeriodoEu.settimana => 'della settimana',
          PeriodoEu.mese => 'del mese',
          PeriodoEu.anno => 'dell\'anno',
        };
        if (linee.length != 3 ||
            linee[1] != 'Il rito $quando: la formula che saluta il Sole.' ||
            !linee[2].startsWith('Fonte: astrologia ') ||
            riga.contains('reggente') ||
            riga.contains('propiziatorio')) {
          fuori.add('${tr.name} ${per.name}: $riga');
        }
      }
    }
    cardinaleMinimo(righe, 12, cosa: 'combinazioni tradizione e periodo');
    print('GA.06 giro 6: righe del rito lette $righe, fuori ${fuori.length}');
    expect(fuori, isEmpty, reason: fuori.take(4).join('\n'));
  });

  test(
      'l\'anno cinese: il rapporto e\' detto in frase, senza Tai Sui e con un '
      'solo due punti per frase', () {
    var anni = 0;
    final fuori = <String>[];
    for (var animale = 0; animale < 12; animale++) {
      final a = LAnnoDelleTradizioni.cinese(DateTime(2026, 10, 25), animale);
      if (a == null) continue;
      anni++;
      final riga = a.daDove.first;
      for (final frase in riga.split(RegExp(r'(?<=\.) '))) {
        if (':'.allMatches(frase).length > 1) {
          fuori.add('animale $animale: due due punti in «$frase»');
        }
      }
      if (RegExp(r'Con (il|la|lo|l.)\s?\w+, il tuo animale:').hasMatch(riga)) {
        fuori.add('animale $animale: la forma telegrafica «il tuo animale:»');
      }
      // LAPIDE, ordine GA voce GA.06, sesto giro: qui si pretendeva "Tai Sui
      // è il signore dell'anno" per intero. Il nome e' gergo: adesso la riga
      // dice se fra i due animali c'e' attrito e che cosa vuol dire.
      if (riga.contains('Tai Sui') || !RegExp(r"c.è attrito").hasMatch(riga)) {
        fuori.add('animale $animale: il rapporto non e\' detto in parole');
      }
    }
    cardinaleMinimo(anni, 12, cosa: 'anni cinesi per animale');
    print('GA.06 giro 6: anni cinesi letti $anni, fuori ${fuori.length}');
    expect(fuori, isEmpty, reason: fuori.take(4).join('\n'));
  });

  test('il Mese e\' maschile e il mantra dice che cosa saluta', () {
    // Realme, gruppo B, difetto D7: "L'oroscopo della mese".
    final schermo =
        File('lib/features/horoscope/oroscopo_screen.dart').readAsStringSync();
    final sbagliate = RegExp(r'della \$\{period\.label').allMatches(schermo);
    print('GA.06 giro 6: "della \${period.label" nello schermo '
        '${sbagliate.length}');
    expect(sbagliate, isEmpty,
        reason: 'il periodo si dice con etichetta o conArticolo');
    for (final p in HoroscopePeriod.values) {
      expect(p.etichetta, isNot(matches(RegExp(r'della (mese|anno|giorno)'))));
      expect(p.conArticolo, isNot(matches(RegExp(r'^la (mese|anno|giorno)'))));
    }
    expect(HoroscopePeriod.mese.conArticolo, 'il mese');

    // LAPIDE, ordine GA voce GA.06, sesto giro: qui si pretendeva "vuol dire"
    // nella fonte del mantra (quarto lettore cieco, oroscopo-17 e 25). Il
    // mantra in sanscrito e il nome del graha sono gergo: la fonte dice in
    // parole che cosa saluta ("La formula che saluta Marte, il pianeta che
    // regge il martedì."), senza nomi sanscriti.
    final riti = File('lib/core/responsi/i_riti_propiziatori_dati.dart')
        .readAsStringSync();
    final fonti = RegExp(r"'mantra_navagraha\|(\w+)': '([^']*(?:\\'[^']*)*)',")
        .allMatches(riti)
        .where((m) => !m.group(1)!.contains('|'))
        .toList();
    cardinaleMinimo(fonti.length, 7, cosa: 'mantra con la loro fonte');
    final senza = [
      for (final m in fonti)
        if (!m.group(2)!.startsWith('La formula che saluta ') ||
            RegExp(r'Surya|Chandra|Mangala|Budha|Guru|Shukra|Shani|Rahu|Ketu')
                .hasMatch(m.group(2)!))
          m.group(1)!,
    ];
    print('GA.06 giro 6: fonti dei mantra ${fonti.length}, senza la forma '
        'in parole ${senza.length}');
    expect(senza, isEmpty);
  });
}
