import 'package:esoteric_circle/design_system/tokens/typography_tokens.dart';
import 'package:flutter_test/flutter_test.dart';

import 'sorgenti_di_lib.dart';

/// Nessuna misura tipografica sotto il minimo del suo token.
///
/// I tre costruttori di `TypographyTokens` alzano la misura al minimo con un
/// `math.max`, quindi chiedere `label(size: 10)` e `label(size: 12)` produce lo
/// stesso identico risultato a video: 12.5. Il codice dichiara una gerarchia che
/// lo schermo non puo' onorare, e nessuno se ne accorge perche' il clamp e'
/// silenzioso. Questo test lo rende rumoroso: chiedere una misura impossibile e'
/// un bug, non una svista di stile.
///
/// Si legge il SORGENTE e non l'albero dei widget, cosi' la regola vale anche
/// per le schermate che nessun test monta.
/// Nessuna eccezione: la lista e' vuota di proposito.
///
/// C'era un debito congelato di 63 file, con 457 chiamate su 571 sotto il
/// minimo. Quella misura ha portato alla decisione giusta, che non era
/// bonificare i punti di chiamata ma correggere i minimi: erano 20, 17 e 12.5,
/// cioe' misure di progetto travestite da soglie di leggibilita', e schiacciavano
/// in silenzio la gerarchia che il codice dichiarava. Ora valgono 16, 13 e 11, e
/// sono quel che devono essere: una rete contro il testo illeggibile.
///
/// Con quei minimi il debito e' rientrato e l'insieme resta vuoto. Se qualcuno
/// dovesse riaggiungere un'eccezione qui, si fermi prima: o la misura chiesta e'
/// davvero illeggibile e va alzata, oppure e' il minimo a essere di nuovo
/// sbagliato, e allora si corregge quello.
const debitoStorico = <String>{};

void main() {
  test('Nessuna misura tipografica sotto il minimo del suo token', () {
    // IL MINIMO VERO E' IL PIU' ALTO FRA QUELLO DI FAMIGLIA E IL PAVIMENTO.
    //
    // Dall'ordine A il pavimento dell'app vale 12 e nessuna famiglia puo'
    // scendere sotto. Senza questo massimo le due regole direbbero cose
    // diverse: `label(size: 11)` sarebbe lecita qui, perche' `minLabel` vale
    // 11, e in debug farebbe scattare l'assert del pavimento. Una regola che
    // vale a runtime e non nel sorgente si scopre sempre troppo tardi.
    double minimoVero(double diFamiglia) =>
        diFamiglia > TypographyTokens.pavimento
            ? diFamiglia
            : TypographyTokens.pavimento;
    final minimi = <String, double>{
      'label': minimoVero(TypographyTokens.minLabel),
      'body': minimoVero(TypographyTokens.minBody),
      'display': minimoVero(TypographyTokens.minDisplay),
    };
    // Cattura TypographyTokens.label(size: 10), anche con altri argomenti dopo.
    final chiamata = RegExp(
        r'TypographyTokens\.(label|body|display)\(\s*size:\s*([0-9]+(?:\.[0-9]+)?)');

    final colpevoli = <String>[];
    for (final f in sorgentiDiLib()
        .where((f) => !debitoStorico.contains(f.path.replaceAll(r'\', '/')))) {
      final righe = f.readAsLinesSync();
      for (var i = 0; i < righe.length; i++) {
        for (final m in chiamata.allMatches(righe[i])) {
          final famiglia = m.group(1)!;
          final misura = double.parse(m.group(2)!);
          final minimo = minimi[famiglia]!;
          if (misura < minimo) {
            colpevoli.add('${f.path.replaceAll(r'\', '/')}:${i + 1} '
                '$famiglia(size: $misura) sotto il minimo $minimo');
          }
        }
      }
    }

    expect(
      colpevoli,
      isEmpty,
      reason:
          'Misure tipografiche sotto il minimo del token: verrebbero alzate '
          'in silenzio dal clamp, quindi la gerarchia dichiarata non esiste a '
          'video. Alza la misura richiesta a un valore reale, e se il layout non '
          'la regge sistema il layout: i minimi esistono per leggibilita\'.\n'
          '${colpevoli.join('\n')}',
    );
  });
}
