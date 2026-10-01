// ignore_for_file: avoid_print
import 'dart:io';

import 'package:esoteric_circle/core/astro/celestial.dart';
import 'package:esoteric_circle/core/astro/effemeridi.dart';
import 'package:esoteric_circle/core/astro/natal_chart.dart';
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/astro/aspetti_di_oggi.dart';
import 'package:esoteric_circle/core/horoscope/cielo_di_oggi.dart';
import 'package:esoteric_circle/core/horoscope/horoscope.dart';
import 'package:esoteric_circle/core/horoscope/il_livello_del_cielo.dart';
import 'package:esoteric_circle/core/horoscope/la_settimana_del_cielo.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **I LIVELLI DEI GIORNI.** Ordine EU voce 09, 1 ottobre 2026.
///
/// Il fondatore, sulla Settimana: *"le barre di cui una gialla in evidenza
/// sembrano tutte uguali"*; nella sua cattura del Generale i sette livelli
/// sono identici. Qui si contano, per tre persone con la carta natale vera
/// (le posizioni dei pianeti di nascita dal motore delle effemeridi
/// dell'app) e per una senza carta, in quattro settimane, quanti livelli
/// diversi ha ogni dominio e quante settimane hanno i sette livelli uguali.
void main() {
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

  test('quanti livelli diversi ha ogni dominio in una settimana', () {
    final persone = <(String, Zodiac, NatalChart?)>[
      () {
        final c = cartaDi(DateTime.utc(1975, 2, 14, 6, 30), 15);
        return ('persona 1, nata il 14 febbraio 1975', c.sunSign, c);
      }(),
      () {
        final c = cartaDi(DateTime.utc(1988, 7, 3, 21, 10), 200);
        return ('persona 2, nata il 3 luglio 1988', c.sunSign, c);
      }(),
      () {
        final c = cartaDi(DateTime.utc(1996, 11, 27, 13, 45), 95);
        return ('persona 3, nata il 27 novembre 1996', c.sunSign, c);
      }(),
      ('persona 4, senza ora di nascita', Zodiac.leo, null),
    ];
    final righe = <String>[];
    var settimane = 0, piatte = 0, giorni = 0;
    final perDominio = <HoroscopeDomain, int>{};
    for (final (nome, segno, carta) in persone) {
      righe.add('$nome, segno ${segno.italianName}'
          '${carta == null ? ', senza carta' : ', con la carta'}');
      for (var w = 0; w < 4; w++) {
        final inizio = DateTime(2026, 10, 1 + 7 * w);
        final periodo =
            LaSettimanaDelCielo.per(segno: segno, carta: carta, oggi: inizio);
        settimane++;
        for (final d in periodo.domini) {
          final livelli = [for (final g in d.giorni) g.livello];
          giorni += livelli.length;
          final diversi = livelli.toSet().length;
          if (diversi == 1) {
            piatte++;
            perDominio[d.dominio] = (perDominio[d.dominio] ?? 0) + 1;
          }
          righe.add('  settimana dal ${LaSettimanaDelCielo.data(inizio)}, '
              '${d.dominio.label}: ${livelli.join(' ')}, livelli diversi '
              '$diversi');
        }
      }
    }
    cardinaleMinimo(settimane, 16, cosa: 'settimane misurate');
    cardinaleMinimo(giorni, 16 * 4 * 7, cosa: 'giorni misurati');
    final sintesi = 'domini-settimana con i sette livelli uguali: $piatte su '
        '${settimane * 4} (${[
      for (final e in perDominio.entries) '${e.key.label} ${e.value}'
    ].join(', ')})';
    print('ORDINE EU VOCE 09: $sintesi');
    File('docs/collaudo/EU/livelli_dei_giorni_misura.txt')
        .writeAsStringSync('${[sintesi, ...righe].join('\n')}\n');
  });

  // **LE DUE REGOLE NUOVE, su un cielo scritto a mano.** Il Generale di una
  // persona col Sole di nascita a 10 gradi dell'Ariete.
  VoceDelCielo voce(CorpoCeleste chi, AspectType a, double orbe,
          {String id = 'sun', String nome = 'Sole'}) =>
      VoceDelCielo(
          transito: chi,
          bersaglio: nome,
          idBersaglio: id,
          aspetto: a,
          orbe: orbe,
          applicativo: null,
          casa: null,
          retrogrado: false,
          giorniDiIncertezza: 0);
  int livello(CieloDiOggi c) => IlLivelloDelCielo.per(
          dominio: HoroscopeDomain.generale,
          segno: Zodiac.aries,
          cielo: c,
          quando: DateTime.utc(2026, 10, 1, 12))
      .$1;
  const natali = {'sun': ('Sole', 10.0)};

  test('il clima dei lenti pesa al massimo un gradino', () {
    // Tre lenti in aspetto armonico esatto, nessun veloce: prima facevano
    // 3 + 3 = 5 per tutti i giorni in cui restavano in orbita, cioe' per
    // settimane; adesso il clima vale un gradino, 4.
    final c = CieloDiOggi(
      voci: [
        voce(CorpoCeleste.giove, AspectType.trine, 0),
        voce(CorpoCeleste.saturno, AspectType.sextile, 0),
        voce(CorpoCeleste.urano, AspectType.trine, 0),
      ],
      livello: LivelloPersonalizzazione.cartaCompleta,
      // La Luna a trenta gradi dal Sole: nessun aspetto.
      lunaDelGiorno: 40,
      natali: natali,
    );
    expect(livello(c), 4,
        reason: 'il clima dei pianeti lenti non e\' tenuto a un gradino');
  });

  test('la Luna del giorno conta con l\'orbe della tradizione', () {
    // La Luna a 3 gradi dal trigono esatto al Sole di nascita: fuori dai
    // due gradi delle voci, dentro i sei della meta' dell'orbe di Lilly.
    // Una voce di Mercurio al limite dell'orbita fa il cielo vero e pesa 0.
    final c = CieloDiOggi(
      voci: [voce(CorpoCeleste.mercurio, AspectType.sextile, 2.0)],
      livello: LivelloPersonalizzazione.cartaCompleta,
      lunaDelGiorno: 133,
      natali: natali,
    );
    final (l, riga) = IlLivelloDelCielo.per(
        dominio: HoroscopeDomain.generale,
        segno: Zodiac.aries,
        cielo: c,
        quando: DateTime.utc(2026, 10, 1, 12));
    expect(l, 4, reason: 'la Luna del giorno in trigono al Sole non conta');
    expect(riga, contains('la Luna in trigono al tuo Sole di nascita'),
        reason: 'la riga non dice da dove viene il gradino: $riga');
  });
}
