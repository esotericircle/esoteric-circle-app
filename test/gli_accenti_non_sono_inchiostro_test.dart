import 'dart:math' as math;

import 'package:esoteric_circle/design_system/theme/maestro_palette.dart';
import 'package:esoteric_circle/design_system/tokens/color_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';
import 'codice_senza_testo.dart';
import 'sorgenti_di_lib.dart';

/// **GLI ACCENTI DEI MAESTRI NON SONO INCHIOSTRO.**
/// Ordine CO voci 08 e 14, 3 settembre 2026.
///
/// Nasce da un fatto del fondatore, "Carta Chiave e' azzurro su blu e non si
/// legge", e da una domanda che l'ordine pone per esteso: **perche' la
/// sorveglianza del contrasto non l'aveva presa.**
///
/// La risposta e' che nessuna la stava guardando, e non per distrazione. La
/// guardia dei grigi spazza i due token di testo grigi contro i fondi veri, ed
/// e' una guardia buona che fa esattamente cio' che dichiara. Ma `palette.glow`
/// **non e' un token di testo**: e' l'accento del Maestro, nato per aloni,
/// bordi e riempimenti, dove la soglia e' tre a uno e non quattro e mezzo.
/// Quando qualcuno lo ha scritto su una lettera, quel colore e' uscito
/// dall'insieme che qualunque guardia stesse spazzando. **Non c'era una
/// guardia cieca: c'era un insieme senza guardia.**
///
/// **Le misure, che sono la ragione di questa regola.** Contrasto WCAG dei
/// quattro `primary` e dei quattro `glow` sui fondi veri dell'app:
///
/// - `primary`, tutti e quattro: da 1,64 a 2,97. **Mai, su nessun fondo.** Un
///   testo a due a uno non e' poco leggibile, e' invisibile.
/// - `medoraGlow` e `neutralGlow`: da 3,32 a 4,98, cioe' sotto soglia su tre
///   fondi su cinque. E' l'azzurro su blu del fondatore, misurato.
/// - `caligoGlow`: 3,71 sulla superficie sollevata.
/// - `auraGlow` regge dappertutto, e non basta a fare una regola: un colore
///   che passa non autorizza la sua famiglia.
///
/// **L'oro invece regge sempre**, da 6,30 a 13,81, ed e' gia' il colore con
/// cui questa app scrive cio' che vuole mettere in evidenza. Non serviva un
/// secondo linguaggio, e il posto dove l'accento era finito su una lettera
/// diceva la stessa cosa che la sua bolla, piu' in basso, diceva gia' in oro.
void main() {
  double luminanza(Color c) {
    double canale(double v) =>
        v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4) as double;
    return 0.2126 * canale(c.r) + 0.7152 * canale(c.g) + 0.0722 * canale(c.b);
  }

  double contrasto(Color a, Color b) {
    final la = luminanza(a), lb = luminanza(b);
    return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
  }

  // I fondi veri, gli stessi della guardia dei grigi piu' la superficie
  // sollevata, che e' il fondo su cui le bolle scrivono.
  final fondi = <String, Color>{
    'deepest': const Color(0xFF070A18),
    'Medora': const Color(0xFF141A33),
    'Caligo': const Color(0xFF1E1016),
    'Aura': const Color(0xFF0E1A18),
    'superficie sollevata di Medora': const Color(0xFF1A2C63),
  };

  test('nessun accento di Maestro regge come inchiostro su tutti i fondi', () {
    final accenti = <String, Color>{
      'medoraGlow': ColorTokens.medoraGlow,
      'medoraPrimary': ColorTokens.medoraPrimary,
      'caligoGlow': ColorTokens.caligoGlow,
      'caligoPrimary': ColorTokens.caligoPrimary,
      'neutralGlow': ColorTokens.neutralGlow,
      'neutralPrimary': ColorTokens.neutralPrimary,
      'auraPrimary': ColorTokens.auraPrimary,
    };
    final reggono = <String>[];
    for (final a in accenti.entries) {
      final peggiore =
          fondi.values.map((f) => contrasto(a.value, f)).reduce(math.min);
      // ignore: avoid_print
      print('ORDINE CO VOCE 08: ${a.key} sul fondo peggiore = '
          '${peggiore.toStringAsFixed(2)} a 1');
      if (peggiore >= 4.5) reggono.add('${a.key}: $peggiore');
    }
    expect(reggono, isEmpty,
        reason: 'questi accenti reggerebbero come inchiostro ovunque, e la '
            'regola qui sotto li vieta lo stesso: ${reggono.join(", ")}. Se '
            'un accento è diventato leggibile, la regola va riscritta '
            'con la sua ragione nuova, non aggirata');

    // E l'oro regge, che e' cio' che rende la regola applicabile invece che
    // solo severa: c'e' sempre un colore giusto da usare al posto suo.
    for (final oro in [ColorTokens.gold, ColorTokens.goldLight]) {
      for (final f in fondi.entries) {
        expect(contrasto(oro, f.value), greaterThanOrEqualTo(4.5),
            reason: 'l’oro non si legge più su ${f.key}, e allora '
                'questa regola non ha più un colore da offrire in '
                'cambio');
      }
    }
  });

  test('nessun sorgente scrive una lettera col colore di un accento', () {
    // **LE ECCEZIONI SI DICHIARANO PER NOME, con la loro ragione scritta.**
    // Adesso non ce n'e' nessuna, ed e' lo stato giusto: un nome qui dentro
    // deve portare il fondo su cui sta e la misura che lo assolve.
    const conRagioneScritta = <String>{};

    var guardati = 0;
    final colpevoli = <String>[];
    for (final file in sorgentiDiLib()) {
      final righe = codiceSenzaTesto(file.readAsStringSync()).split('\n');
      for (var i = 0; i < righe.length; i++) {
        final riga = righe[i];
        // **SI CONTANO TUTTI GLI USI, e si accusano solo le lettere.** Il
        // filtro di prima cercava l'accento nudo, senza opacità: dopo la
        // correzione della voce 08 in tutta lib non ne restava nemmeno uno, e
        // il cardinale minimo ha fermato questa prova mentre stava per
        // diventare verde su un insieme vuoto. Adesso conta anche gli aloni e
        // i bordi, che sono l'uso legittimo e non spariranno mai.
        if (!riga.contains('color: palette.glow') &&
            !riga.contains('color: palette.primary')) {
          continue;
        }
        guardati++;
        // **UNA LETTERA SI RICONOSCE DALLO STILE CHE LA VESTE.** Un accento
        // dentro un `TextStyle` o un `copyWith` di un ruolo tipografico e'
        // inchiostro; lo stesso accento dentro una decorazione, un bordo o
        // un'icona non lo e', e li' la soglia e' tre a uno.
        final intorno = righe
            .sublist(math.max(0, i - 3), math.min(righe.length, i + 2))
            .join(' ');
        final eInchiostro = intorno.contains('TypographyTokens.') ||
            intorno.contains('TextStyle(') ||
            intorno.contains('style:');
        if (!eInchiostro) continue;
        final percorso = file.path.replaceAll(r'\', '/');
        final dove = '${percorso.substring(percorso.indexOf('lib/'))}:${i + 1}';
        if (conRagioneScritta.contains(dove)) continue;
        colpevoli.add('$dove: ${riga.trim()}');
      }
    }
    cardinaleMinimo(guardati, 20,
        cosa: 'usi di un accento di Maestro come colore, di ogni specie',
        perche: 'Se in tutta lib non se ne trova più nemmeno uno, questa '
            'prova è verde per non aver guardato niente: gli accenti '
            'servono ancora ad aloni e bordi, e sparire del tutto vorrebbe '
            'dire che il filtro si è rotto.');
    expect(colpevoli, isEmpty,
        reason: 'QUESTE LETTERE SONO SCRITTE COL COLORE DI UN ACCENTO, e sui '
            'fondi veri di questa app misurano fra 1,64 e 4,98 a '
            'uno:\n${colpevoli.join("\n")}\n'
            'Un accento serve ad aloni, bordi e riempimenti, dove la '
            'soglia è tre a uno. Su una lettera la soglia è '
            'quattro e mezzo, e l’oro la supera su ogni fondo.');
  });

  test('la palette dichiara ancora i colori su cui questa regola poggia', () {
    // Se domani un accento cambiasse valore, le misure scritte qui sopra
    // diventerebbero un ricordo. Questa riga lega la regola ai colori veri.
    expect(MaestroPalette.medora.glow, ColorTokens.medoraGlow);
    expect(MaestroPalette.medora.goldSoft, ColorTokens.goldLight);
  });
}
