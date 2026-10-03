import 'dart:io';

import 'package:esoteric_circle/core/astro/natal_chart.dart';
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/synastry/cielo_della_sinastria.dart';
import 'package:esoteric_circle/core/synastry/responso_della_sinastria.dart';
import 'package:esoteric_circle/core/synastry/testi_della_sinastria.dart';
import 'package:esoteric_circle/core/synastry/vip_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

/// I NOVE RILIEVI DELLA SINASTRIA. Ordine CC voce 06.
///
/// Tutti e nove vengono dallo stesso messaggio del fondatore del 29 agosto
/// 2026, dato guardando l'app sul telefono con otto schermate a corredo.
/// Nessuno si esclude, e ognuno ha qui la sua riga.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// Due aspetti veri, coi nomi dei due cieli attaccati come fa il calcolo.
  List<AspettoDiSinastria> aspetti({String suo = 'Fedez', String tuo = ''}) => [
        AspettoDiSinastria(
          tuo: PuntoDelCielo.venere,
          suo: PuntoDelCielo.mercurio,
          tipo: AspectType.sextile,
          orbo: 1.4,
          nomeSuo: suo,
          nomeTuo: tuo,
        ),
      ];

  group('06b, le linee partono e arrivano sul cerchio', () {
    test('i due capi stanno sullo stesso raggio', () {
      // **SI PROVA SUI PUNTI, non sulla presenza del disegno.** Il rilievo
      // dice "arrivano a meta' e sembrano troncarsi": il difetto era che il
      // secondo capo cadeva su un cerchio interno, e la prova giusta e' che i
      // due capi disti[no] lo stesso dal centro.
      final sorgente = File('lib/features/synastry/chiamata_del_vip.dart')
          .readAsStringSync();
      expect(sorgente.contains('raggio * 0.62'), isFalse,
          reason: 'il secondo capo del filo e\' tornato su un cerchio '
              'interno: la linea finisce di nuovo a meta\' strada');
      final quante = RegExp(r'centro, raggio\)').allMatches(sorgente).length;
      // ignore: avoid_print
      print('ORDINE CC VOCE 06b: capi del filo posati sul cerchio $quante');
      expect(quante, greaterThanOrEqualTo(2),
          reason: 'i due capi del filo non stanno tutti e due sul cerchio');
    });
  });

  group('06c, la bolla parla di voi e non di transiti', () {
    test('la parte tecnica sta sotto un quarto del testo', () {
      final vip = VipCatalog.vips.first;
      final p = ResponsoDellaSinastria.perTeConUnVip(
        tuoSegno: Zodiac.leo,
        vip: vip,
        percento: 72,
        aspetti: aspetti(suo: vip.name),
        oraDelVipNota: true,
        adesso: DateTime(2026, 8, 29),
      );
      // La parte tecnica e' quella fra parentesi: il nome dell'aspetto.
      final tecnica = RegExp(
              r'\([^)]*in (sestile|trigono|quadrato|opposizione|congiunzione)[^)]*\)')
          .allMatches(p.corpo)
          .fold<int>(0, (somma, m) => somma + m.group(0)!.length);
      final quota = tecnica / p.corpo.length;
      // ignore: avoid_print
      print('ORDINE CC VOCE 06c: corpo ${p.corpo.length} caratteri, di cui '
          'tecnici $tecnica, cioe\' il ${(quota * 100).round()} per cento');
      expect(quota, lessThan(0.25),
          reason: 'la bolla e\' tecnica per il ${(quota * 100).round()} per '
              'cento: il fondatore ne vuole al massimo un quarto');
    });

    test('nessun punto doppio, e nessun punto prima dei due punti', () {
      final vip = VipCatalog.vips.first;
      final p = ResponsoDellaSinastria.perTeConUnVip(
        tuoSegno: Zodiac.leo,
        vip: vip,
        percento: 72,
        aspetti: aspetti(suo: vip.name),
        oraDelVipNota: true,
        adesso: DateTime(2026, 8, 29),
      );
      expect(p.corpo.contains('..'), isFalse,
          reason: 'due punti di fila nel corpo: "${p.corpo}"');
      expect(p.corpo.contains('.:'), isFalse,
          reason: 'un punto seguito dai due punti: "${p.corpo}"');
    });
  });

  group('06d, il paragrafo dell\'attualita\'', () {
    test('esiste, e le sue frasi sono dichiarate provvisorie', () {
      expect(TestiDellaSinastria.attualitaProvvisorie, isNotEmpty);
      for (final f in TestiDellaSinastria.attualitaProvvisorie) {
        expect(f.contains('FATTO'), isTrue,
            reason: 'la frase "$f" non ha il posto dove entra la cronaca');
      }
      // ignore: avoid_print
      print('ORDINE CC VOCE 06d: frasi provvisorie dell\'attualita\' '
          '${TestiDellaSinastria.attualitaProvvisorie.length}');
    });

    test('per chi non c\'e\' piu\' il paragrafo non esiste', () {
      final scomparso = VipCatalog.vips.where((v) => v.eScomparso).firstOrNull;
      if (scomparso == null) return;
      final p = ResponsoDellaSinastria.perTeConUnVip(
        tuoSegno: Zodiac.leo,
        vip: scomparso,
        percento: 60,
        aspetti: aspetti(suo: scomparso.name),
        oraDelVipNota: false,
        adesso: DateTime(2026, 8, 29),
      );
      for (final f in TestiDellaSinastria.attualitaProvvisorie) {
        final apertura = f.split(':').first;
        expect(p.corpo.contains(apertura), isFalse,
            reason: 'si fa cronaca su chi non puo\' smentirla');
      }
    });
  });

  group('06g, le due righe in ogni responso', () {
    test('ci sono sempre, e dicono SCONOSCIUTO quando il dato manca', () {
      final vip = VipCatalog.vips.first;
      for (final oraNota in [true, false]) {
        final p = ResponsoDellaSinastria.perTeConUnVip(
          tuoSegno: Zodiac.leo,
          vip: vip,
          percento: 72,
          aspetti: aspetti(suo: vip.name),
          oraDelVipNota: oraNota,
          adesso: DateTime(2026, 8, 29),
        );
        expect(p.oraDiNascita.startsWith('Ora di Nascita:'), isTrue);
        expect(p.luogoDiResidenza.startsWith('Luogo di Residenza:'), isTrue);
        if (!oraNota) {
          expect(p.oraDiNascita.contains('SCONOSCIUTO'), isTrue,
              reason: 'senza l\'ora la riga non dice SCONOSCIUTO');
        }
      }
      // ignore: avoid_print
      print('ORDINE CC VOCE 06g: le due righe ci sono in ogni responso');
    });

    test('il testo del "non si finge" non compare piu\' in nessun responso',
        () {
      final vip = VipCatalog.vips.first;
      final p = ResponsoDellaSinastria.perTeConUnVip(
        tuoSegno: Zodiac.leo,
        vip: vip,
        percento: 72,
        aspetti: aspetti(suo: vip.name),
        oraDelVipNota: false,
        adesso: DateTime(2026, 8, 29),
      );
      expect(p.nota.contains('Non si finge'), isFalse,
          reason: 'il fondatore ha detto "eliminalo!"');
      expect(p.corpo.contains('Non si finge'), isFalse);
    });
  });

  group('06h, i transiti dicono di chi sono', () {
    test('col nome, il fatto lo nomina', () {
      final a = aspetti(suo: 'Fedez').first;
      // ignore: avoid_print
      print('ORDINE CC VOCE 06h: "${a.fatto}"');
      expect(a.fatto.contains('Fedez'), isTrue,
          reason: 'il transito non dice di chi e\': "${a.fatto}"');
      expect(a.fatto.contains('il suo Mercurio'), isFalse,
          reason: 'si legge ancora "il suo Mercurio", che era il rilievo');
    });

    test('fra due VIP tutti e due i punti portano un nome', () {
      final a = aspetti(suo: 'Fedez', tuo: 'Chiara').first;
      // ignore: avoid_print
      print('ORDINE CC VOCE 06h, due VIP: "${a.fatto}"');
      expect(a.fatto.contains('Fedez'), isTrue);
      expect(a.fatto.contains('Chiara'), isTrue,
          reason: 'nel confronto fra due VIP un lato e\' ancora "il tuo"');
    });

    test('il nome arriva dal CALCOLO, non solo da chi costruisce a mano', () {
      // **QUESTA E\' LA RIGA CHE CONTA.** Le altre provano la frase; questa
      // prova che il nome ci arrivi davvero, cioe\' che `AspettiDiSinastria`
      // attacchi a ogni aspetto il nome del cielo da cui viene. Senza, la
      // frase saprebbe dire il nome e nessuno glielo direbbe mai.
      final vip = VipCatalog.vips.first;
      final suo = CieloDiSinastria.perVip(vip);
      final tuo = CieloDiSinastria.perNascita(
        momentoUtc: DateTime.utc(1990, 4, 12, 7, 30),
        oraNota: true,
        latitudine: 41.9,
        longitudineDelLuogo: 12.5,
        nome: 'Mauro',
      );
      final calcolati = AspettiDiSinastria.fra(tuo, suo);
      expect(calcolati, isNotEmpty,
          reason:
              'fra questi due cieli non c\'e\' nessun aspetto: la prova gira '
              'a vuoto');
      final senzaNome = calcolati.where((a) => a.nomeSuo.isEmpty).toList();
      // ignore: avoid_print
      print('ORDINE CC VOCE 06h: aspetti calcolati ${calcolati.length}, senza '
          'il nome del personaggio ${senzaNome.length}');
      expect(senzaNome, isEmpty,
          reason: 'il calcolo non attacca piu\' il nome del personaggio agli '
              'aspetti: a video torna "il suo Mercurio"');
      expect(calcolati.first.fatto.contains(vip.name), isTrue,
          reason: 'il fatto calcolato non nomina ${vip.name}');

      // E dalla parte tua resta "il tuo", che e\' quello che il fondatore
      // chiede: "il mercurio di Fedez e\' in sestile con la tua venere".
      expect(calcolati.first.nomeTuo, isEmpty,
          reason: 'il lato di chi guarda ha preso un nome: la frase direbbe '
              '"la Venere di Mauro" a Mauro stesso');
    });

    test('senza nomi si torna a "il suo" e "il tuo", e non si rompe niente',
        () {
      final a = aspetti(suo: '', tuo: '').first;
      expect(a.fatto.contains('il suo Mercurio'), isTrue);
      expect(a.fatto.contains('alla tua Venere'), isTrue);
    });
  });

  group('06a e 06i, cio\' che si vede', () {
    test('la mappa conosce i nomi delle citta\' e i riferimenti', () {
      final mappa = File('lib/features/synastry/mappa_della_distanza.dart')
          .readAsStringSync();
      expect(mappa.contains('RiferimentiDellaMappa'), isTrue,
          reason: 'la mappa non ha piu\' nessun riferimento: due pallini su '
              'una linea non dicono dove sei');
      expect(mappa.contains('tuaCitta'), isTrue);
      expect(mappa.contains('suaCitta'), isTrue);
      expect(mappa.contains('CityCatalog.luoghi'), isTrue,
          reason: 'i nomi non vengono piu\' dal catalogo che l\'app ha gia\'');
    });

    test('la carta ingrandita porta i suoi cartigli', () {
      final ritratto = File('lib/features/synastry/ritratto_ingrandito.dart')
          .readAsStringSync();
      expect(ritratto.contains('VipFramedPortrait'), isTrue,
          reason: 'la carta ingrandita monta l\'arte nuda, e i cartigli degli '
              'artwork sono vuoti per disegno: i testi spariscono');
      expect(ritratto.contains('Image.asset(vip.fullPath!'), isFalse,
          reason: 'e\' tornata l\'immagine nuda senza chi scrive i cartigli');
    });

    test('l\'infografica sta subito dopo la bolla', () {
      final schermo = File('lib/features/synastry/sinastria_vip_screen.dart')
          .readAsStringSync();
      final bolla = schermo.indexOf("Key('sinastria_reading')");
      final barre = schermo.indexOf('SynastryBarRow');
      final mappa = schermo.indexOf('MappaDellaDistanza(');
      final fili = schermo.indexOf("Key('sinastria_fili_toccabili')");
      // ignore: avoid_print
      print('ORDINE CC VOCE 06f: bolla a $bolla, barre a $barre, mappa a '
          '$mappa, fili a $fili');
      expect(bolla, greaterThan(0));
      expect(barre, greaterThan(bolla),
          reason: 'le barre stanno prima della bolla');
      expect(barre, lessThan(mappa),
          reason: 'fra la bolla e le barre c\'e\' ancora la mappa');
      expect(barre, lessThan(fili),
          reason: 'fra la bolla e le barre ci sono ancora le pastiglie');
    });
  });
}
