import 'dart:io';
import 'dart:math' as math;

import 'package:esoteric_circle/design_system/theme/maestro_palette.dart';
import 'package:esoteric_circle/design_system/tokens/color_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// IL CENSIMENTO DEI GRIGI. Ordine AU voce 08.
///
/// **Il fondatore l'ha segnalato tre volte, e due cure non sono bastate.**
/// L'ordine AS voce 05 aveva alzato `textMuted` da 4,66 a 6,34 e dichiarato
/// chiuso: **il difetto non e' un colore solo**. Sono i testi sotto le bolle e
/// nelle card, e ci sono ancora.
///
/// **Per questo qui si ENUMERA e non si campiona**, come l'ordine pretende.
/// La prova di AS.05 guardava una manciata di token scelti a mano: bastava che
/// un punto qualsiasi del codice applicasse un'opacita' a un colore di testo
/// perche' il conto non lo vedesse. Adesso il censimento e' il prodotto di
/// TUTTI i colori di testo del progetto, token e palette dei tre Maestri, per
/// TUTTE le opacita' che il codice applica davvero, lette dai sorgenti, per
/// TUTTI i fondi veri.
///
/// **Le soglie sono quelle dell'ordine**: 7,0 per i testi piccoli, 4,5 per i
/// titoli grandi.
void main() {
  /// La luminanza relativa, formula WCAG.
  double luminanza(Color c) {
    double canale(double v) =>
        v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4) as double;
    return 0.2126 * canale(c.r) + 0.7152 * canale(c.g) + 0.0722 * canale(c.b);
  }

  double contrasto(Color a, Color b) {
    final la = luminanza(a), lb = luminanza(b);
    final chiaro = math.max(la, lb), scuro = math.min(la, lb);
    return (chiaro + 0.05) / (scuro + 0.05);
  }

  /// Il colore come si vede DAVVERO quando ha un'opacita': si compone col
  /// fondo, che e' cio' che l'occhio riceve.
  Color composto(Color sopra, Color sotto) {
    final a = sopra.a;
    return Color.from(
      alpha: 1,
      red: sopra.r * a + sotto.r * (1 - a),
      green: sopra.g * a + sotto.g * (1 - a),
      blue: sopra.b * a + sotto.b * (1 - a),
    );
  }

  /// **I FONDI VERI, non quelli teorici.** Le quattro case piu' il velo delle
  /// bolle, che e' il fondo su cui stanno i testi che il fondatore non riesce
  /// a leggere.
  final fondi = <String, Color>{
    'fondo piu scuro': const Color(0xFF070A18),
    'casa di Medora': ColorTokens.medoraSurface,
    'casa di Caligo': ColorTokens.caligoSurface,
    'casa di Aura': ColorTokens.auraSurface,
    'vetro sopra Medora': composto(
        ColorTokens.glassTint, ColorTokens.medoraDeep),
    'vetro sopra Caligo': composto(
        ColorTokens.glassTint, ColorTokens.caligoDeep),
    'vetro sopra Aura':
        composto(ColorTokens.glassTint, ColorTokens.auraDeep),
  };

  /// **OGNI COLORE CHE PORTA TESTO**, token del progetto e tinte delle tre
  /// palette. Non si sceglie: si prendono tutti.
  Map<String, Color> tuttiIColoriDiTesto() {
    final colori = <String, Color>{
      'textPrimary': ColorTokens.textPrimary,
      'textSecondary': ColorTokens.textSecondary,
      'textMuted': ColorTokens.textMuted,
      'gold': ColorTokens.gold,
      'goldLight': ColorTokens.goldLight,
      'goldBright': ColorTokens.goldBright,
      'goldDeep': ColorTokens.goldDeep,
    };
    const palette = <String, MaestroPalette>{
      'medora': MaestroPalette.medora,
      'caligo': MaestroPalette.caligo,
      'aura': MaestroPalette.aura,
      'neutra': MaestroPalette.neutral,
    };
    for (final voce in palette.entries) {
      colori['${voce.key}.textPrimary'] = voce.value.textPrimary;
      colori['${voce.key}.textSecondary'] = voce.value.textSecondary;
      colori['${voce.key}.gold'] = voce.value.gold;
      colori['${voce.key}.goldSoft'] = voce.value.goldSoft;
    }
    return colori;
  }

  /// **LE DUE SOGLIE DELL'ORDINE, e servono tutte e due.** Sette per i testi
  /// piccoli, quattro e mezzo per i titoli grandi. Senza questa distinzione il
  /// censimento pretenderebbe sette anche dall'oro di un titolo cerimoniale, e
  /// per ottenerlo l'oro andrebbe schiarito fino a non essere piu' oro: si
  /// curerebbe un difetto rovinando il marchio.
  ///
  /// Il confine sta dove lo mette WCAG, diciotto punti e mezzo: nella scala
  /// del progetto vuol dire i quattro ruoli del display, da `titoloScheda` in
  /// su.
  const grandi = {
    'cerimonialeGrande',
    'cerimoniale',
    'titoloSezione',
    'titoloScheda',
  };

  /// **OGNI PUNTO DEL CODICE CHE DIPINGE UN TESTO**, letto dai sorgenti.
  ///
  /// **La prima stesura di questa prova faceva il prodotto cartesiano** di
  /// tutti i colori per tutte le opacita' trovate in giro, e ne usciva un
  /// elenco di 4.347 righe dove le peggiori erano "goldDeep all'8 per cento",
  /// che nel codice non e' un testo ma un'ombra. Un censimento che inventa
  /// combinazioni non censisce: fa rumore, e nel rumore il difetto vero si
  /// perde.
  List<({String dove, String ruolo, String colore, double alpha})>
      puntiCheDipingonoTesto() {
    final punti =
        <({String dove, String ruolo, String colore, double alpha})>[];
    final stile = RegExp(
        r'TypographyTokens\.(\w+)\([^()]*\)[\s\n]*\.copyWith\(([^;]{0,400}?)\)',
        multiLine: true);
    final colore = RegExp(
        r'color:\s*((?:ColorTokens|palette)\.\w+)'
        r'(?:\s*\.withValues\(alpha:\s*([0-9.]+)\))?');
    for (final f in Directory('lib').listSync(recursive: true)) {
      if (f is! File || !f.path.endsWith('.dart')) continue;
      final sorgente = f.readAsStringSync();
      final nome = f.path.split(RegExp(r'[\/]')).last;
      for (final m in stile.allMatches(sorgente)) {
        final c = colore.firstMatch(m.group(2)!);
        if (c == null) continue;
        punti.add((
          dove: nome,
          ruolo: m.group(1)!,
          colore: c.group(1)!,
          alpha: double.tryParse(c.group(2) ?? '1') ?? 1.0,
        ));
      }
    }
    return punti;
  }

  /// **SU CHE FONDO STA DAVVERO QUEL TESTO.** Un colore preso dalla palette
  /// vive nella casa del suo Maestro e in nessun'altra: misurare l'oro di
  /// Medora sul verde di Aura vuol dire inventare una schermata che non
  /// esiste. I token globali invece compaiono ovunque, e vanno bene su tutti.
  List<({String nome, Color colore, Map<String, Color> fondi})> daMisurare(
      String nome, Map<String, Color> tutti) {
    final corto = nome.split('.').last;
    if (nome.startsWith('ColorTokens.')) {
      final c = tutti[corto];
      return c == null ? const [] : [(nome: nome, colore: c, fondi: fondi)];
    }
    return [
      for (final casa in const ['medora', 'caligo', 'aura'])
        if (tutti['$casa.$corto'] != null)
          (
            nome: '$casa.$corto',
            colore: tutti['$casa.$corto']!,
            fondi: {
              'fondo piu scuro': fondi['fondo piu scuro']!,
              'casa di ${casa[0].toUpperCase()}${casa.substring(1)}':
                  fondi['casa di ${casa[0].toUpperCase()}${casa.substring(1)}']!,
              'vetro sopra ${casa[0].toUpperCase()}${casa.substring(1)}': fondi[
                  'vetro sopra ${casa[0].toUpperCase()}${casa.substring(1)}']!,
            },
          ),
    ];
  }

  List<({String voce, double rapporto, double soglia})> censimento() {
    final tutti = tuttiIColoriDiTesto();
    final misure = <({String voce, double rapporto, double soglia})>[];
    for (final punto in puntiCheDipingonoTesto()) {
      final soglia = grandi.contains(punto.ruolo) ? 4.5 : 7.0;
      for (final c in daMisurare(punto.colore, tutti)) {
        for (final fondo in c.fondi.entries) {
          final vero = punto.alpha == 1.0
              ? c.colore
              : composto(c.colore.withValues(alpha: punto.alpha), fondo.value);
          misure.add((
            voce: '${punto.dove}, ${punto.ruolo}: ${c.nome}'
                '${punto.alpha == 1.0 ? "" : " al ${(punto.alpha * 100).round()} per cento"}'
                ' su ${fondo.key}',
            rapporto: contrasto(vero, fondo.value),
            soglia: soglia,
          ));
        }
      }
    }
    return misure;
  }

  test('il censimento enumera i punti veri, e dichiara i peggiori venti', () {
    final punti = puntiCheDipingonoTesto();
    expect(punti.length, greaterThan(50),
        reason: 'trovati solo ${punti.length} punti che dipingono testo: la '
            'lettura dei sorgenti si e rotta, e un censimento che non trova '
            'niente e verde per cecita');
    final misure = censimento()
      ..sort((a, b) =>
          (a.rapporto / a.soglia).compareTo(b.rapporto / b.soglia));
    // ignore: avoid_print
    print('ORDINE AU VOCE 08: ${punti.length} punti del codice dipingono '
        'testo, e fanno ${misure.length} misure sui fondi che quei testi '
        'toccano davvero');
    // ignore: avoid_print
    print('ORDINE AU VOCE 08: i peggiori venti, col rapporto e la soglia che '
        'devono rispettare');
    for (final m in misure.take(20)) {
      // ignore: avoid_print
      print('  ${m.rapporto.toStringAsFixed(2)} contro ${m.soglia} : ${m.voce}');
    }
    final sotto = misure.where((m) => m.rapporto < m.soglia).length;
    // ignore: avoid_print
    print('ORDINE AU VOCE 08: sotto la loro soglia sono $sotto su '
        '${misure.length}');
  });

  test('nessun testo sta sotto la sua soglia', () {
    final rotti = <String>{};
    for (final m in censimento()) {
      if (m.rapporto < m.soglia) {
        rotti.add('${m.voce} fa ${m.rapporto.toStringAsFixed(2)} contro '
            '${m.soglia}');
      }
    }
    final elenco = rotti.toList()..sort();
    expect(elenco, isEmpty,
        reason: 'questi testi non arrivano alla loro soglia sul fondo su cui '
            'sono dipinti, e sono ${elenco.length}:\n  ${elenco.join("\n  ")}');
  });
}
