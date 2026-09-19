import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **UN COMANDO DI DISTRIBUZIONE HA IL SUO CONTROLLO, E IL CONTROLLO NON
/// INVECCHIA.** Ordine CQ voce 6.12, 4 settembre 2026.
///
/// **Il fatto, misurato sul PC del fondatore.** Il comando
/// `npx firebase deploy --only functions:attivaIlPianoInDemo` ha risposto
/// *No function matches the filter*, e la funzione sembrava non essere mai
/// stata scritta. **Era scritta e spinta**, col commit `9d980de1`: la cartella
/// era ferma **sessantotto commit indietro**, e quel comando cerca la funzione
/// nei file sul disco, non nel ramo.
///
/// **La causa vera non era che mancasse il controllo: il controllo c'era, e
/// diceva il falso.** Il PASSO 0 esisteva dal 31 agosto e chiedeva di leggere
/// lo sha della testa, dicendo *NON deve cominciare con `078d24b4`*. La
/// cartella era a `24eaf172`, che non e' `078d24b4`: il controllo dava il via
/// libera su un albero vecchio di tre giorni.
///
/// **Uno sha scritto a mano invecchia a ogni consegna.** E' la stessa malattia
/// per cui in questo progetto un manifesto non si confronta col registro di
/// oggi: il giorno dopo il confronto e' vero e non vuol dire piu' niente.
///
/// **Cosa misura questa guardia.** Che il controllo dell'albero chieda il
/// numero a git invece di nominare uno sha, e che dica di fermarsi. Non
/// giudica come e' scritto: giudica che la grandezza confrontata sia una che
/// non invecchia.
void main() {
  final foglio =
      File('docs/ordini/DISTRIBUZIONI_DAL_TUO_PC.md').readAsStringSync();

  test('il controllo dell albero chiede il numero a git, non uno sha', () {
    // La grandezza che non invecchia: quanti commit mancano alla testa.
    final chiedeAGit = foglio.contains('git rev-list --count HEAD..origin/');
    // ignore: avoid_print
    print('ORDINE CQ VOCE 6.12: il foglio chiede il conto a git $chiedeAGit');
    expect(chiedeAGit, isTrue,
        reason: 'il controllo dell albero non chiede a git quanti commit '
            'mancano: qualunque altra forma nomina un valore scritto a mano, '
            'che il giorno della consegna dopo da il via libera su un albero '
            'vecchio');

    // **E NESSUNO SHA RESTA COME CRITERIO.** Una riga che dice "non deve
    // cominciare con X" e' il difetto di questa voce, e qui si impedisce che
    // torni: il criterio non puo' essere un valore di allora.
    final comeCriterio = RegExp(
            r'(NON con|non deve cominciare con|deve cominciare con)[^\n]{0,40}`+[0-9a-f]{7,40}`')
        .allMatches(foglio)
        .map((m) => m.group(0)!)
        .toList();
    expect(comeCriterio, isEmpty,
        reason: 'il foglio usa ancora uno sha scritto a mano come criterio, e '
            'quel criterio invecchia alla consegna dopo: '
            '${comeCriterio.join(" | ")}');
  });

  test('il controllo dice di fermarsi, e sta prima di ogni distribuzione', () {
    final doveIlControllo = foglio.indexOf('git rev-list --count HEAD..origin/');
    // I comandi di distribuzione, scoperti leggendo il foglio: un elenco
    // scritto a mano qui direbbe verde il giorno che ne compare uno nuovo.
    final comandi = RegExp(r'firebase deploy --only functions:(\w+)')
        .allMatches(foglio)
        .map((m) => (nome: m.group(1)!, dove: m.start))
        .toList();
    // ignore: avoid_print
    print('ORDINE CQ VOCE 6.12: comandi di distribuzione ${comandi.length}, il '
        'controllo dell albero sta al carattere $doveIlControllo, il primo '
        'comando al ${comandi.isEmpty ? -1 : comandi.first.dove}');
    cardinaleMinimo(comandi.length, 4,
        cosa: 'comandi di distribuzione di funzioni nel foglio',
        perche: 'Senza comandi la prova direbbe che tutti sono coperti per '
            'non averne letto nessuno, ed e la prima specie di cecita.');

    final prima = comandi.where((c) => c.dove < doveIlControllo).toList();
    expect(prima, isEmpty,
        reason: 'questi comandi di distribuzione stanno PRIMA del controllo '
            'dell albero, quindi si possono lanciare senza averlo mai letto: '
            '${prima.map((c) => c.nome).join(", ")}');

    // **UN CONTROLLO SENZA IL SUO RIPIEGO E' UN CONTROLLO A META'.** Leggere
    // un numero e non sapere cosa vuol dire e' la posizione in cui il
    // fondatore si e' trovato il 4 settembre.
    final seguito = foglio.substring(
        doveIlControllo,
        doveIlControllo + 500 < foglio.length
            ? doveIlControllo + 500
            : foglio.length);
    expect(seguito.contains('FERMATI QUI'), isTrue,
        reason: 'il controllo non dice di fermarsi quando il numero non e '
            'zero: chi legge un numero senza istruzioni tira avanti');
  });

  test('e la funzione piu recente si controlla per nome', () {
    // **LA PORTA DELLA DEMO IN PARTICOLARE**, perche' e' quella su cui la
    // voce e' nata: il controllo generale dice che l'albero e' avanti, questo
    // dice che quella funzione precisa e' sul disco.
    final doveIlControllo = foglio.indexOf('-Pattern attivaIlPianoInDemo');
    final doveIlComando = foglio.indexOf('functions:attivaIlPianoInDemo');
    // ignore: avoid_print
    print('ORDINE CQ VOCE 6.12: il controllo della porta della Demo sta al '
        'carattere $doveIlControllo, il comando al $doveIlComando');
    expect(doveIlControllo, greaterThanOrEqualTo(0),
        reason: 'la porta della Demo si distribuisce senza che nessuno dica '
            'come accorgersi che il codice NON e sul disco');
    expect(doveIlControllo, lessThan(doveIlComando),
        reason: 'il controllo della porta della Demo viene DOPO il comando '
            'che la distribuisce, quindi non serve a niente');
  });
}
