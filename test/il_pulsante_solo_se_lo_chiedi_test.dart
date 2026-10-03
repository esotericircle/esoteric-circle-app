// ignore_for_file: avoid_print
import 'package:esoteric_circle/core/chat/immersive_intents.dart';
import 'package:esoteric_circle/core/chat/intent_classifier.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **IL PULSANTE SOLO SE L'UTENTE LO CHIEDE.** Ordine EB voce 03, 21
/// settembre 2026.
///
/// **La decisione del fondatore, verbatim**, alla domanda su quando possa
/// comparire un pulsante verso una funzione: *"Solo se l'utente lo chiede"*.
///
/// **Il difetto che questa prova prende, misurato sulle frasi vere delle due
/// catture del 21 settembre 2026.** Il classificatore cercava la parola
/// dell'arte dentro il testo e bastava quella: *"non voglio una stesa"*
/// apriva la Stesa esattamente come *"fammi una stesa"*. **La negazione
/// pesava zero**, e la domanda preimpostata, che conteneva essa stessa la
/// parola *stesa*, si autodistruggeva.
///
/// **Cosa misura.** Che la parola dell'arte da sola non basti: servono un
/// segno di richiesta, nessuna negazione e nessun riferimento a un responso
/// gia' ottenuto. E che le frasi che chiedono davvero passino ancora, o la
/// cura avrebbe solo spento una funzione.
void main() {
  const c = IntentClassifier();

  /// **Le frasi che NON devono aprire niente**, e il perche' di ognuna.
  const nonAprono = <String, String>{
    // Le due vere, dalle catture del fondatore.
    'Nella mia stesa sono uscite Il Papa, Re di Spade e Dieci di Spade. '
            'Come si legge questa sequenza sulla mia situazione?':
        'la domanda preimpostata che porta le carte da interpretare',
    'Ma io non voglio fare un\'altra stesa di tarocchi. Voglio solo la tua '
        'interpretazione': 'il rifiuto esplicito del fondatore',
    // Altre forme dello stesso rifiuto e della stessa menzione.
    'non voglio una stesa': 'un rifiuto secco',
    'niente tarocchi, interpretami quelle che ho gia\'': 'un rifiuto con un '
        'riferimento a cio\' che si ha gia\'',
    'interpreta le carte che sono uscite': 'una richiesta di interpretazione',
    'mi e\' uscita la Torre, cosa vuol dire?': 'una carta gia\' avuta',
    'nell\'estrazione di ieri mi erano uscite due rune': 'un responso passato',
    'senza tirare le rune, cosa ne pensi?': 'una richiesta esplicita di NON '
        'usare l\'arte',
    'invece di una stesa preferisco parlarne con te': 'una preferenza '
        'contraria',
    'ho gia\' fatto lo scan dei chakra, cosa dice?': 'uno scan gia\' fatto',
    'il sigillo che ho tracciato ieri mi sembra debole': 'un sigillo gia\' '
        'tracciato',
  };

  /// **Le frasi che DEVONO aprire**, o la cura avrebbe spento una funzione.
  const aprono = <String, ImmersiveTarget>{
    'fammi una stesa di tarocchi': ImmersiveTarget.tarocchiStesa,
    'voglio una stesa': ImmersiveTarget.tarocchiStesa,
    'stendi le carte per me': ImmersiveTarget.tarocchiStesa,
    'apri la mia carta natale': ImmersiveTarget.cartaNatale,
    'vorrei fare lo scan dei chakra': ImmersiveTarget.scanChakra,
    'facciamo una meditazione': ImmersiveTarget.meditazione,
  };

  test('la sola parola dell\'arte non apre piu\' niente', () {
    cardinaleMinimo(nonAprono.length, 11,
        cosa: 'frasi che nominano un\'arte senza chiederla',
        perche: 'Se l\'elenco si svuotasse, questa prova direbbe di si\' a '
            'niente.');
    final passate = <String>[];
    for (final e in nonAprono.entries) {
      final maestro = e.key.contains('rune') ||
              e.key.contains('sigillo') ||
              e.key.contains('tirare')
          ? Maestro.caligo
          : e.key.contains('chakra')
              ? Maestro.aura
              : Maestro.medora;
      final i = c.classify(maestro, e.key);
      print('ORDINE EB VOCE 03 | "${e.key}" -> '
          '${i == null ? "niente" : i.target.name}');
      if (i != null) passate.add('${e.value}: "${e.key}"');
    }
    expect(passate, isEmpty,
        reason: 'queste frasi aprono un pulsante che nessuno ha chiesto, e '
            'al loro posto il Maestro non risponde:\n${passate.join("\n")}');
  });

  test('e chi l\'arte la chiede davvero la apre ancora', () {
    cardinaleMinimo(aprono.length, 6,
        cosa: 'frasi che chiedono un\'arte per davvero',
        perche: 'Senza queste, spegnere del tutto l\'instradamento farebbe '
            'passare la prova di sopra.');
    final perse = <String>[];
    for (final e in aprono.entries) {
      final maestro = e.value == ImmersiveTarget.scanChakra ||
              e.value == ImmersiveTarget.meditazione
          ? Maestro.aura
          : Maestro.medora;
      final i = c.classify(maestro, e.key);
      print('ORDINE EB VOCE 03, chiede | "${e.key}" -> '
          '${i == null ? "niente" : i.target.name}');
      if (i?.target != e.value) perse.add('"${e.key}" -> ${i?.target.name}');
    }
    expect(perse, isEmpty,
        reason: 'queste frasi chiedono l\'arte e non la aprono piu\': la cura '
            'ha spento una funzione invece di stringerla:\n'
            '${perse.join("\n")}');
  });
}
