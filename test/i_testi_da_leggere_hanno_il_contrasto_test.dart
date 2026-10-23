// ignore_for_file: avoid_print
import 'package:esoteric_circle/core/rituals/daily_elements.dart';
import 'package:esoteric_circle/design_system/theme/abito_del_responso.dart';
import 'package:esoteric_circle/design_system/theme/accento_del_maestro.dart';
import 'package:esoteric_circle/design_system/theme/app_theme.dart';
import 'package:esoteric_circle/design_system/theme/maestro_palette.dart';
import 'package:esoteric_circle/design_system/tokens/color_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';
import 'sorgenti_di_lib.dart';

/// **I TESTI DA LEGGERE HANNO IL CONTRASTO.** Ordine GA voce GA.10, 21
/// ottobre 2026.
///
/// Il fondatore: *"a volte in alcune funzionalita' c'e' testo chiaro su
/// sfondo chiaro e potrebbe valutare il cambio di colore o di usare
/// un'ombreggiatura del testo o un contorno del testo o altro per aumentare
/// la visibilita'"*. Cinque collaudatori hanno misurato sul Realme, sulle
/// catture renderizzate, i contrasti di ogni testo: i difetti veri, cioe' i
/// testi sotto soglia sul colore di sfondo piu' frequente, erano quasi tutti
/// **una coppia di colori dichiarata nel codice** che nessuna prova guardava.
///
/// **COSA GUARDA, in due parti.**
///
/// 1. **LE COPPIE DICHIARATE.** Ogni coppia testo/fondo pieno che il codice
///    dichiara con i colori delle palette dei Maestri e dei token (pulsante
///    pieno d'oro, pulsante col primario, comandi di testo del tema, dialogo
///    "Ricominciare da zero?", selettore di data, pastiglia del Dominio,
///    colore del Maestro che si legge) deve fare almeno 4,5 a 1 oppure 3 a 1 se
///    e' un titolo grande. Il conto passa dalla porta della casa,
///    `AccentoDelMaestro.contrastoFra`: un secondo conto sarebbe la famiglia
///    di difetti piu' numerosa di questo progetto.
/// 2. **LA FORMA DEL DIFETTO NEI SORGENTI.** Il pulsante d'oro col testo
///    crema nasceva in due modi: tutti e due si cercano nei sorgenti: il
///    `foregroundColor` preso dal primario (`palette.onPrimary`, crema) e lo
///    stile del testo preso dai token tipografici (`TypographyTokens.etichetta()`
///    porta il crema DENTRO e batte il `foregroundColor` del pulsante).
///
/// **Quello che NON guarda: lo dice qui.** I testi sopra immagini, video e cieli
/// hanno un fondo che cambia lettera per lettera: li cura l'ombra comune del
/// testo (`TypographyTokens.ombraDelTesto`) e li misura il collaudo sulle
/// catture, non questa prova. I pulsanti spenti sono esenti per la regola
/// stessa (WCAG 1.4.3).
///
/// **PADRE DEL DIFETTO**: PROVENIENZA IGNOTA. La coppia oro/crema e' entrata
/// copiando lo stile del pulsante primario; nessuna voce l'ha mai misurata
/// (la tavolozza dichiara un solo `onPrimary` crema per tutti i Maestri, e
/// sull'oro fa 1,86, sul verde di Aura 2,84).
void main() {
  double contrasto(Color a, Color b) => AccentoDelMaestro.contrastoFra(a, b);

  final palette = <String, MaestroPalette>{
    'Medora': MaestroPalette.medora,
    'Aura': MaestroPalette.aura,
    'Caligo': MaestroPalette.caligo,
    'Il Cerchio': MaestroPalette.neutral,
  };

  /// Una coppia dichiarata: chi la dichiara, testo, fondo, soglia.
  final coppie = <({String nome, Color testo, Color fondo, double soglia})>[];
  void coppia(String nome, Color testo, Color fondo, [double soglia = 4.5]) =>
      coppie.add((nome: nome, testo: testo, fondo: fondo, soglia: soglia));

  final abito = AbitoDelResponso.di(DailyElement.night);
  for (final e in palette.entries) {
    final p = e.value;
    final n = e.key;
    // I pulsanti pieni.
    coppia('$n: pulsante pieno d\'oro (onGold su gold)', p.onGold, p.gold);
    coppia('$n: pulsante pieno d\'oro chiaro (onGold su goldSoft)', p.onGold,
        p.goldSoft);
    coppia('$n: pulsante col primario (onPrimary su primary)', p.onPrimary,
        p.primary);
    // Il testo comune sulle superfici del Maestro.
    for (final s in [p.surface, p.surfaceElevated, p.deepest]) {
      coppia('$n: testo primario sul fondo', p.textPrimary, s);
      coppia('$n: testo secondario sul fondo', p.textSecondary, s);
      coppia('$n: oro chiaro sul fondo', p.goldSoft, s);
    }
    coppia('$n: titolo d\'oro sul fondo profondo (titolo grande)', p.gold,
        p.deepest, 3);
    // La pastiglia "Entra nel Dominio": superficie al 90 per cento, sul punto
    // peggiore, che e' un fondo bianco.
    for (final s in [p.surface, p.surfaceElevated]) {
      final sulBianco =
          Color.alphaBlend(s.withValues(alpha: 0.9), const Color(0xFFFFFFFF));
      coppia('$n: pastiglia del Dominio sul bianco', p.goldSoft, sulBianco);
    }
    // Il testo che nomina il Maestro ("Guidato da ...") sul fondo del popup.
    coppia('$n: nome del Maestro, alone sul fondo del popup', p.glow,
        ColorTokens.neutralDeep);
    // La pastiglia dei giorni di fila: accento portato alla soglia sul fondo
    // composto, vetro piu' incasso.
    final fondoPastiglia =
        Color.alphaBlend(abito.incasso, abito.superficiePeggiore);
    coppia('$n: accento portato sul fondo della pastiglia',
        AccentoDelMaestro.portatoSu(p.glow, fondoPastiglia), fondoPastiglia);
  }

  // Il dialogo "Ricominciare da zero?": due aspetti, tutti e due leggibili.
  coppia('dialogo: "Lascia tutto" (textSecondary su neutralSurface)',
      ColorTokens.textSecondary, ColorTokens.neutralSurface);
  coppia('dialogo: "Ricomincia" (caligoGlow su neutralSurface)',
      ColorTokens.caligoGlow, ColorTokens.neutralSurface);
  coppia('Diario: "Torna all\'anno" (goldLight sul nero)',
      ColorTokens.goldLight, ColorTokens.neutralDeepest);

  // Il comando di testo di fabbrica del tema e il selettore di data, letti dal
  // tema vero e non da una copia dei suoi colori.
  final tema = AppTheme.dark();
  final comando = tema.textButtonTheme.style!.foregroundColor!.resolve({})!;
  final annulla =
      tema.datePickerTheme.cancelButtonStyle!.foregroundColor!.resolve({})!;
  final conferma =
      tema.datePickerTheme.confirmButtonStyle!.foregroundColor!.resolve({})!;
  for (final fondo in [
    ColorTokens.neutralSurface,
    ColorTokens.neutralDeep,
    ColorTokens.neutralDeepest,
    ColorTokens.auraSurface,
    ColorTokens.caligoSurface,
    ColorTokens.medoraSurface,
    const Color(0xFF2B292F), // il fondo del selettore di data, misurato
  ]) {
    coppia('tema: comando di testo di fabbrica', comando, fondo);
    coppia('tema: ANNULLA del selettore di data', annulla, fondo);
    coppia('tema: OK del selettore di data', conferma, fondo);
  }

  test('ogni coppia testo/fondo dichiarata si legge', () {
    cardinaleMinimo(coppie.length, 90,
        cosa: 'coppie testo/fondo dichiarate',
        perche: 'Sono quattro palette per diciassette coppie piu\' le '
            'dichiarazioni del tema e del dialogo: se il numero scende, una '
            'coppia e\' stata tolta dall\'elenco e non piu\' misurata.');
    final sotto = <String>[];
    var peggiore = double.infinity;
    for (final c in coppie) {
      final r = contrasto(c.testo, c.fondo);
      if (r < peggiore) peggiore = r;
      if (r < c.soglia) {
        sotto.add('${c.nome}: ${r.toStringAsFixed(2)} a 1, soglia '
            '${c.soglia}');
      }
    }
    print('ORDINE GA VOCE GA.10: ${coppie.length} coppie, la peggiore fa '
        '${peggiore.toStringAsFixed(2)} a 1');
    final ordinate = [...coppie]..sort((a, b) =>
        contrasto(a.testo, a.fondo).compareTo(contrasto(b.testo, b.fondo)));
    for (final c in ordinate.take(5)) {
      print('  ${contrasto(c.testo, c.fondo).toStringAsFixed(2)}  ${c.nome}');
    }
    expect(sotto, isEmpty,
        reason: 'queste coppie dichiarate nel codice scendono sotto la '
            'soglia (4,5 a 1 il testo da leggere, 3 a 1 i titoli grandi):\n'
            '${sotto.join("\n")}');
  });

  test('i due aspetti del dialogo di ripartenza sono distinguibili', () {
    // "Lascia tutto" e "Ricomincia" erano identici (viola su viola scuro): il
    // comando che non si disfa deve distinguersi dall'altro.
    expect(ColorTokens.textSecondary, isNot(ColorTokens.caligoGlow));
    final sorgente = sorgentiDiLib().firstWhere(
        (f) => f.path.replaceAll('\\', '/').endsWith('account_screen.dart'));
    final testo = sorgente.readAsStringSync();
    final lascia = testo.indexOf("child: const Text('Lascia tutto')");
    final ricomincia = testo.indexOf("child: const Text('Ricomincia')");
    expect(lascia, greaterThan(0));
    expect(ricomincia, greaterThan(lascia));
    final a = testo.substring(lascia - 260, lascia);
    final b = testo.substring(ricomincia - 260, ricomincia);
    expect(a.contains('foregroundColor'), isTrue,
        reason: '"Lascia tutto" non dichiara il suo colore');
    expect(b.contains('foregroundColor'), isTrue,
        reason: '"Ricomincia" non dichiara il suo colore');
    expect(a.contains('textSecondary') && b.contains('caligoGlow'), isTrue,
        reason: 'i due comandi devono avere due aspetti diversi');
  });

  test('nessun pulsante pieno d\'oro porta il testo crema', () {
    // Il difetto, nella sua forma di sorgente: `backgroundColor: ...gold`
    // con `foregroundColor: ...onPrimary` (crema sull'oro, 1,86) oppure con
    // un'etichetta il cui stile viene dai token tipografici senza dichiarare
    // un colore (il token porta il crema dentro e batte il pulsante).
    final bottone = RegExp(r'(FilledButton|ElevatedButton)(\.icon|\.tonal)?\(');
    final fondoOro = RegExp(r'backgroundColor:\s*([\w.?]*gold\w*)\s*[,)]');
    final primoPiano = RegExp(r'foregroundColor:\s*([\w.?]+)');
    final stili = RegExp(
        r'style:\s*(TypographyTokens\.\w+\((?:[^()]|\([^()]*\))*\)(?:\s*\.copyWith\((?:[^()]|\([^()]*\))*\))?)');
    const colorePerCrema = {
      'palette.onPrimary',
      'ColorTokens.textPrimary',
      'ColorTokens.textSecondary',
      'Colors.white',
    };
    var trovati = 0;
    final difetti = <String>[];
    for (final f in sorgentiDiLib()) {
      final s = f.readAsStringSync();
      for (final m in bottone.allMatches(s)) {
        final apri = m.end - 1;
        var d = 0;
        var fine = -1;
        for (var i = apri; i < s.length; i++) {
          if (s[i] == '(') d++;
          if (s[i] == ')') {
            d--;
            if (d == 0) {
              fine = i;
              break;
            }
          }
        }
        if (fine < 0) continue;
        final blocco = s.substring(m.start, fine + 1);
        if (!fondoOro.hasMatch(blocco)) continue;
        trovati++;
        final riga = '\n'.allMatches(s.substring(0, m.start)).length + 1;
        final dove = '${f.path.replaceAll('\\', '/')}:$riga';
        final fg = primoPiano.firstMatch(blocco)?.group(1);
        if (fg != null && colorePerCrema.contains(fg)) {
          difetti.add('$dove: testo $fg su fondo d\'oro');
        }
        for (final st in stili.allMatches(blocco)) {
          if (!st.group(1)!.contains('color')) {
            difetti.add('$dove: lo stile del testo '
                '(${st.group(1)!.replaceAll(RegExp(r"\s+"), " ")}) porta il '
                'colore dei token, cioe\' il crema, sopra il pulsante');
          }
        }
      }
    }
    cardinaleMinimo(trovati, 30,
        cosa: 'pulsanti pieni d\'oro nei sorgenti',
        perche: 'Erano 35 il 21 ottobre 2026: se il conto cade, o i '
            'pulsanti sono passati a un altro componente o questa guardia '
            'non li trova piu\'.');
    print('ORDINE GA VOCE GA.10: $trovati pulsanti pieni d\'oro guardati');
    expect(difetti, isEmpty,
        reason: 'il testo crema su un pulsante d\'oro fa 1,86 a 1 (soglia '
            '4,5): usare palette.onGold.\n${difetti.join("\n")}');
  });
}
