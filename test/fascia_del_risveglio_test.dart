import 'dart:io';

import 'package:esoteric_circle/core/astro/sky_location.dart';
import 'package:esoteric_circle/core/astro/solar_time.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/rituals/daily_elements.dart';
import 'package:esoteric_circle/core/rituals/daily_rituals.dart';
import 'package:esoteric_circle/core/rituals/rito_alba.dart';
import 'package:esoteric_circle/core/rituals/rito_alba_corpus.dart';
import 'package:flutter_test/flutter_test.dart';

/// LE CINQUE PROVE DEL ROSSO DELLA VOCE 2.
void main() {
  const lat = 45.4642;
  const lon = 9.1900;
  const fuso = Duration(hours: 2);
  final giorno = DateTime(2026, 8, 5);

  PosizioneDiStamattina posizione({bool conLuogo = true}) =>
      PosizioneDiStamattina.da(
        conLuogo ? const SkyPlace(latitude: lat, longitude: lon) : null,
        fuso,
      );

  FasciaDelRisveglio fascia({bool conLuogo = true}) =>
      FasciaDelRisveglio.per(giorno, posizione: posizione(conLuogo: conLuogo));

  group('Il colore nasce dal Maestro, non dalla schermata', () {
    test('la bolla dell\'Alba non e\' piu\' oro fisso', () {
      final sorgente =
          File('lib/features/santuario/daily_strip.dart').readAsStringSync();
      // Il ripiego oro non deve piu' governare l'accento: se qualcuno lo
      // rimette, la bolla torna a non dire chi porge il rito di oggi.
      expect(sorgente.contains('if (guide == null) return _gold;'), isFalse,
          reason: 'la bolla e\' tornata a un colore che non viene dal Maestro');
      expect(sorgente.contains('_accentFor(maestro)'), isTrue,
          reason: 'l\'accento non nasce piu\' dal Maestro');
    });

    test('il Maestro dell\'Alba e\' quello della rotazione, da un punto solo',
        () {
      for (var g = 0; g < 30; g++) {
        final quando = giorno.add(Duration(days: g));
        expect(DailyElements.maestroFor(DailyElement.dawn, quando),
            DailyRituals.dawnMaestro(quando),
            reason: 'la striscia e il rito userebbero due Maestri diversi');
      }
    });

    test('i tre Maestri danno tre colori diversi', () {
      // Se due Maestri dessero lo stesso colore, la bolla non direbbe niente.
      final chiavi = Maestro.values.map((m) => m.name).toSet();
      expect(chiavi, hasLength(3));
    });
  });

  group('La fascia e\' calcolata, non fissa', () {
    test('l\'ora della fascia cambia col giorno e col luogo', () {
      final inverno = FasciaDelRisveglio.per(DateTime(2026, 12, 21),
          posizione: posizione());
      final estate =
          FasciaDelRisveglio.per(DateTime(2026, 6, 21), posizione: posizione());
      expect(inverno.oraDiInizio, isNot(estate.oraDiInizio),
          reason: 'la fascia dice la stessa ora a dicembre e a giugno: '
              'e\' un\'ora fissa travestita da calcolo');

      final altrove = FasciaDelRisveglio.per(giorno,
          posizione: PosizioneDiStamattina.da(
              const SkyPlace(latitude: -33.8688, longitude: 151.2093),
              const Duration(hours: 10)));
      expect(altrove.oraDiInizio, isNot(fascia().oraDiInizio),
          reason: 'due luoghi lontanissimi ricevono la stessa ora');
    });

    test('la fascia dura un\'ora dal sorgere', () {
      final f = fascia();
      expect(f.dichiarabile, isTrue);
      expect(f.fine!.difference(f.inizio!), FasciaDelRisveglio.durataStandard);
    });

    test('l\'avviso dichiara l\'ora vera, non una frase generica', () {
      final f = fascia();
      final righe = RitoAlba.avvisoDellaFascia(f);
      expect(righe, hasLength(3), reason: 'tre righe, non un regolamento');
      expect(righe.first, contains(f.oraDiInizio!),
          reason: 'la prima riga non porta l\'ora calcolata');
      expect(righe.first, contains(f.oraDiFine!));
      // La riga deve dire cosa si riceve, in concreto.
      expect(righe[1].toLowerCase(), contains('riga in più'));
      // E che chi arriva dopo fa il rito lo stesso.
      expect(righe[2].toLowerCase(), contains('intero'));
    });
  });

  group('Senza luogo la fascia non si dichiara', () {
    test('non esce nessuna ora inventata', () {
      final f = fascia(conLuogo: false);
      expect(f.dichiarabile, isFalse);
      expect(f.inizio, isNull);
      expect(f.oraDiInizio, isNull);

      final righe = RitoAlba.avvisoDellaFascia(f);
      expect(righe, hasLength(3));
      expect(righe.first.toLowerCase(), contains('dove sei stamattina'),
          reason: 'senza posizione l\'avviso deve dire cosa serve, non un '
              'orario, e deve chiedere DOVE SEI, non dove sei nato');
      expect(righe.first.toLowerCase().contains('luogo di nascita'), isFalse,
          reason: 'il luogo di nascita non c\'entra con l\'alba di stamattina');
      // Nessuna cifra oraria deve comparire nell'avviso senza luogo.
      expect(RegExp(r'\d{1,2}:\d{2}').hasMatch(righe.join(' ')), isFalse,
          reason: 'e\' comparsa un\'ora pur non sapendo il luogo');
    });

    test('senza luogo nessuno risulta dentro la fascia', () {
      final f = fascia(conLuogo: false);
      for (var ora = 0; ora < 24; ora++) {
        expect(f.contiene(DateTime(2026, 8, 5, ora, 30)), isFalse,
            reason: 'senza un\'ora vera non esiste un dentro e un fuori');
      }
    });

    test('nei casi polari la fascia non si dichiara', () {
      final polare = FasciaDelRisveglio.per(DateTime(2026, 6, 21),
          posizione: PosizioneDiStamattina.da(
              const SkyPlace(latitude: 69.6492, longitude: 18.9553),
              const Duration(hours: 2)));
      expect(polare.dichiarabile, isFalse,
          reason: 'sopra il circolo polare in giugno il Sole non sorge: '
              'dichiarare una fascia sarebbe una promessa falsa');
    });
  });

  group('Coordinate e fuso vengono dalla STESSA origine', () {
    test('col dispositivo le coordinate sono quelle del dispositivo', () {
      final p = posizione();
      expect(p.origine, OrigineDellAlba.dispositivo);
      expect(p.lat, lat);
      expect(p.lon, lon);
      expect(p.scartoDiFuso, fuso);
      expect(p.oraDichiarabile, isTrue);
    });

    test('senza dispositivo la longitudine NASCE dallo scarto di fuso', () {
      // E' l'invariante che questa correzione esiste per garantire: prima le
      // coordinate venivano dal luogo di NASCITA e il fuso dall'orologio del
      // telefono, quindi per chi si era spostato l'ora del sorgere nasceva da
      // due punti diversi del mondo messi insieme.
      for (final scarto in [
        const Duration(hours: -8),
        Duration.zero,
        const Duration(hours: 2),
        const Duration(hours: 10),
      ]) {
        final p = PosizioneDiStamattina.da(null, scarto);
        expect(p.origine, OrigineDellAlba.stimataDalFuso);
        expect(p.scartoDiFuso, scarto);
        expect(p.lon, SunsetTime.longitudineDaFuso(scarto),
            reason: 'la longitudine non viene dallo stesso scarto di fuso che '
                'poi riporta l\'ora a muro: sono due origini diverse');
        expect(p.lat, SunsetTime.latDiRipiego);
      }
    });

    test('il luogo di nascita non puo\' entrare nel calcolo dell\'alba', () {
      // La firma non lo accetta piu': l'unica strada per le coordinate e'
      // `PosizioneDiStamattina`, che nasce da una posizione del dispositivo
      // oppure dallo scarto di fuso. Una prova strutturale lo blocca.
      final sorgente =
          File('lib/core/rituals/rito_alba.dart').readAsStringSync();
      expect(sorgente.contains('birthPlace'), isFalse,
          reason: 'il luogo di nascita e\' rientrato nel calcolo dell\'alba');
      final dono = File('lib/core/rituals/dawn_gift.dart').readAsStringSync();
      final righeVive = dono
          .split('\n')
          .where((r) => !r.trimLeft().startsWith('//'))
          .join('\n');
      expect(righeVive.contains('birthPlace'), isFalse,
          reason: 'il dono legge ancora il luogo di nascita per l\'alba');
    });

    test('la stimata dal fuso non dichiara nessuna ora', () {
      final p = PosizioneDiStamattina.da(null, fuso);
      expect(p.oraDichiarabile, isFalse);
      final f = FasciaDelRisveglio.per(giorno, posizione: p);
      expect(f.dichiarabile, isFalse,
          reason:
              'una longitudine dedotta dal fuso puo\' sbagliare di mezz\'ora: '
              'l\'ora non si dichiara, come nel caso senza luogo');
      // E il rito non nomina l'alba.
      final r = RitoAlba.diOggi(giorno, posizione: p);
      expect(r!.datiNominati.contains(DatoDelCielo.oraDellAlba), isFalse);
    });
  });

  group('La riga del risveglio appartiene solo a chi c\'era', () {
    test('dentro la fascia arriva, fuori no', () {
      final f = fascia();
      final maestro = DailyRituals.dawnMaestro(giorno);

      final dentro = f.inizio!.add(const Duration(minutes: 20));
      expect(RitoAlba.rigaDelRisveglio(dentro, maestro, f), isNotNull);

      final appenaDopo = f.fine!.add(const Duration(minutes: 1));
      expect(RitoAlba.rigaDelRisveglio(appenaDopo, maestro, f), isNull,
          reason: 'la riga del risveglio e\' arrivata anche fuori fascia: '
              'un premio che ricevono tutti non e\' un premio');

      final prima = f.inizio!.subtract(const Duration(minutes: 1));
      expect(RitoAlba.rigaDelRisveglio(prima, maestro, f), isNull);
    });

    test('senza luogo la riga non arriva a nessuno', () {
      final f = fascia(conLuogo: false);
      for (var ora = 0; ora < 24; ora++) {
        expect(
            RitoAlba.rigaDelRisveglio(
                DateTime(2026, 8, 5, ora), Maestro.medora, f),
            isNull);
      }
    });

    test('ogni Maestro ha le sue righe, e non se le scambiano', () {
      for (final m in Maestro.values) {
        expect(RitoAlbaCorpus.righeDelRisveglio[m], isNotNull);
        expect(RitoAlbaCorpus.righeDelRisveglio[m]!.length,
            greaterThanOrEqualTo(4));
      }
      final tutte = <String, Maestro>{};
      RitoAlbaCorpus.righeDelRisveglio.forEach((m, righe) {
        for (final r in righe) {
          expect(tutte.containsKey(r), isFalse,
              reason: 'la stessa riga del risveglio sta sotto due Maestri');
          tutte[r] = m;
        }
      });
    });

    test('la riga non promette esiti', () {
      const vietate = [
        'guarigione',
        'salute',
        'fortuna',
        'successo',
        'garantito',
        'protegge',
      ];
      for (final righe in RitoAlbaCorpus.righeDelRisveglio.values) {
        for (final r in righe) {
          for (final v in vietate) {
            expect(r.toLowerCase().contains(v), isFalse,
                reason: 'la riga del risveglio promette un esito: «$r»');
          }
        }
      }
    });
  });

  group('Il rito non si accorcia per chi arriva tardi', () {
    test('dentro e fuori fascia il rito e\' lo stesso, cambia solo la riga',
        () {
      final f = fascia();
      final ritoDentro = RitoAlba.diOggi(giorno, posizione: posizione());
      final ritoFuori = RitoAlba.diOggi(giorno, posizione: posizione());

      expect(ritoDentro, isNotNull);
      expect(ritoFuori, isNotNull);
      // Il rito non dipende dall'ora in cui lo si apre: dipende dal giorno.
      expect(ritoFuori!.gesto, ritoDentro!.gesto);
      expect(ritoFuori.respiro, ritoDentro.respiro);
      expect(ritoFuori.parola, ritoDentro.parola);
      expect(ritoFuori.viaTattile, ritoDentro.viaTattile);

      // L'unica differenza e' la riga.
      final maestro = DailyRituals.dawnMaestro(giorno);
      expect(
          RitoAlba.rigaDelRisveglio(
              f.inizio!.add(const Duration(minutes: 5)), maestro, f),
          isNotNull);
      expect(
          RitoAlba.rigaDelRisveglio(
              f.fine!.add(const Duration(hours: 3)), maestro, f),
          isNull);
    });
  });
}
