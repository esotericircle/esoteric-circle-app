import 'dart:io';

import 'package:esoteric_circle/core/maestro/frase_di_ripiego.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:flutter_test/flutter_test.dart';

/// LA PAROLA "VOCE" RESTA ALL'AUDIO.
///
/// **Il dato che ha fatto nascere questo file, dal fondatore.** Nell'app "voce"
/// fa pensare all'audio sintetizzato dei Maestri, quello che si compra col
/// piano. In almeno tre punti significava invece il Maestro: il pannello diceva
/// "Voce del Maestro: accesa", l'avviso diceva "la voce di Medora si attiva
/// quando...", e l'etichetta del ripiego diceva "Ripiego, non è la sua voce".
///
/// L'ultima era la peggiore, perche' arriva nel momento in cui la persona ha
/// gia' letto qualcosa che non capisce ed e' confusa.
///
/// **Perche' la prova scandisce tutto `lib` e non i tre punti noti.** E' la
/// stessa forma della prova sugli accenti: correggere i tre punti che qualcuno
/// ha visto lascia scoperto il quarto, e soprattutto lascia scoperto quello che
/// nasce domani. Chi scrivera' "la voce di Aura" fra un mese non avra' letto
/// questo ordine.
void main() {
  test('L\'etichetta del ripiego dice il Maestro, non la sua voce', () {
    for (final maestro in Maestro.values) {
      final etichetta = RipiegoDelMaestro.etichettaDi(maestro);
      expect(etichetta.toLowerCase(), isNot(contains('voce')),
          reason: 'l\'etichetta del ripiego di ${maestro.displayName} usa '
              'ancora la parola voce: "$etichetta"');
      // IL NOME VIENE DAL DATO, mai scritto a mano: il giorno che un Maestro
      // cambia nome, l'etichetta non resta indietro.
      expect(etichetta, contains(maestro.displayName),
          reason: 'l\'etichetta non nomina ${maestro.displayName}');
    }
  });

  test('Nessuna stringa mostrata usa "voce" per dire il Maestro', () {
    // I MODI IN CUI "VOCE" FINISCE PER SIGNIFICARE IL MAESTRO.
    //
    // Non basta cercare la parola: nell'app ci sono usi legittimi e frequenti,
    // "alzare la voce" nei significati degli Angeli, "Voce AI dei Maestri" nel
    // listino, che parla proprio dell'audio. Si cercano le FORME in cui la
    // parola prende il posto del Maestro.
    final forme = <RegExp>[
      RegExp(r'[Vv]oce (di|del|dei) [A-Z]'), // "voce di Medora"
      // IL NOME INTERPOLATO, ed e' la forma piu' certa di tutte.
      //
      // **Questa riga nasce da una prova del rosso rimasta VERDE.** Lo schema
      // qui sopra chiede una maiuscola dopo "di", e nell'avviso della chat
      // c'era "La voce di ${maestro.displayName}": un dollaro, non una
      // maiuscola. Rimettendo la frase vecchia la prova non se ne accorgeva,
      // e proprio nel caso in cui non c'e' nemmeno da interpretare, perche' il
      // nome viene dal dato del Maestro.
      RegExp(r'[Vv]oce (di|del|dei) \$'),
      RegExp(r'[Vv]oce del Maestro'),
      RegExp(r'[Vv]oce dei Maestri'),
      RegExp(r'la sua voce'),
      RegExp(r'[Ll]a mia voce'),
    ];

    // LE ECCEZIONI, dichiarate con la ragione accanto.
    //
    // **Un'eccezione di troppo mi ha nascosto un difetto vero.** Qui c'era
    // anche `frase_di_ripiego.dart`, escluso perche' la parola compare nei
    // commenti che raccontano perche' e' stata tolta. Ma i commenti sono gia'
    // saltati riga per riga: escludere il FILE escludeva anche le frasi
    // mostrate, e una di quelle diceva "e' solo la mia voce che te lo dice",
    // proprio nel ripiego di Medora, cioe' due righe sopra l'etichetta che
    // l'ordine chiamava la peggiore. L'ho vista nell'anteprima, non nella
    // prova. Si escludono i commenti, mai un file intero.
    //
    // Sono i punti in cui "voce" significa DAVVERO l'audio, cioe' il prodotto
    // che si compra, oppure e' una figura del parlare comune. Toglierle
    // sarebbe togliere la parola giusta dal posto giusto.
    const eccezioni = <String, String>{
      'lib/core/entitlement/plan_catalog.dart':
          'e\' il listino, e li\' "Voce AI dei Maestri" e\' proprio l\'audio '
              'sintetizzato che si compra col piano',
      'lib/core/astro/resonance.dart':
          'e\' la voce interiore che un aspetto chiama, una figura del '
              'parlare e non il Maestro che risponde',
      'lib/features/settings/settings_screen.dart':
          'e\' la sezione delle impostazioni AUDIO, intitolata "Voce e '
              'sottotitoli": li\' "la voce dei Maestri" e\' esattamente '
              'l\'audio sintetizzato che deve ancora arrivare',
    };

    final colpe = <String>[];
    final da = <FileSystemEntity>[Directory('lib')];
    while (da.isNotEmpty) {
      final voce = da.removeLast();
      if (voce is Directory) {
        da.addAll(voce.listSync());
        continue;
      }
      if (voce is! File || !voce.path.endsWith('.dart')) continue;
      final percorso = voce.path.replaceAll(Platform.pathSeparator, '/');
      if (eccezioni.containsKey(percorso)) continue;

      final righe = voce.readAsLinesSync();
      for (var i = 0; i < righe.length; i++) {
        final riga = righe[i];
        // I commenti non si mostrano a nessuno: una riga che SPIEGA la regola
        // non e' una violazione della regola.
        if (riga.trimLeft().startsWith('//')) continue;
        if (riga.trimLeft().startsWith('///')) continue;
        // Solo il testo dentro gli apici, cioe' quello che finisce a schermo.
        if (!riga.contains("'")) continue;
        if (!forme.any((f) => f.hasMatch(riga))) continue;
        colpe.add('$percorso riga ${i + 1}: ${riga.trim()}');
      }
    }

    expect(
      colpe,
      isEmpty,
      reason: 'qui "voce" significa il Maestro, e nell\'app "voce" e\' '
          'l\'audio: chi legge capisce un\'altra cosa.\n${colpe.join("\n")}',
    );
  });
}
