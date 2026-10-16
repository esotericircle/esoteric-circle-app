// ignore_for_file: avoid_print
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/horoscope/horoscope.dart';
import 'package:esoteric_circle/core/horoscope/horoscope_data.dart';
import 'package:esoteric_circle/core/horoscope/i_segni_delle_tradizioni.dart';
import 'package:esoteric_circle/core/horoscope/l_annuale.dart';
import 'package:esoteric_circle/core/horoscope/la_lettura_cinese.dart';
import 'package:esoteric_circle/core/horoscope/la_lettura_vedica.dart';
import 'package:esoteric_circle/core/horoscope/la_rivoluzione_solare.dart';
import 'package:esoteric_circle/core/horoscope/la_settimana_del_cielo.dart';
import 'package:esoteric_circle/core/horoscope/le_parti_del_responso.dart';
import 'package:esoteric_circle/core/horoscope/oroscopo_annuale_data.dart';
import 'package:esoteric_circle/core/horoscope/oroscopo_cinese_data.dart';
import 'package:esoteric_circle/core/horoscope/oroscopo_vedico_data.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **IL SIMBOLO NON APRE MAI. Ordine ES, 30 settembre 2026.**
///
/// Il fondatore, davanti all'anteprima della Settimana in cui ogni giorno
/// portava solo i suoi transiti: *"all'utente non gliene frega un cazzo dei
/// transiti, quante volte devo scriverlo e chiederlo? Vuole sapere come andrà
/// in generale, in amore, in lavoro, ecc. Se vuoi inserire i transiti, li
/// inserisci dopo giusto per motivare da dove arriva la risposta."* E le Linee
/// Guida, sezione 2: la risposta, che cosa puoi fare, da dove viene; *"il
/// simbolo non apre mai"*.
///
/// Cosa si pretende, su ogni lettura dell'Oroscopo che non e' il Giorno
/// occidentale (che dall'ordine ER voce 14 apre gia' con la sua prima parte in
/// parole, e qui si guarda solo quella):
/// - ogni frase dei corpora cinese, vedico e annuale ha le due parti, e nel
///   TESTO non c'e' un simbolo; i titoli sono in parole;
/// - le schede composte dai tre motori, Breve e Lunga, non portano simboli nel
///   titolo, nella sintesi e nella lettura, e hanno la riga "da dove viene";
/// - la risposta della Settimana e del Mese, il giorno migliore e il che cosa
///   fare non nominano pianeti, segni o case, e le tessere della card nemmeno.
///
/// **Che cosa e' un simbolo, qui**: i nomi dei pianeti e dei segni con la
/// maiuscola, l'Ascendente, il Medio Cielo, la Rivoluzione Solare, le case
/// contate ("casa 5", "la settima casa"), i transiti, e i termini dei metodi
/// cinese e vedico (animali, dei, nakshatra, tara, Rahu). Le parole comuni che
/// hanno anche un senso quotidiano ("casa" come abitazione, "segno" come
/// traccia) non sono nell'elenco: le prende il controllo delle case contate.
void main() {
  const pianeti = [
    'Sole', 'Luna', 'Mercurio', 'Venere', 'Marte', 'Giove', 'Saturno', //
    'Urano', 'Nettuno', 'Plutone',
  ];
  const segni = [
    'Ariete', 'Toro', 'Gemelli', 'Cancro', 'Leone', 'Vergine', 'Bilancia', //
    'Scorpione', 'Sagittario', 'Capricorno', 'Acquario', 'Pesci',
  ];
  const animali = [
    'Topo', 'Bue', 'Tigre', 'Coniglio', 'Drago', 'Serpente', 'Cavallo', //
    'Capra', 'Scimmia', 'Gallo', 'Cane', 'Maiale',
  ];
  const metodi = [
    'Ascendente', 'Medio Cielo', 'Rivoluzione Solare', 'Ricchezza', //
    'Ufficiale', 'Sigillo', 'Rivale', 'Nutrimento', 'Uccisioni',
    'nakshatra', 'Nakshatra', 'Tara Bala', 'Rahu', 'Chandra', 'BaZi',
  ];
  final simbolo = RegExp([
    for (final w in [...pianeti, ...segni, ...animali, ...metodi])
      '(?<![A-Za-zÀ-ù])${RegExp.escape(w)}(?![A-Za-zÀ-ù])',
    r'\bcas[ae] \d',
    r'\b(prima|seconda|terza|quarta|quinta|sesta|settima|ottava|nona|decima|undicesima|dodicesima) casa\b',
    r'\btransit[oi]\b',
  ].join('|'));
  String? quale(String t) => simbolo.firstMatch(t)?.group(0);

  test('ogni frase dei tre corpora ha le due parti, e il TESTO e\' in parole',
      () {
    final frasi = <String>[
      for (final v in OroscopoCineseData.rapporti.values) ...v,
      for (final v in OroscopoCineseData.guardiani) ...v,
      for (final serie in OroscopoCineseData.dei.values)
        for (final v in serie.values) ...v,
      for (final v in OroscopoVedicoData.chandraBala) ...v,
      for (final v in OroscopoVedicoData.taraBala) ...v,
      ...OroscopoVedicoData.righeDelGiorno,
      ...OroscopoVedicoData.righeDelPianeta,
      for (final v in OroscopoVedicoData.amore) ...v,
      for (final v in OroscopoVedicoData.lavoro) ...v,
      for (final v in OroscopoVedicoData.fortuna) ...v,
      ...OroscopoVedicoData.rahuPrima,
      ...OroscopoVedicoData.rahuInCorso,
      ...OroscopoVedicoData.rahuPassato,
      for (final g in [
        OroscopoAnnualeData.ascendente,
        OroscopoAnnualeData.sole,
        OroscopoAnnualeData.venere,
        OroscopoAnnualeData.giove,
        OroscopoAnnualeData.saturno,
        OroscopoAnnualeData.medioCielo,
        OroscopoAnnualeData.luna,
      ])
        for (final v in g) ...v,
    ];
    final senzaParti = <String>[];
    final colSimbolo = <String>[];
    for (final f in frasi) {
      final pezzi = f.split(LePartiDelResponso.separatore);
      if (pezzi.length != 2 ||
          pezzi[0].trim().isEmpty ||
          pezzi[1].trim().isEmpty) {
        senzaParti.add(f);
        continue;
      }
      final q = quale(pezzi[0]);
      if (q != null) colSimbolo.add('"$q" in: ${pezzi[0]}');
    }
    final titoli = <String>[
      ...OroscopoCineseData.titoliDeiRapporti.values,
      for (final t in OroscopoCineseData.titoliDeiDei.values) ...t.values,
      ...OroscopoVedicoData.titoliDellaLuna,
      ...OroscopoVedicoData.titoliAmore,
      ...OroscopoVedicoData.titoliLavoro,
      ...OroscopoVedicoData.titoliFortuna,
      ...LAnnuale.titoli.values,
    ];
    for (final t in titoli) {
      final q = quale(t);
      if (q != null) colSimbolo.add('titolo "$q": $t');
    }
    cardinaleMinimo(frasi.length, 600, cosa: 'frasi dei tre corpora');
    cardinaleMinimo(titoli.length, 90, cosa: 'titoli dei tre corpora');
    print('IL SIMBOLO NON APRE MAI, corpora: frasi ${frasi.length}, senza le '
        'due parti ${senzaParti.length}; titoli ${titoli.length}; TESTI e '
        'titoli col simbolo ${colSimbolo.length}');
    expect(senzaParti, isEmpty, reason: senzaParti.take(4).join('\n'));
    expect(colSimbolo, isEmpty, reason: colSimbolo.take(6).join('\n'));
  });

  test('il Giorno occidentale apre con la sua prima parte in parole', () {
    final fuori = <String>[];
    var n = 0;
    for (final d in HoroscopeDomain.values) {
      for (final casa in HoroscopeData.primeDelGiorno[d.index]!) {
        for (final f in casa) {
          n++;
          final q = quale(f);
          if (q != null) fuori.add('${d.name} "$q": $f');
        }
      }
      for (final casa in HoroscopeData.titoliDelGiorno[d.index]!) {
        for (final f in casa) {
          final q = quale(f);
          if (q != null) fuori.add('titolo ${d.name} "$q": $f');
        }
      }
    }
    cardinaleMinimo(n, 96, cosa: 'prime parti del Giorno');
    print('IL SIMBOLO NON APRE MAI, Giorno: prime parti e titoli col simbolo '
        '${fuori.length} su $n');
    expect(fuori, isEmpty, reason: fuori.take(6).join('\n'));
  });

  test('le schede della Cinese, della Vedica e dell\'Anno, Breve e Lunga', () {
    final fuori = <String>[];
    var schede = 0;
    void guarda(String chi, HoroscopeCard c) {
      schede++;
      for (final (cosa, t) in [
        ('titolo', c.title),
        ('sintesi', c.synthesis),
        ('lettura', c.text),
      ]) {
        final q = quale(t);
        if (q != null) fuori.add('$chi, $cosa "$q": $t');
      }
      if ((c.rigaDelLivello ?? '').trim().isEmpty) {
        fuori.add('$chi senza "da dove viene"');
      }
    }

    final tutte = {for (final d in HoroscopeDomain.values) d: true};
    for (final lunga in [false, true]) {
      final approfondite = lunga ? tutte : const <HoroscopeDomain, bool>{};
      final chi = lunga ? 'Lunga' : 'Breve';
      for (var a = 0; a < 12; a++) {
        for (final f in CourtesyForm.values) {
          for (var k = 0; k < 20; k++) {
            for (final c in LaLetturaCinese.schede(
                oggi: DateTime(2026, 10, 1 + k * 3),
                nascita: DateTime(1960 + a * 3, 1 + a, 1 + k),
                animale: a,
                forma: f,
                approfondite: approfondite)!) {
              guarda('cinese $chi $a $k ${c.domain.name}', c);
            }
          }
        }
      }
      const roma = LuogoDelGiorno(lat: 41.9, lon: 12.5, citta: 'Roma');
      for (final (oraNota, luogo) in [
        (true, roma),
        (false, null),
      ]) {
        final nascita = NascitaDeiSegni(
            locale: DateTime(1990, 3, 15, 8, 30),
            oraNota: oraNota,
            fuso: 'Europe/Rome');
        for (var k = 0; k < 60; k++) {
          for (final c in LaLetturaVedica.schede(
              adesso: DateTime(2026, 9, 1 + k, 9),
              nascita: nascita,
              luogo: luogo,
              approfondite: approfondite)!) {
            guarda('vedica $chi $k ${c.domain.name}', c);
          }
        }
      }
      for (var mese = 1; mese <= 12; mese++) {
        for (var anno = 2024; anno <= 2028; anno++) {
          final tema = LaRivoluzioneSolare.tema(
              LaRivoluzioneSolare.ritornoInCorso(
                  DateTime.utc(1975 + mese, mese, 11, 5), DateTime(anno, 12)),
              45.5,
              9.2);
          for (final c in LAnnuale.schede(tema, approfondite: approfondite)) {
            guarda('anno $chi $mese $anno ${c.domain.name}', c);
          }
        }
      }
    }
    cardinaleMinimo(schede, 7000, cosa: 'schede delle tre letture');
    print('IL SIMBOLO NON APRE MAI, schede: col simbolo in titolo, sintesi o '
        'lettura, o senza "da dove viene", ${fuori.length} su $schede');
    expect(fuori, isEmpty, reason: fuori.take(6).join('\n'));
  });

  test('la Settimana e il Mese rispondono in parole', () {
    final fuori = <String>[];
    var campi = 0;
    for (final segno in Zodiac.values) {
      for (final (giorni, mese) in [(7, false), (30, true)]) {
        for (final inizio in [DateTime(2026, 9, 30), DateTime(2027, 2, 14)]) {
          final p = LaSettimanaDelCielo.per(
              segno: segno, carta: null, oggi: inizio, giorni: giorni);
          for (final d in p.domini) {
            campi++;
            for (final t in [
              d.risposta(mese: mese),
              d.rigaDelMigliore,
              // EU Aggiunta: i paragrafi e il titolo della voce del periodo
              // al posto della lettura del giorno migliore.
              d.voce.titolo,
              ...d.voce.paragrafi(lunga: true),
            ]) {
              final q = quale(t);
              if (q != null) {
                fuori.add('${segno.name} ${d.dominio.name} "$q": $t');
              }
            }
          }
          for (final c in LaSettimanaDelCielo.tessere(p, mese: mese)) {
            final q = quale(c.synthesis);
            if (q != null) {
              fuori.add('tessera ${segno.name} "$q": ${c.synthesis}');
            }
          }
        }
      }
    }
    cardinaleMinimo(campi, 180, cosa: 'campi dei periodi');
    print('IL SIMBOLO NON APRE MAI, periodi: risposte col simbolo '
        '${fuori.length} su $campi campi');
    expect(fuori, isEmpty, reason: fuori.take(6).join('\n'));
  });
}
