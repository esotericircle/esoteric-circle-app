import 'package:esoteric_circle/core/voce/il_dettato_che_continua.dart';
import 'package:esoteric_circle/services/voce/dettatura_vera.dart';
import 'package:flutter/widgets.dart' show Locale;
import 'package:flutter_test/flutter_test.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// **IL DETTATO NON SI FERMA ALLA PRIMA PAROLA.** Ordine EQ, difetto trovato
/// sul Realme il 27 settembre 2026.
///
/// Il fatto: una frase detta per 8,7 secondi alla dettatura della chat e'
/// arrivata nel campo come *"vorrei"*, poi la dettatura ha smesso di
/// ascoltare (`docs/collaudo/EQ/realme/eq10_dettatura_con_la_voce/`). Padre:
/// ordine CI voce 05, che chiudeva il dettato alla prima chiusura del
/// riconoscitore e dopo tre secondi dall'ultimo risultato cambiato.
///
/// Le prove passano dalla dettatura VERA, con un riconoscitore finto che si
/// comporta come quello del Realme: chiude l'enunciato alla prima pausa.
void main() {
  test('una frase con una pausa arriva intera nel campo', () async {
    final motore = _RiconoscitoreFinto();
    final dettatura =
        DettaturaVera(motore: motore, lingua: () => const Locale('it'));
    var campo = '';
    var finita = false;
    await dettatura.ascolta(
        parole: (p) => campo = p, finito: () => finita = true);

    motore.dice('vorrei');
    motore.chiude();
    await Future<void>.delayed(Duration.zero);
    expect(finita, isFalse,
        reason: 'il riconoscitore ha chiuso dopo "vorrei" e il dettato e\' '
            'finito: e\' il difetto del Realme');
    expect(motore.ascolti, 2,
        reason: 'dopo un enunciato con parole se ne apre un altro');

    motore.dice('andare in Australia a marzo');
    expect(campo, 'vorrei andare in Australia a marzo',
        reason: 'le parole del secondo enunciato hanno cancellato le prime');

    motore.chiude();
    await Future<void>.delayed(Duration.zero);
    motore.chiude();
    await Future<void>.delayed(Duration.zero);
    expect(finita, isTrue,
        reason: 'un enunciato senza parole vuol dire che la persona ha '
            'smesso di parlare: il dettato deve finire');
    expect(campo, 'vorrei andare in Australia a marzo');
  });

  test('il riconoscitore non ha piu\' il tempo dei tre secondi', () async {
    final motore = _RiconoscitoreFinto();
    final dettatura =
        DettaturaVera(motore: motore, lingua: () => const Locale('it'));
    await dettatura.ascolta(parole: (_) {}, finito: () {});
    final opzioni = motore.opzioni.single;
    expect(opzioni.pauseFor, isNull,
        reason: 'il pauseFor del plugin conta dall\'ultimo risultato '
            'cambiato, non dal silenzio, e tagliava le frasi lunghe');
    expect(opzioni.cancelOnError, isFalse,
        reason: 'un errore del riconoscitore chiude un enunciato, non il '
            'dettato');
  });

  test('lo stop della persona chiude e non riapre', () async {
    final motore = _RiconoscitoreFinto();
    final dettatura =
        DettaturaVera(motore: motore, lingua: () => const Locale('it'));
    var finita = false;
    await dettatura.ascolta(parole: (_) {}, finito: () => finita = true);
    motore.dice('vorrei una');
    await dettatura.ferma();
    motore.chiude();
    await Future<void>.delayed(Duration.zero);
    expect(finita, isTrue);
    expect(motore.ascolti, 1,
        reason: 'la persona ha toccato lo stop e la dettatura ha riaperto');
  });

  test('il dettato ha un tetto di un minuto', () {
    var ora = DateTime(2026, 9, 27, 12);
    var riaperti = 0;
    var finito = false;
    final dettato = IlDettatoCheContinua(
      parole: (_) {},
      finito: () => finito = true,
      riapri: () => riaperti++,
      adesso: () => ora,
    );
    dettato.risultato('una frase');
    dettato.enunciatoChiuso();
    expect(riaperti, 1);
    ora = ora.add(IlDettatoCheContinua.tettoDelDettato);
    dettato.risultato('ancora');
    dettato.enunciatoChiuso();
    expect(finito, isTrue);
    expect(riaperti, 1);
  });
}

/// Un riconoscitore che chiude l'enunciato quando glielo si dice, come
/// quello del Realme alla prima pausa.
class _RiconoscitoreFinto implements SpeechToText {
  int ascolti = 0;
  final opzioni = <SpeechListenOptions>[];
  SpeechResultListener? _risultati;
  SpeechStatusListener? _stato;

  void dice(String parole) => _risultati?.call(SpeechRecognitionResult(
      [SpeechRecognitionWords(parole, null, 1)], ResultType.partial.value));

  void chiude() {
    _stato?.call(SpeechToText.notListeningStatus);
    _stato?.call(SpeechToText.doneStatus);
  }

  @override
  set statusListener(SpeechStatusListener? ascoltatore) => _stato = ascoltatore;

  @override
  dynamic noSuchMethod(Invocation chiamata) {
    switch (chiamata.memberName) {
      case #initialize:
        return Future<bool>.value(true);
      case #locales:
        return Future<List<LocaleName>>.value([LocaleName('it_IT', 'it')]);
      case #listen:
        ascolti++;
        _stato?.call(SpeechToText.listeningStatus);
        _risultati =
            chiamata.namedArguments[#onResult] as SpeechResultListener?;
        opzioni.add(
            chiamata.namedArguments[#listenOptions] as SpeechListenOptions);
        return Future<void>.value();
      case #stop:
        return Future<void>.value();
    }
    return null;
  }
}
