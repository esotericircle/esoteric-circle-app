import 'dart:io';

import 'package:esoteric_circle/core/sensi/catalogo_suoni.dart';
import 'package:flutter_test/flutter_test.dart';

import 'codice_senza_testo.dart';

/// **SULLA FESTA SUONA UNA VOCE SOLA.**
/// Ordine CO voce 03, 3 settembre 2026.
///
/// Il fondatore ha sentito due suoni sovrapporsi quando un rito compiuto
/// accendeva anche un Sigillo, e ha chiamato "vecchio" quello di sotto.
/// **Non era un file vecchio, e questa e' la parte che vale la pena
/// ricordare**: era la voce del responso, novecento millesimi di fondamentale
/// e quinta che il telefono sintetizza sul momento, ordine BX voce 05. Non
/// c'era nessun file da cancellare, perche' non c'era nessun file.
///
/// Le due voci non erano in conflitto per un difetto: erano in conflitto per
/// **ordine di esecuzione**. `dopoUnGesto` lanciava la voce del responso senza
/// aspettarla, con una ragione scritta e buona - non ritardare cio' che viene
/// dopo - e cio' che veniva dopo era proprio la festa, che si apre col suo
/// suono di tre secondi e sei decimi.
///
/// **Percio' questa guardia sorveglia l'ordine, non la presenza.** Cercare che
/// la voce del responso non ci sia sarebbe sbagliato: fuori da questo caso e'
/// giusta, e senza di lei ogni responso dell'app tornerebbe muto.
void main() {
  final regia =
      File('lib/features/sigilli/regia_del_cammino.dart').readAsStringSync();
  final codice = codiceSenzaTesto(regia);

  test('la voce del responso arriva DOPO che si e\u0027 guardata la festa', () {
    final guarda = codice.indexOf('guardaCosaSiAccende(context');
    final voce = codice.indexOf('PaletteSensoriale.responso(');
    expect(guarda, greaterThanOrEqualTo(0),
        reason: 'nessuno guarda piu\u0027 cosa si accende');
    expect(voce, greaterThanOrEqualTo(0),
        reason: 'la voce del responso non si emette piu\u0027 da nessuna '
            'parte: non andava cancellata, andava tolta di mezzo alla festa');
    expect(voce, greaterThan(guarda),
        reason: 'LA VOCE DEL RESPONSO PARTE PRIMA CHE SI SAPPIA SE C\u0027E\u0027 '
            'UNA FESTA. E\u0027 esattamente la sequenza che il fondatore ha '
            'sentito sul telefono: novecento millesimi di fondamentale e '
            'quinta sotto un suono di tre secondi e sei decimi. Chi non '
            'festeggia sente la sua voce qualche millesimo dopo, e nessuno '
            'lo nota');
  });

  test('e la si emette solo se una festa NON e\u0027 comparsa', () {
    expect(codice, contains('!festeggiato'),
        reason: 'la voce del responso non guarda piu\u0027 se una festa e\u0027 '
            'comparsa: due voci sopra lo stesso istante non fanno un istante '
            'piu\u0027 ricco, ne fanno uno confuso');
  });

  test('chi guarda cosa si accende sa dire se ha festeggiato', () {
    expect(codice, contains('Future<bool> guardaCosaSiAccende'),
        reason: 'e\u0027 tornata a non dire niente: senza il suo si o no '
            'nessuno puo\u0027 sapere se la voce del responso deve tacere');
    expect(codice, contains('return festeggiato;'));
  });

  test('la festa ha ancora il suo suono, e le monete il loro', () {
    final festa =
        File('lib/features/sigilli/celebrazione.dart').readAsStringSync();
    final senzaTesto = codiceSenzaTesto(festa);
    expect(senzaTesto, contains('SuonoDelCerchio.festa'),
        reason: 'togliendo la voce del responso si e\u0027 tolta anche la '
            'festa: il rimedio ha ucciso il paziente');
    // **E LE MONETE SUONANO DAL VOLO, non da qui. Ordine CO voce 19**, 3
    // settembre 2026. Questa riga cercava il suono dentro la celebrazione, ed
    // era il posto giusto finche' ci stava: adesso il suono e il volo sono la
    // stessa riga, perche' un tintinnio poteva uscire senza che volasse
    // nessuna moneta.
    expect(senzaTesto, isNot(contains('SuonoDelCerchio.eos')),
        reason: 'il suono delle monete e tornato nella celebrazione: da li '
            'esce anche quando non c e niente da accreditare, cioe un '
            'tintinnio senza niente da accompagnare');
    expect(
        codiceSenzaTesto(
            File('lib/design_system/components/volo_degli_eos.dart')
                .readAsStringSync()),
        contains('SuonoDelCerchio.eos'),
        reason: 'il volo delle monete non porta piu il suo suono: i due si '
            'possono separare di nuovo');
    // La festa dura intera, ed e' una decisione del fondatore gia' scritta.
    expect(SuonoDelCerchio.festa.durataAttesa.inMilliseconds, 3600);
  });
}
