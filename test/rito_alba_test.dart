import 'package:esoteric_circle/core/astro/sky_location.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/rituals/daily_rituals.dart';
import 'package:esoteric_circle/core/rituals/rito_alba.dart';
import 'package:esoteric_circle/core/rituals/rito_alba_corpus.dart';
import 'package:flutter_test/flutter_test.dart';

/// LE CINQUE PROVE DEL ROSSO DELLA VOCE 1.
void main() {
  // Milano, per avere anche l'ora dell'alba.
  const lat = 45.4642;
  const lon = 9.1900;
  const fuso = Duration(hours: 2);

  /// La posizione di STAMATTINA, non il luogo di nascita: con `conLuogo` falso
  /// si simula il permesso non concesso, e il ripiego stima dal fuso.
  RitoDiOggi? rito(DateTime giorno, {bool conLuogo = true}) => RitoAlba.diOggi(
        giorno,
        posizione: PosizioneDiStamattina.da(
          conLuogo ? const SkyPlace(latitude: lat, longitude: lon) : null,
          fuso,
        ),
      );

  /// La firma di un rito, per confrontarne due.
  String firma(RitoDiOggi r) =>
      '${r.forma}|${r.gesto}|${r.respiro}|${r.parola}';

  group('Il rito non si ripete', () {
    test('trenta giorni non danno due riti uguali allo stesso Maestro', () {
      final visti = <Maestro, Map<String, DateTime>>{
        for (final m in Maestro.values) m: {},
      };
      for (var g = 0; g < 30; g++) {
        final giorno = DateTime(2026, 8, 5).add(Duration(days: g));
        final r = rito(giorno);
        expect(r, isNotNull);
        final gia = visti[r!.maestro]![firma(r)];
        expect(gia, isNull,
            reason: 'il ${giorno.toIso8601String().substring(0, 10)} ripete '
                'identico il rito del ${gia?.toIso8601String().substring(0, 10)} '
                'per ${r.maestro.name}');
        visti[r.maestro]![firma(r)] = giorno;
      }
    });

    test('nemmeno in un anno intero, e i tre momenti si muovono da soli', () {
      final firme = <String>{};
      final gesti = <String>{};
      final respiri = <String>{};
      final parole = <String>{};
      for (var g = 0; g < 365; g++) {
        final r = rito(DateTime(2026, 1, 1).add(Duration(days: g)))!;
        firme.add('${r.maestro.name}|${firma(r)}');
        gesti.add(r.gesto);
        respiri.add(r.respiro);
        parole.add(r.parola);
      }
      // Se i tre momenti si muovessero in blocco, le combinazioni distinte
      // sarebbero poche quanto le varianti di uno solo.
      expect(gesti.length, greaterThan(8));
      expect(respiri.length, greaterThan(8));
      expect(parole.length, greaterThan(8));
      expect(firme.length, greaterThan(100),
          reason: 'in un anno escono solo ${firme.length} riti distinti');
    });

    test('il corpus produce le combinazioni che dichiara', () {
      expect(RitoAlbaCorpus.forme, hasLength(9));
      for (final m in Maestro.values) {
        expect(RitoAlbaCorpus.perMaestro(m), hasLength(3),
            reason: '${m.name} non ha tre forme');
      }
      for (final f in RitoAlbaCorpus.forme) {
        expect(f.gesti.length, greaterThanOrEqualTo(4));
        expect(f.respiri.length, greaterThanOrEqualTo(4));
        expect(f.parole.length, greaterThanOrEqualTo(4));
        expect(f.combinazioni, greaterThanOrEqualTo(64));
      }
      expect(RitoAlbaCorpus.combinazioniTotali, greaterThanOrEqualTo(576));
    });
  });

  group('Ogni rito nomina il cielo di stamattina', () {
    test('nessun rito dell\'anno resta senza un dato vero', () {
      for (var g = 0; g < 365; g++) {
        final r = rito(DateTime(2026, 1, 1).add(Duration(days: g)))!;
        expect(r.datiNominati, isNotEmpty,
            reason: 'un rito che non nomina niente del cielo non e\' un rito '
                'dell\'alba');
      }
    });

    test('il dato nominato compare davvero nel testo, non solo nel campo', () {
      final r = rito(DateTime(2026, 8, 5))!;
      // Nessun segnaposto deve sopravvivere alla composizione.
      for (final dato in DatoDelCielo.values) {
        expect(r.gesto.contains(dato.segnaposto), isFalse,
            reason: 'il segnaposto ${dato.segnaposto} e\' rimasto nel testo');
      }
    });

    test('senza luogo il rito resta intero e non nomina l\'alba', () {
      for (var g = 0; g < 60; g++) {
        final r =
            rito(DateTime(2026, 1, 1).add(Duration(days: g)), conLuogo: false);
        expect(r, isNotNull, reason: 'senza luogo il rito e\' sparito');
        expect(r!.datiNominati.contains(DatoDelCielo.oraDellAlba), isFalse,
            reason: 'nomina l\'ora dell\'alba senza sapere il luogo');
        expect(r.datiNominati, isNotEmpty);
        expect(r.gesto, isNotEmpty);
        expect(r.respiro, isNotEmpty);
        expect(r.parola, isNotEmpty);
      }
    });
  });

  group('I tre Maestri non si somigliano', () {
    /// Le parole proprie di ogni lente. Non sono sinonimi: sono i campi che
    /// l'ordine assegna a ciascun Maestro.
    const lessico = <Maestro, List<String>>{
      Maestro.medora: [
        'ora',
        'alba',
        'giorno',
        'orologio',
        'passi',
        'direzione',
        'orizzonte',
        'avanti',
        'stasera',
        'settimana',
        'lontano',
        'prima',
      ],
      Maestro.aura: [
        'mani',
        'petto',
        'torace',
        'spalle',
        'piedi',
        'ventre',
        'talloni',
        'braccia',
        'palmi',
        'nuca',
        'respiro',
        'corpo',
        'acqua',
        'labbra',
        'lingua',
        'sbadiglia',
        'ginocchia',
      ],
      Maestro.caligo: [
        'traccia',
        'tracciala',
        'segno',
        'linea',
        'linee',
        'cerchio',
        'sigillo',
        'ombra',
        'buio',
        'iniziale',
        'pugno',
        'tasca',
        'scrivi',
        'disegna',
      ],
    };

    int punteggio(String testo, Maestro m) {
      final basso = testo.toLowerCase();
      return lessico[m]!.where(basso.contains).length;
    }

    test('ogni forma pesa di piu\' sulla lente del suo Maestro', () {
      for (final forma in RitoAlbaCorpus.forme) {
        final testo = forma.gesti.map((g) => g.testo).join(' ');
        final suo = punteggio(testo, forma.maestro);
        for (final altro in Maestro.values) {
          if (altro == forma.maestro) continue;
          expect(suo, greaterThan(punteggio(testo, altro)),
              reason: 'la forma "${forma.nome}" di ${forma.maestro.name} '
                  'pesa ${punteggio(testo, altro)} su ${altro.name} e solo '
                  '$suo sulla sua lente: si potrebbe dare a un altro Maestro');
        }
      }
    });

    test('per Aura il respiro e\' il centro, non un contorno', () {
      // La lente di Aura dice che il respiro e' il centro del rito: i suoi
      // respiri devono essere piu' lunghi di quelli degli altri due.
      final giriAura = RitoAlbaCorpus.perMaestro(Maestro.aura)
          .expand((f) => f.respiri)
          .map((r) => r.giri)
          .reduce((a, b) => a + b);
      for (final altro in [Maestro.medora, Maestro.caligo]) {
        final giriAltro = RitoAlbaCorpus.perMaestro(altro)
            .expand((f) => f.respiri)
            .map((r) => r.giri)
            .reduce((a, b) => a + b);
        expect(giriAura, greaterThan(giriAltro),
            reason: 'i respiri di Aura non sono piu\' lunghi di ${altro.name}');
      }
    });

    test('nessun testo e\' condiviso fra due Maestri', () {
      final di = <String, Maestro>{};
      for (final forma in RitoAlbaCorpus.forme) {
        for (final g in forma.gesti) {
          final gia = di[g.testo];
          expect(gia == null || gia == forma.maestro, isTrue,
              reason: 'lo stesso gesto sta sotto due Maestri');
          di[g.testo] = forma.maestro;
        }
      }
    });
  });

  group('Ogni gesto ha la sua via col dito', () {
    test('nessun gesto resta senza ripiego tattile', () {
      for (final forma in RitoAlbaCorpus.forme) {
        for (final g in forma.gesti) {
          expect(g.viaTattile.trim(), isNotEmpty,
              reason: 'un gesto di "${forma.nome}" non ha la via col dito');
          expect(g.viaTattile.length, greaterThan(15),
              reason: 'la via col dito di "${forma.nome}" e\' troppo corta per '
                  'essere un\'istruzione');
        }
      }
    });

    test('nessun gesto usa sensori, quindi nessuno puo\' restare escluso', () {
      for (final forma in RitoAlbaCorpus.forme) {
        for (final g in forma.gesti) {
          expect(g.usaSensore, isFalse);
        }
      }
    });

    test('il rito composto porta sempre la via col dito', () {
      for (var g = 0; g < 90; g++) {
        final r = rito(DateTime(2026, 1, 1).add(Duration(days: g)))!;
        expect(r.viaTattile.trim(), isNotEmpty);
      }
    });
  });

  group('Nessuna promessa di esito', () {
    test('il corpus non promette guarigione, salute ne fortuna', () {
      // Solo i testi dei riti: il pannello "Fonti e metodo" nomina queste
      // parole apposta, per dire che NON le promettiamo.
      const vietate = [
        'guarigione',
        'guarire',
        'guarisce',
        'cura ',
        'curare',
        'salute',
        'fortuna',
        'ti protegge',
        'protezione',
        'successo',
        'garantito',
        'garantisce',
        'risolvera',
        'ti sentirai meglio',
        'elimina',
        'sconfigge',
      ];
      for (final forma in RitoAlbaCorpus.forme) {
        final testi = <String>[
          forma.nome,
          ...forma.gesti.map((g) => g.testo),
          ...forma.gesti.map((g) => g.viaTattile),
          ...forma.respiri.map((r) => r.testo),
          ...forma.parole.map((p) => '${p.parola} ${p.perche}'),
        ];
        for (final t in testi) {
          final basso = t.toLowerCase();
          for (final v in vietate) {
            expect(basso.contains(v), isFalse,
                reason: 'la forma "${forma.nome}" promette un esito con "$v": '
                    '«$t»');
          }
        }
      }
    });

    test('il pannello delle fonti separa l\'antico dal moderno', () {
      const fonti = RitoAlbaCorpus.fontiEMetodo;
      expect(fonti, contains('Antico'));
      expect(fonti, contains('Moderno, dichiarato come tale'));
      expect(fonti, contains('Patanjali'));
      expect(fonti, contains('Cosa non facciamo'));
    });
  });

  group('Il Maestro del rito e\' quello della rotazione', () {
    test('il rito porta il Maestro che dice DailyRituals, non un altro', () {
      for (var g = 0; g < 40; g++) {
        final giorno = DateTime(2026, 3, 1).add(Duration(days: g));
        expect(rito(giorno)!.maestro, DailyRituals.dawnMaestro(giorno),
            reason: 'il rito ha scelto un Maestro per conto suo');
      }
    });
  });
}
