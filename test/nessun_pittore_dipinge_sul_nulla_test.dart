import 'package:esoteric_circle/features/maestri/caligo/viaggio/la_nebbia_e_l_animale.dart';
import 'package:esoteric_circle/features/maestri/caligo/viaggio/il_tunnel_che_scende.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'sorgenti_di_lib.dart';
import 'cardinale_minimo.dart';

/// **NESSUN PITTORE DIPINGE SUL NULLA.** Ordine DC voce 21, 10 settembre 2026.
///
/// **NASCE DA UN DIFETTO VISTO DUE VOLTE SULLO STESSO SCHERMO.** L'incontro
/// del Viaggio dello Sciamano era uno schermo vuoto. La prima volta l'ho dato
/// al contrasto e ho aggiunto la luce dietro alla sagoma; ricostruito e
/// riprovato sul telefono 767f596c, **era ancora uno schermo vuoto**.
///
/// La causa era un'altra e non aveva niente a che vedere col colore.
/// **`CustomPaint`, quando non ha un figlio e non riceve `size`, si misura
/// con `constraints.constrain(Size.zero)`.** Dentro una `Row` o una `Column`
/// il vincolo trasversale e' largo, non stretto: una delle due dimensioni
/// diventa zero, e il pittore riceve una tela di area nulla. Dipinge
/// perfettamente su niente.
///
/// **PERCHE' NESSUNA GUARDIA POTEVA VEDERLO.** Tutte le guardie dei pittori
/// del Viaggio chiamano `pittore.paint(tela, misura)` con una misura che
/// scelgono loro. Sono giuste e restano, ma **misurano il pittore, non il
/// posto dove il pittore vive**. Questa guardia misura il posto.
///
/// Regola I: cio' che si vede si misura in pixel dipinti, nella finestra vera
/// dove convive con tutto il resto. Una tela di area zero e' zero pixel
/// dipinti, e nessuna quota percentuale se ne accorge, perche' zero diviso
/// zero non e' una percentuale bassa: non e' niente.
void main() {
  group('DC.21, i pittori hanno una tela', () {
    testWidgets('UN CUSTOMPAINT SENZA FIGLIO DENTRO UNA COLUMN E LARGO ZERO',
        (tester) async {
      // **LA PROVA CHE IL DIFETTO E' REALE**, e non una mia ricostruzione.
      // Senza `size`, in una Column, la larghezza e' zero.
      await tester.pumpWidget(MaterialApp(
        home: Column(
          children: [
            Expanded(
              child: CustomPaint(
                key: const Key('senza_misura'),
                painter: PittoreDellAnimale(
                    discesa: 3, quantaLuce: 1.0, seme: 7),
              ),
            ),
            Expanded(
              child: CustomPaint(
                key: const Key('con_misura'),
                size: Size.infinite,
                painter: PittoreDellAnimale(
                    discesa: 3, quantaLuce: 1.0, seme: 7),
              ),
            ),
          ],
        ),
      ));
      final senza = tester.getSize(find.byKey(const Key('senza_misura')));
      final con = tester.getSize(find.byKey(const Key('con_misura')));
      // ignore: avoid_print
      print('ORDINE DC VOCE 21: senza size la tela e $senza, con size e $con');
      expect(senza.width, 0,
          reason: 'il difetto non e piu riproducibile: se CustomPaint senza '
              'size prendesse tutta la larghezza, questa guardia non '
              'servirebbe piu e va tolta invece che tenuta verde per finta');
      expect(con.width, greaterThan(0));
      expect(con.height, greaterThan(0));
    });

    test('OGNI CUSTOMPAINT DEL VIAGGIO E DEL PASSAPORTO DICHIARA LA MISURA',
        () {
      // **SI CONTA TUTTA L'APP E SI PRETENDE SU CIO' CHE QUEST'ORDINE
      // POSSIEDE**, e la differenza fra i due numeri e' essa stessa
      // un'informazione.
      //
      // La trappola e' del componente, quindi il censimento gira su tutto
      // `lib` e stampa quanti `CustomPaint` senza figlio esistono e quanti
      // non dichiarano una misura. **Molti di quelli sono innocenti**: dentro
      // un `Positioned.fill`, un `SizedBox` con due lati o un `AspectRatio` il
      // vincolo e' stretto, e `constrain(Size.zero)` restituisce la misura
      // piena. Distinguere gli innocenti dai colpevoli guardando il testo
      // sorgente non si puo' fare in modo affidabile: **si potrebbe solo
      // montandoli tutti**, che e' un ordine a se'.
      //
      // **DICHIARATO, non fatto**: il censimento dell'intera app resta da
      // riparare, e il numero stampato qui dice quanto e' grande.
      final sorgenti = sorgentiDiCartelle(const [
        'lib/features/maestri/caligo/viaggio',
        'lib/features/passport',
      ], minimo: 4);
      final colpevoli = <String>[];
      var trovati = 0;
      var senzaMisuraInTutto = 0;
      // **I PERCORSI SI CONFRONTANO NORMALIZZATI.**
      //
      // Difetto trovato provando questa guardia col difetto innestato, come
      // vuole la Regola A: il censimento saliva da 69 a 70 e i colpevoli
      // restavano zero. Le due porte comuni tornano i percorsi in due forme
      // diverse, e un confronto fra stringhe grezze non li riconosceva.
      // **Un confronto che non trova mai niente e' una guardia sempre verde.**
      String piano(String p) =>
          p.replaceAll(RegExp(r'[\\/]'), '/').toLowerCase();
      final suoi = {for (final g in sorgenti) piano(g.path)};
      // **OGNI FILE UNA VOLTA SOLA**: le due cartelle stanno dentro `lib`, e
      // scorrerle due volte gonfierebbe il censimento.
      for (final f in sorgentiDiLib()) {
        final suo = suoi.contains(piano(f.path));
        final testo = f.readAsStringSync();
        var da = 0;
        while (true) {
          final i = testo.indexOf('CustomPaint(', da);
          if (i < 0) break;
          da = i + 12;
          // Il corpo della chiamata, fino alla parentesi che la chiude.
          var livello = 1;
          var j = da;
          while (j < testo.length && livello > 0) {
            if (testo[j] == '(') livello++;
            if (testo[j] == ')') livello--;
            j++;
          }
          final corpo = testo.substring(da, j);
          // Si guarda solo il primo livello: un figlio annidato ha le sue
          // parentesi e non conta come `child:` di questo CustomPaint.
          final primoLivello = _soloPrimoLivello(corpo);
          if (primoLivello.contains('child:')) continue;
          trovati++;
          if (!primoLivello.contains('size:')) {
            senzaMisuraInTutto++;
            if (!suo) continue;
            final riga = '\n'.allMatches(testo.substring(0, i)).length + 1;
            colpevoli.add('${f.path.split(RegExp(r'[\\/]')).last}:$riga');
          }
        }
      }
      // ignore: avoid_print
      print('ORDINE DC VOCE 21: CustomPaint senza figlio guardati '
          '$trovati, senza misura in tutta l app '
          '$senzaMisuraInTutto, dei quali nel Viaggio e nel '
          'Passaporto ${colpevoli.length}');
      cardinaleMinimo(trovati, 3,
          cosa: 'CustomPaint senza figlio nel codice',
          perche: 'Se non ne trovasse nessuno, questa guardia sarebbe verde '
              'per non aver guardato niente, e il giorno che qualcuno ne '
              'scrive uno sbagliato non se ne accorgerebbe.');
      expect(colpevoli, isEmpty,
          reason: 'questi CustomPaint non hanno ne figlio ne size, quindi si '
              'misurano con constrain(Size.zero) e dipingono su una tela di '
              'area nulla appena il vincolo non e stretto: '
              '${colpevoli.join(", ")}');
    });

    testWidgets('IL TUNNEL, DENTRO UN POSITIONED.FILL, RICEVE LA SCENA INTERA',
        (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(const MaterialApp(
        home: Stack(children: [
          Positioned.fill(
            child: TunnelCheScende(quantoSiEScesi: 0.5, senzaMoto: false),
          ),
        ]),
      ));
      final misura = tester.getSize(find.byType(TunnelCheScende));
      // ignore: avoid_print
      print('ORDINE DC VOCE 21: il tunnel riceve una tela di $misura');
      expect(misura.width, 390);
      expect(misura.height, 844);
    });
  });
}

/// Cio' che sta al primo livello di parentesi, cioe' gli argomenti di questa
/// chiamata e non quelli delle chiamate annidate.
String _soloPrimoLivello(String corpo) {
  final fuori = StringBuffer();
  var livello = 0;
  for (var i = 0; i < corpo.length; i++) {
    final c = corpo[i];
    if (c == '(' || c == '[') livello++;
    if (livello == 0) fuori.write(c);
    if (c == ')' || c == ']') livello--;
  }
  return fuori.toString();
}
