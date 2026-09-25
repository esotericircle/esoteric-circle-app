import 'dart:io';
import 'dart:typed_data';

import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/features/maestri/live/le_frasi_della_persona.dart';
import 'package:esoteric_circle/services/voce/l_orecchio_del_live.dart';
import 'package:flutter_test/flutter_test.dart';

/// **LA RISPOSTA ARRIVA PRIMA, E AURA SI SCRIVE GIUSTA.** Ordine EM voci 01,
/// 04 e 11, 25 settembre 2026.
void main() {
  final schermata =
      File('lib/features/maestri/live/schermata_live.dart').readAsStringSync();
  String corpoDi(String firma) {
    final inizio = schermata.indexOf(firma);
    expect(inizio, greaterThanOrEqualTo(0), reason: '$firma non c\'e\' piu\'');
    return schermata.substring(inizio, schermata.indexOf('\n  }\n', inizio));
  }

  group('ORDINE EM VOCE 11, LA TRASCRIZIONE ANTICIPATA', () {
    test(
        'L\'ANTEPRIMA E\' TUTTO CIO\' CHE LA PERSONA HA DETTO, E NON CHIUDE '
        'NIENTE', () {
      final f = LeFrasiDellaPersona();
      f.chiusa(Uint8List.fromList([1, 2]));
      final giro = f.giro;
      final anteprima = f.anteprima(Uint8List.fromList([3, 4]));
      expect(anteprima, [1, 2, 3, 4]);
      expect(f.pezziInAttesa, 1);
      expect(f.giro, giro);
    });

    test(
        'LA SCHERMATA TRASCRIVE IN PAUSA, E USA QUELLA TRASCRIZIONE SOLO SE '
        'LA FRASE SI CHIUDE CON LA STESSA PAUSA', () {
      expect(
          corpoDi('Future<void> _ascoltaLaPersona()')
              .contains('_orecchio.suPausa = _inPausa;'),
          isTrue,
          reason: 'nessuno comincia a trascrivere quando la frase va in pausa');
      expect(
          corpoDi('void _inPausa(').contains('_frasi.anteprima(pcm)'), isTrue,
          reason: 'in pausa si trascrive solo l\'ultimo pezzo');
      final frase = corpoDi('Future<void> _unaFrase(');
      for (final condizione in [
        'anticipata.pausa == pausa',
        'anticipata.giro == giroPrima',
        'pausa >= 0',
      ]) {
        expect(frase.contains(condizione), isTrue,
            reason: 'la trascrizione anticipata vale anche quando la persona '
                'ha ripreso a parlare: manca "$condizione"');
      }
    });

    test('L\'ATTESA SI SCRIVE NEL REGISTRO, FINO AL VOLTO CHE PARLA', () {
      expect(schermata.contains('LIVE ATTESA dalla fine del parlato'), isTrue);
      expect(schermata.contains('ActiveSpeakersChangedEvent'), isTrue,
          reason: 'l\'attesa non arriva fino al volto che parla davvero');
      for (final tappa in [
        'frase chiusa',
        'trascritta',
        'risposta',
        'primo audio al volto',
        'il volto parla',
      ]) {
        expect(schermata.contains("'$tappa'"), isTrue,
            reason: 'manca la tappa "$tappa"');
      }
    });
  });

  group('ORDINE EM VOCE 01, NEL LIVE DI AURA "LAURA" E\' AURA', () {
    test('LAURA DIVENTA AURA SOLO NEL LIVE DI AURA', () {
      expect(
          LaTrascrizione.nelLiveDi(
              Maestro.aura, 'Laura, sento un blocco ad Anahata.'),
          'Aura, sento un blocco ad Anahata.');
      expect(
          LaTrascrizione.nelLiveDi(
              Maestro.medora, 'Laura, sento un blocco ad Anahata.'),
          'Laura, sento un blocco ad Anahata.');
      expect(
          LaTrascrizione.nelLiveDi(
              Maestro.caligo, 'Laura mi ha regalato le rune.'),
          'Laura mi ha regalato le rune.');
      // Una parola che contiene Laura non si tocca.
      expect(LaTrascrizione.nelLiveDi(Maestro.aura, 'Lauranna e l\'aura.'),
          'Lauranna e l\'aura.');
    });

    test('LA SCHERMATA APPLICA LA REGOLA A OGNI FRASE TRASCRITTA', () {
      expect(
          corpoDi('Future<String> _trascrivi(')
              .contains('LaTrascrizione.nelLiveDi(widget.maestro, detto)'),
          isTrue);
    });
  });

  test('ORDINE EM VOCE 04: CHI TRASCRIVE IGNORA LE VOCI DI SOTTOFONDO', () {
    expect(LaTrascrizione.istruzione, contains(LaTrascrizione.sottofondo));
    expect(LaTrascrizione.sottofondo, contains('televisione'));
    expect(LaTrascrizione.sottofondo, contains(LaTrascrizione.silenzio));
  });
}
