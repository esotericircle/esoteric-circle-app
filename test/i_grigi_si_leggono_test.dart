import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:esoteric_circle/design_system/tokens/color_tokens.dart';

import 'sorgenti_di_lib.dart';

/// I GRIGI SI LEGGONO. Ordine AS voce 05.
///
/// **Il fatto di Mauro**: certi testi grigi non si leggono. E la regola
/// trasversale di quest'ordine dice che i testi piccoli si ingrandiscono e
/// quelli che si possono togliere si tolgono: un grigio che non si legge non e'
/// un dettaglio di stile, e' un testo che non c'e'.
///
/// **La misura e' il contrasto WCAG**, cioe' il rapporto fra le luminanze
/// relative del testo e del fondo, con la soglia 4,5 a 1 che il progetto ha
/// gia' dichiarato in `SogliaDelLeggibile.contrastoMinimo` per il testo di
/// lettura e di corpo. Non e' un'opinione e non dipende dallo schermo.
///
/// **Cosa si guarda, e perche' cosi'.** Il colore secondario del progetto
/// SOPRA i fondi veri dell'app, e ogni punto del codice che lo sbiadisce con
/// un'opacita': un grigio gia' vicino alla soglia, moltiplicato per 0,4,
/// scende sotto la meta' e nessuna prova se ne accorgeva.
void main() {
  /// La luminanza relativa, formula WCAG.
  double luminanza(Color c) {
    double canale(double v) =>
        v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4) as double;
    return 0.2126 * canale(c.r) + 0.7152 * canale(c.g) + 0.0722 * canale(c.b);
  }

  /// Il contrasto fra due colori, il piu' chiaro sopra il piu' scuro.
  double contrasto(Color a, Color b) {
    final la = luminanza(a), lb = luminanza(b);
    final chiaro = math.max(la, lb), scuro = math.min(la, lb);
    return (chiaro + 0.05) / (scuro + 0.05);
  }

  /// Il colore come si vede DAVVERO quando ha un'opacita': si compone col
  /// fondo, che e' cio' che l'occhio riceve. Un colore trasparente non ha un
  /// contrasto suo: ce l'ha la sua composizione.
  Color composto(Color sopra, Color sotto) {
    final a = sopra.a;
    return Color.from(
      alpha: 1,
      red: sopra.r * a + sotto.r * (1 - a),
      green: sopra.g * a + sotto.g * (1 - a),
      blue: sopra.b * a + sotto.b * (1 - a),
    );
  }

  /// I fondi veri dell'app: il piu' scuro e la superficie sollevata delle tre
  /// case. Un testo si legge su TUTTI, non su quello che gli conviene.
  const fondi = <String, Color>{
    'deepest': Color(0xFF070A18),
    'superficie di Medora': Color(0xFF141A33),
    'superficie di Caligo': Color(0xFF1E1016),
    'superficie di Aura': Color(0xFF0E1A18),
  };

  /// **LA SOGLIA E' 4,5, quella dichiarata dal progetto per il testo.** E per
  /// i due grigi senza opacita' se ne pretende una piu' alta, 6 a 1: non e'
  /// severita' gratuita, e' cio' che il progetto ha appena raggiunto
  /// schiarendo `textMuted`, e serve a impedire che ci torni sopra il filo
  /// senza che nessuno se ne accorga. Un colore al minimo legale su uno
  /// schermo di prova diventa illeggibile su un telefono in mano, ed e'
  /// esattamente cio' che Mauro ha visto.
  const soglia = 4.5;
  const sogliaDeiGrigiPieni = 6.0;

  /// I DUE GRIGI DEL PROGETTO, e si guardano tutti e due.
  ///
  /// **`textMuted` mancava alla prima stesura di questa prova, ed e' proprio
  /// quello che non si legge.** Il censimento guardava il solo `textSecondary`
  /// e usciva verde; ma le righe che spiegano quando arrivano gli Eos sotto i
  /// pulsanti della condivisione sono scritte in `textMuted`, che e' piu'
  /// scuro di un terzo. Una misura che guarda un colore su due dice "va tutto
  /// bene" mentre meta' dei grigi non si legge.
  const grigi = <String, Color>{
    'textSecondary': ColorTokens.textSecondary,
    'textMuted': ColorTokens.textMuted,
  };

  test('i grigi del progetto si leggono su tutti i fondi, senza opacita', () {
    var osservati = 0;
    final sotto = <String>[];
    for (final grigio in grigi.entries) {
      for (final fondo in fondi.entries) {
        osservati++;
        final quanto = contrasto(grigio.value, fondo.value);
        // ignore: avoid_print
        print('ORDINE AS VOCE 05: ${grigio.key} su ${fondo.key} = '
            '${quanto.toStringAsFixed(2)} a 1');
        if (quanto < sogliaDeiGrigiPieni) {
          sotto.add('${grigio.key} su ${fondo.key}: '
              '${quanto.toStringAsFixed(2)}');
        }
      }
    }
    expect(osservati, grigi.length * fondi.length);
    expect(sotto, isEmpty,
        reason: 'questi grigi non arrivano a $sogliaDeiGrigiPieni a 1, cioe '
            'stanno sul filo del leggibile: ${sotto.join("; ")}');
  });

  test('nessun testo sbiadisce il grigio sotto la soglia', () {
    // **IL CENSIMENTO, ed e' il cuore della voce.** Si leggono i sorgenti e si
    // cercano i punti che prendono il colore secondario e lo sbiadiscono con
    // un'opacita'. Per ciascuno si calcola il colore COMPOSTO col fondo piu'
    // scuro e se ne misura il contrasto: e' cio' che l'occhio riceve.
    //
    // **Le eccezioni sono dichiarate una per una, col perche'**, e non sono
    // testi: un puntino di un disegno o un elemento che sta comparendo non
    // sono cose da leggere.
    const perdonati = <String, String>{
      'lib/design_system/components/natal_wheel.dart':
          'e un puntino della ruota che appare via via, non un testo',
      'lib/features/intro/sequenza_intro.dart':
          'e un testo che sta entrando in dissolvenza: la sua opacita e il '
              'movimento stesso, e a fine corsa e piena',
    };
    // **NON TUTTO CIO' CHE E' GRIGIO E' UN TESTO, e la prima stesura di
    // questa prova ci e' cascata.** Accusava due righe di
    // `rune_draw_screen.dart`: erano lo SFONDO di un pulsante spento (alfa
    // 0,25) e il BORDO di un altro (alfa 0,40), mentre il testo sopra e'
    // grigio pieno e si legge benissimo. Una misura che guarda la cosa
    // sbagliata e' come una misura che non c'e': qui si restringe la
    // grandezza misurata al testo, e non si abbassa la soglia.
    const nonSonoTesti = [
      'backgroundColor:',
      'foregroundColor:',
      'side:',
      'BorderSide(',
      'Border.all',
      'shadowColor:',
      'divider',
      'fillColor:',
      'trackColor',
      'thumbColor',
      'barrierColor',
    ];
    var osservati = 0;
    final colpe = <String>[];
    final fondoPeggiore = fondi.values.first;
    for (final file in sorgentiDiLib()) {
      final percorso = file.path.replaceAll('\\', '/');
      final righe = file.readAsLinesSync();
      for (var n = 0; n < righe.length; n++) {
        final riga = righe[n];
        if (riga.trimLeft().startsWith('//')) continue;
        // Il contesto sta sulla riga o nelle DUE precedenti: una decorazione
        // con un colore condizionale si scrive su tre righe, e guardarne solo
        // una lasciava passare il bordo di rune_draw_screen.
        final contesto =
            riga + (n > 0 ? righe[n - 1] : '') + (n > 1 ? righe[n - 2] : '');
        if (nonSonoTesti.any(contesto.contains)) continue;
        final trovato = RegExp(
                r'text(?:Secondary|Muted)\s*\.withValues\(alpha:\s*([0-9.]+)\s*[,)*]')
            .firstMatch(riga);
        if (trovato == null) continue;
        osservati++;
        final alfa = double.parse(trovato.group(1)!);
        final visto = composto(
            ColorTokens.textSecondary.withValues(alpha: alfa), fondoPeggiore);
        final quanto = contrasto(visto, fondoPeggiore);
        if (quanto >= soglia) continue;
        if (perdonati.containsKey(percorso)) continue;
        colpe.add('$percorso riga ${n + 1}: alfa $alfa da '
            '${quanto.toStringAsFixed(2)} a 1');
      }
    }
    // ignore: avoid_print
    print('ORDINE AS VOCE 05: testi grigi con opacita osservati $osservati, '
        'sotto la soglia ${colpe.length}');
    expect(osservati, greaterThan(0),
        reason: 'la ricerca non ha trovato nessun grigio sbiadito: gira a '
            'vuoto, e va rifatta');
    expect(colpe, isEmpty,
        reason: 'questi testi grigi non arrivano a $soglia a 1 sul fondo piu '
            'scuro, cioe non si leggono: ${colpe.join("; ")}');
  });
}
