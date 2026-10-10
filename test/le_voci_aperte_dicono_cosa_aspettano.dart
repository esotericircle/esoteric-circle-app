// ignore_for_file: avoid_print
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **OGNI VOCE APERTA DICE QUALE GESTO ASPETTA.** Ordine FC voce 11, 5
/// ottobre 2026.
///
/// **LAPIDE.** Le guardie degli ordini EI, EJ, EK, EM ed EN pretendevano
/// zero voci aperte, ed erano rosse per costruzione (la REGOLA G del
/// fondatore, 4 settembre 2026). Diciannove voci aspettavano un gesto che
/// sul ramo non esiste e che il codice non puo' fare: il soffio vero del
/// fondatore, il suo orecchio, il suo sguardo, la sua scelta, una scrittura
/// in console che a Code e' negata. Il fondatore, ordine FC voce 11.1: *"Se
/// e' rossa perche' dipende da qualcosa che sul ramo non esiste, la
/// dipendenza si rimuove e la prova gira sul ramo da sola"*; e il 5 ottobre
/// 2026 ha scelto questa cura per queste cinque guardie, sapendo che la
/// REGOLA G cede per loro.
///
/// **Cosa pretende adesso, sul ramo**: che ogni voce abbia uno stato, che i
/// conti dei marcatori tornino, che ogni voce aperta porti una riga
/// `ASPETTA:` che dice, a una macchina e a una persona, quale gesto aspetta e
/// di chi, e che nessuna voce chiusa ne porti una. L'elenco dei gesti del
/// fondatore sta anche nel rapporto dell'ordine FC e in `docs/STATO_VIVO.md`.
/// Quando un gesto arriva, la voce si chiude col protocollo della chiusura e
/// la sua riga `ASPETTA:` si toglie.
void leVociAperteDiconoCosaAspettano(String sigla, int quante) {
  final testo =
      File('docs/ordini/ORDINE_${sigla}_MANIFESTO.md').readAsStringSync();
  int marcatore(String nome) {
    final m =
        RegExp('^$nome:\\s*(\\d+)\\s*\$', multiLine: true).firstMatch(testo);
    expect(m, isNotNull, reason: 'il manifesto non porta il marcatore $nome');
    return int.parse(m!.group(1)!);
  }

  final chiuse = marcatore('VOCI_CHIUSE');
  final aperte = marcatore('VOCI_APERTE');
  final dichiarate = marcatore('VOCI_TOTALI');
  final voci = testo.split(RegExp(r'^## VOCE ', multiLine: true)).skip(1);
  // Una voce finisce alla prossima sezione di secondo livello.
  final sezioni = [
    for (final v in voci) v.split(RegExp(r'^## ', multiLine: true)).first,
  ];
  cardinaleMinimo(sezioni.length, quante, cosa: 'voci dell\'ordine $sigla');
  final aperteContate = <String>[];
  final senzaAttesa = <String>[];
  final chiuseConAttesa = <String>[];
  for (final s in sezioni) {
    final nome = s.split('\n').first.split(',').first;
    final aspetta =
        RegExp(r'^ASPETTA: (.{20,})$', multiLine: true).firstMatch(s)?.group(1);
    // Lo stato e' la prima riga che comincia con **CHIUSA o **APERTA: il
    // racconto di una voce chiusa puo' citare la parola APERTA (EM.04 ed
    // EM.12, chiuse dall'ordine EN, raccontano com'erano).
    final stato = RegExp(r'^\*\*(CHIUSA|APERTA)', multiLine: true)
        .firstMatch(s)
        ?.group(1);
    expect(stato, isNotNull, reason: 'la voce $nome non dichiara uno stato');
    if (stato == 'APERTA') {
      aperteContate.add(nome);
      if (aspetta == null) senzaAttesa.add(nome);
    } else if (aspetta != null) {
      chiuseConAttesa.add(nome);
    }
  }
  print('ORDINE $sigla: voci $dichiarate, chiuse $chiuse, aperte $aperte, '
      'aperte che dicono cosa aspettano '
      '${aperteContate.length - senzaAttesa.length}');
  expect(dichiarate, quante,
      reason: 'il manifesto dichiara $dichiarate voci e sono $quante');
  expect(chiuse + aperte, quante,
      reason: 'chiuse piu\' aperte fanno ${chiuse + aperte} e le voci sono '
          '$quante: un conto che non torna nasconde una voce senza stato');
  expect(aperteContate.length, aperte,
      reason: 'il marcatore dice $aperte aperte e le voci aperte sono '
          '$aperteContate');
  expect(senzaAttesa, isEmpty,
      reason: 'voci aperte che non dicono quale gesto aspettano: '
          '$senzaAttesa');
  expect(chiuseConAttesa, isEmpty,
      reason: 'voci chiuse che portano ancora la riga ASPETTA: '
          '$chiuseConAttesa');
}
