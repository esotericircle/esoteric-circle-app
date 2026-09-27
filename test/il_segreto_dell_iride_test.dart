// ignore_for_file: avoid_print
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:esoteric_circle/core/arts/art_catalog.dart';
import 'package:esoteric_circle/core/arts/arti_preferite.dart';
import 'package:esoteric_circle/core/arts/gli_sfondi_delle_schede.dart';
import 'package:esoteric_circle/core/arts/l_ordine_dei_domini.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/features/santuario/le_righe_della_casa.dart';
import 'package:flutter_test/flutter_test.dart';

/// **IL SEGRETO DELL'IRIDE.** Ordine ER voce 20, "ER Aggiunta", 27 settembre
/// 2026.
///
/// Parole del fondatore: *"Ci siamo dimenticati di creare asset per
/// scansione occhio e inserirlo in home"*; la lettura dell'iride e' di Aura,
/// in Fase 2, fuori dalla Demo.
///
/// **Le grandezze misurate**: i tre sfondi, fissati con lo sha1 dei file del
/// fondatore; l'arte nel catalogo, nel dominio di Aura dopo lo Specchio
/// dell'Anima e nelle righe della home; le arti del catalogo visibili in
/// home; e nelle tre righe toccate le coppie di schede vicine dello stesso
/// Maestro, che devono essere zero.
void main() {
  /// Lo sha1 dei tre webp della cartella del fondatore, letti il 27
  /// settembre 2026 (docs/collaudo/ER/iride_sfondi.txt).
  const sha1DelFondatore = {
    'Vert': '0974589405cc8d84d21c5e64d5a814fa42979234',
    'Square': 'ef9a3b3bc9d92f6f20be8db5be3aa13e32763381',
    'Oriz': '156af3f83823291edca11e2b7efbbfe18e0f9f3b',
  };

  test('ER.20: i tre sfondi sono quelli del fondatore, byte per byte', () {
    var uguali = 0;
    for (final f in FormatoDellaScheda.values) {
      final percorso = GliSfondiDelleSchede.perArte('segreto_iride', f);
      expect(percorso, isNotNull,
          reason: 'l\'Iride non ha lo sfondo ${f.name}');
      final sha = sha1.convert(File(percorso!).readAsBytesSync()).toString();
      if (sha == sha1DelFondatore[f.nelNome]) uguali++;
    }
    print('ORDINE ER VOCE 20: webp uguali a quelli del fondatore $uguali su 3');
    expect(uguali, 3);
  });

  test('ER.20: l\'arte nel catalogo e nel dominio di Aura', () {
    final iride = ArtCatalog.all.firstWhere((a) => a.id == 'segreto_iride');
    expect(iride.title, 'Il Segreto dell\'Iride');
    expect(iride.teaser, 'La tua iride, letta come una mappa di segni.');
    expect(iride.state, ArtState.inArrivo);
    expect(iride.phase, ArtPhase.fase2);
    final fisiognomica = LOrdineDeiDomini.di(Maestro.aura)
        .firstWhere((s) => s.titolo == 'Fisiognomica');
    final k = fisiognomica.arti.indexOf('segreto_iride');
    expect(k, greaterThan(0));
    expect(fisiognomica.arti[k - 1], 'specchio_anima',
        reason: 'nel dominio l\'Iride non sta dopo lo Specchio dell\'Anima');
    expect(
        ArtCatalog.forMaestro(Maestro.aura)
            .firstWhere((s) => s.title == 'Fisiognomica')
            .arts
            .map((a) => a.id),
        contains('segreto_iride'));
  });

  test(
      'ER.20: in home 67 arti, e nelle tre righe toccate nessuna coppia '
      'vicina dello stesso Maestro', () {
    final maestroDi = <String, Maestro>{
      for (final m in Maestro.values)
        for (final s in ArtCatalog.forMaestro(m))
          for (final a in s.arts) a.id: m,
    };
    final inCasa = {
      ...ArtiPreferiteController.semePer(null),
      for (final r in LeRigheDellaCasa.righe) ...r.arti,
    };
    final coppie = <String>[];
    for (final chiave in const [
      'il_tuo_corpo',
      'i_piu_condivisi',
      'la_tua_energia'
    ]) {
      final arti =
          LeRigheDellaCasa.righe.firstWhere((r) => r.chiave == chiave).arti;
      for (var k = 1; k < arti.length; k++) {
        if (maestroDi[arti[k]] == maestroDi[arti[k - 1]]) {
          coppie.add('$chiave: ${arti[k - 1]} e ${arti[k]}');
        }
      }
    }
    final righeConLIride = [
      for (final r in LeRigheDellaCasa.righe)
        if (r.arti.contains('segreto_iride')) r.chiave,
    ];
    print('ORDINE ER VOCE 20: arti del catalogo in home ${inCasa.length}; '
        'righe con l\'Iride $righeConLIride; coppie vicine dello stesso '
        'Maestro nelle tre righe ${coppie.length} $coppie');
    expect(inCasa.length, 67);
    expect(righeConLIride, ['i_piu_condivisi', 'il_tuo_corpo']);
    expect(coppie, isEmpty);
  });
}
