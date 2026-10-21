// ignore_for_file: avoid_print
import 'dart:io';

import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/horoscope/i_segni_delle_tradizioni.dart';
import 'package:esoteric_circle/core/horoscope/i_testi_eu.dart';
import 'package:esoteric_circle/core/horoscope/il_responso_dell_oroscopo.dart';
import 'package:esoteric_circle/core/horoscope/l_anno_delle_tradizioni.dart';
import 'package:esoteric_circle/core/horoscope/la_lettura_vedica.dart';
import 'package:esoteric_circle/core/horoscope/le_parti_del_responso.dart';
import 'package:esoteric_circle/core/horoscope/oroscopo_vedico_data.dart';
import 'package:esoteric_circle/features/horoscope/oroscopo_screen.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **IL "DA DOVE VIENE" DICE PERCHE', ordine GA voce GA.06, quarto giro.**
///
/// Il fondatore, 21 ottobre 2026: *"Le risposte vanno curate, sono la parte
/// più importante e criticata dell'app."* L'ultima lettura cieca (12 responsi)
/// ha dato tre sì su dodici meno due, e i due no avevano un padre ciascuno:
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
/// Il rito non si lega al tema della lettura (si sceglie dal reggente del
/// primo giorno): invece di fingere un nesso, la coda del "Da dove viene" lo
/// dichiara. In piu', dal Realme (gruppo B): "L'oroscopo della mese".
void main() {
  RegExp gruppo(List<String> varianti) => RegExp(
      varianti
          .map((v) => RegExp.escape(LePartiDelResponso.di(v).$2)
              .replaceAll(RegExp(r'\\\{\w+\\\}'), '.+?')
              .replaceAll(RegExp(r'\\\[[^\]]*\\\]'), '.+?'))
          .join('|'),
      caseSensitive: false);

  int? posizione(String testo, List<String> varianti) {
    var migliore = -1;
    for (final v in varianti) {
      final m = gruppo([v]).firstMatch(testo);
      if (m != null && (migliore < 0 || m.start < migliore)) {
        migliore = m.start;
      }
    }
    return migliore < 0 ? null : migliore;
  }

  test('vedica: nel "Da dove viene" viene prima la forza che porta il livello',
      () {
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
      final pLuna = posizione(riga, OroscopoVedicoData.chandraBala[h - 1]);
      final pStella = posizione(riga, OroscopoVedicoData.taraBala[t - 1]);
      if (pLuna == null || pStella == null) {
        fuori.add('giorno $k: manca la Luna o la stella nella riga');
        continue;
      }
      final stellaDecide =
          t == 7 || (luna != EsitoVedico.ottava && stella.index > luna.index);
      if (stellaDecide) {
        stellaPeggiore++;
        if (t == 7) naidhana++;
        if (pStella > pLuna) {
          fuori.add('giorno $k (tara $t, casa $h): la stella viene dopo la '
              'Luna');
        }
        // La riga del livello sta accanto alle due forze, prima del Rahu
        // Kalam e del giorno della settimana.
        final pLivello = riga.indexOf('Il livello viene dalla Luna');
        final pRahu = riga.indexOf('Rahu Kalam');
        if (pRahu >= 0 && pLivello > pRahu) {
          fuori.add('giorno $k: il livello arriva dopo il Rahu Kalam');
        }
      } else if (pLuna > pStella && luna != EsitoVedico.ottava) {
        fuori.add('giorno $k: la Luna decide e la stella la precede');
      }
    }
    cardinaleMinimo(stellaPeggiore, 40, cosa: 'giorni con la stella peggiore');
    cardinaleMinimo(naidhana, 12, cosa: 'giorni di Naidhana');
    print('GA.06 giro 4: giorni vedici letti 180, con la stella che porta il '
        'livello $stellaPeggiore (Naidhana $naidhana), fuori posto '
        '${fuori.length}');
    expect(fuori, isEmpty, reason: fuori.take(5).join('\n'));
  });

  test('il rito dichiara di essere quello del reggente, non finge un nesso',
      () {
    var righe = 0;
    final fuori = <String>[];
    for (final tr in TradizioneEu.values) {
      for (final per in PeriodoEu.values) {
        final riga = IlResponsoDellOroscopo.daDoveViene('Il cielo di oggi.',
            fonteDelRito: 'Il verso viene dall\'Inno orfico al Sole.',
            periodo: per,
            primoGiorno: DateTime(2026, 10, 25),
            tradizione: tr)!;
        righe++;
        if (!riga.contains('Il rito propiziatorio è quello ') ||
            !riga.contains('scelto dal suo reggente: ') ||
            riga.contains('propiziatorio segue')) {
          fuori.add('${tr.name} ${per.name}: $riga');
        }
        if (RegExp(r'quello (il|la) ').hasMatch(riga)) {
          fuori.add('${tr.name} ${per.name}: preposizione mancante');
        }
      }
    }
    cardinaleMinimo(righe, 12, cosa: 'combinazioni tradizione e periodo');
    print('GA.06 giro 4: code del rito lette $righe, fuori ${fuori.length}');
    expect(fuori, isEmpty, reason: fuori.take(4).join('\n'));
  });

  test(
      'l\'anno cinese: il rapporto detto in frase e un solo due punti per '
      'frase', () {
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
      if (!riga.contains('Tai Sui è il signore dell\'anno')) {
        fuori.add('animale $animale: Tai Sui non e\' detto per intero');
      }
    }
    cardinaleMinimo(anni, 12, cosa: 'anni cinesi per animale');
    print('GA.06 giro 4: anni cinesi letti $anni, fuori ${fuori.length}');
    expect(fuori, isEmpty, reason: fuori.take(4).join('\n'));
  });

  test('il Mese e\' maschile e il mantra dice che cosa vuol dire', () {
    // Realme, gruppo B, difetto D7: "L'oroscopo della mese".
    final schermo =
        File('lib/features/horoscope/oroscopo_screen.dart').readAsStringSync();
    final sbagliate = RegExp(r'della \$\{period\.label').allMatches(schermo);
    print('GA.06 giro 4: "della \${period.label" nello schermo '
        '${sbagliate.length}');
    expect(sbagliate, isEmpty,
        reason: 'il periodo si dice con etichetta o conArticolo');
    for (final p in HoroscopePeriod.values) {
      expect(p.etichetta, isNot(matches(RegExp(r'della (mese|anno|giorno)'))));
      expect(p.conArticolo, isNot(matches(RegExp(r'^la (mese|anno|giorno)'))));
    }
    expect(HoroscopePeriod.mese.conArticolo, 'il mese');

    // Quarto lettore cieco (oroscopo-17 e 25): "è la forma breve del suo nome
    // con l'omaggio" non diceva niente a chi non conosce il sanscrito.
    final riti = File('lib/core/responsi/i_riti_propiziatori_dati.dart')
        .readAsStringSync();
    final mantra = RegExp(r"'mantra_navagraha\|(\w+)': '([^']*(?:\\'[^']*)*)',")
        .allMatches(riti)
        .toList();
    cardinaleMinimo(mantra.length, 7, cosa: 'mantra con la loro fonte');
    final senza = [
      for (final m in mantra)
        if (!m.group(2)!.contains('vuol dire') ||
            m.group(2)!.contains('forma breve del suo nome'))
          m.group(1)!,
    ];
    print('GA.06 giro 4: mantra ${mantra.length}, senza il significato '
        '${senza.length}');
    expect(senza, isEmpty);
  });
}
