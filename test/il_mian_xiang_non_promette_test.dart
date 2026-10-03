import 'dart:io';

import 'package:esoteric_circle/core/face/face_trait.dart';
import 'package:esoteric_circle/core/face/mian_xiang.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **IL MIAN XIANG NON PROMETTE E NON DIAGNOSTICA.** Ordine CR voci 06 e 11,
/// 6 settembre 2026.
///
/// **Due confini, e vengono da due posti diversi.**
///
/// Il primo e' la legge di casa che vale per ogni responso: **non si promette
/// un esito**. E' particolarmente facile violarla qui, perche' la tradizione
/// stessa parla di ricchezza e di longevita': il *Palazzo della Ricchezza* e'
/// il nome che il naso ha da secoli, e chiamarlo cosi' e' corretto. Prometterne
/// il contenuto non lo e'.
///
/// Il secondo lo scrive l'ordine CR voce 11: *"Nel testo che la persona legge
/// non compaiono mai le parole diagnosi, disturbo, patologia, ne' nomi di
/// condizioni. La funzione parla di espressione e di tradizione, mai di
/// salute."*
///
/// **E UNA TERZA PRETESA, CHE E' LA PIU' IMPORTANTE.** Che il corpus non
/// contenga i dodici palazzi. Non perche' siano sbagliati, ma perche' non li ho
/// potuti verificare su nessuna fonte leggibile: se un giorno comparissero
/// senza che le fonti siano state lette, questa prova cade e dice perche'.
void main() {
  /// Tutto il testo che la persona legge da questo corpus.
  List<String> testiCheSiLeggono() => [
        for (final e in ElementoDelVolto.values) e.lettura,
        for (final e in ElementoDelVolto.values) e.comeSiRiconosce,
        for (final u in UfficialeDelVolto.values) u.nome,
      ];

  test('nessuna lettura promette un esito', () {
    const promesse = [
      'otterrai', 'avrai', 'sarai', 'ti portera', 'vedrai', 'accadra',
      'succedera', 'riceverai', 'diventerai', 'guadagnerai', 'troverai',
    ];
    final colpe = <String>[];
    var guardati = 0;
    for (final t in testiCheSiLeggono()) {
      guardati++;
      for (final p in promesse) {
        if (t.toLowerCase().contains(p)) colpe.add('"$t" -> $p');
      }
    }
    // ignore: avoid_print
    print('ORDINE CR VOCE 06: testi del corpus guardati $guardati, che '
        'promettono un esito ${colpe.length}');
    cardinaleMinimo(guardati, 12,
        cosa: 'testi del corpus del Mian Xiang riletti',
        perche: 'Con pochi testi la prova direbbe che nessuno promette niente '
            'per non averne letti abbastanza.');
    expect(colpe, isEmpty,
        reason: 'questi testi promettono un esito, e la tradizione qui e '
            'particolarmente insidiosa perche parla di ricchezza e longevita: '
            'il nome del palazzo si puo dire, il suo contenuto no. '
            '${colpe.join(" | ")}');
  });

  test('e nessuna parla di salute', () {
    const vietate = [
      'diagnosi', 'disturbo', 'patologia', 'malattia', 'sintomo', 'cura',
      'terapia', 'depress', 'ansia', 'ansios', 'stress',
    ];
    final colpe = <String>[];
    for (final t in testiCheSiLeggono()) {
      for (final v in vietate) {
        if (t.toLowerCase().contains(v)) colpe.add('"$t" -> $v');
      }
    }
    // ignore: avoid_print
    print('ORDINE CR VOCE 11: testi che nominano la salute ${colpe.length}');
    expect(colpe, isEmpty,
        reason: 'questi testi parlano di salute: la funzione legge un volto e '
            'una tradizione, e non ha nessun titolo per dire a qualcuno come '
            'sta. ${colpe.join(" | ")}');
  });

  test('e il corpus non contiene i dodici palazzi, che non ho verificato', () {
    // **QUESTA PRETESA PROTEGGE UN LIMITE DICHIARATO**, non un difetto. I
    // dodici palazzi sono un impianto vero della tradizione, ma l'elenco delle
    // zone e degli ambiti non l'ho trovato su nessuna fonte verificabile.
    // Se comparissero, o qualcuno ha letto le fonti (e allora si aggiorna
    // questa prova e il documento) o li ha inventati.
    final corpus = File('lib/core/face/mian_xiang.dart').readAsStringSync();
    final fonti = File('docs/viso/mian_xiang_fonti.md');
    expect(fonti.existsSync(), isTrue,
        reason: 'il documento delle fonti non esiste: l ordine CR voce 06 '
            'chiede di dichiarare quali fonti sono state usate');
    final testoFonti = fonti.readAsStringSync();
    cardinaleMinimo(testoFonti.length, 1500,
        cosa: 'caratteri del documento delle fonti',
        perche: 'Un documento delle fonti vuoto non dichiara niente e la '
            'prova passerebbe senza aver letto nulla.');

    final dichiaraIlLimite = testoFonti.contains('NON ENTRANO i dodici palazzi');
    // **SI CONTANO LE STRINGHE, NON I COMMENTI.** La prima stesura contava
    // cinque palazzi e ne accusava uno di troppo: il quinto stava dentro un
    // commento che SPIEGA la regola, cioe' la guardia accusava la propria
    // documentazione. E' la famiglia della guardia legata al token invece
    // che al fatto, e in questo progetto e' gia' costata sei cadute.
    final righeVive = corpus
        .split(String.fromCharCode(10))
        .where((r) => !r.trimLeft().startsWith('//'))
        .join(String.fromCharCode(10));
    final nelCorpus = RegExp(r'[Pp]alazz\w+\s+(dell|di)')
        .allMatches(righeVive)
        .length;
    // ignore: avoid_print
    print('ORDINE CR VOCE 06: nomi di palazzo nel corpus $nelCorpus, il '
        'documento dichiara il limite $dichiaraIlLimite');
    expect(dichiaraIlLimite, isTrue,
        reason: 'il documento delle fonti non dichiara piu che i dodici '
            'palazzi restano fuori: o sono entrati, o il limite e stato '
            'cancellato invece che superato');
    // I quattro ufficiali portano un nome di palazzo ciascuno, ed e' corretto:
    // quello e' il loro nome nella tradizione. Dodici sarebbero un'altra cosa.
    expect(nelCorpus, lessThanOrEqualTo(UfficialeDelVolto.values.length),
        reason: 'nel corpus compaiono $nelCorpus nomi di palazzo, piu dei '
            '${UfficialeDelVolto.values.length} ufficiali: sono entrati i '
            'dodici palazzi senza che le fonti siano state lette');
  });

  test('e ogni forma misurata trova il suo elemento, o nessuno', () {
    // **NESSUN ELEMENTO ASSEGNATO A CASO.** Il classificatore conosce quattro
    // forme e gli elementi sono cinque: il Metallo non ha una forma sua nel
    // nostro impianto e resta fuori, invece di essere appiccicato alla forma
    // che gli somiglia di piu'.
    final forme = FaceTrait.values
        .where((t) => t.categoria == FaceCategory.formaVolto)
        .toList();
    final tradotte = forme.where((f) => MianXiang.elementoDa(f) != null);
    // ignore: avoid_print
    print('ORDINE CR VOCE 06: forme del volto ${forme.length}, con un '
        'elemento ${tradotte.length}, elementi raggiungibili '
        '${MianXiang.elementiRaggiungibili.length} su '
        '${ElementoDelVolto.values.length}');
    cardinaleMinimo(forme.length, 4,
        cosa: 'forme del volto che il classificatore conosce',
        perche: 'Con poche forme la prova direbbe che sono tutte tradotte per '
            'non averne guardate abbastanza.');
    expect(tradotte.length, forme.length,
        reason: 'queste forme non trovano nessun elemento, e chi le ottiene '
            'resta senza la parte piu visibile del responso');
    final duplicati = MianXiang.elementiRaggiungibili.length != tradotte.length;
    expect(duplicati, isFalse,
        reason: 'due forme diverse portano allo stesso elemento: la lettura '
            'perderebbe una distinzione che la misura invece fa');
  });
}
