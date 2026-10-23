// ignore_for_file: avoid_print
import 'dart:io';

import 'package:esoteric_circle/core/arts/art_catalog.dart';
import 'package:esoteric_circle/core/arts/gli_sfondi_delle_schede.dart';
import 'package:esoteric_circle/design_system/tokens/typography_tokens.dart';
import 'package:esoteric_circle/design_system/typography/il_titolo_col_trattino.dart';
import 'package:esoteric_circle/features/santuario/le_righe_della_casa.dart';
import 'package:esoteric_circle/features/schede/la_riga_delle_schede.dart';
import 'package:esoteric_circle/features/schede/la_scheda_dell_arte.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// **LE SCHEDE DELLA HOME E I LORO TITOLI.** Ordine ER voci 09 e 03, 27
/// settembre 2026.
///
/// ER.09, parole del fondatore: *"nelle righe con schede verticali e
/// quadrate, ci stanno esattamente 2 schede e non da continuità [...]
/// Diminuisci ulteriormente quelle orizzontali del 10% e aumenta verticali e
/// quadrate fino a 2 arti e mezzo"*, e sull'anteprima *"La home mi convince
/// adesso."*
///
/// ER.03: *"Viaggiò dello sciamano deve tornare ad essere scritto come gli
/// altri."*
///
/// **Le grandezze misurate**: la larghezza delle schede in home e nei domini;
/// quante schede si vedono a 360 punti; e per ognuna delle 66 arti della home
/// nei tre formati il titolo composto, dipinto col Cinzel vero: quante righe,
/// e se una riga esce dalla scheda.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('ER.09: le misure delle schede, in home e nei domini', () {
    final v = LaSchedaDellArte.larghezzaPer(FormatoDellaScheda.verticale,
        inCasa: true);
    final q = LaSchedaDellArte.larghezzaPer(FormatoDellaScheda.quadrata,
        inCasa: true);
    final o = LaSchedaDellArte.larghezzaPer(FormatoDellaScheda.orizzontale,
        inCasa: true);
    final altezze = [
      v / FormatoDellaScheda.verticale.proporzione,
      q / FormatoDellaScheda.quadrata.proporzione,
      o / FormatoDellaScheda.orizzontale.proporzione,
    ];
    final dominio = [
      LaSchedaDellArte.larghezzaPer(FormatoDellaScheda.verticale),
      LaSchedaDellArte.larghezzaPer(FormatoDellaScheda.quadrata),
      LaSchedaDellArte.larghezzaPer(FormatoDellaScheda.orizzontale),
    ];
    // A 360 punti: margine 16, spazio 12. Quanto della terza scheda si vede.
    const vista = 360.0;
    final terza = (vista -
            LaRigaDelleSchede.margineInCasa -
            2 * (v + LaRigaDelleSchede.spazioInCasa)) /
        v;
    print('ORDINE ER VOCE 9: in home verticale ${v.round()}x'
        '${altezze[0].round()}, quadrata ${q.round()}x${altezze[1].round()}, '
        'orizzontale ${o.round()}x${altezze[2].round()}; nei domini '
        '${dominio.map((d) => d.round()).toList()}; a 360 punti si vedono '
        '2 schede verticali intere e ${(terza * 100).round()} per cento '
        'della terza');
    expect([v, altezze[0]], [128, 160]);
    expect([q, altezze[1]], [128, 128]);
    expect(o, 137);
    expect(altezze[2].round(), 77);
    expect(dominio, [184, 184, 288],
        reason: 'nei domini le schede devono restare come sono');
    expect(LaRigaDelleSchede.margineInCasa, 16);
    expect(LaRigaDelleSchede.spazioInCasa, 12);
    expect(terza, inInclusiveRange(0.35, 0.65),
        reason: 'a 360 punti non si vedono due schede e mezza');
  });

  test(
      'ER.09: il titolo della home e\' a dodici punti, nel carattere dei '
      'titoli; nei domini resta a sedici', () {
    final casa = LaSchedaDellArte.stileDelTitolo(inCasa: true);
    final dominio = LaSchedaDellArte.stileDelTitolo();
    print('ORDINE ER VOCE 9: titolo in home ${casa.fontSize} punti '
        '${casa.fontFamily}, nei domini ${dominio.fontSize} punti '
        '${dominio.fontFamily}');
    expect(casa.fontSize, 12);
    expect(casa.fontFamily, dominio.fontFamily);
    expect(casa.fontFamily, TypographyTokens.titoloDiRiga().fontFamily);
    expect(dominio.fontSize, 16);
  });

  test('ER.09: le sillabe dell\'italiano, sulle parole dei titoli', () {
    String sillabato(String p) {
      final punti = LeSillabe.puntiDiTaglio(p);
      final pezzi = <String>[];
      var da = 0;
      for (final i in punti) {
        pezzi.add(p.substring(da, i));
        da = i;
      }
      pezzi.add(p.substring(da));
      return pezzi.join('-');
    }

    const attese = {
      'Personalizzato': 'Per-so-na-liz-za-to',
      "dell'Intenzione": "dell'-In-ten-zio-ne",
      'Astrocartografia': 'Astro-car-to-gra-fia',
      'Cristalloterapia': 'Cri-stal-lo-te-ra-pia',
      'Oroscopo': 'Oro-sco-po',
      'Interpretazione': 'In-ter-pre-ta-zio-ne',
      'Sigillo': 'Si-gil-lo',
      'Calendario': 'Ca-len-da-rio',
    };
    final sbagliate = <String>[];
    for (final e in attese.entries) {
      final s = sillabato(e.key);
      if (s != e.value) sbagliate.add('${e.key}: $s invece di ${e.value}');
    }
    print('ORDINE ER VOCE 9: parole sillabate ${attese.length}, sbagliate '
        '${sbagliate.length} $sbagliate');
    expect(sbagliate, isEmpty);
  });

  test(
      'ER.09 e ER.03: le 66 arti della home nei tre formati: nessun titolo '
      'oltre due righe, nessuna riga fuori dalla scheda, il Viaggio come gli '
      'altri', () {
    final tutte = {for (final a in ArtCatalog.all) a.id: a};
    final inCasa = <String>{
      ...LeRigheDellaCasa.righe.expand((r) => r.arti),
      'horoscope',
    };
    final righe = <String>[
      'ORDINE ER VOCI 09 E 03: I TITOLI DELLE SCHEDE DELLA HOME, OGNI ARTE NEI '
          'TRE FORMATI, 27 settembre 2026',
      'Titolo a ${TypographyTokens.misuraDelTitoloInCasa.toInt()} punti, '
          'Cinzel, al massimo due righe; misurato col carattere vero.',
      '',
    ];
    var composti = 0;
    var oltreDue = 0;
    var fuori = 0;
    final colTrattino = <String>[];
    for (final id in inCasa.toList()..sort()) {
      final art = tutte[id]!;
      for (final f in FormatoDellaScheda.values) {
        final larghezza = LaSchedaDellArte.larghezzaPer(f, inCasa: true);
        final stile = LaSchedaDellArte.stileDelTitolo(inCasa: true);
        final testo = LaSchedaDellArte.testoDelTitolo(art,
            inCasa: true, larghezza: larghezza);
        final linee = testo.split('\n');
        composti++;
        if (linee.length > 2) oltreDue++;
        final larghe = [
          for (final l in linee)
            if (IlTitoloColTrattino.larghezzaDi(
                    l, stile, TextScaler.noScaling) >
                larghezza + 0.01)
              l,
        ];
        if (larghe.isNotEmpty) fuori++;
        final spezzata = linee.any((l) => l.endsWith('-')) &&
            !art.title.contains(
                linee.firstWhere((l) => l.endsWith('-'), orElse: () => '#'));
        if (spezzata) colTrattino.add('${art.title} (${f.name})');
        righe.add('${art.title.padRight(30)} ${f.name.padRight(11)} '
            '${larghezza.round()} punti  ${linee.length} righe  '
            '"${linee.join(' / ')}"'
            '${larghe.isEmpty ? '' : '  FUORI DALLA SCHEDA: $larghe'}');
      }
    }
    righe
      ..add('')
      ..add('Arti della home: ${inCasa.length}. Titoli composti: $composti.')
      ..add('Titoli su piu\' di due righe: $oltreDue su $composti.')
      ..add('Titoli con una riga fuori dalla scheda (tagliati): $fuori su '
          '$composti.')
      ..add('Titoli andati a capo col trattino: ${colTrattino.length} '
          '$colTrattino');
    Directory('docs/collaudo/ER').createSync(recursive: true);
    File('docs/collaudo/ER/titoli.txt')
        .writeAsStringSync('${righe.join('\n')}\n');
    print('ORDINE ER VOCE 9: ${righe.sublist(righe.length - 4).join(' ')}');

    // 66 arti con l'ordine ER voce 08, 67 col Segreto dell'Iride (voce 20),
    // 68 con la Soglia del Sonno (ordine FF aggiunta 1): tre titoli in piu',
    // uno per formato.
    expect(inCasa.length, 68, reason: 'in home non ci sono le 68 arti');
    expect(composti, 204);
    expect(oltreDue, 0, reason: 'titoli su piu\' di due righe');
    expect(fuori, 0, reason: 'titoli con una riga piu\' larga della scheda');
    // Il Viaggio si compone come gli altri: non ha righe sue.
    final viaggio = LaSchedaDellArte.testoDelTitolo(tutte['guide_animal']!,
        inCasa: true,
        larghezza: LaSchedaDellArte.larghezzaPer(FormatoDellaScheda.verticale,
            inCasa: true));
    print('ORDINE ER VOCE 3: il Viaggio in verticale "$viaggio"');
    expect(viaggio.toUpperCase().contains('VIAGGIO\nDELLO\nSCIAMANO'), isFalse,
        reason: 'il Viaggio e\' ancora scritto su tre righe decise a mano');
    expect(viaggio.split('\n').length, lessThanOrEqualTo(2));
    expect(GliSfondiDelleSchede.nomi.length, 68);
  });

  test('ER.03: nessuna arte ha un titolo scritto a parte', () {
    final sorgente = File('lib/core/arts/art_catalog.dart')
        .readAsStringSync()
        .split('\n')
        .where((r) => !r.trimLeft().startsWith('//'))
        .join('\n');
    final scheda = File('lib/features/schede/la_scheda_dell_arte.dart')
        .readAsStringSync()
        .split('\n')
        .where((r) => !r.trimLeft().startsWith('//'))
        .join('\n');
    final aParte = RegExp(r'righeDelTitolo:\s*\S').allMatches(sorgente).length +
        RegExp(r'stileDellaRigaDecisa').allMatches(scheda).length;
    print('ORDINE ER VOCE 3: arti col titolo scritto a parte $aParte');
    expect(aParte, 0);
  });
}
