import 'package:esoteric_circle/core/sigilli/diario_del_cammino.dart';
import 'package:esoteric_circle/core/viaggio/i_quattro_viaggi.dart';
import 'package:esoteric_circle/features/sigilli/regia_del_cammino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'istante_dichiarato.dart';

/// **IL CERCHIO NON REGALA L'ANIMALE ALLA PRIMA DISCESA.**
/// Ordine DC voci 01, 02 e 04, 10 settembre 2026.
///
/// **DIFETTO VISTO SUL TELEFONO 767f596c IL 10 SETTEMBRE 2026, alla prima
/// discesa del Viaggio dello Sciamano.** Seguita la prima ombra, il Cerchio ha
/// aperto una celebrazione a schermo pieno: *"CONGRATULAZIONI, Il tuo Animale
/// Guida. Hai dato al Cerchio l'Animale Guida: da adesso ogni responso parte
/// da qui. +10 Eos"*.
///
/// **Cioe' esattamente la cosa che l'ordine DC vieta.** La voce 04 dice che
/// l'animale si riconosce quando si e' mostrato quattro volte, e viene da
/// Harner; la voce 02 dice che l'onboarding non puo' bruciare quel nome. La
/// celebrazione lo bruciava peggio dell'onboarding: **lo dichiarava dato al
/// primo colpo**, e con esso il traguardo cal_1, i dieci Eos e la tessera del
/// Passaporto.
///
/// **LA CAUSA, e nessuno l'aveva fatta apposta.** Il pezzo dell'identita'
/// `animale_guida` maturava con `diario.haFatto('animale_guida')`, cioe' col
/// gesto compiuto **almeno una volta**. Era giusto finche' l'Animale Guida era
/// un risultato: si apriva la schermata, usciva un animale, il pezzo c'era.
/// **L'ordine DC ha cambiato la natura dell'arte da risultato a rapporto e il
/// cammino e' rimasto indietro.** E' la famiglia di difetto piu' silenziosa
/// che ci sia: nessuno ha scritto una riga sbagliata, e' il significato di una
/// riga giusta che e' cambiato sotto.
///
/// Il gesto continua a partire a ogni discesa, perche' i conti delle arti, i
/// Ricordi e le finestre del cielo lo aspettano. E' **il pezzo** a maturare
/// solo alla quarta.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<DiarioDelCammino> conDiscese(int quante) async {
    // **L'ISTANTE SI DICHIARA.** Ordine U voce 00: un Diario senza orologio
    // pesca il giorno vero, e una prova che cambia colore col giorno non e'
    // una prova.
    final d = DiarioDelCammino(orologio: orologioDelleProve);
    await d.carica();
    for (var i = 0; i < quante; i++) {
      // **I DETTAGLI DEVONO DIFFERIRE.** Il diario conta lo stesso gesto con
      // gli stessi dettagli una volta al giorno, ed e' la ragione per cui la
      // schermata del Viaggio manda il numero della discesa.
      await d.segna('animale_guida', dettagli: {'discesa': i + 1});
    }
    return d;
  }

  test('IL PEZZO NON MATURA PRIMA DELLA QUARTA DISCESA', () async {
    for (var quante = 0; quante < IQuattroViaggi.quanteDiscese; quante++) {
      final diario = await conDiscese(quante);
      final pezzi = RegiaDelCammino.pezziDellIdentitaMaturi(diario, false);
      // ignore: avoid_print
      print('ORDINE DC VOCE 04: con $quante discese il pezzo animale_guida '
          'e ${pezzi.contains('animale_guida') ? 'maturo' : 'ancora acerbo'}');
      expect(pezzi.contains('animale_guida'), isFalse,
          reason: 'con $quante discese su ${IQuattroViaggi.quanteDiscese} il '
              'Cerchio dichiara di avere gia l Animale Guida: il traguardo '
              'cal_1 si accende, la celebrazione dice il nome, e i quattro '
              'viaggi di Harner non servono piu a niente');
    }
  });

  test('E MATURA ALLA QUARTA', () async {
    final diario = await conDiscese(IQuattroViaggi.quanteDiscese);
    final pezzi = RegiaDelCammino.pezziDellIdentitaMaturi(diario, false);
    // ignore: avoid_print
    print('ORDINE DC VOCE 04: con ${IQuattroViaggi.quanteDiscese} discese il '
        'pezzo animale_guida e '
        '${pezzi.contains('animale_guida') ? 'maturo' : 'ancora acerbo'}');
    // **REGOLA H: una guardia che prova un'assenza prova anche la presenza.**
    // Senza questa meta', bloccare per sempre il pezzo la lascerebbe verde.
    expect(pezzi.contains('animale_guida'), isTrue,
        reason: 'alla quarta discesa il pezzo non matura: il riconoscimento '
            'non arriva mai, e il Viaggio e una porta che non si apre');
  });

  test('IL PASSAPORTO PIENO ASPETTA L ANIMALE', () async {
    // La tessera dell'animale e' una delle sette del documento: finche' e'
    // acerba, il Passaporto pieno non e' pieno.
    final diario = await conDiscese(1);
    for (final g in [
      'carta_natale',
      'numero_della_vita',
      'ora_di_nascita',
      'luogo_di_nascita',
      'angelo_custode',
      'archetipo',
      'passaporto',
    ]) {
      await diario.segna(g);
    }
    final pezzi = RegiaDelCammino.pezziDellIdentitaMaturi(diario, true);
    // ignore: avoid_print
    print('ORDINE DC VOCE 02: con una sola discesa il Passaporto pieno e '
        '${pezzi.contains('passaporto') ? 'maturo' : 'ancora acerbo'}');
    expect(pezzi.contains('passaporto'), isFalse,
        reason: 'il Passaporto si dichiara pieno con la casella dell Animale '
            'ancora vuota');
  });
}
