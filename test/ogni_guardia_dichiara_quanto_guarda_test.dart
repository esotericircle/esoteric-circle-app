import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'codice_senza_testo.dart';

/// OGNI GUARDIA CHE SCORRE I SORGENTI DICHIARA QUANTO HA GUARDATO.
/// Ordine CL voce 04.
///
/// **E' la voce che vale piu' di tutte le altre di quell'ordine messe
/// insieme, perche' uccide due specie di cecita' su quattro e costa
/// pochissimo.**
///
/// Una guardia che gira su un insieme scoperto a esecuzione **diventa verde
/// quando quell'insieme e' vuoto**: non trova difetti perche' non guarda
/// niente. Nell'ordine CI ne sono state trovate quattro cosi', per caso,
/// mentre si lavorava ad altro, e tutte e quattro erano verdi.
///
/// **Le due specie che questa regola uccide.** Quella VUOTA PER COSTRUZIONE
/// non puo' nascere, perche' un insieme vuoto diventa rosso il giorno stesso.
/// Quella DEGRADATA non puo' sopravvivere, perche' la modifica che toglie il
/// bersaglio a una guardia la fa cadere **dentro lo stesso lavoro che l'ha
/// causata**, invece che tre ordini dopo.
///
/// **La forma della regola.** Chi scorre i sorgenti di `lib` passa da
/// `sorgentiDiLib()`, che il cardinale lo dichiara una volta per tutti.
/// Oppure dichiara il proprio, con un `expect` sul numero di elementi
/// guardati. Chi non fa ne' l'una ne' l'altra sta in un elenco scritto qui
/// sotto, **e quell'elenco puo' solo accorciarsi**.
void main() {
  /// **IL DEBITO E' CHIUSO, e questo elenco e' vuoto.** Ordine CM voce
  /// 02, 1 settembre 2026.
  ///
  /// L'ordine CL aveva lasciato settantotto guardie che scorrevano i
  /// sorgenti senza dichiarare quanto guardavano: non cieche, ma senza
  /// modo di sapere se il loro verde valesse. Sessantasei sono passate
  /// alla porta comune `sorgentiDiLib()`, cinque a `sorgentiDiCartelle()`
  /// perche' guardano anche `test` e `tool`, una si e' scritta il
  /// cardinale proprio sul sottoinsieme che filtra.
  ///
  /// **L'elenco resta qui da vuoto, e non e' un residuo da cancellare.**
  /// E' il posto dove una deroga futura dovra' scriversi col suo perche',
  /// sotto gli occhi di chi legge questa prova, invece di nascondersi
  /// dentro una guardia. La prova qui sotto pretende che resti vuoto:
  /// **una deroga si aggiunge solo con una decisione, mai per inerzia.**
  const senzaCardinale = <String>{};

  test('chi scorre i sorgenti dichiara quanto ha guardato', () {
    final nudi = <String>[];
    var scorrono = 0;
    for (final f in Directory('test').listSync()) {
      if (f is! File || !f.path.endsWith('_test.dart')) continue;
      final nome = f.path.split(Platform.pathSeparator).last;
      // **SI GUARDA CIO' CHE IL SORGENTE CHIAMA, non cio' che nomina.**
      // Due prove citano `Directory('lib')` dentro una stringa, perche'
      // il loro mestiere e' cercarlo nelle altre: contarle fra chi
      // scorre i sorgenti le classificava male, e il conto restava
      // coerente con se stesso. **Un conto sbagliato che quadra non
      // chiede di essere guardato**, ed e' il peggiore.
      final nudo = codiceSenzaTesto(f.readAsStringSync());

      // **LA POPOLAZIONE E' PIU' LARGA DI `lib`.** Fino al 1 settembre
      // 2026 questa prova guardava solo chi scorreva i sorgenti di
      // `lib`. Ma la cecita' non riguarda quella cartella: riguarda
      // **qualunque insieme di file scoperto a esecuzione**, e ventisette
      // guardie scoprono cartelle diverse, le anteprime, il corredo, gli
      // asset. Restringere a `lib` lasciava fuori proprio quelle che
      // guardano cose che cambiano piu' spesso.
      final dallaPorta = nudo.contains('sorgentiDiLib(') ||
          nudo.contains('sorgentiDiCartelle(') ||
          nudo.contains('righeDiLib(');
      // **IL GESTO CHE SCOPRE E' ELENCARE, non costruire.** Alcune
      // prove costruiscono una `Directory` per SCRIVERCI dentro
      // un'anteprima: non scoprono niente, e pretendere da loro un
      // cardinale vorrebbe dire chiedere il minimo di un insieme che
      // non guardano.
      final scopreUnInsieme = dallaPorta || nudo.contains('.listSync(');
      if (!scopreUnInsieme) continue;
      scorrono++;

      // Il cardinale si dichiara in tre modi: passando da una delle due
      // porte comuni, chiamando cardinaleMinimo di persona, oppure con un
      // expect sul numero di cose guardate.
      if (dallaPorta) continue;
      if (nudo.contains('cardinaleMinimo(')) continue;
      // **LE FORME LEGITTIME DI CARDINALE SONO QUATTRO**, e non una
      // sola. Fino al 1 settembre 2026 questa prova ne riconosceva
      // una, e accusava di essere nude due guardie che il loro
      // cardinale ce l'avevano da sempre, una perfino piu' forte del
      // minimo: `expect(misure.length, 24)` dice quante cose devono
      // esserci, non quante almeno.
      //
      // **Riconoscere una forma sola non e' rigore, e' un'accusa
      // sbagliata**, e le accuse sbagliate insegnano a non credere
      // alla guardia che le fa.
      final forme = [
        // Un minimo esplicito: expect(quanti, greaterThan(...)).
        RegExp(r'expect\((quanti|guardati|controllate|usi|trovate|censiti|'
            r'esaminate|contate|scorrono|osservate|[a-zA-Z]+\.length), '
            r'greaterThan'),
        // Un numero esatto: expect(misure.length, 24).
        RegExp(r'expect\([a-zA-Z]+\.length, [1-9][0-9]*'),
        // Il minimo piu' debole che esista, ma dichiarato: uno.
        RegExp(r'expect\([a-zA-Z]+, isNotEmpty'),
      ];
      if (forme.any((f) => f.hasMatch(nudo))) continue;
      if (senzaCardinale.contains(nome)) continue;
      nudi.add(nome);
    }

    // Senza questa riga, il giorno che nessuna guardia scorresse piu' i
    // sorgenti questa prova sarebbe verde avendo guardato zero guardie: e'
    // la stessa cecita' che sta sorvegliando, applicata a se stessa.
    expect(scorrono, greaterThanOrEqualTo(90),
        reason: 'questa prova ha trovato solo $scorrono guardie che scorrono '
            'i sorgenti: o sono sparite, o non le sta piu\' riconoscendo, e '
            'in tutti e due i casi non sta sorvegliando niente');

    expect(nudi, isEmpty,
        reason: 'queste guardie scorrono i sorgenti senza dichiarare quanto '
            'guardano, quindi diventerebbero VERDI su un insieme vuoto:\n'
            '${nudi.join("\n")}\n'
            'Passa da sorgentiDiLib(), che il cardinale lo dichiara per tutti, '
            'oppure scrivi il tuo con un expect sul numero di elementi '
            'guardati. L\'elenco delle deroghe puo\' solo accorciarsi.');

    // ignore: avoid_print
    print('ORDINE CM VOCE 02: guardie che scorrono i sorgenti $scorrono, '
        'senza cardinale ${nudi.length + senzaCardinale.length}');
  });

  test(
      'l\'elenco delle deroghe e\' vuoto, e ogni nome che ci torni e\' una decisione',
      () {
    // **QUESTA PROVA NON E' VUOTA PER COSTRUZIONE anche se l'elenco lo
    // e'.** Cade nel momento esatto in cui qualcuno rimette un nome qui
    // dentro, ed e' il punto: dopo l'ordine CM, aggiungere una deroga
    // non e' piu' una riga silenziosa, e' una prova rossa che chiede di
    // essere motivata.
    expect(senzaCardinale, isEmpty,
        reason:
            'qualcuno ha rimesso una deroga nell\'elenco: $senzaCardinale.\n'
            'Il debito era chiuso il 1 settembre 2026. Se la deroga serve '
            'davvero, scrivi QUI SOPRA perche\' quella guardia non puo\' '
            'passare da sorgentiDiLib() ne\' dichiarare un cardinale '
            'proprio, e allora la riga vale. Senza quel perche\' e\' '
            'soltanto un debito che torna.');

    // E le deroghe non restano appese a guardie che non esistono piu'.
    final sparite = <String>[];
    for (final nome in senzaCardinale) {
      if (!File('test/$nome').existsSync()) sparite.add(nome);
    }
    expect(sparite, isEmpty,
        reason:
            'queste deroghe non hanno piu\' una guardia da scusare: $sparite');
  });
}
