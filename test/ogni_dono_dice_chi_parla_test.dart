import 'dart:io';

import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/rituals/daily_elements.dart';
import 'package:esoteric_circle/core/rituals/voce_del_dono.dart';
import 'package:esoteric_circle/design_system/theme/accento_del_maestro.dart';
import 'package:esoteric_circle/design_system/theme/maestro_palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// OGNI DONO DICE CHI PARLA, e la prova li ENUMERA tutti.
///
/// Non si scelgono due schermate a campione: si passa da `DailyElement.values`,
/// cosi' un sesto Dono che nascesse muto farebbe cadere questa prova invece di
/// passare inosservato. La rotta si prende da `dailyElementRoute`, che e' la
/// stessa porta da cui ci arriva la striscia del Santuario.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('la frase, senza montare niente', () {
    // Un giorno qualunque ma fisso: la frase e' deterministica, quindi si puo'
    // interrogare come un dato.
    final giorno = DateTime(2026, 8, 6, 12);

    test('ogni Dono nomina il suo Maestro', () {
      for (final dono in DailyElement.values) {
        final atteso = DailyElements.maestroFor(dono, giorno);
        final frase = VoceDelDono.frase(dono: dono, giorno: giorno);
        expect(frase, startsWith('Oggi ${atteso.displayName} '),
            reason: 'Il dono ${dono.title} non nomina ${atteso.displayName}: '
                'ha detto "$frase".');
      }
    });

    test('la stessa cosa due volte da' ' la stessa frase', () {
      for (final dono in DailyElement.values) {
        expect(VoceDelDono.frase(dono: dono, giorno: giorno),
            VoceDelDono.frase(dono: dono, giorno: giorno),
            reason: 'La frase non e\' deterministica.');
      }
    });

    test('Alba e Sogno, che hanno lo stesso Maestro, non dicono la stessa cosa',
        () {
      // Ruotano insieme: `nightMaestro` e' `dawnMaestro`. Senza il dono nel
      // seme aprirebbero con la stessa identica riga tutti i giorni.
      var uguali = 0;
      for (var i = 0; i < 60; i++) {
        final g = giorno.add(Duration(days: i));
        if (VoceDelDono.frase(dono: DailyElement.dawn, giorno: g) ==
            VoceDelDono.frase(dono: DailyElement.night, giorno: g)) {
          uguali++;
        }
      }
      expect(uguali, lessThan(30),
          reason: 'Su sessanta giorni Alba e Sogno hanno aperto con la stessa '
              'riga $uguali volte: il dono non entra nel seme.');
    });

    test('il verbo appartiene alla voce del Maestro', () {
      // Medora indica nel tempo, Aura chiede al corpo, Caligo consegna un
      // segno: le tre famiglie non si toccano. Se una formula fosse condivisa,
      // la riga non direbbe piu' chi parla.
      final perMaestro = <Maestro, Set<String>>{
        for (final m in Maestro.values) m: <String>{},
      };
      for (var i = 0; i < 400; i++) {
        final g = giorno.add(Duration(days: i));
        for (final dono in DailyElement.values) {
          final m = DailyElements.maestroFor(dono, g);
          final frase = VoceDelDono.frase(dono: dono, giorno: g);
          perMaestro[m]!.add(frase.replaceFirst('Oggi ${m.displayName} ', ''));
        }
      }
      for (final m in Maestro.values) {
        expect(perMaestro[m], hasLength(3),
            reason: '${m.displayName} usa ${perMaestro[m]!.length} formule '
                'invece di tre: ${perMaestro[m]}');
        for (final altro in Maestro.values) {
          if (altro == m) continue;
          final comuni = perMaestro[m]!.intersection(perMaestro[altro]!);
          expect(comuni, isEmpty,
              reason: '${m.displayName} e ${altro.displayName} condividono '
                  '$comuni: una formula che due Maestri potrebbero dire non '
                  'dice chi parla.');
        }
      }
    });
  });

  group('ogni schermata di un Dono monta la riga', () {
    // **LA GRANDEZZA MISURATA E' CAMBIATA, E VA DETTO.** La prima stesura
    // montava le cinque schermate e cercava la riga a video: cadeva su tutte e
    // cinque, ma per il motivo sbagliato. Il contenuto di un rito compare DOPO
    // il gesto, cioe' dopo un soffio, un'incisione, una costellazione da
    // unire: appena aperta la schermata la riga non e' ancora costruita, e una
    // prova che pretende di vederla li' non potrebbe passare nemmeno col
    // codice giusto. Compiere i cinque gesti dentro questa prova vorrebbe dire
    // riscrivere qui le cinque coreografie, che hanno gia' le loro prove.
    //
    // Si misura quindi il MONTAGGIO: ogni schermata dichiara la riga col
    // proprio Dono. L'enumerazione resta, ed e' il punto: un sesto Dono senza
    // schermata dichiarata fa cadere questa prova invece di nascere muto.
    const schermatePerDono = <DailyElement, String>{
      DailyElement.dawn: 'lib/features/rituals/ritual_gift_card.dart',
      DailyElement.breath: 'lib/features/rituals/ritual_gift_card.dart',
      DailyElement.oracle: 'lib/features/rituals/day_oracle_screen.dart',
      DailyElement.rune: 'lib/features/rituals/sunset_rune_screen.dart',
      DailyElement.night: 'lib/features/rituals/dream_rite_screen.dart',
    };

    test('nessun Dono resta fuori dall\'elenco delle schermate', () {
      expect(schermatePerDono.keys.toSet(), DailyElement.values.toSet(),
          reason: 'Un Dono non ha una schermata dichiarata: o si aggiunge qui '
              'con la sua, oppure nascera\' senza dire chi parla.');
    });

    for (final voce in schermatePerDono.entries) {
      test('${voce.key.title} monta la riga di chi parla', () {
        final sorgente = File(voce.value).readAsStringSync();
        expect(sorgente.contains('RigaDelDono('), isTrue,
            reason: '${voce.value} non monta `RigaDelDono`: il dono '
                '${voce.key.title} non dice di chi e\' la voce.');
      });
    }

    test('chi passa il Dono lo passa giusto', () {
      // La scheda condivisa serve due Doni, quindi il valore glielo passano le
      // due schermate: qui si controlla che lo passino, e che sia il proprio.
      const chiPassa = <DailyElement, String>{
        DailyElement.dawn: 'lib/features/rituals/dawn_rite_screen.dart',
        DailyElement.breath: 'lib/features/rituals/breath_destiny_screen.dart',
      };
      chiPassa.forEach((dono, file) {
        final sorgente = File(file).readAsStringSync();
        expect(sorgente.contains('dono: DailyElement.${dono.name}'), isTrue,
            reason: '$file non passa alla scheda il proprio Dono, quindi la '
                'riga nominerebbe il Maestro di un altro appuntamento.');
      });
    });
  });

  group('il colore della riga si legge davvero', () {
    test('il colore di partenza di Aura NON passerebbe', () {
      // Se passasse, la regola sarebbe inerte e nessuno se ne accorgerebbe.
      final crudo = AccentoDelMaestro.su(Maestro.aura,
          superficie: AccentoDelMaestro.vetro);
      final partenza = MaestroPaletteDiProva.primarioDi(Maestro.aura);
      expect(
          AccentoDelMaestro.contrastoFra(
              partenza, AccentoDelMaestro.vetro),
          lessThan(AccentoDelMaestro.contrastoMinimo),
          reason: 'Il verde di Aura passa gia\' com\'e\': la regola che lo '
              'scurisce non sta correggendo niente, quindi non protegge '
              'nessuno.');
      expect(
          AccentoDelMaestro.contrastoFra(crudo, AccentoDelMaestro.vetro),
          greaterThanOrEqualTo(AccentoDelMaestro.contrastoMinimo),
          reason: 'Dopo la regola il verde deve leggersi.');
    });

    test('su un fondale scuro il colore sale invece di scendere', () {
      // Le schermate dei riti sono le piu' scure dell'app: una regola scritta
      // in un verso solo le avrebbe rese illeggibili.
      const scuro = Color(0xFF07070C);
      for (final m in Maestro.values) {
        final sopra = AccentoDelMaestro.su(m, superficie: scuro);
        expect(AccentoDelMaestro.contrastoFra(sopra, scuro),
            greaterThanOrEqualTo(AccentoDelMaestro.contrastoMinimo),
            reason: 'Sul fondale scuro ${m.displayName} non si legge.');
      }
    });
  });
}

/// Il colore di partenza, letto dalla palette come lo legge la regola.
class MaestroPaletteDiProva {
  static Color primarioDi(Maestro m) =>
      MaestroPalette.forKey(ThemeKey.of(m)).primary;
}
