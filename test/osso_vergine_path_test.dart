import 'package:esoteric_circle/core/rituals/runes.dart';
import 'package:esoteric_circle/features/rituals/sunset_rune_screen.dart';
import 'package:flutter_test/flutter_test.dart';

/// La convenzione di nome delle pietre vergini, cioe' l'osso senza segno che la
/// Runa del Tramonto mostra in attesa. I ventiquattro file non esistono ancora:
/// qui NON si verifica che ci siano, si blocca il nome che il codice va a
/// cercare. Se qualcuno tocca la convenzione, questo test diventa rosso.
void main() {
  test('I ventiquattro percorsi seguono la convenzione, senza doppia versione',
      () {
    // rune_bone_NN_nome_vergine_v1.webp, con NN da 01 a 24 nell'ordine Futhark.
    final atteso = RegExp(
        r'^assets/img/rune_bone_vergine/rune_bone_(\d{2})_([a-z]+)_vergine_v1\.webp$');
    expect(kElderFuthark.length, 24);
    for (var i = 0; i < kElderFuthark.length; i++) {
      final r = kElderFuthark[i];
      final path = pathVergineDi(r.stem);
      expect(path, isNotNull, reason: '${r.name} senza percorso');
      final m = atteso.firstMatch(path!);
      expect(m, isNotNull, reason: 'fuori convenzione: $path');
      // Il numero segue l'ordine del Futhark, da 01 a 24.
      expect(m!.group(1), (i + 1).toString().padLeft(2, '0'),
          reason: '${r.name} col numero sbagliato in $path');
      // Il nome coincide con quello dello stem, non con altro.
      final nomeStem = r.stem!.split('_')[3];
      expect(m.group(2), nomeStem, reason: '${r.name} col nome sbagliato');
      // E soprattutto: mai due versioni in coda.
      expect(path.contains('_v1_vergine'), isFalse,
          reason: 'doppia versione in $path');
    }
  });

  test('Alcuni percorsi attesi, per esteso', () {
    expect(pathVergineDi('rune_bone_01_fehu_v1'),
        'assets/img/rune_bone_vergine/rune_bone_01_fehu_vergine_v1.webp');
    expect(pathVergineDi('rune_bone_24_othala_v1'),
        'assets/img/rune_bone_vergine/rune_bone_24_othala_vergine_v1.webp');
    // Uno stem senza suffisso di versione resta intero.
    expect(pathVergineDi('rune_bone_09_hagalaz'),
        'assets/img/rune_bone_vergine/rune_bone_09_hagalaz_vergine_v1.webp');
    // Nessuna arte, nessun percorso.
    expect(pathVergineDi(null), isNull);
  });
}
