// ignore_for_file: avoid_print
import 'dart:io';

import 'package:esoteric_circle/core/astro/celestial.dart';
import 'package:esoteric_circle/core/astro/effemeridi.dart';
import 'package:esoteric_circle/core/astro/natal_chart.dart';
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/horoscope/cielo_di_oggi.dart';
import 'package:esoteric_circle/core/horoscope/horoscope.dart';
import 'package:esoteric_circle/core/horoscope/i_segni_delle_tradizioni.dart';
import 'package:esoteric_circle/core/horoscope/i_testi_eu.dart';
import 'package:esoteric_circle/core/horoscope/l_anno_delle_tradizioni.dart';
import 'package:esoteric_circle/core/horoscope/la_lettura_cinese.dart';
import 'package:esoteric_circle/core/horoscope/la_lettura_vedica.dart';
import 'package:esoteric_circle/core/horoscope/la_settimana_del_cielo.dart';
import 'package:esoteric_circle/design_system/typography/paragrafi_di_lettura.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **I PARAGRAFI DICONO RISPOSTE.** Ordine EU voce 01, 1 ottobre 2026.
///
/// Il fondatore: *"QUANTE VOLTE DEVO SCRIVERLO: ALL'UTENTE NON GLIENE FREGA
/// UN CAZZO DEI TRANSITI: VUOLE RISPOSTE O UNA GUIDA."*; *"In generale per
/// breve sono sufficienti 2 paragrafi e per lunga aggiungere altri 2
/// paragrafi mai di transiti o tecnicismi perché sotto c'è già sempre "da
/// dove arriva"."*
///
/// Per l'Occidentale, la Vedica e la Cinese, nel Giorno, nella Settimana, nel
/// Mese e nell'Anno, per tre persone in tre giorni, e per l'amico, si contano:
/// le schede con un numero di paragrafi diverso da 2 in Breve e da 4 in
/// Lunga (i paragrafi come li spezza la schermata, `spezzaInParagrafi`); i
/// paragrafi con una parola del cielo (transiti, pianeti, case contate,
/// aspetti, nakshatra, tara, tronchi e rami); le schede che dicono il cielo
/// due volte (una frase del "Da dove viene" ripetuta nel testo, o due volte
/// nella sua riga). Tutti e tre devono essere zero. La misura si scrive in
/// `docs/collaudo/EU/paragrafi.txt`.
void main() {
  // Le parole del cielo, dalla voce EU.01: "nessun transito, pianeta, casa,
  // aspetto, nakshatra, tara, tronco o ramo". La casa conta solo quando e'
  // quella del cielo (contata, o col numero): "case" come abitazioni no.
  final cielo = RegExp(
      r'\b(transit\w*|pianet\w*|Venere|Marte|Giove|Saturno|Mercurio|Urano|'
      r'Nettuno|Plutone|Sole|Luna|trigon\w*|quadratur\w*|sestil\w*|'
      r'opposizion\w*|congiunzion\w*|retrograd\w*|Ascendente|Medio Cielo|'
      r'nakshatra|tara|tronc\w*|rami?|Rahu|Chandra|rashi|gochara|Tai Sui|'
      r'BaZi|(?:prima|seconda|terza|quarta|quinta|sesta|settima|ottava|nona|'
      r'decima|undicesima|dodicesima) casa|casa \d+|segno zodiacale)\b');
  const stile = TextStyle(fontSize: 18, height: 1.5);

  NatalChart cartaDi(DateTime nascitaUtc, double ascendente) {
    final jd = Celestial.julianDay(nascitaUtc);
    final pianeti = [
      for (final c in CorpoCeleste.values)
        () {
          final l = Effemeridi.longitudineEclittica(c, jd);
          return PlanetPosition(
              id: c.id,
              name: c.nome,
              glyph: c.glifo,
              longitude: l,
              sign: Zodiac.values[(l ~/ 30) % 12]);
        }(),
    ];
    return NatalChart(
      sunSign: pianeti.first.sign,
      planets: pianeti,
      ascendantLongitude: ascendente,
      midheavenLongitude: (ascendente + 270) % 360,
      houses: [
        for (var n = 1; n <= 12; n++)
          HouseCusp(
              number: n, longitude: (ascendente + (n - 1) * 30.0) % 360.0),
      ],
      hasTime: true,
    );
  }

  test('due paragrafi in Breve, quattro in Lunga, il cielo solo sotto', () {
    final persone = [
      (DateTime(1975, 2, 14, 7, 30), 15.0, true),
      (DateTime(1988, 7, 3, 23, 10), 200.0, true),
      (DateTime(1996, 11, 27, 14, 45), 95.0, false),
    ];
    final giorni = [
      DateTime(2026, 10, 1),
      DateTime(2026, 11, 12),
      DateTime(2027, 2, 20),
    ];
    final paragrafiSbagliati = <String>[];
    final conIlCielo = <String>[];
    final cieloDueVolte = <String>[];
    final righe = <String>[];
    var schede = 0;

    void misura(String dove, List<HoroscopeCard> breve,
        List<HoroscopeCard> lunga) {
      for (final (profondita, elenco, attesi) in [
        ('Breve', breve, 2),
        ('Lunga', lunga, 4),
      ]) {
        var parole = 0, sbagliati = 0, doppie = 0;
        for (final c in elenco) {
          schede++;
          final p = spezzaInParagrafi(c.text, stile: stile);
          if (p.length != attesi) {
            sbagliati++;
            paragrafiSbagliati.add('$dove $profondita ${c.domain.label}: '
                '${p.length} paragrafi');
          }
          for (final x in p) {
            for (final m in cielo.allMatches(x)) {
              parole++;
              conIlCielo.add('$dove $profondita ${c.domain.label}: '
                  '"${m.group(0)}" in "${x.length > 80 ? x.substring(0, 80) : x}"');
            }
          }
          // Il cielo una volta sola: nessuna frase del "Da dove viene" sta
          // anche nel testo, e nessuna sta due volte nella riga.
          final daDove = (c.rigaDelLivello ?? '')
              .split(RegExp(r'(?<=[.!?]) '))
              .where((f) => f.trim().length > 20)
              .toList();
          final viste = <String>{};
          for (final f in daDove) {
            if (c.text.contains(f.trim()) || !viste.add(f.trim())) {
              doppie++;
              cieloDueVolte.add('$dove $profondita ${c.domain.label}: '
                  '"${f.trim()}"');
            }
          }
        }
        righe.add('$dove, $profondita: ${elenco.length} schede, paragrafi '
            '${[for (final c in elenco) spezzaInParagrafi(c.text, stile: stile).length].join(' ')}'
            ', fuori misura $sbagliati, parole del cielo $parole, cielo due '
            'volte $doppie');
      }
    }

    for (final (nascita, asc, conCarta) in persone) {
      final carta = conCarta ? cartaDi(nascita.toUtc(), asc) : null;
      final segno = Zodiac.fromDate(nascita);
      final n = NascitaDeiSegni(
          locale: nascita, oraNota: true, fuso: 'Europe/Rome');
      final animale = ISegniDelleTradizioni.cinese(n).animale!;
      final chi = 'nato il ${nascita.day}/${nascita.month}/${nascita.year}'
          '${conCarta ? ' con la carta' : ' senza carta'}';
      for (final oggi in giorni) {
        final g = '$chi, ${oggi.day}/${oggi.month}/${oggi.year}';
        final m = DateTime.utc(oggi.year, oggi.month, oggi.day, 12);
        final cieloDelGiorno =
            CieloDiOggi.perIlGiorno(adesso: m, carta: carta);
        List<HoroscopeCard> occ(bool lunga) => Horoscope.forSign(
            sign: segno,
            dayOfYear: Horoscope.dayOfYear(oggi),
            year: oggi.year,
            cielo: cieloDelGiorno,
            nascita: nascita,
            vocativo: 'Ciao Prova',
            profonde: {for (final d in HoroscopeDomain.values) d: lunga});
        misura('Occidentale Giorno, $g', occ(false), occ(true));
        // L'amico: la stessa porta, senza carta e senza vocativo.
        List<HoroscopeCard> amico(bool lunga) => Horoscope.forSign(
            sign: segno,
            dayOfYear: Horoscope.dayOfYear(oggi),
            year: oggi.year,
            nascita: nascita,
            profonde: {for (final d in HoroscopeDomain.values) d: lunga});
        misura('Amico, Occidentale Giorno, $g', amico(false), amico(true));
        List<HoroscopeCard> ved(bool lunga) => LaLetturaVedica.schede(
            adesso: DateTime(oggi.year, oggi.month, oggi.day, 9),
            nascita: n,
            forma: CourtesyForm.unknown,
            vocativo: 'Ciao Prova',
            approfondite: {
              for (final d in HoroscopeDomain.values) d: lunga
            })!;
        misura('Vedica Giorno, $g', ved(false), ved(true));
        List<HoroscopeCard> cin(bool lunga) => LaLetturaCinese.schede(
            oggi: oggi,
            nascita: nascita,
            animale: animale,
            forma: CourtesyForm.unknown,
            vocativo: 'Ciao Prova',
            approfondite: {
              for (final d in HoroscopeDomain.values) d: lunga
            })!;
        misura('Cinese Giorno, $g', cin(false), cin(true));
        // La Settimana e il Mese: i paragrafi della voce del periodo.
        for (final mese in [false, true]) {
          final nome = mese ? 'Mese' : 'Settimana';
          final periodi = <String, IlPeriodoDelCielo>{
            'Occidentale': LaSettimanaDelCielo.per(
                segno: segno,
                carta: carta,
                oggi: oggi,
                giorni: mese ? 30 : 7,
                nascita: nascita),
            'Cinese': LaSettimanaDelCielo.dalleSchede(
                oggi: oggi,
                giorni: mese ? 30 : 7,
                tradizione: TradizioneEu.cinese,
                scarto: ITestiEu.scarto(nascita),
                schedeDi: (x) => LaLetturaCinese.schede(
                    oggi: x,
                    nascita: nascita,
                    animale: animale,
                    forma: CourtesyForm.unknown))!,
            'Vedica': LaSettimanaDelCielo.dalleSchede(
                oggi: oggi,
                giorni: mese ? 30 : 7,
                tradizione: TradizioneEu.vedica,
                scarto: ITestiEu.scarto(nascita),
                schedeDi: (x) => LaLetturaVedica.schede(
                    adesso: DateTime(x.year, x.month, x.day, 12),
                    nascita: n,
                    forma: CourtesyForm.unknown))!,
          };
          for (final e in periodi.entries) {
            HoroscopeCard comeScheda(DominioDelPeriodo d, bool lunga) =>
                HoroscopeCard(
                    domain: d.dominio,
                    title: d.voce.titolo,
                    text: d.voce.testo(lunga: lunga),
                    synthesis: d.voce.risposta,
                    indicator: d.livello,
                    rigaDelLivello: d.momentoChiave);
            misura('${e.key} $nome, $g', [
              for (final d in e.value.domini) comeScheda(d, false)
            ], [
              for (final d in e.value.domini) comeScheda(d, true)
            ]);
          }
        }
        // L'Anno della Vedica e della Cinese (quello occidentale lo misura
        // la prova del PDF e dell'anno, con la Rivoluzione Solare).
        final annoCinese = LAnnoDelleTradizioni.cinese(oggi, animale,
            annoDiNascita: nascita.year)!;
        final rashi = LaLetturaVedica.lunaDiNascita(n)!.$1;
        final annoVedico = LAnnoDelleTradizioni.vedico(oggi, nascita, rashi);
        for (final (t, anno) in [
          (TradizioneEu.cinese, annoCinese),
          (TradizioneEu.vedica, annoVedico),
        ]) {
          misura(
              '${t.name} Anno, $g',
              LAnnoDelleTradizioni.schede(t, anno,
                  scarto: ITestiEu.scarto(nascita), approfondite: const {}),
              LAnnoDelleTradizioni.schede(t, anno,
                  scarto: ITestiEu.scarto(nascita)));
        }
      }
    }
    cardinaleMinimo(schede, 3 * 3 * 2 * (4 * 4 + 6 * 4 + 2 * 4),
        cosa: 'schede misurate');
    final sintesi = 'ORDINE EU VOCE 01: $schede schede; paragrafi fuori '
        'misura ${paragrafiSbagliati.length}, parole del cielo nei paragrafi '
        '${conIlCielo.length}, cielo detto due volte ${cieloDueVolte.length}';
    print(sintesi);
    File('docs/collaudo/EU/paragrafi_misura.txt').writeAsStringSync([
      sintesi,
      ...righe,
      if (paragrafiSbagliati.isNotEmpty) ...['', ...paragrafiSbagliati],
      if (conIlCielo.isNotEmpty) ...['', ...conIlCielo],
      if (cieloDueVolte.isNotEmpty) ...['', ...cieloDueVolte],
    ].join('\n'));
    expect(paragrafiSbagliati, isEmpty,
        reason: paragrafiSbagliati.take(10).join('\n'));
    expect(conIlCielo, isEmpty, reason: conIlCielo.take(10).join('\n'));
    expect(cieloDueVolte, isEmpty, reason: cieloDueVolte.take(10).join('\n'));
  });
}
