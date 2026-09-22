// ignore_for_file: avoid_print
import 'dart:io';

import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/rituals/dream_rite_corpus.dart';
import 'package:esoteric_circle/core/rituals/rito_alba.dart';
import 'package:esoteric_circle/core/rituals/sunset_rune.dart';
import 'package:esoteric_circle/core/rituals/sunset_rune_corpus.dart';
import 'package:flutter_test/flutter_test.dart';

/// **NESSUN DONO DEL GIORNO RIPETE LA GIORNATA PRIMA.** Ordine EH voce 03, 24
/// settembre 2026.
///
/// ## PERCHE' ESISTE: UN DIFETTO SI CERCA DOVE PUO' ESSERE, NON DOVE E' STATO
/// TROVATO
///
/// Il fondatore ha trovato il Sigillo del Sogno identico a due sere di
/// distanza. La voce EH.01 l'ha curato. **Ma la domanda giusta non e' "e'
/// curato?", e' "gli altri Doni hanno lo stesso difetto?"**: nascono tutti
/// dallo stesso cielo, con la stessa forma, e chi ha scritto l'uno ha scritto
/// gli altri.
///
/// **Misurati tutti e tre, la stessa grandezza: quante cose diverse dicono a
/// una stessa persona in sette giorni di fila.**
///
/// | Dono | prima della cura | dopo |
/// |---|---|---|
/// | Sigillo del Sogno | due notti identiche parola per parola, e **un solo**
/// modo di dire la giornata su sette | sette saluti distinti, tre modi |
/// | Runa del Tramonto | **sette su sette**, gia' sano | invariato |
/// | Arcano dell'Alba | **sette su sette**, gia' sano | invariato |
///
/// **E una misura sbagliata ha quasi accusato l'Alba.** La prima stesura di
/// questa prova confrontava `r.toString()`: un oggetto senza `toString`
/// proprio rende sempre la stessa stringa, quindi la misura diceva **"un rito
/// distinto su sette"** su qualunque codice, sano o malato. Il difetto era
/// nella prova, non nel Dono. Si misurano **i campi**, non l'oggetto.
void main() {
  const giorni = 7;
  final nascita = DateTime(1988, 7, 5, 14, 30);
  final rapporto = StringBuffer()
    ..writeln('I TRE DONI DEL GIORNO, SETTE GIORNI DI FILA, STESSA PERSONA')
    ..writeln('Ordine EH voce 03, nascita 5 luglio 1988.')
    ..writeln();

  /// **TUTTI DIVERSI, E LA PRIMA SOGLIA CHE AVEVO SCELTO ERA SBAGLIATA.**
  ///
  /// La prima stesura chiedeva **cinque su sette**, col ragionamento che la
  /// Luna resta in un segno due giorni e mezzo e pretendere sette valori
  /// distinti sarebbe stato pretendere che il cielo corresse. Poi la prova del
  /// rosso ha detto un'altra cosa: **rimesso il difetto vero, il Sigillo del
  /// Sogno rendeva cinque su sette e questa guardia restava verde.**
  ///
  /// **La soglia non si abbassa per far passare, ma qui andava alzata**, e non
  /// per far cadere: andava allineata alla richiesta del fondatore, che non e'
  /// *"abbastanza varieta'"* ma *"non deve essere uguale a ieri"*. Due giorni
  /// di fila diversi vuol dire, su sette giorni, sette testi distinti.
  ///
  /// **E si puo' pretendere perche' il codice lo sa fare**: il cielo si muove
  /// piano, ma la scelta di quale cosa vera dire cambia ogni notte. Misurati
  /// oggi: Sogno sette su sette, Tramonto sette su sette, Alba sette su sette.
  const minimoDistinti = giorni;

  test('il Sigillo del Sogno dice sette cose diverse in sette notti', () {
    final saluti = <String>{};
    for (var g = 0; g < giorni; g++) {
      saluti.add(DreamRiteCorpus.saluto(DateTime(2026, 9, 23 + g, 22, 47),
          nascita: nascita));
    }
    rapporto.writeln(
        'Sigillo del Sogno: ${saluti.length} saluti distinti su $giorni');
    print('ORDINE EH VOCE 03, SOGNO: ${saluti.length}/$giorni distinti');
    expect(saluti.length, greaterThanOrEqualTo(minimoDistinti));
  });

  test('la Runa del Tramonto non ripete la sera prima', () {
    final voci = <String>{};
    for (var g = 0; g < giorni; g++) {
      final e = SunsetRune.estrai(DateTime(2026, 9, 23 + g, 20),
          identita: '1988-07-05');
      voci.add('${e.rune.name}|${SunsetRuneCorpus.vocePrimaLasciare(e)}');
    }
    rapporto
        .writeln('Runa del Tramonto: ${voci.length} voci distinte su $giorni');
    print('ORDINE EH VOCE 03, TRAMONTO: ${voci.length}/$giorni distinti');
    expect(voci.length, greaterThanOrEqualTo(minimoDistinti));
  });

  test('l Arcano dell Alba non ripete la mattina prima', () {
    final riti = <String>{};
    for (var g = 0; g < giorni; g++) {
      final r = RitoAlba.diOggi(DateTime(2026, 9, 23 + g, 8),
          soleNatale: Zodiac.cancer, nascita: nascita);
      if (r == null) continue;
      // **I CAMPI, NON L'OGGETTO**: vedi la lapide in cima al file.
      riti.add('${r.maestro.id}|${r.forma}|${r.gesto}');
    }
    rapporto
        .writeln('Arcano dell Alba: ${riti.length} riti distinti su $giorni');
    print('ORDINE EH VOCE 03, ALBA: ${riti.length}/$giorni distinti');
    expect(riti.length, greaterThanOrEqualTo(minimoDistinti));
  });

  tearDownAll(() {
    final cartella = Directory('docs/collaudo/EH')..createSync(recursive: true);
    File('${cartella.path}/i_tre_doni.txt')
        .writeAsStringSync(rapporto.toString());
  });
}
